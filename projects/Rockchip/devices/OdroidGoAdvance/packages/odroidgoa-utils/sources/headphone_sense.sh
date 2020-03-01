#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

if [ -e "/emuelec/configs/emuelec.conf" ]; then
/emuelec/scripts/odroidgoa_utils.sh setaudio $(get_ee_setting "audio.device")
/emuelec/scripts/odroidgoa_utils.sh vol $(get_ee_setting "audio.volume")
/emuelec/scripts/odroidgoa_utils.sh bright $(get_ee_setting "brightness.level")
# set global hotkeys
/emuelec/bin/jslisten --mode hold &
fi

# Headphone sensing 
DEVICE='/dev/input/event1'

HP_ON='*(SW_HEADPHONE_INSERT), value 0*'
HP_OFF='*(SW_HEADPHONE_INSERT), value 1*'

evtest "${DEVICE}" | while read line; do
    case $line in
		(${HP_ON})
		amixer cset name='Playback Path' HP 
	;;
		(${HP_OFF})
		amixer cset name='Playback Path' SPK
	;;
    esac
done
