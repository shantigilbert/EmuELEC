#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)



if [ ! -d "/storage/roms/bios/mame/hash" ]; then
    mkdir /storage/roms/bios/mame/hash
    cp -rf "/usr/config/emuelec/configs/multiemu/hash/"fm* "/storage/roms/bios/mame/hash"
fi

if [ ! -d "/storage/roms/bios/mame/ini" ]; then
    mkdir /storage/roms/bios/mame/ini
    cp -rf "/usr/config/emuelec/configs/multiemu/ini/"fm* "/storage/roms/bios/mame/ini"
fi

