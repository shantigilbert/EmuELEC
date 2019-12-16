#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)

# 12/07/2019 use mpv for all splash 

. /etc/profile

PLATFORM="$1"
GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
DURATION="5"

# we make sure the platform is all lowercase
PLATFORM=${PLATFORM,,}

case $PLATFORM in
 "arcade"|"fba"|"neogeo"|"mame"|cps*)
   PLATFORM="arcade"
  ;;
 "retropie")
   # fbterm does not like the splash screen 
   exit 0
  ;;
esac

if [ "$PLATFORM" == "intro" ] || [ "$PLATFORM" == "exit" ]; then
	SPLASH=${DEFAULTSPLASH}
#elif [ "$PLATFORM" == "default" ]; then
#	SPLASH=${GAMELOADINGSPLASH}
else
	SPLASHDIR="/storage/overlays/splash"
	ROMNAME=$(basename "${2%.*}")
	SPLMAP="/emuelec/bezels/arcademap.cfg"
	SPLNAME=$(sed -n "/`echo ""$PLATFORM"_"${ROMNAME}" = "`/p" "$SPLMAP")
	REALSPL="${SPLNAME#*\"}"
	REALSPL="${REALSPL%\"*}"
[ ! -z "$REALSPL" ] && SPLASH1=$(find $SPLASHDIR/$PLATFORM -iname "$REALSPL*.png" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$ROMNAME" ] && SPLASH2=$(find $SPLASHDIR/$PLATFORM -iname "$ROMNAME*.png" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$REALSPL" ] && SPLASHVID1=$(find $SPLASHDIR/$PLATFORM -iname "$REALSPL*.mp4" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$ROMNAME" ] && SPLASHVID2=$(find $SPLASHDIR/$PLATFORM -iname "$ROMNAME*.mp4" -maxdepth 1 | sort -V | head -n 1)

SPLASH3="$SPLASHDIR/$PLATFORM/launching.png"
SPLASHVID3="$SPLASHDIR/$PLATFORM/launching.mp4"
	
	if [ -f "$SPLASH1" ]; then
		SPLASH=$SPLASH1
		if [ -f "$SPLASHVID1" ]; then
			SPLASH=$SPLASHVID1
		fi
	elif [ -f "$SPLASH2" ]; then
		SPLASH=$SPLASH2
		if [ -f "$SPLASHVID2" ]; then
			SPLASH=$SPLASHVID2
		fi
	elif [ -f "$SPLASH3" ]; then
		SPLASH=$SPLASH3
		if [ -f "$SPLASHVID3" ]; then
			SPLASH=$SPLASHVID3
		fi
	else
		SPLASH=${GAMELOADINGSPLASH}
	fi
fi 
[[ "${PLATFORM}" != "intro" ]] && VIDEO=0 || VIDEO=$(get_ee_setting ee_bootvideo.enabled)

if [[ -f "/storage/.config/emuelec/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]; then
	if [ "$PLATFORM" != "intro" ]; then
		#(
			#vlc -I "dummy" --aout=alsa --image-duration=${DURATION} $SPLASH vlc://quit < /dev/tty1 
			mpv -fs $SPLASH > /dev/null 2>&1
			#ply-image $SPLASH > /dev/null 2>&1
		#)&
	fi 
else
# Show intro video
	SPLASH=${VIDEOSPLASH}
	set_audio alsa
	[ -e /storage/.config/asound.conf ] && mv /storage/.config/asound.conf /storage/.config/asound.confs
	mpv -fs $SPLASH > /dev/null 2>&1
	touch "/storage/.config/emuelec/configs/novideo"
	[ -e /storage/.config/asound.confs ] && mv /storage/.config/asound.confs /storage/.config/asound.conf
fi

# Wait for the time specified in ee_splash_delay setting in emuelec.conf
SPLASHTIME=$(get_ee_setting ee_splash.delay)
sleep $SPLASHTIME
