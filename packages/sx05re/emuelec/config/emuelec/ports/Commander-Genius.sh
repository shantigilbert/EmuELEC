#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

PORT="CGeniusExe"

# init_port binary audio(alsa. pulseaudio, default)
init_port ${PORT} alsa

[[ ! -L "/storage/.CommanderGenius" ]] && ln -sf /emuelec/configs/CommanderGenius /storage/.CommanderGenius
/emuelec/bin/${PORT}

end_port
