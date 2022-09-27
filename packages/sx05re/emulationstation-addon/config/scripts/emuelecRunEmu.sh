#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# This whole file has become very hacky, I am sure there is a better way to do all of this, but for now, this works.

arguments="$@"

#set audio device out according to emuelec.conf
AUDIO_DEVICE="hw:$(get_ee_setting audio_device)"
[ $AUDIO_DEVICE = "hw:" ] &&  AUDIO_DEVICE="hw:0,0"
sed -i "s|pcm \"hw:.*|pcm \"${AUDIO_DEVICE}\"|" /storage/.config/asound.conf

# set audio to alsa
set_audio alsa

# Set the variables
CFG="/storage/.emulationstation/es_settings.cfg"
LOGEMU="No"
VERBOSE=""
LOGSDIR="/emuelec/logs"
EMUELECLOG="$LOGSDIR/emuelec.log"
EMU=$(get_es_setting string EmuELEC_${1}_CORE)
TBASH="/usr/bin/bash"
JSLISTENCONF="/emuelec/configs/jslisten.cfg"
RATMPCONF="/tmp/retroarch/ee_retroarch.cfg"
RATMPCONF="/storage/.config/retroarch/retroarch.cfg"
set_kill_keys() {
	KILLTHIS=${1}
    sed -i '/program=.*/d' ${JSLISTENCONF}
	echo "program=\"/usr/bin/killall ${1}\"" >> ${JSLISTENCONF}
	}

# Make sure the /emuelec/logs directory exists
if [[ ! -d "$LOGSDIR" ]]; then
mkdir -p "$LOGSDIR"
fi


# Extract the platform from the arguments in order to show the correct bezel/splash
if [[ "$arguments" == *"-P"* ]]; then
	PLATFORM="${arguments##*-P}"  # read from -P onwards
	PLATFORM="${PLATFORM%% *}"  # until a space is found
else
# if no -P was set, read the first argument as platform
	PLATFORM="$1"
fi

[ "$1" = "LIBRETRO" ] && ROMNAME="$3" || ROMNAME="$2"

# JSLISTEN setup so that we can kill running ALL emulators using hotkey+start
/storage/.emulationstation/scripts/configscripts/z_getkillkeys.sh
. ${JSLISTENCONF}

KILLDEV=${ee_evdev}
KILLTHIS="none"

# remove Libretro_ from the core name
EMU=$(echo "$EMU" | sed "s|Libretro_||")

# if there wasn't a --NOLOG included in the arguments, enable the emulator log output. TODO: this should be handled in ES menu
if [[ $arguments != *"--NOLOG"* ]]; then
LOGEMU="Yes"
VERBOSE="-v"
fi

# if the emulator is in es_settings this is the line that will run 
RUNTHIS='/usr/bin/retroarch $VERBOSE -L /tmp/cores/${EMU}_libretro.so --config ${RATMPCONF} "${ROMNAME}"'

# very WIP {

BEZ=$(get_ee_setting bezels.enabled)
[ "$BEZ" == "1" ] && ${TBASH} /usr/bin/bezels.sh "$PLATFORM" "${ROMNAME}" || ${TBASH} /usr/bin/bezels.sh "default"
SPL=$(get_ee_setting splash.enabled)
[ "$SPL" == "1" ] && ${TBASH} /usr/bin/show_splash.sh "$PLATFORM" "${ROMNAME}" || ${TBASH} /usr/bin/show_splash.sh "default" 

# } very WIP 

# Read the first argument in order to set the right emulator
case $1 in
"HATARI")
	if [ "$EMU" = "HATARISA" ]; then
	set_kill_keys "hatari"
	RUNTHIS='${TBASH} /usr/bin/hatari.start "${ROMNAME}"'
	fi
	;;
"OPENBOR")
	set_kill_keys "OpenBOR"
	RUNTHIS='${TBASH} /usr/bin/openbor.sh "${ROMNAME}"'
	;;
"RETROPIE")
    set_kill_keys "fbterm"
	RUNTHIS='${TBASH} /usr/bin/fbterm.sh "${ROMNAME}"'
	EMUELECLOG="$LOGSDIR/ee_script.log"
	;;
"LIBRETRO")
	RUNTHIS='/usr/bin/retroarch $VERBOSE -L /tmp/cores/$2_libretro.so --config ${RATMPCONF} "${ROMNAME}"'
		;;
"REICAST")
    if [ "$EMU" = "REICASTSA" ]; then
    set_kill_keys "reicast"
		sed -i "s|REICASTBIN=.*|REICASTBIN=\"/usr/bin/reicast\"|" /usr/bin/reicast.sh
		RUNTHIS='${TBASH} /usr/bin/reicast.sh "${ROMNAME}"'
		LOGEMU="No" # ReicastSA outputs a LOT of text, only enable for debugging.
		cp -rf /storage/.config/reicast/emu_new.cfg /storage/.config/reicast/emu.cfg
		fi
		if [ "$EMU" = "REICASTSA_OLD" ]; then
		set_kill_keys "reicast_old"
		sed -i "s|REICASTBIN=.*|REICASTBIN=\"/usr/bin/reicast_old\"|" /usr/bin/reicast.sh
		RUNTHIS='${TBASH} /usr/bin/reicast.sh "${ROMNAME}"'
		LOGEMU="No" # ReicastSA outputs a LOT of text, only enable for debugging.
		cp -rf /storage/.config/reicast/emu_old.cfg /storage/.config/reicast/emu.cfg
		fi
		;;
