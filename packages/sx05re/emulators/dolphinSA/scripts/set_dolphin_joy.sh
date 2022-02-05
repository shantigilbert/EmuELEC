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

declare -A GC_DOLPHIN_VALUES=(
[h0.1]="Axis 7-"
[h0.4]="Axis 7+"
[h0.8]="Axis 6-"
[h0.2]="Axis 6+"
[b0]="Button 0"
[b1]="Button 1"
[b2]="Button 2"
[b3]="Button 3"
[b4]="Button 4"
[b5]="Button 5"
[b6]="Button 6"
[b7]="Button 7"
[b8]="Button 8"
[b9]="Button 9"
[b10]="Button 10"
[b11]="Button 11"
[b12]="Button 12"
[b13]="Button 13"
[b14]="Button 14"
[b15]="Button 15"
[b16]="Button 16"

)

declare -A GC_DOLPHIN_BUTTONS=(
  [dpleft]="D-Pad/Left"
  [dpright]="D-Pad/Right"
  [dpup]="D-Pad/Up"
  [dpdown]="D-Pad/Down"
  [x]="Buttons/Y"
  [y]="Buttons/X"
  [a]="Buttons/B"
  [b]="Buttons/A"
  [lefttrigger]="Triggers/L"
  [righttrigger]="Triggers/R"
  [start]="Buttons/Start"
  [rightshoulder]="Buttons/Z"
)

declare -A GC_DOLPHIN_STICKS=(
  ["leftx,0"]="Main Stick/Left"
  ["leftx,1"]="Main Stick/Right"
  ["lefty,0"]="Main Stick/Up"
  ["lefty,1"]="Main Stick/Down"
  ["rightx,0"]="C-Stick/Left"
  ["rightx,1"]="C-Stick/Right"
  ["righty,0"]="C-Stick/Up"
  ["righty,1"]="C-Stick/Down"
)

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1 
clean_pad() {
  #echo "Cleaning pad $1 $2" #debug
  local P_INDEX=${1}
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
  local START_DELETING=0
  local GC_REGEX="\[GCPad[1-9]{1}\]"
  while read -r line; do
    if [[ "$line" =~ $GC_REGEX && "[GCPad${P_INDEX}]" != "$line" ]]; then
      START_DELETING=0
    fi
    [[ "[GCPad${P_INDEX}]" == "$line" ]] && START_DELETING=1
    if [[ $START_DELETING == 1 ]]; then
      [[ "$line" =~ ^(.*)+Stick\/Modifier(.*)+$ ]] && echo "$line" >> ${CONFIG_TMP}
      [[ "$line" =~ ^(.*)+Stick\/Dead(.*)+$ ]] && echo "$line" >> ${CONFIG_TMP}
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
  local DEVICE_GUID=$3
  local JOY_NAME=$4

  echo "DEVICE_GUID=$DEVICE_GUID"
  
  local GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID" | grep -v "platform:Linux" | head -1)
  echo "GC_CONFIG=$GC_CONFIG"
  [[ -z $GC_CONFIG ]] && return

  local GC_MAP=$(echo $GC_CONFIG | cut -d',' -f3-)
  #local JOY_NAME=$(echo $GC_CONFIG | cut -d',' -f2)
  echo "[GCPad$1]" >> ${CONFIG}
  local JOY_INDEX=$(( $1 - 1 ))
  echo "Device = evdev/${JOY_INDEX}/${JOY_NAME}" >> ${CONFIG}

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[$index]}
      local BUTTON_INDEX=$(echo $REC | cut -d ":" -f 1)
      local TVAL=$(echo $REC | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_DOLPHIN_BUTTONS[$BUTTON_INDEX]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_DOLPHIN_VALUES[$TVAL]}"
      
      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "$GC_INDEX" ]]; then
        if [[ "$BTN_TYPE" == "b"  || "$BTN_TYPE" == "h" ]]; then
          [[ ! -z "$VAL" ]] && echo "${GC_INDEX} = ${VAL}" >> ${CONFIG_TMP}
        fi
      fi

      # Create Axis Maps
      case $BUTTON_INDEX in
        lefttrigger|righttrigger)
          if [[ "$BTN_TYPE" == "a" ]]; then
            VAL=${BUTTON_VAL}
            echo "${GC_INDEX} = Axis $VAL+" >> ${CONFIG_TMP}
          fi
          ;;
        leftx|lefty|rightx|righty)
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},0]}"
          echo "$GC_INDEX = Axis $BUTTON_VAL-" >> ${CONFIG_TMP}
          GC_INDEX="${GC_DOLPHIN_STICKS[${BUTTON_INDEX},1]}"
          echo "$GC_INDEX = Axis $BUTTON_VAL+" >> ${CONFIG_TMP}
          ;;
      esac
  done

  JOYSTICK="Main Stick"
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier = Shift_L" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Modifier\/Range *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Modifier/Range = 50.000000000000000" >> ${CONFIG_TMP}
  GC_RECORD=$(cat ${CONFIG_TMP} | grep -E "^$JOYSTICK\/Dead Zone *\= *(.*)$")
  [[ -z "$GC_RECORD" ]] && echo "$JOYSTICK/Dead Zone = 25.000000000000000" >> ${CONFIG_TMP}

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

  local v
  v+=$(echo ${p1:6:2}${p1:4:2}${p1:2:2}${p1:0:2})
  v+=$(echo ${p2:6:2}${p2:4:2}${p2:2:2}${p2:0:2})
  v+=$(echo ${p3:6:2}${p3:4:2}${p3:2:2}${p3:0:2})
  v+=$(echo ${p4:6:2}${p4:4:2}${p4:2:2}${p4:0:2})
  
  echo "$v"
}

get_players

