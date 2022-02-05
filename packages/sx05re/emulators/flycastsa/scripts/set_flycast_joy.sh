#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
GCDB="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"
ESINPUT="/storage/.config/emulationstation/es_input.cfg"
CONFIG_DIR="/storage/.config/flycast/mappings"
EMU_FILE="/storage/.config/flycast/emu.cfg"

#CONFIG_TMP=/tmp/SDLflycast.tmp
CONFIG_TMP_A="/tmp/SDLflycastA.tmp"
CONFIG_TMP_D="/tmp/SDLflycastD.tmp"
CONFIG_TMP_E="/tmp/SDLflycastE.tmp"
FOUND=0
PAD_FOUND=0
EE_DEV="js0"
GPFILE=""
GAMEPAD=""

BTN_H0=$(get_ee_setting flycast_btn_h0)
[[ -z "$BTN_H0" ]] && BTN_H0=255

declare -A FLYCAST_D_INDEXES=(
[h0.1]=$(( BTN_H0+1 ))
[h0.4]=$(( BTN_H0+2 ))
[h0.8]=$(( BTN_H0+3 ))
[h0.2]=$(( BTN_H0+4 ))
)

# Only needed for version 3.
#declare -A FLYCAST_D_BIND=(
#  [a]=1
#  [b]=0
#  [x]=3
#  [y]=2
#  [leftshoulder]=4
#  [rightshoulder]=5
#  [lefttrigger]=6
#  [righttrigger]=7
#  [back]=8
#  [start]=9
#  [guide]=10
#  [dpup]=11
#  [dpdown]=12
#  [dpleft]=13
#  [dpright]=14
#)

# Regular buttons a,b,x,y flipped.
declare -A FLYCAST_D_BUTTONS=(
  [x]="btn_y"
  [y]="btn_x"
  [a]="btn_b"
  [b]="btn_a"
  [leftshoulder]="btn_c"
  [rightshoulder]="btn_d"
  [lefttrigger]="btn_trigger_left"
  [righttrigger]="btn_trigger_right"
  [back]="btn_menu"
  [start]="btn_start"
  [guide]="btn_escape"
  [dpup]="btn_dpad1_up"
  [dpdown]="btn_dpad1_down"
  [dpleft]="btn_dpad1_left"
  [dpright]="btn_dpad1_right"
  [leftx]="axis_x"
  [lefty]="axis_y"
  [rightx]="axis_right_x"
  [righty]="axis_right_y"
)

declare -A FLYCAST_A_BUTTONS=(
)

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1 
clean_pad() {
  #echo "Cleaning pad $1 $2" #debug
  [[ -f "${CONFIG_TMP_A}" ]] && rm "${CONFIG_TMP_A}"
  [[ -f "${CONFIG_TMP_D}" ]] && rm "${CONFIG_TMP_D}"
  [[ -f "${CONFIG_TMP_E}" ]] && rm "${CONFIG_TMP_E}"
}

# Sets pad depending on parameters.
# $1 = Player Number
# $2 = js[0-7]
# $3 = Device GUID
# $4 = Device Name

