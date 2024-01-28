#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present SumavisionQ5 (https://github.com/SumavisionQ5)
# Modifications by Shanti Gilbert (https://github.com/shantigilbert)

# 12/07/2019 use mpv for all splash 
# 19/01/2020 use ffplay for all splash 
# 06/02/2020 move splash to roms folder and add global splash support

. /etc/profile

ACTION_TYPE="$1"
PLATFORM="$2"

GAMELOADINGSPLASH="/storage/.config/splash/loading-game.png"
BLANKSPLASH="/storage/.config/splash/blank.png"
DEFAULTSPLASH="/storage/.config/splash/splash-1080.png"
VIDEOSPLASH="/usr/config/splash/emuelec_intro_1080p.mp4"
RANDOMVIDEO="/storage/roms/splash/introvideos"
DURATION="5"

if [ -f "/storage/roms/splash/intro.mp4" ]; then
    VIDEOSPLASH="/storage/roms/splash/intro.mp4"
fi

# we make sure the platform is all lowercase
PLATFORM=${PLATFORM,,}
PLAYER="ffplay"

case $PLATFORM in
 "arcade"|"fba"|"fbn"|"neogeo"|"mame"|cps*)
   PLATFORM="arcade"
  ;;
 "retropie"|"setup")
   # fbterm does not like the splash screen 
   exit 0
  ;;
esac

MODE=`get_resolution`;

SPLASHDIR="/storage/roms/splash"
  
if [ "$ACTION_TYPE" == "intro" ] || [ "$ACTION_TYPE" == "exit" ]; then
	SPLASH=${DEFAULTSPLASH}
  if [[ "$MODE" == *"x"* ]]; then
    SPLASH="/storage/.config/splash/splash-std.png"
  fi
elif [ "$ACTION_TYPE" == "blank" ]; then
  SPLASH=${BLANKSPLASH}
elif [ "$ACTION_TYPE" == "gameloading" ]; then
  if [[ "$MODE" == *"x"* ]]; then
    GAMELOADINGSPLASH="/storage/.config/splash/loading-game-std.png"
  fi

	ROMNAME=$(basename "${3%.*}")
	SPLMAP="/emuelec/configs/bezels/arcademap.cfg"
	SPLNAME=$(sed -n "/`echo ""$PLATFORM"_"${ROMNAME}" = "`/p" "$SPLMAP")
	REALSPL="${SPLNAME#*\"}"
	REALSPL="${REALSPL%\"*}"
[ ! -z "$ROMNAME" ] && SPLASH1=$(find $SPLASHDIR/$PLATFORM -iname "$ROMNAME*.png" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$ROMNAME" ] && SPLASHVID1=$(find $SPLASHDIR/$PLATFORM -iname "$ROMNAME*.mp4" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$REALSPL" ] && SPLASH2=$(find $SPLASHDIR/$PLATFORM -iname "$REALSPL*.png" -maxdepth 1 | sort -V | head -n 1)
[ ! -z "$REALSPL" ] && SPLASHVID2=$(find $SPLASHDIR/$PLATFORM -iname "$REALSPL*.mp4" -maxdepth 1 | sort -V | head -n 1)

SPLASH3="$SPLASHDIR/$PLATFORM/launching.png"
SPLASHVID3="$SPLASHDIR/$PLATFORM/launching.mp4"

SPLASH4="$SPLASHDIR/$PLATFORM.png"
SPLASHVID4="$SPLASHDIR/$PLATFORM.mp4"

SPLASH5="$SPLASHDIR/launching.png"
SPLASHVID5="$SPLASHDIR/launching.mp4"
	
	if [ -f "$SPLASHVID1" ]; then
		SPLASH="$SPLASHVID1"
	elif [ -f "$SPLASH1" ]; then
		SPLASH="$SPLASH1"
	elif [ -f "$SPLASHVID2" ]; then
		SPLASH="$SPLASHVID2"
	elif [ -f "$SPLASH2" ]; then
		SPLASH="$SPLASH2"
	elif [ -f "$SPLASHVID3" ]; then
		SPLASH="$SPLASHVID3"
	elif [ -f "$SPLASH3" ]; then
		SPLASH="$SPLASH3"
	elif [ -f "$SPLASHVID4" ]; then
		SPLASH="$SPLASHVID4"
	elif [ -f "$SPLASH4" ]; then
		SPLASH="$SPLASH4"
	elif [ -f "$SPLASHVID5" ]; then
		SPLASH="$SPLASHVID5"
	elif [ -f "$SPLASH5" ]; then
		SPLASH="$SPLASH5"
	else
		SPLASH="${GAMELOADINGSPLASH}"
	fi
fi

# Odroid Go Advance still does not support splash screens
SS_DEVICE=0
if [[ "$EE_DEVICE" == "OdroidGoAdvance" ]] || [[ "$EE_DEVICE" == "GameForce" ]]; then
  SS_DEVICE=1
  clear > /dev/console
  echo "Loading ..." > /dev/console
  PLAYER="mpv"
fi

declare -a RES=( $MODE )
SIZE=" -x ${RES[0]} -y ${RES[1]}"

[[ "${ACTION_TYPE}" != "intro" ]] && VIDEO=0 || VIDEO=$(get_ee_setting ee_bootvideo.enabled)

if [[ -f "/storage/.config/emuelec/configs/novideo" ]] && [[ ${VIDEO} != "1" ]]; then
	if [ "$ACTION_TYPE" != "intro" ]; then
	if [ "$SS_DEVICE" == 1 ]; then
        $PLAYER "$SPLASH" > /dev/null 2>&1
    else
        $PLAYER -fs -autoexit ${SIZE} "$SPLASH" > /dev/null 2>&1
    fi

	fi 
else
# Show intro video
RND=$(get_ee_setting "ee_randombootvideo.enabled" == "1")
if [ "${RND}" ==  1 ]; then
    SPLASH=$(ls ${RANDOMVIDEO}/*.mp4 |sort -R |tail -1)
    [[ -z "${SPLASH}" ]] && SPLASH="${VIDEOSPLASH}"
else
	SPLASH="${VIDEOSPLASH}"
fi
	set_audio alsa
	#[ -e /storage/.config/asound.conf ] && mv /storage/.config/asound.conf /storage/.config/asound.confs
    if [ $SS_DEVICE -eq 1 ]; then
        $PLAYER "$SPLASH" > /dev/null 2>&1
    else
        $PLAYER -fs -autoexit ${SIZE} "$SPLASH" > /dev/null 2>&1
    fi
	touch "/storage/.config/emuelec/configs/novideo"
	#[ -e /storage/.config/asound.confs ] && mv /storage/.config/asound.confs /storage/.config/asound.conf
fi

# Wait for the time specified in ee_splash_delay setting in emuelec.conf
SPLASHTIME=$(get_ee_setting ee_splash.delay)
[ ! -z "$SPLASHTIME" ] && sleep $SPLASHTIME
