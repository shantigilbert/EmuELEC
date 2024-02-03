#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# DO NOT modify this file. 

# It seems some slow SDcards have a problem creating the symlink on time :/
CONFIG_FLASH="/flash/config.ini"
VIDEO_FILE="/storage/.config/EE_VIDEO_MODE"
VIDEO_MODE="/sys/class/display/mode"

DEFE="1080p60hz"
if [[ "${EE_DEVICE}" == "Rockchip" ]]; then
	VIDEO_MODE="/sys/class/display/HDMI/mode"
	DEFE="1920x1080p-60"
fi

# FLASH CONFIG hdmimode takes priority 1.
CFG_VAL=$(get_config_value "${CONFIG_FLASH}" "vout")
if [[ ! -z "${CFG_VAL}" ]]; then
  DEFE="${CFG_VAL}"
	set_ee_setting "ee_videomode" "${DEFE}"
fi


# Check for EE_VIDEO_MODE override 2nd.
if [[ -f "${VIDEO_FILE}" ]]; then
  DEFE=$(cat ${VIDEO_FILE})
	set_ee_setting "ee_videomode" "${DEFE}"
fi

# 3rd check ES for it's preferred resolution.
ES_DEFE=$(get_ee_setting ee_videomode)
if [ "${ES_DEFE}" == "Custom" ]; then
  ES_DEFE=$(cat ${VIDEO_MODE})
else
	DEFE=${ES_DEFE}

fi

# Set video mode, this has to be done before starting ES
# finally we correct the FB according to video mode
[[ -f "${VIDEO_MODE}" ]] && setres.sh ${DEFE}


