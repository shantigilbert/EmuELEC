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
		kmscon --font-size 8 --login /usr/bin/bash
	else
		case ${1} in
		*.sh)
			kmscon --font-size 8 --login /usr/bin/bash "${1}"
		;;
		"mplayer_video")
			/storage/.config/emuelec/scripts/playvideo.sh "${2}" "${3}"
		;;
		*)
			kmscon --font-size 8 --login /usr/bin/bash -- -c "${1}"
		;;
		esac
	fi 
else
	if [[ "${1}" == *"13 - Launch Terminal (kb).sh"* ]]; then
	fbterm -s 32 --verbose < /dev/tty1
	else
		case ${1} in
		*.sh)
			fbterm "${1}" -s 24 < /dev/tty1
		;;
		"mplayer_video")
			fbterm /emuelec/scripts/playvideo.sh "${2}" "${3}" < /dev/tty1
		;;
		*)
			fbterm -c "${1}" -s 24 < /dev/tty1
		;;
		esac
	fi 
fi

joy2keyStop
