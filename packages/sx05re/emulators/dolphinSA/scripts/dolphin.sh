#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

. /etc/profile

CONFIG_DIR="/storage/.local/share/dolphin-emu"

if [ -d "${CONFIG_DIR}" ]; then
	rm -rf "$CONFIG_DIR"
fi

mkdir -p /storage/.local/share/

if [ ! -L "$CONFIG_DIR" ]; then
 ln -sf "/emuelec/configs/dolphin-emu" "${CONFIG_DIR}"
fi

/usr/bin/set_dolphin_joy.sh

XDG_CONFIG_HOME=/emuelec/configs XDG_DATA_HOME=/storage/roms/dolphin /usr/bin/dolphin-emu-nogui -p fbdev "${1}"
