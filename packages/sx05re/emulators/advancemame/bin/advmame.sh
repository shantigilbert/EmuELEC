#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

CONFIG_DIR="/emuelec/configs/advmame"
export DISPLAY=:0

if [ -L "${CONFIG_DIR}" ]; then
 rm "${CONFIG_DIR}"
fi

if [ ! -d "${CONFIG_DIR}" ]; then
 mkdir -p "${CONFIG_DIR}"
 cp -rf /usr/config/emuelec/configs/advmame/* "${CONFIG_DIR}/"
fi

if [ ! -L "/storage/.advance" ]; then
    cp -rf /storage/.advance/* ${CONFIG_DIR}/
    rm -rf /storage/.advance
    ln -sf ${CONFIG_DIR} /storage/.advance
fi

if [[ "$1" = *"roms/arcade"* ]]; then
sed -i "s|/roms/mame|/roms/arcade|g" $CONFIG_DIR/advmame.rc
 else
sed -i "s|/roms/arcade|/roms/mame|g" $CONFIG_DIR/advmame.rc
fi

if [ "$EE_DEVICE" != "OdroidGoAdvance" ] && [ "$EE_DEVICE" != "GameForce" ]; then
    unset DISPLAY
    MODE=`cat /sys/class/display/mode`;
    sed -i '/device_video_modeline/d' $CONFIG_DIR/advmame.rc

    if [[ -f "/ee_s905" && "$MODE" == "1080p"* ]]; then
        MODE="720p60hz"
    fi

    case "$MODE" in
        "480p"*)
            echo "device_video_modeline 720x480 15.246 720 762 834 968 480 484 491 525 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
        ;;
        "720p"*)
            echo "device_video_modeline 1280x720-60 91.517 1280 1440 1531 1691 720 810 812 902 +hsync +vsync" >> $CONFIG_DIR/advmame.rc
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
fi

ROMNAME=$(basename $1)
AUTOGP=$(get_ee_setting advmame_auto_gamepad)
[[ "${AUTOGP}" != "0" ]] && set_advmame_joy.sh "$ROMNAME"

ARG=$(echo basename $1 | sed 's/\.[^.]*$//')
ARG="$(echo $1 | sed 's=.*/==;s/\.[^.]*$//')"
SDL_AUDIODRIVER=alsa advmame $ARG -quiet
