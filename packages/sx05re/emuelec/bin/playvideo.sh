#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

clear > /dev/console
clear > /dev/tty1
clear > /dev/tty0
ee_console disable

set_video_controls
romdir="/storage/roms/"

PLAYER="${2}"

case ${PLAYER} in
	"ffplay")
MODE=`get_resolution`;	

	case "$MODE" in
		*480)
			SIZE=" -x 800 -y 480"
		;;
		*576)
			SIZE=" -x 768 -y 576"
		;;
		*720)
			SIZE=" -x 1280 -y 720"
		;;
		*)
			SIZE=" -x 1920 -y 1080"
		;;
	esac
	player="ffplay -fs -autoexit -loglevel warning -hide_banner ${SIZE}"
	;;
	"vlc")
	# does not work...
	/usr/bin/vlc -I "dummy" --aout=alsa "${1}" vlc://quit < /dev/tty1 > /dev/null 2>&1
	;;
	"mpv")
	player="mpv -fs --volume-max=200 --really-quiet"
	;;
esac

cd /tmp

case ${1} in
	*.ytb)
		#Youtube Video
		${player} "/storage/.config/splash/youtube-1080.png"
		youtube-dl --quiet --no-warnings -o - -a "${1}" | ${player} - > /dev/tty1 2>&1
	;;
	*.twi)
		# Twitch Video
		${player}  "/storage/.config/splash/twitch-1080.png" 
		youtube-dl --quiet --no-warnings -o - -a "${1}" | ${player} - > /dev/tty1 2>&1
	;;
	*)
	# Regular video
	${player} "${1}" #> /dev/tty1 2>&1
	;;
esac

clear > /dev/console
clear > /dev/tty1
clear > /dev/tty0

kill_video_controls
