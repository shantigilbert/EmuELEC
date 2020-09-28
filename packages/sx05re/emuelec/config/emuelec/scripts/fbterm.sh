#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile
source /emuelec/scriptmodules/helpers.sh

if [ -e /proc/device-tree/t82x@d00c0000/compatible ]; then
	/emuelec/scripts/setres.sh 16
fi

EE_DEVICE=$(cat /ee_arch)

if [ "$EE_DEVICE" == "OdroidGoAdvance" ]; then
	#kmscon
	if [[ "${1}" == *"13 - Launch Terminal (kb).sh"* ]]; then
		kmscon --font-size 8 --login /usr/bin/login -- -p -f root 
	else
        echo 1 > /sys/class/vtconsole/vtcon1/bind
        echo 0 > /sys/class/graphics/fb0/blank
        cat /dev/zero 2> /dev/null > /dev/fb0

		case ${1} in
		"mplayer_video")
            /storage/.config/emuelec/scripts/playvideo.sh "${2}" "${3}"
		;;
		"error")
            /usr/bin/bash /emuelec/scripts/emuelec-utils showdialog "${2}" "${3}" > /dev/tty0
		;;
		*)
            /usr/bin/bash "${1}" > /dev/tty0
		;;
		esac

        cat /dev/zero 2> /dev/null > /dev/fb0
        echo 0 > /sys/class/vtconsole/vtcon1/bind
        echo 0 > /sys/class/graphics/fb0/blank
	fi 
else
	if [[ "${1}" == *"13 - Launch Terminal (kb).sh"* ]]; then
		tmpsh=/tmp/tmp.$$.sh
		echo "/usr/bin/login -p -f root" > ${tmpsh}
		chmod +x ${tmpsh}
		fbterm "${tmpsh}" -s 24 < /dev/tty1
		rm ${tmpsh}
	else
		case ${1} in
		"mplayer_video")
			fbterm /emuelec/scripts/playvideo.sh "${2}" "${3}" < /dev/tty1
		;;
		"error")
			fbterm /emuelec/scripts/emuelec-utils showdialog "${2}" "${3}" -s 24 < /dev/tty1
		;;
		*)
			fbterm "${1}" -s 24 < /dev/tty1
		;;
		esac
	fi 
fi

joy2keyStop
killall joy2key.py || true
