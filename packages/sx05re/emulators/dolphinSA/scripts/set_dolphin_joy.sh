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

  GC_MAP=$(echo $GC_CONFIG | cut -d',' -f4-)
  
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
  declare -i PLAYER=1
  
  cat /proc/bus/input/devices | grep -E "^I\: (.*)$|^H\: Handlers\=.*${JSI}.*+$|^N\: Name\=\"(.*)+$|^B\: KEY\=[0-9a-f ]+$" > /tmp/input_devices
  
  for ((y = 1; y <= 8; y++)); do
    #echo "Getting GUID for INPUT P${y}GUID" #debug

    local DEVICE_GUID=$(get_es_setting string "INPUT P${y}GUID")
    
    declare -i JOY_INDEX=$y-1
    local JSI="js${JOY_INDEX}"
    local DETECT_LINE=$(echo "^H\: Handlers.*[\= ]?${JSI}.*$")
      
    declare -i LINE_NUM=0
    local LINE_NUM=$(cat /tmp/input_devices | grep -E -n "${DETECT_LINE}" | cut -d : -f 1)
    [[ ! $LINE_NUM =~ ^[0-9]+$ ]] && continue

    ((LINE_NUM++))
    local JOY_KEY=$(cat /tmp/input_devices | sed -n "${LINE_NUM}p" | grep -E "^B\: KEY\=[0-9a-f ]+$")
    [[ -z "$JOY_KEY" ]] && continue

    ((LINE_NUM-=2))
    local JOY_NAME=$(cat /tmp/input_devices | sed -n "${LINE_NUM}p" | cut -d "=" -f 2 | tr -d '"')
    [[ -z "$JOY_NAME" ]] && continue

    ((LINE_NUM--))
    local GUID_LINE=$(cat /tmp/input_devices | sed -n "${LINE_NUM}p")

    DEVICE_GUID=$(generate_guid "$GUID_LINE")
    [[ -z "$DEVICE_GUID" ]] && continue

    if [[ ! -z "${DEVICE_GUID}" ]]; then
        clean_pad
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

  local v
  v+=$(echo ${p1:6:2}${p1:4:2}${p1:2:2}${p1:0:2})
  v+=$(echo ${p2:6:2}${p2:4:2}${p2:2:2}${p2:0:2})
  v+=$(echo ${p3:6:2}${p3:4:2}${p3:2:2}${p3:0:2})
  v+=$(echo ${p4:6:2}${p4:4:2}${p4:2:2}${p4:0:2})
  
  echo "$v"
}

get_players

