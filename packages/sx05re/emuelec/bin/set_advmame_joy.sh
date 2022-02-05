#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.advance"
CONFIG=${CONFIG_DIR}/advmame.rc
ES_FEATURES="/storage/.config/emulationstation/es_features.cfg"
FOUND=0
PAD_FOUND=0
EE_DEV="js0"
GPFILE=""
GAMEPAD=""
ROMNAME=$1

BTN_CFG="0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"

DEBUGFILE="$CONFIG_DIR/joy_debug.cfg"

BTN_H0=$(get_ee_setting advmame_btn_h0)
[[ -z "$BTN_H0" ]] && BTN_H0=4

declare -A JS_BUTTON_INDEXES=(
  ["0"]="button1"
  ["1"]="button2"
  ["2"]="button3"
  ["3"]="button4"
  ["4"]="button5"
  ["5"]="button6"
  ["6"]="button7"
  ["7"]="button8"
  ["8"]="button9"
  ["9"]="button10"
  ["10"]="button11"
  ["11"]="button12"
  ["12"]="button13"
  ["13"]="button14"
  ["14"]="button15"
  ["15"]="button16"
  ["h0up"]="stick${BTN_H0},y,up"
  ["h0down"]="stick${BTN_H0},y,down"
  ["h0left"]="stick${BTN_H0},x,left"
  ["h0right"]="stick${BTN_H0},x,right"
  ["-0"]="stick,x,left"
  ["+0"]="stick,x,right"
  ["-1"]="stick,y,up"
  ["+1"]="stick,y,down"
)

BTN_ORDER=(
  "input_a_btn"
	"input_b_btn"
	"input_x_btn"
	"input_y_btn"
	"input_r_btn"
	"input_l_btn"
	"input_r2_btn"
	"input_l2_btn"
	"input_up_btn"
	"input_down_btn"
	"input_right_btn"
	"input_left_btn"
  "input_l_y_minus_axis"
  "input_l_y_plus_axis"
  "input_l_x_minus_axis"
  "input_l_x_plus_axis"
)

get_button_cfg() {	
	local BTN_INDEX=$(get_ee_setting "joy_btn_cfg" "mame" "${ROMNAME}")
  [[ -z $BTN_INDEX ]] && BTN_INDEX=$(get_ee_setting "mame.joy_btn_cfg")

  local BTN_CFG_TMP=
  if [[ ! -z $BTN_INDEX ]] && [[ $BTN_INDEX -gt 0 ]]; then
		local BTN_SETTING="AdvanceMame.joy_btn_order$BTN_INDEX"
    BTN_CFG_TMP="$(get_ee_setting $BTN_SETTING)"
		[[ ! -z $BTN_CFG_TMP ]] && BTN_CFG="${BTN_CFG_TMP} 8 9 10 11 12 13 14 15"
	fi
	echo "$BTN_CFG"
}

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1 
clean_pad() {
#echo "Cleaning pad $1 $2" #debug
	sed -i "/device_joystick.*/d" ${CONFIG}
	sed -i "/input_map\[p${1}_*/d" ${CONFIG}
	sed -i "/input_map\[coin${1}.*/d" ${CONFIG}
	sed -i "/input_map\[start${1}.*/d" ${CONFIG}

  if [[ "${1}" == "1" ]]; then
  	sed -i '/input_map\[ui_[[:alpha:]]*\].*/d' ${CONFIG}
  fi
	echo "device_joystick raw" >> ${CONFIG}
}

# Sets pad depending on parameters $GAMEPAD = name $1 = player
set_pad(){
#echo "Setting pad $1 from ${GPFILE}" #debug
  local GPFILE="/tmp/joypads/${JOY_NAME}.cfg"
  local EE_GAMEPAD=$(cat "$GPFILE" | grep input_device |  cut -d'"' -f2)
  local GAMEPAD=$(echo "$EE_GAMEPAD" | sed "s|,||g" | sed "s|_||g" | cut -d'"' -f 2 | sed "s|(||" | sed "s|)||" | sed -e 's/[^A-Za-z0-9._-]/ /g' | sed 's/[[:blank:]]*$//' | sed 's/-//' | sed -e 's/[^A-Za-z0-9._-]/_/g' |tr '[:upper:]' '[:lower:]' | tr -d '.')
	[[ "$1" != "1" ]] && GAMEPAD="$GAMEPAD_${1}"

  local COIN=$(cat "${GPFILE}" | grep -E 'input_select_btn' | cut -d '"' -f2) 
	COIN=$((COIN+1))
	echo "input_map[coin${1}] joystick_button[${GAMEPAD},button${COIN}]" >> ${CONFIG}
	local START=$(cat "${GPFILE}" | grep -E 'input_start_btn' | cut -d '"' -f2)
	START=$((START+1))
	echo "input_map[start${1}] joystick_button[${GAMEPAD},button${START}]" >> ${CONFIG}

  local button=""
  local i=1
  local DIR_LEFT=""
  local DIR_RIGHT=""
  local DIR_UP=""
  local DIR_DOWN=""
  

  for bi in ${BTN_CFG}; do
  	button="${BTN_ORDER[$bi]}"
    #echo "button=$button"
  	local KEY=$(cat "${GPFILE}" | grep -E "${button}" | cut -d '"' -f2)
    #echo "KEY=$KEY"
    if [ ! -z "$KEY" ]; then
      local KEY_MAP="${JS_BUTTON_INDEXES[${KEY}]}"
      #echo "KEY_MAP=$KEY_MAP"
      case "${button}" in
      	input_up_btn|input_l_y_minus_axis)
          [[ ! -z "$DIR_UP" ]] && DIR_UP+=" or "
          DIR_UP+="joystick_digital[${GAMEPAD},${KEY_MAP}]"
          ;;
      	input_down_btn|input_l_y_plus_axis)
          [[ ! -z "$DIR_DOWN" ]] && DIR_DOWN+=" or "
          DIR_DOWN+="joystick_digital[${GAMEPAD},${KEY_MAP}]"
      		;;
      	input_left_btn|input_l_x_minus_axis)
          [[ ! -z "$DIR_LEFT" ]] && DIR_LEFT+=" or "
          DIR_LEFT+="joystick_digital[${GAMEPAD},${KEY_MAP}]"
      		;;
      	input_right_btn|input_l_x_plus_axis)
          [[ ! -z "$DIR_RIGHT" ]] && DIR_RIGHT+=" or "
          DIR_RIGHT+="joystick_digital[${GAMEPAD},${KEY_MAP}]"
      		;;
        *)
      	  echo "input_map[p${1}_button${i}] joystick_button[${GAMEPAD},${KEY_MAP}]" >> ${CONFIG}
      	  i=$((i+1))
      	  ;;
      esac
    fi
  done

  echo "input_map[p${1}_up] $DIR_UP" >> ${CONFIG}
  echo "input_map[p${1}_down] $DIR_DOWN" >> ${CONFIG}
  echo "input_map[p${1}_left] $DIR_LEFT" >> ${CONFIG}
  echo "input_map[p${1}_right] $DIR_RIGHT" >> ${CONFIG}


  # Menu should only be set to player 1
  if [[ "${1}" == "1" ]]; then	
  #echo "Setting menu buttons for player 1" #debug
    echo "input_map[ui_up] $DIR_UP" >> ${CONFIG}
    echo "input_map[ui_down] $DIR_DOWN" >> ${CONFIG}
    echo "input_map[ui_left] $DIR_LEFT" >> ${CONFIG}
    echo "input_map[ui_right] $DIR_RIGHT" >> ${CONFIG}

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

