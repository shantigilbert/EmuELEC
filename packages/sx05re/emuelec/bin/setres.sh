#!/bin/bash

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
HZ=60

MODE=$1
CUR_MODE=`cat /sys/class/display/mode`;

# If the current display is the same as the change just exit.
[ -z "$MODE" ] && exit 0;
[[ $MODE == "auto" ]] && exit 0;
# Removed because if try to set invalid video mode it becomes a valid MODE
# in display/mode and then when trying to revert back this becomes true exiting.
#[[ "$MODE" == "$CUR_MODE" ]] && exit 0;

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


# hides buffer
show_buffer 1

case $MODE in
	480p*hz|480i*hz|576p*hz|720p*hz|1080p*hz|1440p*hz|2160p*hz|576i*hz|720i*hz|1080i*hz|1440i*hz|2160i*hz)
    W=$(($H*16/9))
    [[ "$MODE" == "480"* ]] && W=854
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
    echo 480cvbs > /sys/class/display/mode
		fbset -fb /dev/fb0 -g 640 480 640 960 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 639 479 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 639 479 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode    
		echo 0 > /sys/class/graphics/fb1/free_scale
		;;
	576cvbs)
    echo 576cvbs > /sys/class/display/mode
		fbset -fb /dev/fb0 -g 720 576 720 1152 $BPP
		fbset -fb /dev/fb1 -g $BPP $BPP $BPP $BPP $BPP
		echo 0 0 719 575 > /sys/class/graphics/fb0/free_scale_axis
		echo 0 0 719 575 > /sys/class/graphics/fb0/window_axis
		echo 0 > /sys/class/graphics/fb0/free_scale
		echo 1 > /sys/class/graphics/fb0/freescale_mode    
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

blank_buffer

# shows buffer
show_buffer 0


# End of reading the video output mode and setting it for emuelec to avoid video flicking.
# The codes can be simplified with "elseif" sentences.
# The codes for 480I and 576I are adjusted to avoid overscan.
# Forece 720p50hz to 720p60hz and 1080i/p60hz to 1080i/p60hz since 50hz would make video very choppy.
