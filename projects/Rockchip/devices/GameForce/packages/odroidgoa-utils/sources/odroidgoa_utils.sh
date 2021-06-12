#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

# THESE NEEDS TO BE CLEANED UP, MAYBE WITH CASE OR FUNCTIONS

# Source predefined functions and variables
. /etc/profile

if [ "${1}" == "toggleaudio" ];then
# Toggle audio output
CURRENTAUDIO=$(get_ee_setting "audio.device")
	case "${CURRENTAUDIO}" in
	    "headphone")
	    echo "setting speakers"
		amixer cset name='Playback Path' SPK
		set_ee_setting "audio.device" "speakers"
		;;
	    "auto"|"speakers"|*)
	    echo "setting headphones"
		amixer cset name='Playback Path' HP
		set_ee_setting "audio.device" "headphone"
		;;
	esac
fi

if [ "${1}" == "setaudio" ];then
# Set audio output second parameter is either headphones or speakers
	case "${2}" in
	    "headphone")
	    echo "setting headphones"
		amixer cset name='Playback Path' HP
		set_ee_setting "audio.device" "headphone"
		;;
	  	"auto"|"speakers"|*)
	  	echo "setting speakers"
		amixer cset name='Playback Path' SPK
		set_ee_setting "audio.device" "speakers"
		;;
	esac
fi

if [ "${1}" == "vol" ];then
VOLSTEP=5
CURRENTVOL=$(get_ee_setting "audio.volume")
MAXVOL=100
MINVOL=0
	if [ "${2}" == "+" ]; then
		STEPVOL=$(($CURRENTVOL+$VOLSTEP))
	elif [ "${2}" == "-" ]; then
		STEPVOL=$(($CURRENTVOL-$VOLSTEP))
	else
		STEPVOL=${2}
	fi
	[ "$STEPVOL" -ge "$MAXVOL" ] && STEPVOL="$MAXVOL"
	[ "$STEPVOL" -le "$MINVOL" ] && STEPVOL="$MINVOL"
	amixer set 'Playback' ${STEPVOL}%
	set_ee_setting "audio.volume" ${STEPVOL}
  fi    


if [ "${1}" == "bright" ]; then
STEPS="5"
CURBRIGHT=$(cat /sys/class/backlight/backlight/brightness)
MAXSYSBRIGHT=$(cat /sys/class/backlight/backlight/max_brightness)
CURRENTBRIGHT=$(awk -v a="$CURBRIGHT" -v b="$MAXSYSBRIGHT" 'BEGIN{print int((a*100/b)+0.5)}')
MAXBRIGHT="100"
MINBRIGHT="5"

    if [ "${2}" == "+" ]; then
        STEPBRIGHT=$(($CURRENTBRIGHT+$STEPS))
    elif [ "${2}" == "-" ]; then
        STEPBRIGHT=$(($CURRENTBRIGHT-$STEPS))
    else
        STEPBRIGHT=${2}
    fi

    [ "$STEPBRIGHT" -ge "$MAXBRIGHT" ] && STEPBRIGHT="$MAXBRIGHT"
    [ "$STEPBRIGHT" -le "$MINBRIGHT" ] && STEPBRIGHT="$MINBRIGHT"
    #echo "Setting bright to $STEPBRIGHT"

    NEWVAL=$(awk -v a="$STEPBRIGHT" -v b="$MAXSYSBRIGHT" 'BEGIN{print int((a*b/100)+0.5)}')
echo "${NEWVAL}" > /sys/class/backlight/backlight/brightness
set_ee_setting "brightness.level" $STEPBRIGHT
fi

if [ "${1}" == "oga_oc" ]; then

    case ${2} in 
        "1.4ghz")
        gov="userspace"
        freq="1416000"
        ;;
        "1.5ghz")
        gov="userspace"
        freq="1512000"
        ;;
        *)
        gov="performance"
        freq="1296000"
        ;;
    esac

    echo ${gov} > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor
    echo ${freq} > /sys/devices/system/cpu/cpufreq/policy0/scaling_setspeed
    echo ${freq} > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq
fi

if [ "${1}" == "bl" ]; then

case "${2}" in
    "red")
    echo 1 > /sys/class/leds/red/brightness
    echo 0 > /sys/class/leds/green/brightness
    echo 0 > /sys/class/leds/blue/brightness
    ;;
    "green")
    echo 0 > /sys/class/leds/red/brightness
    echo 1 > /sys/class/leds/green/brightness
    echo 0 > /sys/class/leds/blue/brightness
    ;;
    "blue")
    echo 0 > /sys/class/leds/red/brightness
    echo 0 > /sys/class/leds/green/brightness
    echo 1 > /sys/class/leds/blue/brightness
    ;;
    "white")
    echo 1 > /sys/class/leds/red/brightness
    echo 1 > /sys/class/leds/green/brightness
    echo 1 > /sys/class/leds/blue/brightness
    ;;
    "purple")
    echo 1 > /sys/class/leds/red/brightness
    echo 0 > /sys/class/leds/green/brightness
    echo 1 > /sys/class/leds/blue/brightness
    ;;
    "yellow")
    echo 1 > /sys/class/leds/red/brightness
    echo 1 > /sys/class/leds/green/brightness
    echo 0 > /sys/class/leds/blue/brightness
    ;;
    "cyan")
    echo 0 > /sys/class/leds/red/brightness
    echo 1 > /sys/class/leds/green/brightness
    echo 1 > /sys/class/leds/blue/brightness
    ;;
    "off")
    echo 0 > /sys/class/leds/red/brightness
    echo 0 > /sys/class/leds/green/brightness
    echo 0 > /sys/class/leds/blue/brightness
    ;;
    esac
fi

if [ "${1}" == "pl" ]; then

case "${2}" in
    "off")
    echo 0 > /sys/class/leds/heartbeat/brightness
    ;;
    "heartbeat")
    echo "heartbeat"  > /sys/class/leds/heartbeat/trigger
    ;;
    "on")
    echo 0 > /sys/class/leds/heartbeat/brightness
    echo 1 > /sys/class/leds/heartbeat/brightness
    ;;
    esac
fi
