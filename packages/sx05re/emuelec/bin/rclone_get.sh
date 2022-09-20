#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Joshua L. (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

PLATFORM=$1
ROMNAME="$2"

RA_CONFIG="/storage/.config/retroarch/retroarch.cfg"
RUNSYNC=$(get_ee_setting rclone_save)
if [[ "${RUNSYNC}" == "1" ]]; then
  SRM_CONTENT=$(cat "${RA_CONFIG}" | grep savefiles_in_content_dir | cut -d'"' -f2)
  if [[ "$SRM_CONTENT" == "true" ]]; then
    RA_LSAVES="${ROMNAME%/*}"
  else
    SAVEFILE_PATH=$(cat "${RA_CONFIG}" | grep savefile_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}$//g" | sed -e "s/^~/\/storage/g" )    
    echo "SAVEFILE_PATH=${SAVEFILE_PATH}"
    RA_LSAVES="${SAVEFILE_PATH}"
  fi
  echo "RA_LSAVES=${RA_LSAVES}"
  SAVESTATE_PATH=$(cat "${RA_CONFIG}" | grep savestate_directory | cut -d'"' -f2 | sed -e "s/\/${PLATFORM}$//g" | sed -e "s/^~/\/storage/g" )
  echo "SAVESTATE_PATH=${SAVESTATE_PATH}"

  echo "ROMNAME=${ROMNAME}"
  BASENAME="${ROMNAME##*/}"
  echo "BASENAME=${BASENAME}"
  ROMSTEM="${BASENAME%.*}"
  echo "ROMSTEM=${ROMSTEM}"
	RA_RBASE="ra-drive:/retroarch-saves"

  echo "RA_LSAVES=\"${RA_LSAVES}\""
	RA_LSTATES="${SAVESTATE_PATH}/${PLATFORM}"
  echo "RA_LSTATES=\"${RA_LSTATES}\""
	
	RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}
  #echo "RA_RSAVES=${RA_RBASE}/saves/${PLATFORM}"
	RA_RSTATES=${RA_RBASE}/states/${PLATFORM}
  #echo "RA_RSTATES=${RA_RBASE}/states/${PLATFORM}"
	RCLONE_ARGS=" --update --verbose --transfers 4 --checkers 4 --contimeout 30s --timeout 120s --retries 3 --low-level-retries 10 --stats 1s"
  rclone copy ${RCLONE_ARGS} "${RA_RSAVES}/${ROMSTEM}.srm" "${RA_LSAVES}"
  rclone copy ${RCLONE_ARGS} "${RA_RSTATES}/" --include "/${ROMSTEM}.state*" "${RA_LSTATES}"
fi
