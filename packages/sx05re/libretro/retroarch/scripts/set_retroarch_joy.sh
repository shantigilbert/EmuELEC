#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

# Configure ADVMAME players based on ES settings
CONFIG_DIR="/storage/.config/retroarch"
CONFIG=${CONFIG_DIR}/retroarch.cfg

source joy_common.sh "retroarch"

declare -A GC_RA_VALUES=(
[h0.1]="12"
[h0.4]="13"
[h0.8]="14"
[h0.2]="15"
[b0]="0"
[b1]="1"
[b2]="2"
[b3]="3"
[b4]="4"
[b5]="5"
[b6]="6"
[b7]="7"
[b8]="8"
[b9]="9"
[b10]="10"
[b11]="11"
[b12]="12"
[b13]="13"
[b14]="14"
[b15]="15"
[b16]="16"
[a0]="0"
[a1]="1"
[a2]="2"
[a3]="3"
[a4]="4"
[a5]="5"
)

# Cleans all the inputs for the gamepad with name ${GAMEPAD} and player ${1}
clean_pad() {
	return
}

# Sets pad depending on parameters.
# ${1} = Player Number
# ${2} = js[0-7]
# ${3} = Device GUID
# ${4} = Device Name

set_pad() {
	local P_INDEX=${1}
  local DEVICE_GUID=${3}
  local JOY_NAME="${4}"

	[[ "${P_INDEX}" == "1" ]] && return

	declare -A GC_RA_BUTTONS=(
	  [dpleft]="input_player${P_INDEX}_left_btn"
	  [dpright]="input_player${P_INDEX}_right_btn"
	  [dpup]="input_player${P_INDEX}_up_btn"
	  [dpdown]="input_player${P_INDEX}_down_btn"
	  [x]="input_player${P_INDEX}_x_btn"
	  [y]="input_player${P_INDEX}_y_btn"
	  [a]="input_player${P_INDEX}_a_btn"
	  [b]="input_player${P_INDEX}_b_btn"
		[leftshoulder]="input_player${P_INDEX}_l_btn"
	  [rightshoulder]="input_player${P_INDEX}_r_btn"
	  [lefttrigger]="input_player${P_INDEX}_l2_btn"
	  [righttrigger]="input_player${P_INDEX}_r2_btn"
    [back]="input_player${P_INDEX}_select_btn"
		[start]="input_player${P_INDEX}_start_btn"
	)

	declare -A GC_RA_AXIS=(
	  [lefttrigger,a]="input_player${P_INDEX}_l2_axis"
	  [righttrigger,a]="input_player${P_INDEX}_r2_axis"
	  ["leftx,0"]="input_player${P_INDEX}_l_x_minus_axis"
	  ["leftx,1"]="input_player${P_INDEX}_l_x_plus_axis"
	  ["lefty,0"]="input_player${P_INDEX}_l_y_minus_axis"
	  ["lefty,1"]="input_player${P_INDEX}_l_y_plus_axis"
	  ["rightx,0"]="input_player${P_INDEX}_r_x_minus_axis"
	  ["rightx,1"]="input_player${P_INDEX}_r_x_plus_axis"
	  ["righty,0"]="input_player${P_INDEX}_r_y_minus_axis"
	  ["righty,1"]="input_player${P_INDEX}_r_y_plus_axis"
	)

  echo "DEVICE_GUID=${DEVICE_GUID}"

  local GC_CONFIG=$(cat "${GCDB}" | grep "${DEVICE_GUID}" | grep "platform:Linux" | head -1)
  echo "GC_CONFIG=${GC_CONFIG}"
  [[ -z ${GC_CONFIG} ]] && return

  local GC_MAP=$(echo ${GC_CONFIG} | cut -d',' -f3-)

  set -f
  local GC_ARRAY=(${GC_MAP//,/ })
  for index in "${!GC_ARRAY[@]}"
  do
      local REC=${GC_ARRAY[${index}]}
      local BUTTON_INDEX=$(echo ${REC} | cut -d ":" -f 1)
      local TVAL=$(echo ${REC} | cut -d ":" -f 2)
      local BUTTON_VAL=${TVAL:1}
      local GC_INDEX="${GC_RA_BUTTONS[${BUTTON_INDEX}]}"
      local BTN_TYPE=${TVAL:0:1}
      local VAL="${GC_RA_VALUES[${TVAL}]}"

      # CREATE BUTTON MAPS (inlcuding hats).
      if [[ ! -z "${GC_INDEX}" ]]; then
        if [[ "${BTN_TYPE}" == "b"  || "${BTN_TYPE}" == "h" ]]; then
					sed -i "s/${GC_INDEX}.*/${GC_INDEX} = \"${VAL}\"/" ${CONFIG}
        fi
        if [[ "${BTN_TYPE}" == "a" ]]; then
					sed -i "s/${GC_INDEX}.*/${GC_INDEX} = \"+${VAL}\"/" ${CONFIG}
        fi
      fi

      # Create Axis Maps
      case ${BUTTON_INDEX} in
        lefttrigger|righttrigger)
          if [[ "${BTN_TYPE}" == "a" ]]; then
            VAL=${BUTTON_VAL}
            GC_INDEX="${GC_RA_AXIS[${BUTTON_INDEX},a]}"
						sed -i "s/${GC_INDEX}.*/${GC_INDEX} = \"+${VAL}\"/" ${CONFIG}
          fi
          ;;
        leftx|lefty|rightx|righty)
					VAL=${BUTTON_VAL}
          GC_INDEX="${GC_RA_AXIS[${BUTTON_INDEX},0]}"
					sed -i "s/${GC_INDEX}.*/${GC_INDEX} = \"-${VAL}\"/" ${CONFIG}
          GC_INDEX="${GC_RA_STICKS[${BUTTON_INDEX},1]}"
					sed -i "s/${GC_INDEX}.*/${GC_INDEX} = \"+${VAL}\"/" ${CONFIG}
          ;;
      esac
  done

}

cp ${CONFIG} ${CONFIG}.jc.bak

jc_get_players
