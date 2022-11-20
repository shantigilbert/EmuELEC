#!/bin/sh

case "$1" in
    start)
        [ -d "/sys/module/amvdec_h265" ] && echo 3 > /sys/module/amvdec_h265/parameters/double_write_mode
        [ -d "/sys/module/amvdec_vp9"  ] && echo 3 > /sys/module/amvdec_vp9/parameters/double_write_mode
        [ -d "/sys/module/amvdec_av1"  ] && echo 3 > /sys/module/amvdec_av1/parameters/double_write_mode
    ;;
    stop)
        [ -d "/sys/module/amvdec_h265" ] && echo 0 > /sys/module/amvdec_h265/parameters/double_write_mode
        [ -d "/sys/module/amvdec_vp9"  ] && echo 0 > /sys/module/amvdec_vp9/parameters/double_write_mode
        [ -d "/sys/module/amvdec_av1"  ] && echo 0 > /sys/module/amvdec_av1/parameters/double_write_mode
    ;;
esac
