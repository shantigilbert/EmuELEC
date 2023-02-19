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

# hides the screen from the buffer, 1 activates it, 0 otherwise.
hide_screen()
{
  echo $1 > /sys/class/graphics/fb0/blank
  echo $1 > /sys/class/graphics/fb1/blank
}

# switches the display mode.
switch_resolution()
{
  local MODE=$1

  # Here we first clear the primary display buffer of leftover artifacts then set
  # the secondary small buffers flag to stop copying across.
  blank_buffer >> /dev/null

  # Makes sure it's a valid mode before trying to set the display mode.
  case $MODE in
    480cvbs|576cvbs|480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*|*x*)
      echo $MODE > "${FILE_MODE}"
      sleep 1
      ;;
  esac
}

# gets the resolution sizes, its real size, and its scaled size.
get_resolution_size()
{
  local MODE=$1

  # Here we set the Height and Width of the particular resolution, RH and RW stands
  # for Real Width and Real Height respectively.
  # SW and SH stand for scaled width and height and only differ in cvbs cases.
  local RW=0
  local RH=0
  case $MODE in
    480cvbs)
      RW=720
      RH=480
      # Sets the default scaled size for cvbs, Note - it's ratio is same as res.
      [[ -z "$SW" ]] && SW=1280
      [[ -z "$SH" ]] && SH=960
      ;;
    576cvbs)
      RW=720
      RH=576
      [[ -z "$SW" ]] && SW=1280
      [[ -z "$SH" ]] && SH=960
      ;;
    480p*|480i*|576p*|720p*|1080p*|1440p*|2160p*|576i*|720i*|1080i*|1440i*|2160i*)
      # Extracts height from the mode for progressive and interlaced scanning.
      case $MODE in
        *p*) SH=$(echo $MODE | cut -d'p' -f 1) ;;
        *i*) SH=$(echo $MODE | cut -d'i' -f 1) ;;
      esac    
      SW=$(( $SH*16/9 ))
      # Sets 480p's width to 640, not sure if we keep this value as it really 
      # should be 853.
      [[ "$MODE" == "480"* ]] && SW=640
      RW=$SW
      RH=$SH
      ;;
    *x*)
      # Extracts width and height for modes that have both dimensions contained.
      SW=$(echo $MODE | cut -d'x' -f 1)
      SH=$(echo $MODE | cut -d'x' -f 2 | cut -d'p' -f 1)
      [ ! -n "$SH" ] && H=$(echo $MODE | cut -d'x' -f 2 | cut -d'i' -f 1)
      RW=$SW
      RH=$SH      
      ;;
  esac
  echo "$SW $SH $RW $RH"
}

# Sets the main framebuffer fb0 to match the display mode. For cvbs the scaled,
# dimensions are larger than the real sizes.
set_main_framebuffer() {
  local SW=$1
  local SH=$2
  local BPP=32

  if [[ -n "$SW" && "$SW" > 0 && -n "$SH" && "$SH" > 0 ]]; then
    # We multiply the 2nd height by a factor of 2 I assume for interlaced 
    # support.
    MSH=$(( SH*2 ))
    fbset -fb /dev/fb0 -g $SW $SH $SW $MSH $BPP
    echo 0 0 $(( SW-1 )) $(( SH-1 )) > /sys/class/graphics/fb0/free_scale_axis
    echo 0 > /sys/class/graphics/fb0/free_scale
    echo 0 > /sys/class/graphics/fb0/freescale_mode
  fi
}

