#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present NeoTheFox (https://github.com/NeoTheFox)
# 2024-present DiegroSan

mkdir -p /storage/roms/zerotier_networks
mkdir -p /storage/.config/zerotier/networks.d
ln -s /storage/roms/zerotier_networks/* /storage/.config/zerotier/networks.d/

NETWORKS_FILE=/storage/.config/zerotier
[[ -f ${NETWORKS_FILE} ]] || (echo "No networks defined" && exit 0)

shopt -s expand_aliases
alias zerotier-cli="zerotier-cli -D/storage/.config/zerotier/"

zerotier-cli listnetworks | cut -d' ' -f 3 | while read net
do
    [[ "$net" == "<nwid>" ]] && continue
    echo "Checking $net"
    grep -Fxq $net ${NETWORKS_FILE} || (echo "Leaving $net (not in the file)" && zerotier-cli leave $net)
done

cat ${NETWORKS_FILE} | while read net
do
    echo "Joining $net"
    zerotier-cli join $net
done

# Just in case the last join fails...
exit 0