get_players() {
# You can set up to 8 player on ES
  declare -i PLAYER=1
  
  cat /proc/bus/input/devices | grep -E -B5 -A3 "^H: Handlers\=.*js[0-9]{1}.*+$" > /tmp/input_devices
  
  for ((y = 1; y <= 8; y++)); do
    #echo "Getting GUID for INPUT P${y}GUID" #debug

    local DEVICE_GUID=$(get_es_setting string "INPUT P${y}GUID")
    
    declare -i JOY_INDEX=$y-1
    local JSI="js${JOY_INDEX}"
    local DETECT_LINE=$(echo "^H\: Handlers.*[\= ]?${JSI}.*$")
      
    declare -i LINE_NUM=0
    local LINE_NUM=$(cat /tmp/input_devices | grep -E -n "${DETECT_LINE}" | cut -d : -f 1)
    [[ ! $LINE_NUM =~ ^[0-9]+$ ]] && continue

    declare -i LINE_KEY_NUM=$(( LINE_NUM+3 ))
    local JOY_KEY=$(cat /tmp/input_devices | sed -n "${LINE_KEY_NUM}p" | grep -E "^B\: KEY\=[0-9a-f ]+$")
    [[ -z "$JOY_KEY" ]] && continue

    declare -i LINE_NAME_NUM=$(( LINE_NUM-4 ))
    local JOY_NAME=$(cat /tmp/input_devices | sed -n "${LINE_NAME_NUM}p" | cut -d "=" -f 2 | tr -d '"')
    [[ -z "$JOY_NAME" ]] && continue

    ((LINE_NAME_NUM--))
    local GUID_LINE=$(cat /tmp/input_devices | sed -n "${LINE_NAME_NUM}p")

    DEVICE_GUID=$(generate_guid "$GUID_LINE")
    [[ -z "$DEVICE_GUID" ]] && continue

    if [[ ! -z "${DEVICE_GUID}" ]]; then
      clean_pad "${PLAYER}"
  	  set_pad "${PLAYER}" "${JSI}" "${DEVICE_GUID}" "${JOY_NAME}"
  	fi
    ((PLAYER++))
  done

  rm /tmp/input_devices
}

generate_guid() {
  local GUID_STRING="$1"
  local p1=$( echo $GUID_STRING | cut -d = -f2 | cut -d ' ' -f1 | awk '{ printf "%8s\n", $0 }' | sed 's/ /0/g')
  local p2=$( echo $GUID_STRING | cut -d = -f3 | cut -d ' ' -f1 | awk '{ printf "%8s\n", $0 }' | sed 's/ /0/g')
  local p3=$( echo $GUID_STRING | cut -d = -f4 | cut -d ' ' -f1 | awk '{ printf "%8s\n", $0 }' | sed 's/ /0/g')
  local p4=$( echo $GUID_STRING | cut -d = -f5 | cut -d ' ' -f1 | awk '{ printf "%8s\n", $0 }' | sed 's/ /0/g')

  local v=$(echo ${p1:6:2}${p1:4:2}${p1:2:2}${p1:0:2})
  v+=$(echo ${p2:6:2}${p2:4:2}${p2:2:2}${p2:0:2})
  v+=$(echo ${p3:6:2}${p3:4:2}${p3:2:2}${p3:0:2})
  v+=$(echo ${p4:6:2}${p4:4:2}${p4:2:2}${p4:0:2})
  
  echo "$v"
}

ADVMAME_REMAP=$(cat "${ES_FEATURES}" | grep -E "<emulator.*name\=\"AdvanceMame\".*features\=\".*[ ,]{1}joybtnremap[, \"]{1}.*\".*/>$")
[[ ! -z "$ADVMAME_REMAP" ]] && BTN_CFG=$(get_button_cfg)
#echo "SETTING_BUTTONS=$BTN_CFG"  >> "${DEBUGFILE}"

get_players
