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

switch_resolution()
{
  local MODE=$1

  # Here we first clear the primary display buffer of leftover artifacts then set
  # the secondary small buffers flag to stop copying across.
  blank_buffer >> /dev/null

  case $MODE in
    480cvbs|576cvbs|480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*|*x*)
      echo null > "${FILE_MODE}"
      sleep 0.5
      echo $MODE > "${FILE_MODE}"
  esac
}

get_resolution_size()
{
  local MODE=$1

  # Here we set the Height and Width of the particular resolution.
  # FBW - Frame Buffer Width, PSW - Physical Screen Width.
  # FBH - Frame Buffer Height, PSH - Physical Screen Height.

  local FBW=$2
  local FBH=$3

  local PSW=0
  local PSH=0

  case $MODE in
    480cvbs)
      PSW=640
      PSH=480
      [[ -z "$FBW" ]] && FBW=1024
      [[ -z "$FBH" ]] && FBH=768
      ;;
    576cvbs)
      PSW=720
      PSH=576
      [[ -z "$FBW" ]] && FBW=1024
      [[ -z "$FBH" ]] && FBH=768
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      # For resolution with 2 width and height resolution numbers extract the Height.
      # *p* stand for progressive and *i* stand for interlaced.      
      case $MODE in
        *p*) PSH=$(echo $MODE | cut -d'p' -f 1) ;;
        *i*) PSH=$(echo $MODE | cut -d'i' -f 1) ;;
      esac
      PSW=$(( $PSH*16/9 ))
      [[ "$MODE" == "480"* ]] && PSW=640
      [[ -z "$FBW" || $FBW == 0 ]] && FBW=$PSW
      [[ -z "$FBH" || $FBH == 0 ]] && FBH=$PSH
      ;;
    *x*)
    
      PSW=$(echo $MODE | cut -d'x' -f 1)
      PSH=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
      [ ! -n "$PSH" ] && PSH=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
      [[ -z "$FBW" || $FBW == 0 ]] && FBW=$PSW
      [[ -z "$FBH" || $FBH == 0 ]] && FBH=$PSH
      ;;
  esac
  echo "$FBW $FBH $PSW $PSH"
}

