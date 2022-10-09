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


blank_buffer()
{
  # Blank the buffer.
  echo 1 > /sys/class/graphics/fb1/blank
  dd if=/dev/zero of=/dev/fb1 bs=8M > /dev/null 2>&1
  echo 0 > /sys/class/graphics/fb1/blank
  echo 1 > /sys/class/graphics/fb0/blank
  dd if=/dev/zero of=/dev/fb0 bs=32M > /dev/null 2>&1
  echo 0 > /sys/class/graphics/fb0/blank
  [[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix
}

switch_resolution()
{
  local OLD_MODE=$1
  local MODE=$2

  # This first checks that if you need to change the resolution and if so update
  # the file that switches the mode automatically if the value is valid if not exit.
  if [[ "$OLD_MODE" != "$MODE" ]]; then
    # Here we first clear the primary display buffer of leftover artifacts then set
    # the secondary small buffers flag to stop copying across.
    blank_buffer >> /dev/null

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
    local NEW_MODE=$(cat $FILE_MODE)
    if [[ "$NEW_MODE" == "$MODE" ]]; then
      echo "1"
      return
    fi
  fi
  echo "0"
}

get_resolution_size()
{
  local MODE=$1

  # Here we set the Height and Width of the particular resolution, RH and RW stands
  # for Real Width and Real Height respectively.
  local RW=0
  local RH=0
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
      RW=$SW
      RH=$SH
      ;;
    *x*)
      SW=$(echo $MODE | cut -d'x' -f 1)
      SH=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
      [ ! -n "$SH" ] && H=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
      RW=$SW
      RH=$SH      
      ;;
  esac
  echo "$SW $SH $RW $RH"
}

set_main_framebuffer() {
  local SW=$1
  local SH=$2
  local BPP=32

  if [[ -n "$SW" && "$SW" > 0 && -n "$SH" && "$SH" > 0 ]]; then
    MSH=$(( SH*2 ))
    fbset -fb /dev/fb0 -g $SW $SH $SW $MSH $BPP
    echo 0 0 $(( SW-1 )) $(( SH-1 )) > /sys/class/graphics/fb0/free_scale_axis
    echo 0 > /sys/class/graphics/fb0/free_scale
    echo 0 > /sys/class/graphics/fb0/freescale_mode
  fi
}

set_display_borders() {
  local PX=$1
  local PY=$2
  local PW=$3
  local PH=$4
  local RW=$5
  local RH=$6
  
  if [[ -z "$PX" || -z "$PY" || -z "$PW" || -z "$PH" ]]; then
    return 1
  elif [[ ! -n "$PX" || ! -n "$PY" || ! -n "$PW" || ! -n "$PH" ]]; then
    return 2
  elif [[ "$PW" == "0" || "$PH" == "0" ]]; then
    return 3
  fi
  echo "PX:$PX PY:$PY PW:$PW PH:$PH"

  # Sets the default 2nd point of the display which should always be slightly
  # smaller then the acual size of the screen display.
  PX2=$(( RW-PX-1 ))
  PY2=$(( RH-PY-1 ))

  # If the real width and height are defined particularly for cvbs then use
  # the real values of the screen resolution not the display buffers resolution
  # which may differ and generally be allot bigger so all the gui objects are
  # kept in perspective.
  [[ ${RW} != ${PW} ]] && PX2=$(( PW+PX-1 ))
  [[ ${RH} != ${PH} ]] && PY2=$(( PH+PY-1 ))

  echo "PX:${PX} PY:${PY} PX2:${PX2} PY2:${PY2}"
  echo 1 > /sys/class/graphics/fb0/freescale_mode
  echo "${PX} ${PY} ${PX2} ${PY2}" > /sys/class/graphics/fb0/window_axis
  echo 0x10001 > /sys/class/graphics/fb0/free_scale
  return 0
}

# Here we initialize any arguments and variables to be used in the script.
# The Mode we want the display to change too.
MODE=$1
FORCE_RUN=$2


[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

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

BORDER_VALS=$(get_ee_setting ee_videowindow)


# Legacy code, we use to set the buffer that is used for small parts of graphics
# like Cursors and Fonts but setting default 32 made ES Fonts dissappear.
BUFF=$(get_ee_setting ee_video_fb1_size)
[[ -z "$BUFF" ]] && BUFF=32

if [[ -n "$BUFF" ]] && [[ $BUFF > 0 ]]; then
  fbset -fb /dev/fb1 -g $BUFF $BUFF $BUFF $BUFF $BPP
fi


# If the current display is the same as the change just exit. First we hide the
# primary display buffer by setting the fb1 blank flag so it stops copying chunks
# of data on to the image, then we blank the buffer by setting all the bits to 0.
if [[ ! -f "$FILE_MODE" ]] || [[ $MODE == "auto" ]]; then
  exit 0
fi

if [[ "$FORCE_RUN" == "" ]] && [[ "$MODE" == "$OLD_MODE" ]]; then
  if [[ -z "${BORDER_VALS}" ]]; then
    exit 0
  fi
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

SWITCHED_MODES=$(switch_resolution $OLD_MODE $MODE)

declare -a SIZE=($( get_resolution_size $MODE ))

SW=${SIZE[0]}
SH=${SIZE[1]}
RW=${SIZE[2]}
RH=${SIZE[3]}

echo "SWITCHED_MODES=$SWITCHED_MODES"

# Once we know the Width and Height is valid numbers we set the primary display
# buffer, and we multiply the 2nd height by a factor of 2 I assume for interlaced 
# support.
if [[ "$SWITCHED_MODES" == "1" ]]; then
  echo "SET MAIN FRAME BUFFER"
  set_main_framebuffer $RW $RH
  blank_buffer
fi

# Now that the primary buffer has been acquired we blank it again because the new
# memory allocated, may contain garbage artifact data.

# Gets the default X, and Y position offsets for cvbs so the display can fit 
# inside the actual analog diplay resolution which is a bit smaller than the 
# resolution it's usually transmitted as.
if [[ "${MODE}" == "480cvbs" ]]; then
  BORDERS=(4 0)
fi
if [[ "${MODE}" == "576cvbs" ]]; then
  BORDERS=(12 0)
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
    exit 0
  fi
fi

# If border values have been supplied then we can check the offsets and the
# width and height and make sure they are all valid and will not cause issues for
# when we set the borders, and allow the primary display buffer to resize the screen.
if [[ ! -z "${BORDERS}" ]]; then
  PW=${BORDERS[2]}
  [[ -z "$PW" ]] && PW=$RW
  PH=${BORDERS[3]}
  [[ -z "$PH" ]] && PH=$RH
  set_display_borders ${BORDERS[0]} ${BORDERS[1]} $PW $PH $RW $RH
fi

# Lastly we call fbfix to reset its known memory offsets so when the primary 
# buffer display is used, it's got the correct starting memory address. Note - 
# This only need appply to new generation devices.
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix
