#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2016-2018 kszaq (kszaquitto@gmail.com)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

HDMI_UNPLUGGED=0
while :; do
  ! grep -q . /sys/class/amhdmitx/amhdmitx0/disp_cap &&
    grep -q 0 /sys/class/amhdmitx/amhdmitx0/hpd_state &&
    HDMI_UNPLUGGED=1 && sleep 2 && continue ||
  break
done

if [ $HDMI_UNPLUGGED = 1 ]
then systemctl restart kodi
fi
