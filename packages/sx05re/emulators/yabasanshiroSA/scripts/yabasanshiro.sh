#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

mkdir -p "/storage/roms/saturn/yabasanshiro/"

if [ ! -e "/storage/roms/saturn/yabasanshiro/input.cfg" ]; then
    cp -rf "/emuelec/configs/yabasanshiro/input.cfg" "/storage/roms/saturn/yabasanshiro/input.cfg"
fi


if [ -e "/storage/roms/bios/saturn_bios.bin" ]; then

    # We use { } to avoid SIGUSR signal showing text and messing up with the error handling
    { yabasanshiro -r 2 -i "${1}" -b "/storage/roms/bios/saturn_bios.bin"; } > /emuelec/logs/emuelec.log 2>&1

# BIOS is not mandatory 
else
    { yabasanshiro -r 2 -i "${1}"; } > /emuelec/logs/emuelec.log 2>&1
fi
