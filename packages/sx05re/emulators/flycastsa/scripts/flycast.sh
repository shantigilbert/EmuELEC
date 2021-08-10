#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

mkdir -p "/storage/.local/share/"

if [ ! -L "/storage/.local/share/flycast" ]; then
    mkdir -p "/storage/roms/bios/dc"
    rm -rf "/storage/.local/share/flycast"
    ln -sf "/storage/roms/bios/dc" "/storage/.local/share/flycast"
fi

flycast "${1}"
