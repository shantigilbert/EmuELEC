#!/bin/bash

# Source predefined functions and variables
. /etc/profile

CONFIGDIR="/emuelec/configs/mupen64plussa"

if [[ ! -f "${CONFIGDIR}/InputAutoCfg.ini" ]]; then
	mkdir -p ${CONFIGDIR}
	cp /usr/local/share/mupen64plus/InputAutoCfg.ini ${CONFIGDIR}/
fi

if [[ ! -f "${CONFIGDIR}/mupen64plus.cfg" ]]; then
	mkdir -p ${CONFIGDIR}
	cp /usr/local/share/mupen64plus/mupen64plus.cfg ${CONFIGDIR}/
fi


FILE="$1"
if [[ "${FILE: -4}" == ".zip" ]]; then
	mkdir -p /tmp/mupen64plus
	rm -fr /tmp/mupen64plus/*.*
	unzip "${1}" -d "/tmp/mupen64plus"
	FILE=$( ls /tmp/mupen64plus/*.*64* )	
fi

AUTOGP=$(get_ee_setting mupen64plus_auto_gamepad)
if [[ "${AUTOGP}" != "0" ]]; then
  /usr/bin/set_mupen64_joy.sh
fi

case ${2} in
	"m64p_gl64mk2")
		mupen64plus --configdir ${CONFIGDIR} --gfx mupen64plus-video-glide64mk2 "${FILE}"
	;;
	*)
		mupen64plus --configdir ${CONFIGDIR} --gfx mupen64plus-video-rice "${FILE}"
	;;
esac

rm -fr /tmp/mupen64plus/*.*
