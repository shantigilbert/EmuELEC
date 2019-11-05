#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# DO NOT modify this file, if you need to use autostart please use /storage/.config/custom_start.sh 

# It seems some slow SDcards have a problem creating the symlink on time :/
CONFIG_DIR="/storage/.emulationstation"
CONFIG_DIR2="/storage/.config/emulationstation"

if [ ! -L "$CONFIG_DIR" ]; then
ln -sf $CONFIG_DIR2 $CONFIG_DIR
fi

# Check if we have unsynched update files
/usr/config/emuelec/scripts/force_update.sh

# Set video mode, this has to be done before starting ES
DEFE=$(get_ee_setting videomode)

if [ "${DEFE}" != "Custom" ]; then
    [ ! -z "${DEFE}" ] && echo "${DEFE}" > /sys/class/display/mode
fi 

if [ -f "/storage/.config/EE_VIDEO_MODE" ]; then
        echo $(cat /storage/.config/EE_VIDEO_MODE) > /sys/class/display/mode
elif [ -f "/flash/EE_VIDEO_MODE" ]; then
        echo $(cat /flash/EE_VIDEO_MODE) > /sys/class/display/mode
fi 

# finally we correct the FB according to video mode
/emuelec/scripts/setres.sh

# Show splash creen 
/emuelec/scripts/show_splash.sh intro

# Clean cache garbage when boot up.
rm -rf /storage/.cache/cores/*

# handle SSH
DEFE=$(get_ee_setting ssh)

case "$DEFE" in
"true")
	mkdir -p /storage/.cache/services/
	touch /storage/.cache/services/sshd.conf
	systemctl start sshd
	;;
"false")
	systemctl stop sshd
	rm /storage/.cache/services/sshd.conf
	;;
esac

# What to start at boot?
DEFE=$(get_ee_setting boot)

case "$DEFE" in
"Retroarch")
	rm -rf /var/lock/start.retro
	touch /var/lock/start.retro
	systemctl start retroarch
	;;
*)
	rm /var/lock/start.games
	touch /var/lock/start.games
    systemctl start emustation
	;;
esac

source /storage/.config/custom_start.sh
