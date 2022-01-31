#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.advance"
CONFIG=${CONFIG_DIR}/advmame.rc
FOUND=0
PAD_FOUND=0
EE_DEV="js0"
GPFILE=""
GAMEPAD=""

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1 
clean_pad() {
#echo "Cleaning pad $1 $2" #debug
	sed -i "/device_joystick.*/d" ${CONFIG}
	sed -i "/input_map\[p${1}_*/d" ${CONFIG}
	sed -i "/input_map\[coin${1}.*/d" ${CONFIG}
	sed -i "/input_map\[start${1}.*/d" ${CONFIG}

if [[ "${1}" == "1" ]]; then
	sed -i '/input_map\[ui_cancel\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_configure\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_select\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_up\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_down\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_left\].*/d' ${CONFIG}
	sed -i '/input_map\[ui_right\].*/d' ${CONFIG}
fi
	echo "device_joystick raw" >> ${CONFIG}
	}

# Sets pad depending on parameters $GAMEPAD = name $1 = player
set_pad(){
#echo "Setting pad $1 from ${GPFILE}" #debug
	COIN=$(cat "${GPFILE}" | grep -E 'input_select_btn' | cut -d '"' -f2) 
	COIN=$((COIN+1))
	echo "input_map[coin${1}] joystick_button[${GAMEPAD},button${COIN}]" >> ${CONFIG}
	START=$(cat "${GPFILE}" | grep -E 'input_start_btn' | cut -d '"' -f2)
	START=$((START+1))
	echo "input_map[start${1}] joystick_button[${GAMEPAD},button${START}]" >> ${CONFIG}

i=1
button=""

for button in input_a_btn input_b_btn input_x_btn input_y_btn input_r_btn input_l_btn input_r2_btn input_l2_btn input_up_btn input_down_btn input_right_btn input_left_btn; do 
	KEY=$(cat "${GPFILE}" | grep -E "${button}" | cut -d '"' -f2)
if [ ! -z "$KEY" ]; then 
	KEY=$((KEY+1))
case "${button}" in 
	"input_up_btn")
	echo "input_map[p${1}_up] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,y,up]" >> ${CONFIG}
	[[ "${1}" == "1" ]] && echo "input_map[ui_up] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,y,up]" >> ${CONFIG}
		;;
	"input_down_btn")
	echo "input_map[p${1}_down] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,y,down]" >> ${CONFIG}
	[[ "${1}" == "1" ]] && echo "input_map[ui_down] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,y,down]" >> ${CONFIG}
		;;
	"input_left_btn")
	echo "input_map[p${1}_left] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,x,left]" >> ${CONFIG}
	[[ "${1}" == "1" ]] && echo "input_map[ui_left] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,x,left]" >> ${CONFIG}
		;;
	"input_right_btn")
	echo "input_map[p${1}_right] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,x,right]" >> ${CONFIG}
	[[ "${1}" == "1" ]] && echo "input_map[ui_right] joystick_button[${GAMEPAD},button${KEY}] or joystick_digital[${GAMEPAD},stick,x,right]" >> ${CONFIG}
		;;
	*)
	echo "input_map[p${1}_button${i}] joystick_button[${GAMEPAD},button${KEY}]" >> ${CONFIG}
	i=$((i+1))
	;;
esac

fi
done

# Menu should only be set to player 1
if [[ "${1}" == "1" ]]; then	
#echo "Setting menu buttons for player 1" #debug

	BSELECT=$(cat "${GPFILE}" | grep -E 'input_a_btn' | cut -d '"' -f2)
if [ ! -z "$BSELECT" ]; then 
	BSELECT=$((BSELECT+1))
	echo "input_map[ui_select] keyboard[0,enter] or keyboard[1,enter] or joystick_button[${GAMEPAD},button${BSELECT}]" >> ${CONFIG}
fi
	MENU=$(cat "${GPFILE}" | grep -E 'input_r3_btn' | cut -d '"' -f2)
if [ ! -z "$MENU" ]; then 
	MENU=$((MENU+1))
	echo "input_map[ui_cancel] keyboard[0,backspace] or keyboard[1,backspace] or joystick_button[${GAMEPAD},button${MENU}]" >> ${CONFIG}
