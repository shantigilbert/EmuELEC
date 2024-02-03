#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Joshua L. (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

ACTION=${1}
PLATFORM=${2}
ROMNAME="${3}"

RA_CONFIG="/storage/.config/retroarch/retroarch.cfg"
RA_RBASE="emuelec:/retroarch-saves"
RC_LOG="/emuelec/logs/rclone.log"
RCLONE_ARGS=" --log-file=${RC_LOG} --log-level DEBUG --transfers 2 --checkers 2 --contimeout 30s --timeout 120s --retries 3 --low-level-retries 10 --stats 1s"

DEBUG=1

rm "${RC_LOG}"
touch "${RC_LOG}"

[[ ! -f "${ROMNAME}" ]] && exit 1

[[ ${DEBUG} == 1 ]] && echo "ROMNAME=${ROMNAME}" >> "${RC_LOG}"
BASENAME="${ROMNAME##*/}"
[[ ${DEBUG} == 1 ]] && echo "BASENAME=${BASENAME}" >> "${RC_LOG}"
ROMSTEM="${BASENAME%.*}"
[[ ${DEBUG} == 1 ]] && echo "ROMSTEM=${ROMSTEM}" >> "${RC_LOG}"

if [[ "${ACTION}" == "get" || "${ACTION}" == "set" ]]; then  
  SRM_CONTENT=$(cat "${RA_CONFIG}" | grep savefiles_in_content_dir | cut -d'"' -f2)
  if [[ "${SRM_CONTENT}" == "true" ]]; then
    RA_LSAVES="${ROMNAME%/*}"
  else
    SAVEFILE_PATH=$(cat "${RA_CONFIG}" | grep savefile_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}${/}/g" | sed -e "s/^~/\/storage/g" )    
    [[ ${DEBUG} == 1 ]] && echo "SAVEFILE_PATH=${SAVEFILE_PATH}" >> "${RC_LOG}"
    RA_LSAVES="${SAVEFILE_PATH}"
  fi
  [[ ${DEBUG} == 1 ]] && echo "RA_LSAVES=${RA_LSAVES}" >> "${RC_LOG}"
  SAVESTATE_PATH=$(cat "${RA_CONFIG}" | grep savestate_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}${/}/g" | sed -e "s/^~/\/storage/g" )
  [[ ${DEBUG} == 1 ]] && echo "SAVESTATE_PATH=${SAVESTATE_PATH}" >> "${RC_LOG}"

  RA_LSTATES="${SAVESTATE_PATH}/${PLATFORM}/"
  [[ ${DEBUG} == 1 ]] && echo "RA_LSTATES=\"${RA_LSTATES}\"" >> "${RC_LOG}"

  RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}
  [[ ${DEBUG} == 1 ]] && echo "RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}" >> "${RC_LOG}"
  
  RA_RSTATES=${RA_RBASE}/states/${PLATFORM}
  [[ ${DEBUG} == 1 ]] && echo "RA_RSTATES=${RA_RBASE}/states/${PLATFORM}" >> "${RC_LOG}"
  
fi

RUNSYNC=$(get_ee_setting cloudsave "${PLATFORM}"  "${ROMNAME}")
if [[ "${RUNSYNC}" == "1" ]]; then
  rclone mkdir "${RA_RBASE}"
  wait
  if [[ "${ACTION}" == "get" ]]; then
    rclone copy ${RCLONE_ARGS} "${RA_RSAVES}/" --include "/${ROMSTEM}.srm" "${RA_LSAVES}" &
    rclone copy ${RCLONE_ARGS} "${RA_RSTATES}/" --include "/${ROMSTEM}.state*" "${RA_LSTATES}" &
  fi
  if [[ "${ACTION}" == "set" ]]; then
    
    SRM="${RA_LSAVES}/${ROMSTEM}.srm"
    if [[ -f "${SRM}" ]]; then
      rclone copy ${RCLONE_ARGS} "${SRM}" "${RA_RSAVES}" &
      fc -ln -1 >> "${RC_LOG}"
    fi
    SF_FILES="${RA_LSTATES}${ROMSTEM}.state"
    SF_OK=$(ls "${SF_FILES}"*)
    if [[ ! -z "${SF_OK}" ]]; then
      rclone copy ${RCLONE_ARGS} "${RA_LSTATES}" --include "/${ROMSTEM}.state*" "${RA_RSTATES}" &
      fc -ln -1 >> "${RC_LOG}"
    fi
  fi
  wait
  LOG_ERROR_TEXT=$(cat ${RC_LOG} \
    | grep -e "ERROR :" -e "Failed to create file system" \
    | grep -v "directory not found")
  [[ ! -z "${LOG_ERROR_TEXT}" ]] || [[ ! -f "${RC_LOG}" ]] && exit 1
  exit 0  
fi
