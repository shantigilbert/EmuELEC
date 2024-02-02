#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

DATA="https://github.com/mmatyas/supermariowar-data/archive/master.zip"
DATAFOLDER="/storage/roms/ports/smw/data"
CONFIGFOLDER="/emuelec/configs/smw"

mkdir -p "${DATAFOLDER}"
mkdir -p "${CONFIGFOLDER}"
cd "${DATAFOLDER}"

if [ ! -f "${CONFIGFOLDER}/nofakekeyb" ]; then 
    gptokeyb &
    touch "${CONFIGFOLDER}/nofakekeyb"
fi

if [ ! -e "${DATAFOLDER}/worlds/Big JM_Mixed River.txt" ]; then
    text_viewer -y -w -f 24 -t "Data does not exists!" -m "It seems this is the first time you are launching Super Mario War or the data folder does not exists\n\nData is about 30 MB total, and you need to be connected to the internet\n\nKeep in mind the first time you run the game a fake keyboard is set, you need to set up your controller/gamepad and restart the game.\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
            unzip "master.zip" > /dev/tty0
            mv supermariowar-data-master/* "${DATAFOLDER}" > /dev/tty0
            rm -rf "supermariowar-data-master" > /dev/tty0 2>&1
            rm "master.zip" > /dev/tty0 2>&1
            rm "imgui.ini" > /dev/tty0 2>&1
            ee_console disable
            cd "${DATAFOLDER}/.."
            smw --datadir "${DATAFOLDER}" > /emuelec/logs/emuelec.log 2>&1
        else
            exit 0
        fi
else
    smw --datadir "${DATAFOLDER}" > /emuelec/logs/emuelec.log 2>&1
fi

killall gptokeyb &
