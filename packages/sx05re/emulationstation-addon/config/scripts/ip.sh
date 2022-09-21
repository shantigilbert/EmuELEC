#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

  IP="$(ifconfig wlan0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')"
  
  if [ -z "$IP" ]; then
     IP="$(ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')"
  fi

 if [ -z "$IP" ]; then
    echo "No Internet"
 else
    echo ${IP}
    echo ${IP} > /storage/ip.txt
 fi
