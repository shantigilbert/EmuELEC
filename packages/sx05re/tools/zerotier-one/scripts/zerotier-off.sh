#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present DiegroSan

systemctl stop zerotier-one.service
rm /storage/.config/zerotier/networks.d/*