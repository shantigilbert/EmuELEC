#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

PORT="VVVVVV"

# init_port binary audio(alsa. pulseaudio, default)
init_port ${PORT} alsa

# VVVVVV will complain about a missing gamecontrollerdb.txt unless we switch to this folder first
cd /storage/.config/SDL-GameControllerDB/
${PORT}

end_port
