#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# OpenBOR only works with Pak files, if you have an extracted game you will need to create a pak first.

/usr/bin/setres.sh 16

pakname=$(basename "$1")
pakname="${pakname%.*}"

CONFIGDIR="/emuelec/configs/openbor"
PAKS="${CONFIGDIR}/Paks"
SAVES="${CONFIGDIR}/Saves"

# Make sure the folders exists
	mkdir -p "${PAKS}"
	mkdir -p "${SAVES}"

# make a symlink to the pak
    ln -sf "$1" "${PAKS}"

# only create symlink to master.cfg if its the first time running the pak
	if [ ! -f "${SAVES}/${pakname}.cfg" ]; then
		ln -sf "${CONFIGDIR}/master.cfg" "${SAVES}/${pakname}.cfg"
	fi

# We start the fake keyboard
gptokeyb openbor &

# Run OpenBOR in the config folder
    cd "${CONFIGDIR}"
	SDL_AUDIODRIVER=alsa OpenBOR

# Clear PAKS folder to avoid getting the launcher on nex run
rm -rf ${PAKS}/*

/usr/bin/setres.sh
killall gptokeyb &
