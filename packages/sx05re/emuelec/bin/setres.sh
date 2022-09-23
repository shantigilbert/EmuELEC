#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Joshua L (https://github.com/Langerz82)

# Read the video output mode and set it for emuelec to avoid video flicking.

# This file sets the hdmi output and frame buffer to the argument in pixel width.
# Allowed argument example ./setres.sh 1080p60hz <-- For height 1080 pixels.

# set -x #echo on

# Source predefined functions and variables
. /etc/profile

BPP=32
BUFF=32

MODE=$1
FILE_MODE="/sys/class/display/mode"

# If the current display is the same as the change just exit.
if [[ ! -f "$FILE_MODE" || $MODE == "auto" ]]; then
  hide_buffer 1
  blank_buffer
  hide_buffer 0
  exit 0
fi

OLD_MODE=$( cat ${FILE_MODE} )

if [[ ! "$MODE" == *"x"* ]]; then
  case $MODE in
    *p*) H=$(echo $MODE | cut -d'p' -f 1) ;;
    *i*) H=$(echo $MODE | cut -d'i' -f 1) ;;
  esac
fi

# This is needed to reset scaling.
echo 0 > /sys/class/ppmgr/ppscaler

if [[ "$OLD_MODE" != "$MODE" ]]; then
  hide_buffer 1
  blank_buffer
  case $MODE in
    480cvbs)
      echo 480cvbs > "${FILE_MODE}"
      ;;
    576cvbs)
      echo 576cvbs > "${FILE_MODE}"
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      echo $MODE > "${FILE_MODE}"
      ;;
    *x*)
      echo $MODE > "${FILE_MODE}"
      ;;
  esac
  NEW_MODE=$(cat $FILE_MODE)
  if [[ "$NEW_MODE" != "$MODE" ]]; then
    hide_buffer 0
    exit 0
  fi

  case $MODE in
    480cvbs)
      W=640
      H=480
      fbset -fb /dev/fb0 -g 640 480 640 960 $BPP
      ;;
    576cvbs)
      W=720
      H=576
      fbset -fb /dev/fb0 -g 720 576 720 1152 $BPP
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      W=$(( $H*16/9 ))
      [[ "$MODE" == "480"* ]] && W=640
      DH=$(($H*2))
      fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
      ;;
    *x*)
      W=$(echo $MODE | cut -d'x' -f 1)
      H=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
      [ ! -n "$H" ] && H=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
      if [ -n "$W" ] && [ -n "$H" ]; then
        DH=$(($H*2))
        fbset -fb /dev/fb0 -g $W $H $W $DH $BPP
      fi
      ;;
  esac
  echo 0 0 $(( W-1 )) $(( H-1 )) > /sys/class/graphics/fb0/free_scale_axis
  echo 0 > /sys/class/graphics/fb0/free_scale
  echo 0 > /sys/class/graphics/fb0/freescale_mode
  
#  fbset -fb /dev/fb1 -g $BUFF $BUFF $BUFF $BUFF $BPP  
  blank_buffer
  hide_buffer 0
fi

BORDER_VALS=$(get_ee_setting ee_videowindow)
if [[ ! -z "${BORDER_VALS}" ]]; then
  declare -a BORDERS=(${BORDER_VALS})
  COUNT_ARGS=${#BORDERS[@]}
  if [[ ${COUNT_ARGS} != 4 && ${COUNT_ARGS} != 2 ]]; then
    exit 0;
  fi
else
  if [[ "${MODE}" == "480cvbs" ]]; then
    BORDERS=(10 10)
  fi
  if [[ "${MODE}" == "576cvbs" ]]; then
    BORDERS=(15 15)
  fi    
fi

if [[ ! -z "${BORDERS}" ]]; then
    PX=${BORDERS[0]}
    [[ -z "${PX}" ]] && PX=0
    PY=${BORDERS[1]}
    [[ -z "${PY}" ]] && PY=0
    PW=${BORDERS[2]}
    [[ -z "${PW}" ]] && PW=$W
    PH=${BORDERS[3]}
    [[ -z "${PH}" ]] && PH=$H
    
    if [[ -z "$PX" || -z "$PY" || -z "$PW" || -z "$PH" ]]; then
      exit 0
    elif [[ ! -n "$PX" || ! -n "$PY" || ! -n "$PW" || ! -n "$PH" ]]; then
      exit 0
    elif [[ "$PW" == "0" || "$PH" == "0" ]]; then
      exit 0
    fi

    echo "All parameters passed: $PX $PY $PW $PH. Autogen: $(( PW-PX-1 )) $(( PH-PY-1 ))"

    PX2=$(( PW-PX-1 ))
    PY2=$(( PH-PY-1 ))
    if [[ "$PX2" -gt "$W" ]]; then
      PX2=$(( W-1 )) 
    fi
    [[ "$PY2" > "$H" ]] && PY2=$(( H-1 ))

    echo "${PX} ${PY} ${PX2} ${PY2}" > /sys/class/graphics/fb0/window_axis
    echo 1 > /sys/class/graphics/fb0/freescale_mode
    echo 0x10001 > /sys/class/graphics/fb0/free_scale
fi

[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# End of reading the video output mode and setting it for emuelec to avoid video flicking.
# The codes can be simplified with "elseif" sentences.
# The codes for 480I and 576I are adjusted to avoid overscan.
# Force 720p50hz to 720p60hz and 1080i/p60hz to 1080i/p60hz since 50hz would make video very choppy.
