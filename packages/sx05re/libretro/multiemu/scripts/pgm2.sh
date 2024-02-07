#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

if [ ! -f "/storage/roms/bios/mame/ini/mame.ini" ]; then
    if [ ! -d "/storage/roms/bios/mame/ini" ]; then
    mkdir /storage/roms/bios/mame/ini
    fi
    cp -rf "/usr/config/emuelec/configs/multiemu/ini/"mame* "/storage/roms/bios/mame/ini"
fi
