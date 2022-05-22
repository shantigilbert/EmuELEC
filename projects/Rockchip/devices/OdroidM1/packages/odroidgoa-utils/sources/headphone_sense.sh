#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Switch to headphones if we have them already connected at boot
GPIO=$(cat /sys/class/gpio/gpio86/value)
[[ "$GPIO" == "1" ]] && set_ee_setting "audio.device" "headphone" || set_ee_setting "audio.device" "speakers"

if [ -e "/emuelec/configs/emuelec.conf" ]; then
/usr/bin/odroidgoa_utils.sh setaudio $(get_ee_setting "audio.device")
/usr/bin/odroidgoa_utils.sh vol $(get_ee_setting "audio.volume")
/usr/bin/odroidgoa_utils.sh bright $(get_ee_setting "brightness.level")
fi

# Headphone sensing 
DEVICE='/dev/input/event1'

HP_ON='*(SW_HEADPHONE_INSERT), value 0*'
HP_OFF='*(SW_HEADPHONE_INSERT), value 1*'

evtest "${DEVICE}" | while read line; do
    case $line in
	(${HP_ON})
	amixer cset name='Playback Path' HP
	set_ee_setting "audio.device" "headphone"
	;;
	(${HP_OFF})
	amixer cset name='Playback Path' SPK
	set_ee_setting "audio.device" "speakers"
	;;
    esac
done
