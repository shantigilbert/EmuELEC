#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
GCDB="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"
ESINPUT="/storage/.config/emulationstation/es_input.cfg"
CONFIG_DIR="/storage/.config/emuelec/configs/dolphin-emu"
CONFIG=${CONFIG_DIR}/GCPadNew.ini
CONFIG_TMP=${CONFIG_DIR}/GCPadNew.tmp
FOUND=0
PAD_FOUND=0
EE_DEV="js0"
GPFILE=""
GAMEPAD=""

declare -A GC_DOLPHIN_BUTTONS=(
  [dpleft]="D-Pad/Left"
  [dpright]="D-Pad/Right"
  [dpup]="D-Pad/Up"
  [dpdown]="D-Pad/Down"
  [x]="Buttons/X"
  [y]="Buttons/Y"
  [a]="Buttons/A"
  [b]="Buttons/B"
  [leftshoulder]="Triggers/L"
  [rightshoulder]="Triggers/R"
  [start]="Buttons/Start"
)

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1 
clean_pad() {
  #echo "Cleaning pad $1 $2" #debug
  START_DELETING=0
  while read -r line; do
    [[ "[GCPad${1}]" == "$line" ]] && START_DELETING=1
    if [[ $START_DELETING == 1 ]]; then
      [[ "$line" == "[GCPad"[0-9]"]" ]] && [[ "[GCPad${1}]" != "$line" ]] && return
      sed -i "1 d" "$CONFIG"
    fi
  done < ${CONFIG}
}

# Sets pad depending on parameters $GAMEPAD = name $1 = player $2 js0 / js1 etc.
set_pad() {

  DEVICE_GUID=$(get_es_setting string "INPUT P${1}GUID")
  #echo "Gamepad ${2}"
  DETECT_LINE=$(echo "Handlers=event[0-9] ${2}")
  LINE_NUMBER=$(grep -n "${DETECT_LINE}" /proc/bus/input/devices | cut -d ":" -f 1)
  #echo "LINE_NUMBER=$LINE_NUMBER"
  [[ ! "$LINE_NUMBER" -eq "$LINE_NUMBER" ]] && return
  LINE_NUMBER=$(( $LINE_NUMBER - 4 ))
  
  CTRLR_NAME=$(sed -n "${LINE_NUMBER}p" /proc/bus/input/devices | cut -d "=" -f 2 | tr -d '"')
  #echo "CTRLR_NAME=$CTRLR_NAME"
  if [[ -z "${DEVICE_GUID}" ]]; then
    INPUTCONFIG_XML=$(cat "$ESINPUT" | grep "$CTRLR_NAME")
    if [[ ! -z "${INPUTCONFIG_XML}" ]]; then
      GUID_DIRTY=$(echo "$INPUTCONFIG_XML" | cut -d "=" -f 4)
      DEVICE_GUID="${GUID_DIRTY:1:-2}"
    fi
  fi
  #echo "DEVICE_GUID=$DEVICE_GUID"
  if [[ -z "${DEVICE_GUID}" ]]; then
    return
  fi

  #echo "CTRLR_NAME=$CTRLR_NAME"
  GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID")
  #echo "GC_CONFIG=$GC_CONFIG"
  GC_NAME=$(echo $GC_CONFIG | cut -d "," -f 2)
  #echo "GC_NAME=$GC_NAME"
  GC_MAP=$(echo $GC_CONFIG | grep -Eo '([^,]+\,){4}(.*)+$')
  #echo "GC_MAP=$GC_MAP"
  
  echo "[GCPad$1]" >> ${CONFIG}
  echo "Device = evdev/0/$CTRLR_NAME" >> ${CONFIG}

  rm "${CONFIG_TMP}"

  set -f
  GC_ARRAY=(${GC_MAP//,/ })
  #echo "GC_ARRAY=${!GC_ARRAY[@]}"
  for index in "${!GC_ARRAY[@]}"
  do
      REC=${GC_ARRAY[$index]}
      BUTTON_INDEX=$(echo $REC | cut -d ":" -f 1)
      #echo "BUTTON_INDEX=$BUTTON_INDEX"
      TVAL=$(echo $REC | cut -d ":" -f 2)
      #echo "TVAL=$TVAL"
      BUTTON_VAL=${TVAL:1}
      TMP=${GC_DOLPHIN_BUTTONS[$BUTTON_INDEX]}
      #echo "TMP=$TMP"
      if [[ ! -z "$TMP" ]]; then
          GC_INDEX=${GC_DOLPHIN_BUTTONS[$BUTTON_INDEX]}
          [[ ${TVAL:0:1} == "b" ]] && echo "${GC_INDEX} = Button $BUTTON_VAL" >> ${CONFIG_TMP}
      fi
      case $BUTTON_INDEX in
        "lefttrigger")
          # unused
          ;;
        "righttrigger")
          [[ ${TVAL:0:1} == "b" ]] && echo "Buttons/Z = Button $BUTTON_VAL" >> ${CONFIG_TMP}
          [[ ${TVAL:0:1} == "a" ]] && echo "Buttons/Z = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
        "leftx")
          echo "Main Stick/Left  = Axis $BUTTON_VAL-" >> ${CONFIG_TMP}
          echo "Main Stick/Right  = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
        "lefty")
          echo "Main Stick/Up  = Axis $BUTTON_VAL-" >> ${CONFIG_TMP}
          echo "Main Stick/Down  = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
        "rightx")
          echo "C-Stick/Left  = Axis $BUTTON_VAL-" >> ${CONFIG_TMP}
          echo "C-Stick/Right  = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
        "righty")
          echo "C-Stick/Up  = Axis $BUTTON_VAL-" >> ${CONFIG_TMP}
          echo "C-Stick/Down  = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
      esac
  done
  echo "C-Stick/Modifier = Control_L" >> ${CONFIG_TMP}
  echo "C-Stick/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  echo "C-Stick/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}
  echo "Main Stick/Modifier = Shift_L" >> ${CONFIG_TMP}
  echo "Main Stick/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  echo "Main Stick/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" | sort >> ${CONFIG}
  rm "${CONFIG_TMP}"
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
  	clean_pad "${1}" "${2}"
  	set_pad "${1}" "${2}"
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
        echo $EE_DEV
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
