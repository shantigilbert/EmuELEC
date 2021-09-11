#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

CFG_FILE="$1"
CFG_NAME="$2"

CFG_PAT="^${CFG_NAME}='(.*)'"
CFG_TMP=$(cat "${CFG_FILE}" | grep -oE "${CFG_PAT}")
CFG_TMP="${CFG_TMP##*=}"
if [ ! -z "$CFG_TMP" ]; then
  # Strips the config value of single and double qoutes.    
  CFG_VAL=$(echo $CFG_TMP | sed -e "s/^['\"]//" -e "s/['\"]$//")
  echo $CFG_VAL
fi
