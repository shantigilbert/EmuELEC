#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# DO NOT modify this file, if you need to use autostart please use /storage/.config/custom_start.sh 

# Enable these 3 following lines to add a small boost in performance mostly for s912 devices but might work for others, but remember to keep an eye on the temp!
# echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
# echo "performance" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor
# echo 5 > /sys/class/mpgpu/cur_freq

# It seems some slow SDcards have a problem creating the symlink on time :/
CONFIG_DIR="/storage/.emulationstation"
CONFIG_DIR2="/storage/.config/emulationstation"

if [ ! -L "$CONFIG_DIR" ]; then
ln -sf $CONFIG_DIR2 $CONFIG_DIR
fi

BTENABLED=$(get_ee_setting ee_bluetooth.enabled)

if [[ "$BTENABLED" != "1" ]]; then
systemctl stop bluetooth
/storage/.cache/services/bluez.conf
fi

# copy default bezel to /storage/roms/bezel if it doesn't exists
if [ ! -f "/storage/roms/bezels/default.cfg" ]; then 
mkdir -p /storage/roms/bezels/
cp -rf /usr/share/retroarch-overlays/bezels/* /storage/roms/bezels/
fi

# Restore config if backup exists
BACKUPFILE="/storage/downloads/ee_backup_config.zip"

if [ -f ${BACKUPFILE} ]; then 
	unzip -o ${BACKUPFILE} -d /
	rm ${BACKUPFILE}
fi

# Check if we have unsynched update files
/usr/config/emuelec/scripts/force_update.sh

DEFE=""

# If the video-mode is contained in flash config.
if [ -s "${CONFIG_FLASH}" ]; then
  CFG_VAL=$(get_config_value "$CONFIG_FLASH" "hdmimode")
  [ ! -z "$CFG_VAL" ] && DEFE="$CFG_VAL" && set_ee_setting ee_videomode $DEFE
fi

# Otherwise retrieve via normal methods.
if [ -z "$DEFE" ]; then
  if [ -s "/storage/.config/EE_VIDEO_MODE" ]; then
      DEFE=$(cat /storage/.config/EE_VIDEO_MODE) && set_ee_setting ee_videomode $DEFE
  fi
fi

if [ -z "$DEFE" ]; then
  # Set video mode, this has to be done before starting ES
  DEFE=$(get_ee_setting ee_videomode)
  if [ "${DEFE}" == "Custom" ]; then
      DEFE=$(cat /sys/class/display/mode)
  fi
fi

# finally we correct the FB according to video mode
setres.sh ${DEFE}

# Clean cache garbage when boot up.
rm -rf /storage/.cache/cores/*

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
/emuelec/scripts/show_splash.sh intro


# run custom_start before FE scripts
/storage/.config/custom_start.sh before


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
