#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Joshua L. (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

ACTION=$1
PLATFORM=$2
ROMNAME="$3"

RA_CONFIG="/storage/.config/retroarch/retroarch.cfg"
RA_RBASE="ra-drive:/retroarch-saves"
RCLONE_ARGS=" --verbose --transfers 4 --checkers 4 --contimeout 30s --timeout 120s --retries 3 --low-level-retries 10 --stats 1s"
RC_LOG="/emuelec/logs/rclone.log"
DEBUG=1

[[ ! -f "${RC_LOG}" ]] && touch "${RC_LOG}"

[[ $DEBUG == 1 ]] && echo "ROMNAME=${ROMNAME}"
BASENAME="${ROMNAME##*/}"
[[ $DEBUG == 1 ]] && echo "BASENAME=${BASENAME}"
ROMSTEM="${BASENAME%.*}"
[[ $DEBUG == 1 ]] && echo "ROMSTEM=${ROMSTEM}"

if [[ "$ACTION" == "get" || "$ACTION" == "set" ]]; then
  SRM_CONTENT=$(cat "${RA_CONFIG}" | grep savefiles_in_content_dir | cut -d'"' -f2)
  if [[ "$SRM_CONTENT" == "true" ]]; then
    RA_LSAVES="${ROMNAME%/*}"
  else
    SAVEFILE_PATH=$(cat "${RA_CONFIG}" | grep savefile_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}$//g" | sed -e "s/^~/\/storage/g" )    
    [[ $DEBUG == 1 ]] && echo "SAVEFILE_PATH=${SAVEFILE_PATH}"
    RA_LSAVES="${SAVEFILE_PATH}"
  fi
  [[ $DEBUG == 1 ]] && echo "RA_LSAVES=${RA_LSAVES}"
  SAVESTATE_PATH=$(cat "${RA_CONFIG}" | grep savestate_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}$//g" | sed -e "s/^~/\/storage/g" )
  [[ $DEBUG == 1 ]] && echo "SAVESTATE_PATH=${SAVESTATE_PATH}"

  RA_LSTATES="${SAVESTATE_PATH}/${PLATFORM}/"
  [[ $DEBUG == 1 ]] && echo "RA_LSTATES=\"${RA_LSTATES}\""

  RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}
  [[ $DEBUG == 1 ]] && echo "RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}"
  
  RA_RSTATES=${RA_RBASE}/states/${PLATFORM}
  [[ $DEBUG == 1 ]] && echo "RA_RSTATES=${RA_RBASE}/states/${PLATFORM}"
  
fi

RUNSYNC=$(get_ee_setting rclone_save "$PLATFORM"  "${ROMNAME}")
if [[ "${RUNSYNC}" == "1" ]]; then
  if [[ "$ACTION" == "get" ]]; then
    rclone copy ${RCLONE_ARGS} "${RA_RSAVES}/" --include "/${ROMSTEM}.srm" "${RA_LSAVES}"
    rclone copy ${RCLONE_ARGS} "${RA_RSTATES}/" --include "/${ROMSTEM}.state*" "${RA_LSTATES}"
  fi
  if [[ "$ACTION" == "set" ]]; then
    SRM="${RA_LSAVES}/${ROMSTEM}.srm"
    [[ -f "$SRM" ]] && rclone copy ${RCLONE_ARGS} "${SRM}" ${RA_RSAVES}
    SF_FILES="${RA_LSTATES}${ROMSTEM}.state"
    SF_OK=$(ls "$SF_FILES"*)
    [[ ! -z "$SF_OK" ]] && rclone copy ${RCLONE_ARGS} "${RA_LSTATES}" --include "/${ROMSTEM}.state*" ${RA_RSTATES}
  fi
fi