"MAME"|"ARCADE")
	if [ "$EMU" = "AdvanceMame" ]; then
	set_kill_keys "advmame"
	RUNTHIS='${TBASH} /usr/bin/advmame.sh "${ROMNAME}"'
	fi
	;;
"DRASTIC")
	set_kill_keys "drastic"
	RUNTHIS='${TBASH} /storage/.emulationstation/scripts/drastic.sh "${ROMNAME}"'
		;;
"N64")
    if [ "$EMU" = "M64P" ]; then
    set_kill_keys "mupen64plus"
	RUNTHIS='${TBASH} /usr/bin/m64p.sh "${ROMNAME}"'
	fi
	;;
"AMIGA")
    if [ "$EMU" = "AMIBERRY" ]; then
    set_kill_keys "amiberry"
	RUNTHIS='${TBASH} /usr/bin/amiberry.start "${ROMNAME}"'
	fi
	;;
"SCUMMVM")
	RUNTHIS='/usr/bin/retroarch $VERBOSE -L /tmp/cores/scummvm_libretro.so --config ${RATMPCONF} "${ROMNAME}"'
	;;
"DOSBOX")
    if [ "$EMU" = "DOSBOXSDL2" ]; then
    set_kill_keys "dosbox"
	RUNTHIS='${TBASH} /usr/bin/dosbox.start "${ROMNAME}"'
	fi
	;;		
"PSP")
	if [ "$EMU" = "PPSSPPSA" ]; then
	set_kill_keys "ppsspp"
	RUNTHIS='${TBASH} /usr/bin/ppsspp.sh "${ROMNAME}"'
	fi
	;;
"NEOCD")
	if [ "$EMU" = "fbneo" ]; then
	RUNTHIS='/usr/bin/retroarch $VERBOSE -L /tmp/cores/fbneo_libretro.so --subsystem neocd --config ${RATMPCONF} "${ROMNAME}"'
	fi
	;;
esac

# If we are running a Libretro emulator set all the settings that we chose on ES
if [[ ${RUNTHIS} == *"libretro"* ]]; then
CORE=${EMU}
[ -z ${CORE} ] && CORE=${2}
echo ${CORE}
SHADERSET=$(/usr/bin/setsettings.sh "${PLATFORM}" "${ROMNAME}" "${CORE}")
echo $SHADERSET

if [[ ${SHADERSET} != 0 ]]; then
RUNTHIS=$(echo ${RUNTHIS} | sed "s|--config|${SHADERSET} --config|")
fi

fi
# Clear the log file
echo "EmuELEC Run Log" > $EMUELECLOG

# Write the command to the log file.
echo "PLATFORM: $PLATFORM" >> $EMUELECLOG
echo "ROM NAME: ${ROMNAME}" >> $EMUELECLOG
echo "USING CONFIG: ${RATMPCONF}" >> $EMUELECLOG
echo "1st Argument: $1" >> $EMUELECLOG 
echo "2nd Argument: $2" >> $EMUELECLOG
echo "3rd Argument: $3" >> $EMUELECLOG 
echo "4th Argument: $4" >> $EMUELECLOG 
echo "Run Command is:" >> $EMUELECLOG 
eval echo  ${RUNTHIS} >> $EMUELECLOG 

if [[ "$KILLTHIS" != "none" ]]; then

# We need to make sure there are at least 2 buttons setup (hotkey plus another) if not then do not load jslisten
	KKBUTTON1=$(sed -n "s|^button1=\(.*\)|\1|p" "${JSLISTENCONF}")
	KKBUTTON2=$(sed -n "s|^button2=\(.*\)|\1|p" "${JSLISTENCONF}")
	if [ ! -z $KKBUTTON1 ] && [ ! -z $KKBUTTON2 ]; then
		if [ ${KILLDEV} == "auto" ]; then
			/usr/bin/jslisten &>> ${EMUELECLOG} &
		else
			/usr/bin/jslisten --device /dev/input/${KILLDEV} &>> ${EMUELECLOG} &
		fi
	fi
fi

# Only run fbfix on N2
[[ ! -f "/ee_s905" ]] && /usr/bin/fbfix

# Exceute the command and try to output the results to the log file if it was not dissabled.
if [[ $LOGEMU == "Yes" ]]; then
   echo "Emulator Output is:" >> $EMUELECLOG
   eval ${RUNTHIS} >> $EMUELECLOG 2>&1
else
   echo "Emulator log was dissabled" >> $EMUELECLOG
   eval ${RUNTHIS}
fi 

# Only run fbfix on N2
[[ ! -f "/ee_s905" ]] && /usr/bin/fbfix

# Show exit splash
${TBASH} /usr/bin/show_splash.sh exit

# Kill jslisten, we don't need to but just to make sure 
killall jslisten

# Just for good measure lets make a symlink to Retroarch logs if it exists
if [[ -f "/storage/.config/retroarch/retroarch.log" ]]; then
	ln -sf /storage/.config/retroarch/retroarch.log ${LOGSDIR}/retroarch.log
fi

#{log_addon}#

# Return to default mode
${TBASH} /usr/bin/setres.sh

# reset audio to default
set_audio default
