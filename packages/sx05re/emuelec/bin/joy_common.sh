#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

GCDB="${SDL_GAMECONTROLLERCONFIG_FILE}"

EMULATOR="$1"

mkdir -p "/tmp/jc"

DEBUG_FILE="/tmp/jc/${EMULATOR}_joy_debug.cfg"
CACHE_FILE="/tmp/jc/${EMULATOR}_joy_cache.cfg"


jc_get_players() {
# You can set up to 8 player on ES
  declare -i PLAYER=1

# Dump gamepad information
  cat /proc/bus/input/devices \
    | grep -E -B 5 -A 3 "H\: Handlers=(js[0-9] event[0-9]+)|(event[0-9]+ js[0-9])" \
    | grep -Ew -B 8 "B: KEY\=[0-9a-f ]+" > /tmp/input_devices

# Determine how many gamepads/players are connected
  JOYS=$(cat /proc/bus/input/devices | grep -E -B 5 -A 3 "H\: Handlers=(js[0-9] event[0-9]+)|(event[0-9]+ js[0-9])" | grep -Ew -B 8 "B: KEY\=[0-9a-f ]+" | grep Handlers | cut -d' ' -f3)

  declare -a PLAYER_CFGS=()

  for dev in $(echo $JOYS); do
    local JSI=$dev
    local DETAILS=$(cat /tmp/input_devices \
        | grep -E "H\: Handlers=(${JSI} event[0-9]+)|(event[0-9]+ ${JSI})" -B 5)
    
    local PROC_GUID=$(echo "${DETAILS}" | grep I: | sed "s|I:\ Bus=||" | sed "s|\ Vendor=||" | sed "s|\ Product=||" | sed "s|\ Version=||")
    local DEVICE_GUID=$(jc_generate_guid ${PROC_GUID})
    [[ -z "${DEVICE_GUID}" ]] && continue

    local GC_CONFIG=$(cat "$GCDB" | grep "$DEVICE_GUID" | grep "platform:Linux" | head -1)
    echo "GC_CONFIG=$GC_CONFIG"
    [[ -z $GC_CONFIG ]] && continue

    local JOY_NAME=$(echo "${DETAILS}" | grep -E "^N\: Name.*[\= ]?.*$" | cut -d "=" -f 2 | tr -d '"')
    [[ -z "$JOY_NAME" ]] && continue

    # Add the joy config to array if guid and joyname set.
    if [[ ! -z "${DEVICE_GUID}" && ! -z "$JOY_NAME" ]]; then
      local PLAYER_CFG="${JSI} ${DEVICE_GUID} ${JOY_NAME}"
      PLAYER_CFGS[$((PLAYER-1))]="${PLAYER_CFG}"
      ((PLAYER++))
    fi
  done

  rm /tmp/input_devices

  if [[ -z "${PLAYER_CFGS[@]}" ]]; then
    echo "NO GAME CONTROLLERS WERE DETECTED."
    return
  fi

  local cfgCount=${#PLAYER_CFGS[@]}
  MANUAL_CONFIG=$(cat "/tmp/controllerconfig.txt")  
  if [[ ! -z "${MANUAL_CONFIG}" && ! -f "/storage/.config/EE_CONTROLLER_OVERIDE_OFF" ]]; then
    declare -a GUID_ORDER=($MANUAL_CONFIG)

    local index=0
    local row=0
    local i=0
    for i in ${GUID_ORDER[@]}; do
      row=$(( index % 4 ))
      [[ $row != 3 ]] && unset GUID_ORDER[$index]
      (( index++ ))
    done
  
    local si=0
    for tGUID in ${GUID_ORDER[@]}; do
      for (( c=$si; c<$cfgCount; c++ )); do
        cfgGUID=$(echo "${PLAYER_CFGS[$c]}" | cut -d' ' -f2)
        if [[ $tGUID == $cfgGUID ]]; then
          local tmp="${PLAYER_CFGS[$c]}"
          PLAYER_CFGS[$c]="${PLAYER_CFGS[$si]}"
          PLAYER_CFGS[$si]="$tmp"
          (( si++ ))
          break
        fi
      done
    done
  fi

  local PLAYER_CFG=
  for p in {1..4}; do
    PLAYER_CFG="${PLAYER_CFGS[$(( p-1 ))]}"
    local INFO=
    local NAME=
    if [[ $p -le $cfgCount ]]; then
      echo "PLAYER_CFG=${PLAYER_CFG}"
      INFO=$(echo "$PLAYER_CFG" | cut -d' ' -f1-2)
      NAME=$(echo "$PLAYER_CFG" | cut -d' ' -f3-)
      echo "${p} ${INFO} \"${NAME}\""
      set_pad ${p} ${INFO} "${NAME}"
    fi
    clean_pad ${p} ${INFO} "${NAME}"
  done
}

jc_generate_guid() {
  local GUID_STRING="$1"

  local p1=${GUID_STRING::4}
  local p2=${GUID_STRING:4:4}
  local p3=${GUID_STRING:8:4}
  local p4=${GUID_STRING:12:4}

  local v=$(echo ${p1:6:2}${p1:4:2}${p1:2:2}${p1:0:2})0000
        v+=$(echo ${p2:6:2}${p2:4:2}${p2:2:2}${p2:0:2})0000
        v+=$(echo ${p3:6:2}${p3:4:2}${p3:2:2}${p3:0:2})0000
        v+=$(echo ${p4:6:2}${p4:4:2}${p4:2:2}${p4:0:2})0000

  echo "$v"
}
