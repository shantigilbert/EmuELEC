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

# Functions that are included in 99-emuelec.conf however since this file is
# going to be tested by itself we need to include the dependent functions.

# Hides the primary display buffer of having any colors by stopping to copy 
# across chunks of data when the blank flag file is set too 1. When hide_buffer
# is 0 it copies across chunks to the display.
# arg1, 1 = Hides, 0 = Show.
hide_buffer ()
{
  echo $1 > /sys/class/graphics/fb1/blank
}

# Basically sets all the data in the primary display buffer to zero so it does
# not show any colors.
blank_buffer()
{
  # Blank the buffer.
  dd if=/dev/zero of=/dev/fb0 bs=8M > /dev/null 2>&1
}

# Here we initialize any arguments and variables to be used in the script.
# The Mode we want the display to change too.
MODE=$1

# File location of the file that when written to switches the display to match
# that screen resolution. Note - You do not have to alter anything else, if it's
# a valid screen value ti will auto-change, if not it will just keep it's
# original value.
FILE_MODE="/sys/class/display/mode"

# SH=Height in pixels, SW=Width in pixels, BPP=Bits Per Pixel.
BPP=32
SH=0
SW=0

# The current display mode before it may get changed below.
OLD_MODE=$( cat ${FILE_MODE} )

# If the current display is the same as the change just exit. First we hide the
# primary display buffer by setting the fb1 blank flag so it stops copying chunks
# of data on to the image, then we blank the buffer by setting all the bits to 0.
if [[ ! -f "$FILE_MODE" || $MODE == "auto" ]]; then
  hide_buffer 1
  blank_buffer
  hide_buffer 0
  exit 0
fi


# For resolution with 2 width and height resolution numbers extract the Height.
# *p* stand for progressive and *i* stand for interlaced.
if [[ ! "$MODE" == *"x"* ]]; then
  case $MODE in
    *p*) SH=$(echo $MODE | cut -d'p' -f 1) ;;
    *i*) SH=$(echo $MODE | cut -d'i' -f 1) ;;
  esac
fi

# Option too Custom set the CVBS Resolution by creating a cvbs_resolution.txt file.
# File contents must just 2 different integers seperated by a space. e.g. 800 600.
CVBS_RES_FILE="/storage/.config/cvbs_resolution.txt"
if [[ "$MODE" == *"cvbs" ]]; then
  if [[ -f "${CVBS_RES_FILE}" ]]; then
    declare -a CVBS_RES=($(cat "${CVBS_RES_FILE}"))
    if [[ ! -z "${CVBS_RES[@]}" ]]; then
        SW=${CVBS_RES[0]}
        SH=${CVBS_RES[1]}
    fi
  fi
fi

# This is needed to reset scaling.
echo 0 > /sys/class/ppmgr/ppscaler

# Here we first clear the primary display buffer of leftover artifacts then set
# the secondary small buffers flag to stop copying across.
blank_buffer
hide_buffer 1

# This first checks that if you need to change the resolution and if so update
# the file that switches the mode automatically if the value is valid if not exit.
if [[ "$OLD_MODE" != "$MODE" ]]; then
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
fi

# Legacy code, we use to set the buffer that is used for small parts of graphics
# like Cursors and Fonts but setting default 32 made ES Fonts dissappear.
BUFF=64
fbset -fb /dev/fb1 -g $BUFF $BUFF $BUFF $BUFF $BPP  

# Here we set the Height and Width of the particular resolution, RH and RW stands
# for Real Width and Real Height respectively.
RW=0
RH=0
case $MODE in
  480cvbs)
    RW=640
    RH=480
    [[ -z "$SW" ]] && SW=1024
    [[ -z "$SH" ]] && SH=768
    ;;
  576cvbs)
    RW=720
    RH=576
    [[ -z "$SW" ]] && SW=1024
    [[ -z "$SH" ]] && SH=768
    ;;
  480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
    SW=$(( $SH*16/9 ))
    [[ "$MODE" == "480"* ]] && SW=640
    ;;
  *x*)
    SW=$(echo $MODE | cut -d'x' -f 1)
    SH=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
    [ ! -n "$SH" ] && H=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
    ;;
esac

# Once we know the Width and Height is valid numbers we set the primary display
# buffer, and we multiply the 2nd height by a factor of 2 I assume for interlaced 
# support.
if [[ -n "$SW" && "$SW" > 0 && -n "$SH" && "$SH" > 0 ]]; then
  MSH=$(( SH*2 ))
  fbset -fb /dev/fb0 -g $SW $SH $SW $MSH $BPP
  echo 0 0 $(( SW-1 )) $(( SH-1 )) > /sys/class/graphics/fb0/free_scale_axis
  echo 0 > /sys/class/graphics/fb0/free_scale
  echo 0 > /sys/class/graphics/fb0/freescale_mode
fi

# Now that the primary buffer has been acquired we blank it again because the new
# memory allocated, may contain garbage artifact data.
blank_buffer
hide_buffer 0

# Gets the default X, and Y position offsets for cvbs so the display can fit 
# inside the actual analog diplay resolution which is a bit smaller than the 
# resolution it's usually transmitted as.
#  if [[ "${MODE}" == "480cvbs" || "${MODE}" == "640x480p60hz" ]]; then
if [[ "${MODE}" == "480cvbs" ]]; then
  BORDERS=(30 10)
fi
if [[ "${MODE}" == "576cvbs" ]]; then
  BORDERS=(33 12)
fi

# This monolith slab of code basically gets the users preference of if they want 
# to resize there screen display to make it smaller so it can fit into a screen
# properly. If the user suppllies values its coded to restrict the user into not
# letting the user set a width greater than the screen display size.
BORDER_VALS=$(get_ee_setting ee_videowindow)
if [[ ! -z "${BORDER_VALS}" ]]; then
  declare -a BORDERS=(${BORDER_VALS})
  COUNT_ARGS=${#BORDERS[@]}
  if [[ ${COUNT_ARGS} != 4 && ${COUNT_ARGS} != 2 ]]; then
    exit 0;
  fi
fi

# If border values have been supplied then we can check the offsets and the
# width and height and make sure they are all valid and will not cause issues for
# when we set the borders, and allow the primary display buffer to resize the screen.
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
    echo "PX:$PX PY:$PY PW:$PW PH:$PH"

    # Sets the default 2nd point of the display which should always be slightly
    # smaller then the acual size of the screen display.
    PX2=$(( PW-PX-1 ))
    PY2=$(( PH-PY-1 ))

    # If the real width and height are defined particularly for cvbs then use
    # the real values of the screen resolution not the display buffers resolution
    # which may differ and generally be allot bigger so all the gui objects are
    # kept in perspective.
    [[ ! -z "${RW}" ]] && PY2=$(( RW-PX-1 ))
    [[ ! -z "${RH}" ]] && PY2=$(( RH-PY-1 ))

    [[ "$PX2" -gt "$SW" ]] && PX2=$(( SW-1 ))
    [[ "$PY2" -gt "$SH" ]] && PY2=$(( SH-1 ))

    echo "PX:${PX} PY:${PY} PX2:${PX2} PY2:${PY2}"
    echo 1 > /sys/class/graphics/fb0/freescale_mode
    echo "${PX} ${PY} ${PX2} ${PY2}" > /sys/class/graphics/fb0/window_axis
    echo 0x10001 > /sys/class/graphics/fb0/free_scale
fi

# Lastly we call fbfix to reset its known memory offsets so when the primary 
# buffer display is used, it's got the correct starting memory address. Note - 
# This only need appply to new generation devices.
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix
