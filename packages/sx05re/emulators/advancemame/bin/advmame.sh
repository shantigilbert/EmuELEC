#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

CONFIG_DIR="/storage/.advance"

if [ ! -d "$CONFIG_DIR" ]; then
 mkdir -p $CONFIG_DIR
 cp -rf /usr/share/advance/* $CONFIG_DIR/
fi

if [[ "$1" = *"roms/arcade"* ]]; then 
sed -i "s|/roms/mame|/roms/arcade|g" $CONFIG_DIR/advmame.rc
 else
sed -i "s|/roms/arcade|/roms/mame|g" $CONFIG_DIR/advmame.rc
fi 

if [ "$EE_DEVICE" != "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then

MODE=`cat /sys/class/display/mode`;
sed -i '/device_video_modeline/d' $CONFIG_DIR/advmame.rc

case "$MODE" in
"720p"*)
if [ -f /ee_s905 ]; then
	echo "device_video_modeline 1280x720-60 91.517 1280 1440 1531 1691 720 810 812 902 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
fi
	;;
"1080p"*)
	echo "device_video_modeline 1920x1080_60.00 153.234 1920 1968 2121 2168 1080 1127 1130 1178 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
	;;
"1280x1024p60hz"*)
	echo "device_video_modeline 1280x1024_60.00 108.88 1280 1360 1496 1712 1024 1025 1028 1060 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
	;;
"1024x768p60hz"*)
	echo "device_video_modeline 1024x768_60.00 64.11 1024 1080 1184 1344 768 769 772 795 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
	;;
"640x480p60hz"*)
	echo "device_video_modeline 640x480_60.00 23.86 640 656 720 800 480 481 484 497 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
	;;
esac

AUTOGP=$(get_ee_setting advmame_auto_gamepad)
[[ "${AUTOGP}" != "0" ]] && /usr/bin/set_advmame_joy.sh

fi

ARG=$(echo basename $1 | sed 's/\.[^.]*$//')
ARG="$(echo $1 | sed 's=.*/==;s/\.[^.]*$//')"         

SDL_AUDIODRIVER=alsa /usr/bin/advmame $ARG -quiet
