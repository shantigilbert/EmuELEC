#!/bin/sh

# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
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
      esac

      if [ -f "/proc/device-tree/coreelec-dt-id" ]; then
        DT_ID=$(cat /proc/device-tree/coreelec-dt-id)
      elif [ -f "/proc/device-tree/le-dt-id" ]; then
        DT_ID=$(cat /proc/device-tree/le-dt-id)
      fi

      if [ -n "$DT_ID" ]; then
        case $DT_ID in
          *lepotato)
            SUBDEVICE="LePotato"
            ;;
          *odroid*c2)
            SUBDEVICE="Odroid_C2"
            DT_ID="gxbb_p200_2g_odroid_c2"
            ;;
        esac
      fi

      if [ -n "$DT_ID" -a -f "$SYSTEM_ROOT/usr/share/bootloader/device_trees/$DT_ID.dtb" ]; then
        UPDATE_DTB_SOURCE="$SYSTEM_ROOT/usr/share/bootloader/device_trees/$DT_ID.dtb"
      fi

      if [ -f "$UPDATE_DTB_SOURCE" ]; then
        echo "Updating device tree from $UPDATE_DTB_SOURCE..."
        case $boot in
          /dev/system)
            dd if=/dev/zero of=/dev/dtb bs=256k count=1 status=none
            dd if="$UPDATE_DTB_SOURCE" of=/dev/dtb bs=256k status=none
            ;;
          /dev/mmc*|LABEL=*|UUID=*)
            cp -f "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
            ;;
        esac
      fi

      for all_dtb in /flash/*.dtb ; do
        if [ -f $all_dtb ]; then
          dtb=$(basename $all_dtb)
          if [ -f $SYSTEM_ROOT/usr/share/bootloader/$dtb ]; then
            echo "Updating $dtb..."
            cp -p $SYSTEM_ROOT/usr/share/bootloader/$dtb $BOOT_ROOT
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
      esac
      ;;
  esac
done

if [ -d $BOOT_ROOT/device_trees ]; then
  echo "Updating device_trees folder..."
  rm $BOOT_ROOT/device_trees/*.dtb
  cp -p $SYSTEM_ROOT/usr/share/bootloader/device_trees/*.dtb $BOOT_ROOT/device_trees/
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_boot.ini ]; then
  echo "Updating boot.ini..."
  cp -p $SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_boot.ini $BOOT_ROOT/boot.ini
  sed -e "s/@BOOT_UUID@/$BOOT_UUID/" \
      -e "s/@DISK_UUID@/$DISK_UUID/" \
      -i $BOOT_ROOT/boot.ini

  if [ -f $SYSTEM_ROOT/usr/share/bootloader/config.ini ]; then
    if [ ! -f $BOOT_ROOT/config.ini ]; then
      echo "Creating config.ini..."
      cp -p $SYSTEM_ROOT/usr/share/bootloader/config.ini $BOOT_ROOT/config.ini
    fi
  fi
fi

if [ "${SUBDEVICE}" == "Odroid_C2" ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot-logo.bmp.gz ]; then
    echo "Updating boot logo..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/boot-logo.bmp.gz $BOOT_ROOT
  fi
fi

if [ "${SUBDEVICE}" == "LePotato" ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot-logo-1080.bmp.gz ]; then
    echo "Updating boot logos..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/boot-logo-1080.bmp.gz $BOOT_ROOT
  fi
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/timeout-logo-1080.bmp.gz ]; then
    cp -p $SYSTEM_ROOT/usr/share/bootloader/timeout-logo-1080.bmp.gz $BOOT_ROOT
  fi
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_u-boot -a ! -e /dev/system -a ! -e /dev/boot ]; then
  echo "Updating u-boot on: $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_u-boot of=$BOOT_DISK conv=fsync bs=1 count=112 status=none
  dd if=$SYSTEM_ROOT/usr/share/bootloader/${SUBDEVICE}_u-boot of=$BOOT_DISK conv=fsync bs=512 skip=1 seek=1 status=none
fi

if [ -f $BOOT_ROOT/aml_autoscript ]; then
  if [ -f $SYSTEM_ROOT/usr/share/bootloader/aml_autoscript ]; then
    echo "Updating aml_autoscript..."
    cp -p $SYSTEM_ROOT/usr/share/bootloader/aml_autoscript $BOOT_ROOT
  fi
fi

if [ ! -f $BOOT_ROOT/@KERNEL_NAME@ -a -f $BOOT_ROOT/@LEGACY_KERNEL_NAME@ ]; then
  echo "Updating Legacy Kernel name..."
  cp -p $BOOT_ROOT/@LEGACY_KERNEL_NAME@ $BOOT_ROOT/@KERNEL_NAME@
  cp -p $BOOT_ROOT/@LEGACY_KERNEL_NAME@.md5 $BOOT_ROOT/@KERNEL_NAME@.md5
fi

if [ ! -f $BOOT_ROOT/dtb.img -a -f $BOOT_ROOT/@LEGACY_DTB_NAME@ ]; then
  echo "Updating Legacy dtb name..."
  cp -p $BOOT_ROOT/@LEGACY_DTB_NAME@ $BOOT_ROOT/dtb.img
fi

mount -o ro,remount $BOOT_ROOT

# Leave a hint that we just did an update
echo "UPDATE" >/storage/.config/boot.hint
