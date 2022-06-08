#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# Read the video output mode and set it for emuelec to avoid video flicking.

# This file sets the hdmi output and frame buffer to the argument in pixel width.
# Allowed argument example ./setres.sh 1080p60hz <-- For height 1080 pixels.

# set -x #echo on

# Source predefined functions and variables
. /etc/profile

# arg1, 1 = Hides, 0 = Show.
show_buffer ()
{
  echo $1 > /sys/class/graphics/fb0/blank
  echo $1 > /sys/class/graphics/fb1/blank
}

blank_buffer()
{
  # Blank the buffer.
  dd if=/dev/zero of=/dev/fb0 bs=12M > /dev/null 2>&1
}

BPP=32
MODE=$1

FILE_MODE="/sys/class/display/mode"
if [[ -f "/sys/class/display/display0.HDMI/mode" ]]; then
  FILE_MODE="/sys/class/display/display0.HDMI/mode"
fi

# If the current display is the same as the change just exit.
[ -z "$MODE" ] && exit 0;
[[ $MODE == "auto" ]] && exit 0;

if [[ ! "$MODE" == *"x"* ]]; then
  case $MODE in
    *p*) H=$(echo $MODE | cut -d'p' -f 1) ;;
    *i*) H=$(echo $MODE | cut -d'i' -f 1) ;;
  esac
fi

blank_buffer
show_buffer 0

# hides buffer
show_buffer 1

case $MODE in
  480cvbs)
		fbset -fb /dev/fb0 -g 640 480 640 960 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 639 479 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 639 479 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode    
		echo 0 > /sys/class/graphics/fb1/free_scale
		;;
	576cvbs)
		fbset -fb /dev/fb0 -g 720 576 720 1152 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 719 575 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 719 575 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode    
    echo 0 > /sys/class/graphics/fb1/free_scale
		;;
	480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
    W=$(( $H*16/9 ))
    [[ "$MODE" == "480"* ]] && W=854
		DH=$(($H*2))
		W1=$(($W-1))
		H1=$(($H-1))
		fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
    echo $MODE > "${FILE_MODE}"
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb1/free_scale
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
      echo $MODE > "${FILE_MODE}"
  		echo 0 > /sys/class/graphics/fb0/free_scale
  		echo 1 > /sys/class/graphics/fb0/freescale_mode
  		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
  		echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
  		echo 0 > /sys/class/graphics/fb1/free_scale      
    fi
    ;;
esac

blank_buffer

# shows buffer
show_buffer 0

[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# End of reading the video output mode and setting it for emuelec to avoid video flicking.
# The codes can be simplified with "elseif" sentences.
# The codes for 480I and 576I are adjusted to avoid overscan.
# Forece 720p50hz to 720p60hz and 1080i/p60hz to 1080i/p60hz since 50hz would make video very choppy.
