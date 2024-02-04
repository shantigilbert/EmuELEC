#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Place any scripts you need to run at boot on this file

case "${1}" in
"before")

# Any commands that you want to run before the frontend begins should go here

# example BT config, use only as a last resort
# Bluetooth, Make sure you change your BT MAC address, you need to do this by SSH the first time
# by running 

# hcitool scan
# bluetoothctl pair yourmac
# bluetoothctl trust yourmac 

# If you want to use bluetooth, uncomment every line after this one 

# BTMAC="E4:17:D8:8B:F1:80"
# (
# echo "agent on" | bluetoothctl
# echo "default-agent" | bluetoothctl
# echo "power on" | bluetoothctl
# echo "discoverable on" | bluetoothctl
# echo "pairable on" | bluetoothctl
# echo "scan on" | bluetoothctl
# echo "trust ${BTMAC}" | bluetoothctl
# echo "connect ${BTMAC}" | bluetoothctl
# )&

	exit 0
	;;
*)
# Any commands that you want to run after the frontend has started goes here

    exit 0
	;;
esac
## nothing was called so exit
exit 0
