#!/bin/bash

# This file sets the hdmi output and frame buffer to the argument in pixel width.
# Allowed argument example ./display.sh 1080p60hz <-- For height 1080 pixels.

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

resolution=720p60hz
bpp=32
hz=60

i=$1

[ -z "$1" ] && i=$resolution

[[ $i == *"p"* ]] && w=$(echo $i | cut -d'p' -f 1)
[[ $i == *"i"* ]] && w=$(echo $i | cut -d'i' -f 1)
[[ $i == *"cvbs"* ]] && w=$(echo $i | cut -d'c' -f 1)

if [[ $i == *"hz"* ]]; then
	hz=${i:(-4):2}
fi

# echo $w
# echo $hz
# exit 1

case $i in
    480)
       w=720
       di=$(($i*2))
       w1=$(($w-1))
       i1=$(($i-1))
       fbset -fb /dev/fb0 -g $w $i $w $di $bpp
       fbset -fb /dev/fb1 -g 32 32 32 32 32
       mode=$(echo "${i}p${hz}hz")
       echo $mode > /sys/class/display/mode
       echo 0 > /sys/class/graphics/fb0/free_scale
       echo 1 > /sys/class/graphics/fb0/freescale_mode
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/free_scale_axis
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/window_axis
       echo 0 > /sys/class/graphics/fb1/free_scale
       ;;
    576|720|1080|2160)
       w=$(($i*16/9))
       di=$(($i*2))
       w1=$(($w-1))
       i1=$(($i-1))
       fbset -fb /dev/fb0 -g $w $i $w $di $bpp
       fbset -fb /dev/fb1 -g 32 32 32 32 32
       mode=$(echo "${i}p${hz}hz")
       echo $mode > /sys/class/display/mode
       echo 0 > /sys/class/graphics/fb0/free_scale
       echo 1 > /sys/class/graphics/fb0/freescale_mode
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/free_scale_axis
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/window_axis
       echo 0 > /sys/class/graphics/fb1/free_scale
       ;;
    *)
       i=720
       w=$(($i*16/9))
       di=$(($i*2))
       w1=$(($w-1))
       i1=$(($i-1))
       fbset -fb /dev/fb0 -g $w $i $w $di $bpp
       fbset -fb /dev/fb1 -g 32 32 32 32 32
       mode=$(echo "${i}p${hz}hz")
       echo $mode > /sys/class/display/mode
       echo 0 > /sys/class/graphics/fb0/free_scale
       echo 1 > /sys/class/graphics/fb0/freescale_mode
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/free_scale_axis
       echo 0 0 $w1 $i1 > /sys/class/graphics/fb0/window_axis
       echo 0 > /sys/class/graphics/fb1/free_scale
       ;;
esac

# Enable framebuffer device
echo 0 > /sys/class/graphics/fb0/blank

# Blank fb1 to prevent static noise
echo 1 > /sys/class/graphics/fb1/blank