# Sets display borders around the screen. Expects 6 arguments, X position,
# Y position, the width and height of the display area. Also the real width and 
# height of the display size.
set_display_borders() {
  local PX=$1
  local PY=$2
  local PW=$3
  local PH=$4
  local RW=$5
  local RH=$6
  
  # Make sure recieved arguments are valid and good.
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
# Platform is optional and used so the user can supply ee_videowindow sizes 
# specific for the Core Emulator.
PLATFORM=$2

FILE_MODE="/sys/class/display/mode"

# Safeguard to prevent a blank mode being set.
[[ -z "$MODE" ]] && exit 0

# If the display file mode is NOT present, or the video mode supplied is set to
# auto then just exit.
if [[ ! -f "$FILE_MODE" ]] || [[ $MODE == "auto" ]]; then
  exit 0
fi


# BPP=Bits Per Pixel.
BPP=32

# The current display mode before it may get changed below.
OLD_MODE=$( cat ${FILE_MODE} )

# Legacy code, we use to set the sub-buffer that is used for small parts of
# graphics. It has always been set to 32x32 so seems no need to change it.
BUFF=$(get_ee_setting ee_video_fb1_size)
[[ -z "$BUFF" ]] && BUFF=32

if [[ -n "$BUFF" ]] && [[ $BUFF > 0 ]]; then
  fbset -fb /dev/fb1 -g $BUFF $BUFF $BUFF $BUFF $BPP
fi

# This is needed to reset scaling.
echo 0 > /sys/class/ppmgr/ppscaler

# Resets the pointer of the current index of the frame buffer to the start.
[[ "$EE_DEVICE" == "Amlogic-ng" ]] && fbfix

# Switch the resolution of the display mode. 
switch_resolution $MODE

# Give some time for the res to take effect for the display.
#sleep 0.25

# Here we hide the screen after mode change so the buffer can be set.
#hide_screen 1

# Check that the display mode did change or just show the screen and exit. This
# is a safeguard to prevent continueing with display settings.
NEW_MODE=$( cat ${FILE_MODE} )
[[ "$NEW_MODE" != "$MODE" ]] && exit 1

# Option to Custom set the CVBS Resolution by creating a cvbs_resolution.txt file.
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

# Get the real and scaled sizes of the display.
declare -a SIZE=($( get_resolution_size $MODE ))

SW=${SIZE[0]}
SH=${SIZE[1]}
RW=${SIZE[2]}
RH=${SIZE[3]}

# Once we know the Width and Height is valid numbers we set the primary display
# buffer.
echo "SET MAIN FRAME BUFFER"
set_main_framebuffer $RW $RH

# Clears the screen of any pixel corruption so it becomes fresh and blank.
blank_buffer

# We can show the screen now that we have properly set the dimensions.
#hide_screen 0

# Legacy code - I have no idea about these values but apparently they should
# make cvbs display properly. The values go over the real values which leads me
# to believe that cvbs uses longer pixel ranges because of overscanning.
declare -a CVBS_OFFSETS
if [[ "$MODE" == *"cvbs" ]]; then
  CVBS_OFFSETS=( $( cat "/storage/.config/${MODE}_offsets" ) )
  COUNT_ARGS=${#CVBS_OFFSETS[@]}
  if [[ "$COUNT_ARGS" == "0" ]]; then
    [[ "$MODE" == "480cvbs" ]] && CVBS_OFFSETS="60 20 659 459"
    [[ "$MODE" == "576cvbs" ]] && CVBS_OFFSETS="60 20 659 555"
  elif [[ "$COUNT_ARGS" == "2" ]]; then
      TMP="${CVBS_OFFSETS[0]}"
      CVBS_OFFSETS[2]=$(( $RW - $TMP - 1 ))
      TMP="${CVBS_OFFSETS[1]}"
      CVBS_OFFSETS[3]=$(( $RH - $TMP - 1 ))
  fi
fi

case $MODE in
	480cvbs)
		echo ${CVBS_OFFSETS[@]} > /sys/class/graphics/fb0/window_axis
    echo 1 > /sys/class/graphics/fb0/freescale_mode
		echo 0x10001 > /sys/class/graphics/fb0/free_scale
    exit 0
		;;
	576cvbs)
		echo ${CVBS_OFFSETS[@]} > /sys/class/graphics/fb0/window_axis
    echo 1 > /sys/class/graphics/fb0/freescale_mode
		echo 0x10001 > /sys/class/graphics/fb0/free_scale
    exit 0
		;;
esac

# Gets the default X, and Y position offsets for cvbs so the display can fit 
# inside the actual analog diplay resolution which is a bit smaller than the 
# resolution it's usually transmitted as.
declare -a BORDERS

# This monolith slab of code basically gets the users preference of if they want 
# to resize there screen display to make it smaller so it can fit into a screen
# properly. If the user suppllies values its coded to restrict the user into not
# letting the user set a width greater than the screen display size.
BORDER_VALS=$(get_ee_setting ee_videowindow ${PLATFORM})
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
  PW=${BORDERS[2]}
  [[ -z "$PW" ]] && PW=$RW
  PH=${BORDERS[3]}
  [[ -z "$PH" ]] && PH=$RH
  set_display_borders ${BORDERS[0]} ${BORDERS[1]} $PW $PH $RW $RH
fi