set_pad() {
  DEVICE_GUID=$3
  JOY_NAME=$4

  CONFIG="${CONFIG_DIR}/SDL_${JOY_NAME}.cfg"
  [[ -f "${CONFIG}" ]] && cp "${CONFIG}" "${CONFIG}.bak"

  echo "DEVICE_GUID=${DEVICE_GUID}"

  touch "${CONFIG_TMP_A}"
  touch "${CONFIG_TMP_D}"
  touch "${CONFIG_TMP_E}"

  echo "axis_right_x_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_right_y_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_x_inverted = no" >> ${CONFIG_TMP_A}
  echo "axis_y_inverted = no" >> ${CONFIG_TMP_A}


  [[ -f "${CONFIG}" ]] && GC_RECORD=$(cat "${CONFIG}" | grep -E "^dead_zone \= [0-9]*$")
  [[ -z "$GC_RECORD" ]] && GC_RECORD="dead_zone = 10"
  echo "$GC_RECORD" >> ${CONFIG_TMP_E}

  [[ -f "${CONFIG}" ]] && rm "${CONFIG}"

  echo "mapping_name = $JOY_NAME" >> ${CONFIG_TMP_E}
  echo "version = 2" >> ${CONFIG_TMP_E}

  local GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID" | grep -v "platform:Linux" | head -1)
  echo "GC_CONFIG=$GC_CONFIG"
  [[ -z $GC_CONFIG ]] && return

  GC_MAP=$(echo $GC_CONFIG | cut -d',' -f3-)

  set -f
  GC_ARRAY=(${GC_MAP//,/ })
  
  for index in "${!GC_ARRAY[@]}"; do
      REC=${GC_ARRAY[$index]}
      BUTTON_INDEX=$(echo $REC | cut -d ":" -f 1)
      TVAL=$(echo $REC | cut -d ":" -f 2)
      BTN_TYPE="${TVAL:1}"
      FC_INDEX_D=${FLYCAST_D_BUTTONS[$BUTTON_INDEX]}
      ABORT_ENTRY=0
      if [[ ! -z "$FC_INDEX_D" ]]; then
          BTN_TYPE=${TVAL:0:1}
          NUM=${TVAL:1}
          [[ $BUTTON_INDEX == "lefttrigger" ]] && ABORT_ENTRY=1
          [[ $BUTTON_INDEX == "righttrigger" ]] && ABORT_ENTRY=1
          [[ $BUTTON_INDEX == "back" ]]  && ABORT_ENTRY=1 && echo "${FC_INDEX_D} = $NUM" >> ${CONFIG_TMP_E}
          [[ $BUTTON_INDEX == "guide" ]] && ABORT_ENTRY=1 && echo "${FC_INDEX_D} = $NUM" >> ${CONFIG_TMP_E} 

          if [[ $ABORT_ENTRY == 0 ]]; then
            [[ $BTN_TYPE == "a" ]] && echo "${FC_INDEX_D} = $NUM" >> ${CONFIG_TMP_D}
            [[ $BTN_TYPE == "b" ]] && echo "${FC_INDEX_D} = $NUM" >> ${CONFIG_TMP_D}
            [[ $BTN_TYPE == "h" ]] && NUM=${FLYCAST_D_INDEXES[$TVAL]} && echo "${FC_INDEX_D} = ${NUM}" >> ${CONFIG_TMP_D}
          fi
      fi

      FC_INDEX_A=${FLYCAST_D_BUTTONS[$BUTTON_INDEX]}
      if [[ ! -z "$FC_INDEX_A" ]]; then
        NUM=${TVAL:1}
        case $BUTTON_INDEX in
          "lefttrigger")
            echo "${FC_INDEX_A} = $NUM" >> ${CONFIG_TMP_A}
            ;;
          "righttrigger")
            echo "${FC_INDEX_A} = $NUM" >> ${CONFIG_TMP_A}
            ;;
        esac
      fi
  done 

  echo "[compat]" >> "${CONFIG}"
  cat "${CONFIG_TMP_A}" | sort >> "${CONFIG}"

  echo -e "\n[dreamcast]" >> "${CONFIG}"
  cat "${CONFIG_TMP_D}" | sort >> "${CONFIG}"
  
  echo -e "\n[emulator]" >> "${CONFIG}"
  cat "${CONFIG_TMP_E}" | sort >> "${CONFIG}"

  rm "${CONFIG_TMP_A}"
  rm "${CONFIG_TMP_D}"
  rm "${CONFIG_TMP_E}"
  
  # Adjust the emulator config file to load sdl controller files.
  declare -i LN=$( cat "$EMU_FILE" | grep -n "\[input\]" | cut -d: -f1 )
  if [ ${LN} -ne 0 ]; then
    sed -i '/maple_sdl_joystick_0/d' "$EMU_FILE"
    sed -i '/maple_sdl_joystick_1/d' "$EMU_FILE"
  fi
  ((LN++))
  sed -i "${LN} i maple_sdl_joystick_0 = 0\nmaple_sdl_joystick_1 = 1" "$EMU_FILE"

}

# This will extract the GUID from es_settings.cfg depending on how many players have been set on ES and determine if they are currently connected to the device.
get_players() {
# You can set up to 8 player on ES
  local OLD_DEVICE_GUID
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
        if [[ ! "${DEVICE_GUID}" == "${OLD_DEVICE_GUID}" ]]; then
          clean_pad
    	    set_pad "${PLAYER}" "${JSI}" "${DEVICE_GUID}" "${JOY_NAME}"
          OLD_DEVICE_GUID="${DEVICE_GUID}"
        fi
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

mkdir -p "/storage/.config/flycast"
mkdir -p "/storage/.config/flycast/mappings"
get_players
