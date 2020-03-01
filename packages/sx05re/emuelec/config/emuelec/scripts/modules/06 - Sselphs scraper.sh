#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

source /emuelec/scripts/env.sh
source "$scriptdir/scriptmodules/supplementary/esthemes.sh"
rp_registerAllModules

joy2keyStart

function scrape_confirm() {
     if dialog --ascii-lines --yesno "This will Kill Emulationstation and will start Sselph's Scraper, do you want to continue?"  22 76 >/dev/tty; then
		start_scraper
      fi
 }

function start_scraper() {
systemd-run bash /emuelec/scripts/fbterm.sh /emuelec/scripts/modules/scraper.start
systemctl stop emustation
}

scrape_confirm
