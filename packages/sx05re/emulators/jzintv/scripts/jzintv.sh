#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

CUR_MODE=`cat /sys/class/display/mode`;

case ${CUR_MODE} in
    480*)
        RES="640,480,32"
    ;;
    720*)
        RES="1280,720,32"
    ;;
    1080*)    
        RES="1920,1080,32"
    ;;
esac

jzintv -f1 -z${RES} -p /storage/roms/bios/ "${1}" --kbdhackfile /emuelec/configs/jzintv_keyb.hack
exit 0
