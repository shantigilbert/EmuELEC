#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2014 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""

MIN_CONFIG_TXT_VERSION=1

# mount $BOOT_ROOT r/w
mount -o remount,rw $BOOT_ROOT

# Something has gone horribly wrong... clean up
[ -s $BOOT_ROOT/overlays ] || rm -fr $BOOT_ROOT/overlays $BOOT_ROOT/FSCK*.REC

# update bootloader files
cp -p $SYSTEM_ROOT/usr/share/bootloader/LICENCE* $BOOT_ROOT
for f in bootcode.bin fixup.dat start.elf ; do
  if [ -f "${SYSTEM_ROOT}/usr/share/bootloader/$f" ]; then
    cp -p "${SYSTEM_ROOT}/usr/share/bootloader/$f" "${BOOT_ROOT}"
  fi
done

rm -f $BOOT_ROOT/bcm283*.dtb # cleanup excess dtb's used by upstream kernels (ie. not LE)
cp -p $SYSTEM_ROOT/usr/share/bootloader/*.dtb $BOOT_ROOT
cp -pR $SYSTEM_ROOT/usr/share/bootloader/overlays $BOOT_ROOT

# cleanup unneeded files
rm -rf $BOOT_ROOT/loader.bin
rm -rf $BOOT_ROOT/fixup_x.dat
rm -rf $BOOT_ROOT/start_x.elf

# some config.txt magic
if [ ! -f $BOOT_ROOT/config.txt ]; then
  cp -p $SYSTEM_ROOT/usr/share/bootloader/config.txt $BOOT_ROOT
else
  CONFIG_TXT_VERSION=$( \
    grep "^# config.txt version v[0-9]\+" $BOOT_ROOT/config.txt | \
    head -n 1 | \
    sed 's/^# config.txt version v\([0-9]\+\) .*$/\1/' \
  )
  if [ ${CONFIG_TXT_VERSION:-0} -lt $MIN_CONFIG_TXT_VERSION ]; then
    mv -f $BOOT_ROOT/config.txt $BOOT_ROOT/config.txt.old
    cp -p $SYSTEM_ROOT/usr/share/bootloader/config.txt $BOOT_ROOT/config.txt
    echo "WARNING incompatible config.txt detected, replacing with default."
    echo "Previous config.txt has been moved to config.txt.old"
  fi
fi

# Add distro config files
for distro in "$SYSTEM_ROOT/usr/share/bootloader/distroconfig"*.txt ; do
  if [ -f "${distro}" ]; then
    cp -p "${distro}" $BOOT_ROOT
  fi
done

# mount $BOOT_ROOT r/o
sync
mount -o remount,ro $BOOT_ROOT
