#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

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
  cat /proc/bus/input/devices > /tmp/input_devices 

# Determine how many gamepads/players are connected
  JOYS=$(ls -A1 /dev/input/js*| sort )
  
  declare -a PLAYER_CFGS=()
  
  for dev in $(echo $JOYS); do
   
    JOY_INDEX=$(basename $dev)
   
    PROC_GUID=$(cat /tmp/input_devices | grep ${JOY_INDEX} -B 5 | grep I: | sed "s|I:\ Bus=||" | sed "s|\ Vendor=||" | sed "s|\ Product=||" | sed "s|\ Version=||")
    local DEVICE_GUID=$(jc_generate_guid ${PROC_GUID})

    [[ -z "${DEVICE_GUID}" ]] && continue

    local JOY_NAME=$(jc_get_device_name "${DEVICE_GUID}")
    local JSI=$(jc_get_device_name "${DEVICE_GUID}" "true")

    # Add the joy config to array if guid and joyname set.
    if [[ ! -z "${DEVICE_GUID}" && ! -z "$JOY_NAME" ]]; then
      local PLAYER_CFG="${PLAYER} ${JSI} ${DEVICE_GUID} ${JOY_NAME}"

      PLAYER_CFGS+=("${PLAYER_CFG}")
      ((PLAYER++))
    fi
  done

  rm /tmp/input_devices

  if [[ -z "${PLAYER_CFGS[@]}" ]]; then
    echo "NO GAME CONTROLLERS WERE DETECTED."
    return
  fi

  SDL_CHECK=$(get_ee_setting ${EMULATOR}_joy_sdl_check)

  if [[ "${SDL_CHECK}" == "1" ]]; then
    jc_get_sdl_order

    declare -i PLAYER=1
    for SDL_NAME in "${SDL_GC_ORDER[@]}"; do
      declare -i index=0
      for PLAYER_CFG in "${PLAYER_CFGS[@]}"; do
        local JOY_NAME=$(echo $PLAYER_CFG | cut -d' ' -f4-)
        if [[ "$SDL_NAME" == "${JOY_NAME}" ]]; then
          PLAYER_CFG="${PLAYER} ${PLAYER_CFG:2}"
          jc_setup_gamecontroller "${PLAYER_CFG}"
          unset 'PLAYER_CFGS[index]'
        fi
        (( index++ ))
      done
      (( PLAYER++ ))
    done
  else
    for PLAYER_CFG in "${PLAYER_CFGS[@]}"; do
      jc_setup_gamecontroller "${PLAYER_CFG}"
    done
  fi
}

jc_setup_gamecontroller() {
  local PLAYER_CFG="$1"
  local JOY_INFO=$(echo "$1" | cut -d' ' -f1-3)
  local JOY_NAME=$(echo "$1" | cut -d' ' -f4-)

  [[ -z "${CACHE_FILE}" ]] && return

  local USE_CACHE=$(get_ee_setting ${EMULATOR}_joy_cache)
  if [[ "${USE_CACHE}" == "1" ]]; then
    local CACHE=""
    [[ -f "${CACHE_FILE}" ]] && CACHE=$(cat $CACHE_FILE | grep "$PLAYER_CFG")

    if [[ ! -z "$CACHE" || "$CACHE" == "${PLAYER_CFG}" ]]; then
      return
    fi
  fi

  clean_pad ${PLAYER_CFG}
  echo "CONTROLLER: ${PLAYER_CFG}"
  set_pad ${JOY_INFO} "${JOY_NAME}"

  [[ -f "${CACHE_FILE}" ]] && sed -i "/^${PLAYER_CFG:0:1} js.*$/d" ${CACHE_FILE}
  echo "${PLAYER_CFG}" >> "${CACHE_FILE}"
}

declare SDL_GC_ORDER=()

jc_get_sdl_order() {
  echo "Performing sdljoytest"

  SDL_OUT="/tmp/sdljoytest.txt"

  sdljoytest > "${SDL_OUT}" &
  SDL_PID=$!
  sleep 2
  kill -9 $SDL_PID
  wait $SDL_PID 2>/dev/null

  while read line; do
    local REC=$(echo $line | grep "SDL_JOYDEVICEADDED")
    if [[ ! -z "$REC" ]]; then
      local JOY_NAME=$(echo $REC | cut -d ' ' -f4- )
      SDL_GC_ORDER+=("${JOY_NAME:1:-16}")
    fi
  done < "${SDL_OUT}"

  rm "${SDL_OUT}"
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

jc_get_device_name() {
  local GUID="${1}"
  local RETURN_JSI="${2}"

  v=${DEVICE_GUID:0:8}
  local p1=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Bus, generally not needed
  local v=${GUID:8:8}
  local p2=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Vendor
  v=${GUID:16:8}
  local p3=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Product
  v=${GUID:24:8}
  local p4=$(echo ${v:6:2}${v:4:2}${v:2:2}${v:0:2}) # Version

  local vendor=$(echo ${p2:4})
  local product=$(echo ${p3:4})
  local version=$(echo ${p4:4})

  local I_REGEX="^I\: .* Vendor\=${vendor} Product\=${product} Version\=${version}$"
  local EE_DEV=$(cat /proc/bus/input/devices | grep -Ew -A 8 "$I_REGEX" | grep -Ew -B 8 "B: KEY\=[0-9a-f ]+")
  local JSI=$(echo -e "${EE_DEV}" | grep "H: Handlers" | sed -E 's/.*H: Handlers=.*(js[0-9]).*/\1/')
  
  if [[ ! -z "${EE_DEV}" ]]; then
    local JOY_NAME=$(echo "${EE_DEV}" | grep -E "^N\: Name.*[\= ]?.*$" \
      | cut -d "=" -f 2 | tr -d '"')
    [ "${RETURN_JSI}" == "true" ] && echo ${JSI} || echo "${JOY_NAME}"
    return
  fi
  echo "0"
}