set_main_framebuffer() {
  local FBW=$1
  local FBH=$2
  local BPP=32

  if [[ -n "$FBW" && "$FBW" > 0 && -n "$FBH" && "$FBH" > 0 ]]; then
    MFBH=$(( FBH*2 ))
    fbset -fb /dev/fb0 -g $FBW $FBH $FBW $MFBH $BPP
    echo 0 0 $(( FBW-1 )) $(( FBH-1 )) > /sys/class/graphics/fb0/free_scale_axis
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
FBW=$2
FBH=$3

FILE_MODE="/sys/class/display/mode"

# Here we first clear the primary display buffer of leftover artifacts then set
# the secondary small buffers flag to stop copying across.
blank_buffer >> /dev/null

# Safeguard to prevent blank mode being set.
[[ -z "$MODE" ]] && exit 0

# If the display file mode is NOT present, or the video mode supplied is set to
# auto then just exit.
if [[ ! -f "$FILE_MODE" ]] || [[ $MODE == "auto" ]]; then
  exit 0
fi

# SH=Height in pixels, SW=Width in pixels, BPP=Bits Per Pixel.
BPP=32

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

# This is needed to reset scaling.
echo 0 > /sys/class/ppmgr/ppscaler


AMLOGIC_RES_FILE="/storage/.config/amlogic_resolution.txt"
if [[ "$EE_DEVICE" == "Amlogic" ]]; then
  if [[ ! -f "$AMLOGIC_RES_FILE" ]]; then
    echo 1920 1080 > $AMLOGIC_RES_FILE
  fi
  declare -a AMLOGIC_RES=($(cat "${AMLOGIC_RES_FILE}"))
  if [[ ! -z "${AMLOGIC_RES[@]}" ]]; then
      FBW=${AMLOGIC_RES[0]}
      FBH=${AMLOGIC_RES[1]}
  fi
fi

# Option too Custom set the CVBS Resolution by creating a cvbs_resolution.txt file.
# File contents must just 2 different integers seperated by a space. e.g. 800 600.
CVBS_RES_FILE="/storage/.config/cvbs_resolution.txt"
if [[ "$MODE" == *"cvbs" ]]; then
  if [[ -f "${CVBS_RES_FILE}" ]]; then
    declare -a CVBS_RES=($(cat "${CVBS_RES_FILE}"))
    if [[ ! -z "${CVBS_RES[@]}" ]]; then
        FBW=${CVBS_RES[0]}
        FBH=${CVBS_RES[1]}
    fi
  fi
fi

CUSTOM_RES=$(get_ee_setting ${MODE}.ee_framebuffer)
if [[ ! -z "${CUSTOM_RES}" ]]; then  
  declare -a RES=($(echo "${CUSTOM_RES}"))
  if [[ ! -z "${RES[@]}" ]]; then
      FBW=${RES[0]}
      FBH=${RES[1]}
  fi
fi

switch_resolution $MODE

# Check that the display mode did change or just show the screen and exit. This
# is a safeguard to prevent continueing with display settings.
NEW_MODE=$( cat ${FILE_MODE} )
[[ "$NEW_MODE" != "$MODE" ]] && exit 1


declare -a SIZE=($( get_resolution_size $MODE $FBW $FBH))

FBW=${SIZE[0]}
FBH=${SIZE[1]}
PSW=${SIZE[2]}
PSH=${SIZE[3]}

# Once we know the Width and Height is valid numbers we set the primary display
# buffer, and we multiply the 2nd height by a factor of 2 I assume for interlaced 
# support.
CURRENT_MODE=$( cat ${FILE_MODE} )
if [[ "$CURRENT_MODE" == "$MODE" ]]; then
  echo "SET MAIN FRAME BUFFER"
  set_main_framebuffer $FBW $FBH
  blank_buffer
fi

# Resets the pointer of the current index of the frame buffer to the start.
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# Now that the primary buffer has been acquired we blank it again because the new
# memory allocated, may contain garbage artifact data.

# Legacy code - I have no idea about these values but apparently they should
# make cvbs display properly. The values go over the real values which leads me
# to believe that cvbs uses longer pixel ranges because of overscanning.
declare -a CUSTOM_OFFSETS
if [[ -f "/storage/.config/${MODE}_offsets" ]]; then
  CUSTOM_OFFSETS=( $( cat "/storage/.config/${MODE}_offsets" ) )
fi

OFFSET_SETTING="$(get_ee_setting ${MODE}.ee_offsets)"
if [[ ! -z "${OFFSET_SETTING}" ]]; then
  CUSTOM_OFFSETS=( ${OFFSET_SETTING} )
fi

# Now that the primary buffer has been acquired we blank it again because the new
# memory allocated, may contain garbage artifact data.
COUNT_ARGS=${#CUSTOM_OFFSETS[@]}
if [[ "$MODE" == *"cvbs" ]]; then
  if [[ "$COUNT_ARGS" == "0" ]]; then
    [[ "$MODE" == "480cvbs" ]] && CUSTOM_OFFSETS="55 13"
    [[ "$MODE" == "576cvbs" ]] && CUSTOM_OFFSETS="55 13"
  fi
fi

if [[ "$COUNT_ARGS" == "2" ]]; then
  TMP="${CUSTOM_OFFSETS[0]}"
  CUSTOM_OFFSETS[2]=$(( $RW - $TMP - 1 ))
  TMP="${CUSTOM_OFFSETS[1]}"
  CUSTOM_OFFSETS[3]=$(( $RH - $TMP - 1 ))
fi

COUNT_ARGS=${#CUSTOM_OFFSETS[@]}
if [[ "$COUNT_ARGS" == "4" ]]; then
  echo ${CUSTOM_OFFSETS[@]} > /sys/class/graphics/fb0/window_axis
  echo 1 > /sys/class/graphics/fb0/freescale_mode
  echo 0x10001 > /sys/class/graphics/fb0/free_scale
  exit 0
fi

# Gets the default X, and Y position offsets for cvbs so the display can fit 
# inside the actual analog diplay resolution which is a bit smaller than the 
# resolution it's usually transmitted as.
declare -a BORDERS

# This monolith slab of code basically gets the users preference of if they want 
# to resize there screen display to make it smaller so it can fit into a screen
# properly. If the user suppllies values its coded to restrict the user into not
# letting the user set a width greater than the screen display size.
BORDER_VALS=$(get_ee_setting ee_videowindow)
if [[ ! -z "${BORDER_VALS}" ]]; then
  BORDERS=(${BORDER_VALS})
  COUNT_ARGS=${#BORDERS[@]}
  if [[ ${COUNT_ARGS} != 4 && ${COUNT_ARGS} != 2 ]]; then
    exit 0
  fi
fi

# If border values have been supplied then we can check the offsets and the
# width and height and make sure they are all valid and will not cause issues for
# when we set the borders, and allow the primary display buffer to resize the screen.
if [[ ! -z "${BORDERS[@]}" ]]; then
  BW=${BORDERS[2]}
  [[ -z "$BW" ]] && BW=$PSW
  BH=${BORDERS[3]}
  [[ -z "$BH" ]] && BH=$PSH
  set_display_borders ${BORDERS[0]} ${BORDERS[1]} $BW $BH $PSW $PSH
fi