fi
	CONFIGURE=$(cat "${GPFILE}" | grep -E 'input_l3_btn' | cut -d '"' -f2)
if [ ! -z "$CONFIGURE" ]; then 
	CONFIGURE=$((CONFIGURE+1))
	echo "input_map[ui_configure] keyboard[1,tab] or keyboard[0,tab] or joystick_button[${GAMEPAD},button${CONFIGURE}]" >> ${CONFIG}	
fi
fi
	}

# Search for connected gamepads based on parameters $1 = player number $2 = device number e.g js0 and extract the name to $GAMEPAD
find_gamepad() {
for file in /tmp/joypads/*.cfg; do
	EE_GAMEPAD=$(cat "$file" | grep input_device|  cut -d'"' -f 2)
	ES_EE_GAMEPAD=$(printf %q "$EE_GAMEPAD")
if cat /proc/bus/input/devices | grep -Ew -A 4 -B 1 "Name=\"${ES_EE_GAMEPAD}" | grep ${2} > /dev/null; then
	FOUND=1
	GPFILE="$file"
	GAMEPAD=$(echo "$EE_GAMEPAD" | sed "s|,||g" | sed "s|_||g" | cut -d'"' -f 2 | sed "s|(||" | sed "s|)||" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/[[:blank:]]*$//' | sed 's/-//' | sed -e 's/[^A-Za-z0-9._-]/_/g' |tr '[:upper:]' '[:lower:]' | tr -d '.')

# check to see if the gamepad is exactly the same, if it is set a number after the gamepad, unfortunately this will be set according to the jsX as I do not know how to diferentiate from them	
	if [[ "$GAMEPAD" == "$FIRST_GAMEPAD" ]]; then
		GAMEPAD="$GAMEPAD"_${1}
	fi
[[ -z "${FIRST_GAMEPAD}" ]] && FIRST_GAMEPAD="$GAMEPAD"
	break
else
	FOUND=0
fi
done

if [ ${FOUND} = 1 ]; then
#echo "setting gamepad $GAMEPAD as player $1 on $2" #debug
	clean_pad "${1}" "$GAMEPAD"
	set_pad "${1}"
else
	clean_pad "${1}"
fi
}

# This will extract the GUID from es_settings.cfg depending on how many players have been set on ES and determine if they are currently connected to the device.
get_players() {
# You can set up to 8 player on ES
for ((y = 1; y <= 8; y++)); do
#echo "Player $y" #debug
#echo "Getting GUID for INPUT P${y}GUID" #debug

DEVICE_GUID=$(get_es_setting string "INPUT P${y}GUID")
	if [[ ! -z "${DEVICE_GUID}" ]]; then
		v=${DEVICE_GUID:0:8}
		part1=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Bus, generally not needed
		v=${DEVICE_GUID:8:8}
		part2=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Vendor
		v=${DEVICE_GUID:16:8}
		part3=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Product
		v=${DEVICE_GUID:24:8}
		part4=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Version

		input_vendor=$(echo ${part2:4})
		input_product=$(echo ${part3:4})
		input_version=$(echo ${part4:4})

		EE_DEV=$(cat /proc/bus/input/devices | grep -Ew -A 6 "Vendor=${input_vendor}" | grep -Ew -A 6 "Product=${input_product}" | grep -Ew -A 6 "Version=${input_version}" | grep -Ew "H: Handlers=.*js.*")
		if [[ ! -z "${EE_DEV}" ]]; then
		JOYSTICK="${EE_DEV##*js}"  # read from -P onwards
		JOYSTICK="${JOYSTICK%% *}"  # until a space is found
		
#echo "${y}" "js${JOYSTICK##*js}" #debug
			PAD_FOUND=1
			find_gamepad "${y}" "js${JOYSTICK##*js}"
		else
			EE_DEV=""
		fi
	fi
done

if [[ "$PAD_FOUND" == "0" ]]; then
#echo "Pad was not found, try failsafe 1 and js0" #debug
find_gamepad "1" "js0"
fi
}
	
get_players
