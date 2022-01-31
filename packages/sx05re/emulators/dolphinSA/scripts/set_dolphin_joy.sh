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
CONFIG_TMP=/tmp/GCPadNew.tmp
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
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
  START_DELETING=0
  while read -r line; do
    [[ "[GCPad${1}]" == "$line" ]] && START_DELETING=1
    if [[ $START_DELETING == 1 ]]; then
      [[ "$line" == "[GCPad"[0-9]"]" ]] && [[ "[GCPad${1}]" != "$line" ]] && return
      [[ "$line" =~ ^(.*)+Stick\/Modifier(.*)+$ ]] && echo "$line" >> ${CONFIG_TMP}
      [[ "$line" =~ ^(.)+Stick\/Dead(.*)+$ ]] && echo "$line" >> ${CONFIG_TMP}
      sed -i "1 d" "$CONFIG"
    fi
  done < ${CONFIG}
}

# Sets pad depending on parameters.
# $1 = Player Number
# $2 = js[0-7]
# $3 = Device GUID
# $4 = Device Name

set_pad() {
  DEVICE_GUID=$3
  JOY_NAME=$4

  echo "DEVICE_GUID=$DEVICE_GUID"
  
  GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID")
  echo "GC_CONFIG=$GC_CONFIG"
  [[ -z $GC_CONFIG ]] && return

  GC_MAP=$(echo $GC_CONFIG | grep -Eo '([^,]+\,){4}(.*)+$' | head -1)
  
  echo "[GCPad$1]" >> ${CONFIG}
  echo "Device = evdev/0/$JOY_NAME" >> ${CONFIG}

  set -f
  GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      REC=${GC_ARRAY[$index]}
      BUTTON_INDEX=$(echo $REC | cut -d ":" -f 1)
      TVAL=$(echo $REC | cut -d ":" -f 2)
      BUTTON_VAL=${TVAL:1}
      TMP_BUTTONS=${GC_DOLPHIN_BUTTONS[$BUTTON_INDEX]}
      if [[ ! -z "$TMP_BUTTONS" ]]; then
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

  JOYSTICK="Main Stick"
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier = Shift_L" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier\/Range *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Dead Zone *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$stick/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

  JOYSTICK="C-Stick"
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier = Control_L" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier\/Range *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Dead Zone *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" | sort >> ${CONFIG}
  rm "${CONFIG_TMP}"
}

# This will extract the GUID from es_settings.cfg depending on how many players have been set on ES and determine if they are currently connected to the device.
get_players() {
# You can set up to 8 player on ES
  for ((y = 1; y <= 8; y++)); do
  #echo "Player $y" #debug
    echo "Getting GUID for INPUT P${y}GUID" #debug

    DEVICE_GUID=$(get_es_setting string "INPUT P${y}GUID")
    
    JOY_INDEX=$(( $y - 1 ))
    DETECT_LINE=$(echo "Handlers=event[0-9] js${JOY_INDEX}")
    
    cat /proc/bus/input/devices | grep -E '^\H: Handlers\=event[0-9]+(.*)+$|^N\: Name\=\"(.*)+$' > /tmp/input_devices
    LINE_NUMBER=$(cat /tmp/input_devices | grep -n "${DETECT_LINE}" | cut -d ":" -f 1)
    echo "LINE_NUMBER=$LINE_NUMBER"
    [[ ! $LINE_NUMBER =~ ^[0-9]+$ ]] && continue
    LINE_NUMBER=$(( $LINE_NUMBER - 1 ))
    
    JOY_NAME=$(cat /tmp/input_devices | sed -n "${LINE_NUMBER}p" | cut -d "=" -f 2 | tr -d '"')
    rm /tmp/input_devices

    echo "JOY_NAME=$JOY_NAME"
    [[ -z "$JOY_NAME" ]] && continue

    if [[ -z "${DEVICE_GUID}" ]]; then
      INPUTCONFIG_XML=$(cat "$ESINPUT" | grep -i "$JOY_NAME")
      if [[ ! -z "${INPUTCONFIG_XML}" ]]; then
        GUID_DIRTY=$(echo "$INPUTCONFIG_XML" | cut -d "=" -f 4)
        DEVICE_GUID="${GUID_DIRTY:1:-2}"
      fi
    fi
    if [[ ! -z "${DEVICE_GUID}" ]]; then
        clean_pad "${y}"
    	  set_pad "${y}" "js${JOY_INDEX}" "${DEVICE_GUID}" "${JOY_NAME}"
  	fi
  done
}

get_players
