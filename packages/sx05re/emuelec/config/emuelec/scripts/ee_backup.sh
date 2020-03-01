#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Usage:
# ee_backup.sh b -- backup configurations 
# ee_backup.sh r -- restore configurations 

BACKUPFILE="/storage/downloads/ee_backup_config.zip"
mkdir -p "/storage/downloads/"

case "$1" in
"b")
[ -f "${BACKUPFILE}" ] && rm "${BACKUPFILE}"
[ -z "$2" ] && systemctl stop emustation
	zip ${BACKUPFILE} /storage/.local/share/VVVVVV/* \
	                  /storage/.cache/bluetooth/* \
	                  /storage/.cache/connman* \
	                  /emuelec/configs/emuoptions.conf \
	                  /emuelec/configs/emuelec.conf \
	                  /storage/.emulationstation/es_*.cfg \
	                  /tmp/joypads/* \
	                  /storage/.config/retroarch/*.cfg \
	                  /storage/.config/ppsspp/* \
	                  /storage/.config/retroarch/config/*
sleep 3
[ -z "$2" ] && systemctl start emustation
;;
"r")
systemctl stop emustation
unzip -o ${BACKUPFILE} -d /
sleep 3
systemctl start emustation
;;
esac





