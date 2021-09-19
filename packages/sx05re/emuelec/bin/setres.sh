#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Read the video output mode and set it for emuelec to avoid video flicking.

# This file sets the hdmi output and frame buffer to the argument in pixel width.
# Allowed argument example ./setres.sh 1080p60hz <-- For height 1080 pixels.

# set -x #echo on

# 1080p60hz
# 1080i60hz
# 720p60hz
# 720p50hz
# 480p60hz
# 480cvbs
# 576p50hz
# 1080p50hz
# 1080i50hz
# 576cvbs

TBASH="/usr/bin/bash"

show_blank()
{
  # Blank the buffer.
  ${TBASH} show_splash.sh "blank"
  echo 1 > /sys/class/graphics/fb0/blank
  echo 1 > /sys/class/graphics/fb1/blank
  
}

BPP=32
HZ=60

MODE=$1

[ -z "$MODE" ] && MODE=`cat /sys/class/display/mode`;

if [[ ! "$MODE" == *"x"* ]]; then
  case $MODE in
  	*p*) H=$(echo $MODE | cut -d'p' -f 1) ;;
  	*i*) H=$(echo $MODE | cut -d'i' -f 1) ;;
  	*cvbs*) H=$(echo $MODE | cut -d'c' -f 1) ;;
  esac
fi

HZ=${MODE:(-4):2}
if [[ ! -n "$HZ" ]] || [[ $HZ -eq 50 ]]; then
	HZ=60
fi

[[ "${1}" != "intro" ]] && show_blank

case $MODE in
	480p*hz|480i*hz)
		W=854
		DI=$(($H*2))
		W1=$(($W-1))
		H1=$(($H-1))
		fbset -fb /dev/fb0 -g $W $H $W $DI $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo $MODE > /sys/class/display/mode
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb1/free_scale
		;;
	576p*hz|720p*hz|1080p*hz|2160p*hz|576i*hz|720i*hz|1080i*hz|2160i*hz)
		W=$(($H*16/9))
		DH=$(($H*2))
		W1=$(($W-1))
		H1=$(($H-1))
		fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo $MODE > /sys/class/display/mode
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb1/free_scale
		;;
	480cvbs)
		fbset -fb /dev/fb0 -g 1280 960 1280 1920 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 1279 959 > /sys/class/graphics/fb0/free_scale_axis
		echo 30 10 669 469 > /sys/class/graphics/fb0/window_axis
		echo 640 > /sys/class/graphics/fb0/scale_width
		echo 480 > /sys/class/graphics/fb0/scale_height
		echo 0x10001 > /sys/class/graphics/fb0/free_scale
		;;
	576cvbs)
		fbset -fb /dev/fb0 -g 1280 960 1280 1920 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 1279 959 > /sys/class/graphics/fb0/free_scale_axis
		echo 35 20 680 565 > /sys/class/graphics/fb0/window_axis
		echo 720 > /sys/class/graphics/fb0/scale_width
		echo 576 > /sys/class/graphics/fb0/scale_height
		echo 0x10001 > /sys/class/graphics/fb0/free_scale
		;;
  *x*)
    W=$(echo $MODE | cut -d'x' -f 1)
    H=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
    [ ! -n "$H" ] && H=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
    if [ -n "$W" ] && [ -n "$H" ]; then
      DH=$(($H*2))
  		W1=$(($W-1))
  		H1=$(($H-1))
  		fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
  		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
#  		[[ "$MODE" = "720x480p"* ]] && MODE=$(echo "${H}p${HZ}hz")
  		echo $MODE > /sys/class/display/mode
  		echo 0 > /sys/class/graphics/fb0/free_scale
  		echo 1 > /sys/class/graphics/fb0/freescale_mode
  		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
  		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
  		echo 0 > /sys/class/graphics/fb1/free_scale      
    fi
    ;;
esac

# Enable the buffer again.
echo 0 > /sys/class/graphics/fb0/blank
echo 0 > /sys/class/graphics/fb1/blank

# End of reading the video output mode and setting it for emuelec to avoid video flicking.
# The codes can be simplified with "elseif" sentences.
# The codes for 480I and 576I are adjusted to avoid overscan.
# Forece 720p50hz to 720p60hz and 1080i/p60hz to 1080i/p60hz since 50hz would make video very choppy.
