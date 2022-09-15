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
  dd if=/dev/zero of=/dev/fb0 bs=10M > /dev/null 2>&1
}

# By initially setting with these values we can garuntee the file changes, and the mode corrects itself.
HACK_480_MODE="640x480p60hz"
HACK_576_MODE="800x600p60hz"

FILE_MODE="/sys/class/display/mode"
[[ ! -f "$FILE_MODE" ]] && exit 0;

BPP=32

MODE=$1
DEF_MODE=$(cat $FILE_MODE)

# If the current display is the same as the change just exit.
[[ $MODE == "auto" ]] && exit 0;

if [[ ! "$MODE" == *"x"* ]]; then
  case $MODE in
    *p*) H=$(echo $MODE | cut -d'p' -f 1) ;;
    *i*) H=$(echo $MODE | cut -d'i' -f 1) ;;
  esac
fi

[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# hides buffer
show_buffer 1

#if [[ ! "$MODE" == "$DEF_MODE" ]]; then
  case $MODE in
    480cvbs)
      echo $HACK_480_MODE > "${FILE_MODE}"
      echo 480cvbs > "${FILE_MODE}"
      ;;
    576cvbs)
      echo $HACK_576_MODE > "${FILE_MODE}"
      echo 576cvbs > "${FILE_MODE}"
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      echo $MODE > "${FILE_MODE}"
      ;;
    *x*)
      echo $MODE > "${FILE_MODE}"
      ;;
  esac
#fi

case $MODE in
  480cvbs)
    W1=639
    H1=479  
    fbset -fb /dev/fb0 -g 640 480 640 960 $BPP
    echo 0 > /sys/class/graphics/fb0/free_scale
    echo 0 > /sys/class/graphics/fb0/freescale_mode
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis    
    ;;
  576cvbs)
    W1=719
    H1=575
    fbset -fb /dev/fb0 -g 720 576 720 1152 $BPP
    echo 0 > /sys/class/graphics/fb0/free_scale
    echo 0 > /sys/class/graphics/fb0/freescale_mode
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
    ;;
  480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
    W=$(( $H*16/9 ))
    [[ "$MODE" == "480"* ]] && W=640
    DH=$(($H*2))
    W1=$(($W-1))
    H1=$(($H-1))
    fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
    echo 0 > /sys/class/graphics/fb0/free_scale
    echo 0 > /sys/class/graphics/fb0/freescale_mode
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
    echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
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
      echo 0 > /sys/class/graphics/fb0/free_scale
      echo 0 > /sys/class/graphics/fb0/freescale_mode
      echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/free_scale_axis
      echo 0 0 $W1 $H1 > /sys/class/graphics/fb0/window_axis
    fi
    ;;
esac

BORDER_SIZE=$(get_ee_setting ee_videoborder)
BORDER_SIZE_X=0
BORDER_SIZE_Y=0
if [ -n ${BORDER_SIZE} ] & [ ${BORDER_SIZE} > 0 ]; then
  BORDER_SIZE_X=${BORDER_SIZE}
  BORDER_SIZE_Y=${BORDER_SIZE}
fi

if [ -z ${BORDER_SIZE_X} ]; then
  BORDER_SIZE_X=$(get_ee_setting ee_videoborderx)
  BORDER_SIZE_Y=$(get_ee_setting ee_videobordery)
fi

if [ -n ${BORDER_SIZE_X} ] & [ -n ${BORDER_SIZE_Y} ]; then
  if [ ${BORDER_SIZE_X} > 0 ] | [ ${BORDER_SIZE_Y} > 0 ]; then
    SCALE_H=$(( $H1 - $BORDER_SIZE_X ))
    SCALE_W=$(( $W1 - $BORDER_SIZE_Y ))
    echo ${BORDER_SIZE_X} ${BORDER_SIZE_Y} ${SCALE_W} ${SCALE_H} > /sys/class/graphics/fb0/window_axis
    echo 0 > /sys/class/graphics/fb0/freescale_mode
    echo 0x10001 > /sys/class/graphics/fb0/free_scale
  fi
fi

blank_buffer

# shows buffer
show_buffer 0

[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# End of reading the video output mode and setting it for emuelec to avoid video flicking.
# The codes can be simplified with "elseif" sentences.
# The codes for 480I and 576I are adjusted to avoid overscan.
# Force 720p50hz to 720p60hz and 1080i/p60hz to 1080i/p60hz since 50hz would make video very choppy.
