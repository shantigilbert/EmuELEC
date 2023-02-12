#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/roms/saturn/yabasanshiro"
CONFIG="keymapv3.json"

CONFIG_TMP=/tmp/jc/yabasan.tmp

source /usr/bin/joy_common.sh "yabasanshiro"

declare -A GC_VALUES=(
[h0.1]="8"
[h0.4]="2"
[h0.8]="1"
[h0.2]="4"
[b0]="0"
[b1]="1"
[b2]="2"
[b3]="3"
[b4]="9"
[b5]="10"
[b6]="4"
[b7]="6"
[b8]="5"
[b9]="7"
[b10]="8"
[b11]="11"
[b12]="12"
[b13]="13"
[b14]="14"
[a0]="0"
[a1]="1"
[a2]="2"
[a3]="3"
[a4]="4"
[a5]="5"
)

declare -A GC_TYPES=(
[h0.1]="hat"
[h0.4]="hat"
[h0.8]="hat"
[h0.2]="hat"
[b0]="button"
[b1]="button"
[b2]="button"
[b3]="button"
[b4]="button"
[b5]="button"
[b6]="button"
[b7]="button"
[b8]="button"
[b9]="button"
[b10]="button"
[b11]="button"
[b12]="button"
[b13]="button"
[b14]="button"
[a0]="axis"
[a1]="axis"
[a2]="axis"
[a3]="axis"
[a4]="axis"
[a5]="axis"
)

declare -A GC_BUTTONS=(
  [dpleft]="left"
  [dpright]="right"
  [dpup]="up"
  [dpdown]="down"
  [x]="x"
  [y]="y"
  [a]="a"
  [b]="b"
  [leftshoulder]="c"
  [rightshoulder]="z"
  [lefttrigger]="l"
  [righttrigger]="r"
  #[leftstick]=""
  #[rightstick]=""
  [back]="select"
  [start]="start"
  #[guide]=""
  [leftx-0]="analogx"
  [leftx-1]="analogy"
  [lefty-0]="analogl"
  [lefty-1]="analogr"
  #[rightx]=""
  #[righty]=""
)

# Cleans all the inputs for the gamepad with name $GAMEPAD and player $1
clean_pad() {
  [[ -f "${CONFIG_TMP}" ]] && rm "${CONFIG_TMP}"
}

# Sets pad depending on parameters.
# $1 = Player Number
# $2 = js[0-7]
# $3 = Device GUID
# $4 = Device Name

set_pad() {
  local DEVICE_GUID=$3
  local JOY_NAME="$4"

  echo "DEVICE_GUID=$DEVICE_GUID"

  local GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=$GC_CONFIG"
  [[ -z $GC_CONFIG ]] && return

  touch "${CONFIG_TMP}"

  local GC_MAP=$(echo $GC_CONFIG | cut -d',' -f3-)

  [[ "$1" != "1" ]] && echo "," >> ${CONFIG_TMP}

  declare -i JOY_INDEX=$(( $1 - 1 ))
  echo -e "\t\"${JOY_INDEX}_${JOY_NAME}_${DEVICE_GUID}\": {" >> ${CONFIG_TMP}

  local LINE_INSERT=
  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[$index]}
      local BUTTON_INDEX=$(echo $REC | cut -d ":" -f 1)
      local TVAL=$(echo $REC | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_BUTTONS[$BUTTON_INDEX]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_VALUES[$TVAL]}"
      local TYPE="${GC_TYPES[$TVAL]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "$GC_INDEX" ]]; then
        if [[ "$BTN_TYPE" == "b" ]]; then
          [[ ! -z "$VAL" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
        fi
        if [[ "$BTN_TYPE" == "h" ]]; then
          [[ ! -z "$VAL" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": 0, \"type\": \"${TYPE}\", \"value\": ${VAL} }," >> ${CONFIG_TMP}
        fi
        if [[ "$BTN_TYPE" == "a" ]]; then
          [[ ! -z "$VAL" ]] && echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
        fi
      fi
      if [[ "$BTN_TYPE" == "a" ]]; then
          case $BUTTON_INDEX in
            leftx|lefty)
              GC_INDEX="${GC_BUTTONS[${BUTTON_INDEX}-1]}"
              echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": 1 }," >> ${CONFIG_TMP}
              GC_INDEX="${GC_BUTTONS[${BUTTON_INDEX}-0]}"
              echo -e "\t\t\"${GC_INDEX}\": { \"id\": ${VAL}, \"type\": \"${TYPE}\", \"value\": -1 }," >> ${CONFIG_TMP}
              ;;
          esac
      fi
  done

  sed -i '$ s/.$//' ${CONFIG_TMP}

  echo -e "\t}," >> ${CONFIG_TMP}
  echo -e "\t\"player${1}\": {" >> ${CONFIG_TMP}
  echo -e "\t\t\"DeviceID\": ${2:2}," >> ${CONFIG_TMP}
  echo -e "\t\t\"deviceGUID\": \"${DEVICE_GUID}\"," >> ${CONFIG_TMP}
  echo -e "\t\t\"deviceName\": \"${JOY_NAME}\"," >> ${CONFIG_TMP}
  echo -e "\t\t\"padmode\": 1" >> ${CONFIG_TMP}
  echo -e "\t}" >> ${CONFIG_TMP}

  cat "${CONFIG_TMP}" >> ${CONFIG}

  rm "${CONFIG_TMP}"
}

rm ${CONFIG}
echo "{" >> ${CONFIG}
jc_get_players
echo "}" >> ${CONFIG}
