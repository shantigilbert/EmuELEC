#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# DO NOT modify this file, if you need to use autostart please use /storage/.config/custom_start.sh 

# Enable these 3 following lines to add a small boost in performance but remember to keep an eye on the temp!
# echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# echo "performance" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
# echo 5 > /sys/class/mpgpu/cur_freq

# It seems some slow SDcards have a problem creating the symlink on time :/
CONFIG_DIR="/storage/.emulationstation"
CONFIG_DIR2="/storage/.config/emulationstation"

if [ ! -L "$CONFIG_DIR" ]; then
ln -sf $CONFIG_DIR2 $CONFIG_DIR
fi

if [[ "$EE_DEVICE" == "GameForce" ]]; then
LED=$(get_ee_setting bl_rgb)
[ -z "${LED}" ] && LED="Off"
odroidgoa_utils.sh bl "${LED}"

LED=$(get_ee_setting gf_statusled)
[ -z "${LED}" ] && LED="heartbeat"
odroidgoa_utils.sh pl "${LED}"


rk_wifi_init /dev/ttyS1
fi

if [[ "$EE_DEVICE" == "GameForce" ]] || [[ "$EE_DEVICE" == "OdroidGoAdvance" ]]; then
    if [ -e "/flash/no_oc.oga" ]; then 
        set_ee_setting ee_oga_oc disable
        OGAOC=""
    else
        OGAOC=$(get_ee_setting ee_oga_oc)
    fi
[ -z "${OGAOC}" ] && OGAOC="Off"
    odroidgoa_utils.sh oga_oc "${OGAOC}"
fi

BTENABLED=$(get_ee_setting ee_bluetooth.enabled)

if [[ "$BTENABLED" != "1" ]]; then
systemctl stop bluetooth
rm /storage/.cache/services/bluez.conf & 
fi

# copy default bezel to /storage/roms/bezel if it doesn't exists
if [ ! -f "/storage/roms/bezels/default.cfg" ]; then 
mkdir -p /storage/roms/bezels/
cp -rf /usr/share/retroarch-overlays/bezels/* /storage/roms/bezels/ &
fi

# Restore config if backup exists
BACKUPFILE="ee_backup_config.tar.gz"
BACKUPFILE="/storage/roms/backup/${BACKUPFILE}"

[[ ! -f "${BACKUPFILE}" ]] && BACKUPFILE="/var/media/EEROMS/backup/${BACKUPFILE}"

if [ -f ${BACKUPFILE} ]; then 
	emuelec-utils ee_backup restore no
	rm ${BACKUPFILE} &
fi

# Set video mode, this has to be done before starting ES
DEFE=$(get_ee_setting ee_videomode)

if [ "${DEFE}" != "Custom" ]; then
    [ ! -z "${DEFE}" ] && echo "${DEFE}" > /sys/class/display/mode
fi 

if [ -s "/storage/.config/EE_VIDEO_MODE" ]; then
        echo $(cat /storage/.config/EE_VIDEO_MODE) > /sys/class/display/mode
elif [ -s "/flash/EE_VIDEO_MODE" ]; then
        echo $(cat /flash/EE_VIDEO_MODE) > /sys/class/display/mode
fi

# finally we correct the FB according to video mode
setres.sh &

# Clean cache garbage when boot up.
rm -rf /storage/.cache/cores/* &

# handle SSH
DEFE=$(get_ee_setting ee_ssh.enabled)

case "$DEFE" in
"0")
	systemctl stop sshd
	rm /storage/.cache/services/sshd.conf
	;;
*)
	mkdir -p /storage/.cache/services/
	touch /storage/.cache/services/sshd.conf
	systemctl start sshd
	;;
esac

# Show splash creen 
show_splash.sh intro


# run custom_start before FE scripts
/storage/.config/custom_start.sh before &


# Just make sure all the subshells are finished before starting front-end
wait

# What to start at boot?
DEFE=$(get_ee_setting ee_boot)

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

# run custom_start ending scripts
/storage/.config/custom_start.sh after
