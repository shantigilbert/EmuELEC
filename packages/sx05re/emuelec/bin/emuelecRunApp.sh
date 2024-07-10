#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2024-present Langerz82 (https://github.com/Langerz82)

# Source predefined functions and variables
. /etc/profile

arguments="$@"

# Extract the platform name from the arguments
PLATFORM="${arguments##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found

ROMNAME="${1}"
BASEROMNAME=${ROMNAME##*/}
GAMEFOLDER="${ROMNAME//${BASEROMNAME}}"

emuelec-utils init_app_video "${PLATFORM}" "${ROMNAME}"

RUN_CMD="$1"
shift

"$RUN_CMD" "$@"

emuelec-utils end_app_video
