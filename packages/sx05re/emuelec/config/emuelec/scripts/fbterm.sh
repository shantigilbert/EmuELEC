#!/usr/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

source /emuelec/scriptmodules/helpers.sh

if [ -e /proc/device-tree/t82x@d00c0000/compatible ]; then
	/emuelec/scripts/setres.sh 16
fi

EE_DEVICE=$(cat /ee_arch)

if [ "$EE_DEVICE" == "OdroidGoAdvance" ]; then
	#kmscon
	if [[ "$1" == *"13 - Launch Terminal (kb).sh"* ]]; then
	kmscon --font-size 8 --login /usr/bin/bash
	else
	kmscon --font-size 8 --login /usr/bin/bash "$1"
	fi 

else

	if [[ "$1" == *"13 - Launch Terminal (kb).sh"* ]]; then
	fbterm -s 32 --verbose < /dev/tty1
	else
	fbterm "$1" -s 24 < /dev/tty1
	fi 
fi

joy2keyStop
