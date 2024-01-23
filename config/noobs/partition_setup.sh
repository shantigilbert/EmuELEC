#!/bin/sh -x

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

MOUNTPOINT="/tmp/LibreELEC-System"

md5sumCheck() {
  ( cd $MOUNTPOINT
    echo "checking MD5: $1"
    md5sum -c $1.md5
    if [ "$?" = "1" ]; then
      echo "#######################################################"
      echo "#                                                     #"
      echo "# LibreELEC failed md5 check - Installation will quit #"
      echo "#                                                     #"
      echo "#    Your original download was probably corrupt.     #"
      echo "#   Please visit libreelec.tv and get another copy    #"
      echo "#                                                     #"
      echo "#######################################################"
      exit 1
    fi
    rm -rf $1.md5
  )
}

if [ -z $part1 -o -z $part2 -o -z $id1 -o -z $id2 ]; then
  echo "error: part1, part2, id1 or id2 not specified"
  echo "actual values:"
  echo "part1:" $part1
  echo "part2:" $part2
  echo "id1  :" $id1
  echo "id2  :" $id2
  exit 1
fi

# create mountpoint
  mkdir -p $MOUNTPOINT

# mount needed partition
  mount $part1 $MOUNTPOINT

# check md5sum
  md5sumCheck kernel.img
  md5sumCheck SYSTEM

# create bootloader configuration
  echo "creating bootloader configuration..."
  echo "boot=$id1 disk=$id2 quiet @EXTRA_CMDLINE@" > $MOUNTPOINT/cmdline.txt

# cleanup mountpoint
  umount $MOUNTPOINT
  rmdir $MOUNTPOINT
