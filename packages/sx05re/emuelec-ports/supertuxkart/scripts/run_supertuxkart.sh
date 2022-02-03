#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

ASSETS="https://github.com/supertuxkart/stk-assets-mobile/releases/download/1.3/stk-assets.zip"
DATA="https://github.com/supertuxkart/stk-code/archive/refs/heads/master.zip"
DATAFOLDER="/storage/roms/ports/supertuxkart"

mkdir -p "${DATAFOLDER}"
cd "${DATAFOLDER}"

if [ "$EE_DEVICE" == "Amlogic-ng" ]; then 
fbfix
fi

if [ ! -e "${DATAFOLDER}/data/supertuxkart.git" ]; then
    text_viewer -y -w -f 24 -t "Data does not exists!" -m "It seems this is the first time you are launching Super Tux Kart or the data folder does not exists\n\nData is about 250 MB total, and you need to be connected to the internet\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${DATA}" -q --show-progress > /dev/tty0 2>&1
            unzip "master.zip" > /dev/tty0
            rm -rf "${DATAFOLDER}/data"
            mv "stk-code-master/data" "${DATAFOLDER}" > /dev/tty0
            rm -rf "stk-code-master"
            wget "${ASSETS}" -q --show-progress > /dev/tty0 2>&1
            unzip "stk-assets.zip" -d data > /dev/tty0
            rm "stk-assets.zip"
            rm "master.zip"
            ee_console disable
            mkdir -p /storage/.config/supertuxkart/config-0.10

cat > /storage/.config/supertuxkart/config-0.10/players.xml << EOF
<?xml version="1.0"?>
<players version="1" >
    <player name="EmuELEC" guest="false" use-frequency="0"
            icon-filename="1.png"
            unique-id="1" saved-session="false"
            saved-user="0" saved-token=""
            last-online-name="" last-was-online="false"
            remember-password="false"
            default-kart-color="0">
    </player>
</players>            
EOF
            SUPERTUXKART_DATADIR="${DATAFOLDER}" supertuxkart
        else
            exit 0
        fi
else
    SUPERTUXKART_DATADIR="${DATAFOLDER}" supertuxkart
fi

