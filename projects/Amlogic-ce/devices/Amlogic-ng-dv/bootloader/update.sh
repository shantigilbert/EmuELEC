#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

# use chroot because of running xmlstarlet and other binaries build with newer glibc
if [ "${SYSTEM_ROOT}" = "/update" ]; then
  # run from init
  # unset SYSTEM_ROOT because we are chroot-ing and /update become new / anyway
  unset SYSTEM_ROOT

  # mount some folders from old root
  mount -o bind /tmp /update/var

  for folder in proc sys dev tmp run flash storage; do
    [ -d /${folder} ] && mount -o bind /${folder} /update/${folder}
  done

  /usr/bin/busybox chroot /update /usr/share/bootloader/update.sh

  # umount folders
  for folder in proc sys dev tmp run flash storage; do
    [ -d /${folder} ] && umount /update/${folder}
  done

  umount /update/var

  # set it back just in case
  SYSTEM_ROOT="/update"
  exit 0
fi

# change to writable folder
cd /tmp

[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/sd[a-z][0-9]*)
      BOOT_DISK=$(echo $BOOT_PART | sed -e "s,[0-9]*,,g")
      ;;
    /dev/mmcblk*)
      BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g")
      ;;
  esac
fi

mount -o rw,remount $BOOT_ROOT

DT_ID=""
SUBDEVICE=""

for arg in $(cat /proc/cmdline); do
  case $arg in
    boot=*)
      boot="${arg#*=}"
      case $boot in
        /dev/mmc*)
          BOOT_UUID="$(blkid $boot | sed 's/.* UUID="//;s/".*//g')"
          ;;
        UUID=*|LABEL=*)
          BOOT_UUID="$(blkid | sed 's/"//g' | grep -m 1 -i " $boot " | sed 's/.* UUID=//;s/ .*//g')"
          ;;
        FOLDER=*)
          BOOT_UUID="$(blkid ${boot#*=} | sed 's/.* UUID="//;s/".*//g')"
          ;;
      esac

      DT_ID=$(dtname)
      MIGRATE_DTB=""
      if [ -n "$DT_ID" ]; then
        SUBDEVICE="Generic"
        # modify DT_ID, SUBDEVICE and MIGRATE_DTB by dtb.conf
        [ -f /usr/bin/convert_dtname ] && . /usr/bin/convert_dtname $DT_ID
      fi

      UPDATE_DTB_SOURCE="/usr/share/bootloader/device_trees/$DT_ID.dtb"
      if [ -n "$DT_ID" -a -f "$UPDATE_DTB_SOURCE" ]; then
        echo "Updating device tree with $DT_ID.dtb..."
        case $BOOT_PART in
          /dev/coreelec)
            dd if=/dev/zero of=/dev/dtb bs=256k count=1 status=none
            dd if="$UPDATE_DTB_SOURCE" of=/dev/dtb bs=256k status=none
            rm -f "$BOOT_ROOT/dtb.img" # this should not exist, remove if it does
            ;;
          *)
            cp -f "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
            ;;
        esac
        [ -n "$MIGRATE_DTB" ] && eval $MIGRATE_DTB
      fi

      for all_dtb in /flash/*.dtb ; do
        if [ -f $all_dtb ]; then
          dtb=$(basename $all_dtb)
          if [ -f /usr/share/bootloader/$dtb ]; then
            echo "Updating $dtb..."
            cp -p /usr/share/bootloader/$dtb $BOOT_ROOT
          fi
        fi
      done
      ;;

    disk=*)
      disk="${arg#*=}"
      case $disk in
        /dev/mmc*)
          DISK_UUID="$(blkid $disk | sed 's/.* UUID="//;s/".*//g')"
          ;;
        UUID=*|LABEL=*)
          DISK_UUID="$(blkid | sed 's/"//g' | grep -m 1 -i " $disk " | sed 's/.* UUID=//;s/ .*//g')"
          ;;
        FOLDER=*)
          DISK_UUID="$(blkid ${disk#*=} | sed 's/.* UUID="//;s/".*//g')"
          ;;
      esac
      ;;
  esac
done

if [ -d $BOOT_ROOT/device_trees ]; then
  echo "Updating device_trees folder..."
  rm $BOOT_ROOT/device_trees/*.dtb
  cp -p /usr/share/bootloader/device_trees/*.dtb $BOOT_ROOT/device_trees/
fi

if [ -f /usr/share/bootloader/config.ini ]; then
  if [ ! -f $BOOT_ROOT/config.ini ]; then
    echo "Creating config.ini..."
    cp -p /usr/share/bootloader/config.ini $BOOT_ROOT/config.ini
  fi
fi

if [ -f $BOOT_ROOT/dtb.xml ]; then
  if [ -f /usr/lib/coreelec/dtb-xml ]; then
    echo "Updating dtb.img by dtb.xml..."
    /usr/lib/coreelec/dtb-xml
  fi
fi

if [ -f $BOOT_ROOT/aml_autoscript ]; then
  if [ -f /usr/share/bootloader/aml_autoscript ]; then
    echo "Updating aml_autoscript..."
    cp -p /usr/share/bootloader/aml_autoscript $BOOT_ROOT
    if [ -e /dev/env ]; then
      mkdir -p /var/lock
      dd if=$BOOT_ROOT/aml_autoscript bs=72 skip=1 status=none | \
      while read line; do
        cmd=$(echo $line | sed -n "s|^setenv \(.*\)|fw_setenv -c /etc/fw_env.config \1|gp")
        [ -n "$cmd" ] && eval $cmd
      done
    fi
  fi
  if [ -f /usr/share/bootloader/${SUBDEVICE}_cfgload ]; then
    echo "Updating cfgload..."
    cp -p /usr/share/bootloader/${SUBDEVICE}_cfgload $BOOT_ROOT/cfgload
  fi
  /usr/lib/coreelec/check-bl301
  if [ ${?} = 1 ]; then
    echo "Found custom CoreELEC BL301, running inject_bl301 tool..."
    inject_bl301 -Y &>/dev/null
  fi
fi

mount -o ro,remount $BOOT_ROOT

# Leave a hint that we just did an update
echo "UPDATE" > /storage/.config/boot.hint
