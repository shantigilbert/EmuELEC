#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# This whole file has become very hacky, I am sure there is a better way to do all of this, but for now, this works.

blank_buffer

BTENABLED=$(get_ee_setting ee_bluetooth.enabled)

if [[ "$BTENABLED" == "1" ]]; then
	# We don't need the BT agent while running games
    systemctl stop bluetooth-agent
fi

# clear terminal window
	clear > /dev/tty < /dev/null 2>&1
	clear > /dev/tty0 < /dev/null 2>&1
	clear > /dev/tty1 < /dev/null 2>&1
	clear > /dev/console < /dev/null 2>&1

arguments="$@"

emuelec-utils setauddev

# set audio to alsa
set_audio alsa

# Set the variables
CFG="/storage/.emulationstation/es_settings.cfg"
LOGEMU="No"
VERBOSE=""
LOGSDIR="/emuelec/logs"
TBASH="/usr/bin/bash"

# Make sure the /emuelec/logs directory exists
if [[ ! -d "$LOGSDIR" ]]; then
    mkdir -p "$LOGSDIR"
fi

if [ "$(get_es_setting string LogLevel)" == "minimal" ]; then 
    EMUELECLOG="/dev/null"
    cat /etc/motd > "$LOGSDIR/emuelec.log"
    echo "Logging has been dissabled, enable it in Main Menu > System Settings > Developer > Log Level" >> "$LOGSDIR/emuelec.log"
else
    EMUELECLOG="$LOGSDIR/emuelec.log"
fi

set_kill_keys() {
    # If gptokeyb is running we kill it first. 
    kill_video_controls
    KILLTHIS=${1}
    KILLSIGNAL=${2}
}

# Extract the platform name from the arguments
PLATFORM="${arguments##*-P}"  # read from -P onwards
PLATFORM="${PLATFORM%% *}"  # until a space is found

CORE="${arguments##*--core=}"  # read from --core= onwards
CORE="${CORE%% *}"  # until a space is found

EMULATOR="${arguments##*--emulator=}"  # read from --emulator= onwards
EMULATOR="${EMULATOR%% *}"  # until a space is found

PORTNAME="$1"

SET_DISPLAY_SH="setres.sh"
VIDEO="$(cat /sys/class/display/mode)"
VIDEO_EMU=$(get_ee_setting nativevideo "${PLATFORM}" "${PORTNAME}")
[[ -z "$VIDEO_EMU" ]] && VIDEO_EMU=$VIDEO

KILLTHIS="none"
KILLSIGNAL="15"

# if there wasn't a --NOLOG included in the arguments, enable the emulator log output. TODO: this should be handled in ES menu
if [[ $arguments != *"--NOLOG"* ]]; then
    LOGEMU="Yes"
    VERBOSE="-v"
fi

# Show splash screen if enabled
SPL=$(get_ee_setting ee_splash.enabled)
[ "$SPL" -eq "1" ] && ${TBASH} show_splash.sh gameloading "$PLATFORM" "${PORTNAME}"

# Set the display video to that of the emulator setting.
[ ! -z "$VIDEO_EMU" ] && $TBASH $SET_DISPLAY_SH $VIDEO_EMU $PLATFORM # set display


CONTROLLERCONFIG="${arguments#*--controllers=*}"
echo "${CONTROLLERCONFIG}" | tr -d '"' > "/tmp/controllerconfig.txt"

GPTOKEYB=$(get_ee_setting "gptokeyb" "${PLATFORM}" "${PORTNAME}")
VIRTUAL_KB=

RUNTHIS="$PORTNAME"
RUNFILE="/usr/bin/${PORTNAME}.sh"
[[ -f "$RUNFILE" ]] && RUNTHIS="$RUNFILE"

case ${PORTNAME} in
	"abuse")
		VIRTUAL_KB=$(emuelec-utils set_gptokeyb "abuse" "${GPTOKEYB}")
		set_kill_keys "abuse"
		;;
	"bgdi")
		VIRTUAL_KB=$(emuelec-utils set_gptokeyb "sorr" "${GPTOKEYB}")
		set_kill_keys "bgdi"
		;;
esac

if [ "$(get_es_setting string LogLevel)" != "minimal" ]; then # No need to do all this if log is disabled
    # Clear the log file
    echo "EmuELEC Run Log" > $EMUELECLOG
    cat /etc/motd >> $EMUELECLOG

    # Write the command to the log file.
    echo "PLATFORM: $PLATFORM" >> $EMUELECLOG
		echo "PORT NAME: ${PORTNAME}" >> $EMUELECLOG
    echo "1st Argument: $1" >> $EMUELECLOG
    echo "2nd Argument: $2" >> $EMUELECLOG
    echo "3rd Argument: $3" >> $EMUELECLOG
    echo "4th Argument: $4" >> $EMUELECLOG
    echo "Full arguments: $arguments" >> $EMUELECLOG
    echo "Run Command is:" >> $EMUELECLOG
    eval echo ${RUNTHIS} >> $EMUELECLOG
fi

gptokeyb 1 ${KILLTHIS} ${VIRTUAL_KB} -killsignal ${KILLSIGNAL} &

# Execute the command and try to output the results to the log file if it was not disabled.
if [[ $LOGEMU == "Yes" ]]; then
   echo "Emulator Output is:" >> $EMUELECLOG
   eval ${RUNTHIS} >> $EMUELECLOG 2>&1
   ret_error=$?
else
   echo "Emulator log was dissabled" >> $EMUELECLOG
   eval ${RUNTHIS} > /dev/null 2>&1
   ret_error=$?
fi

blank_buffer

# clear terminal window
	reset > /dev/tty < /dev/null 2>&1
	reset > /dev/tty0 < /dev/null 2>&1
	reset > /dev/tty1 < /dev/null 2>&1
	reset > /dev/console < /dev/null 2>&1

# Return to default mode
$TBASH $SET_DISPLAY_SH $VIDEO

# Show exit splash
${TBASH} show_splash.sh exit

# Just in case
kill_video_controls

#{log_addon}#

# reset audio to default
set_audio default

if [[ "$BTENABLED" == "1" ]]; then
	# Restart the bluetooth agent
    systemctl start bluetooth-agent
fi

if [[ "$ret_error" != "0" ]]; then
    echo "exit $ret_error" >> $EMUELECLOG

    # Since the error was not because of missing BIOS but we did get an error, display the log to find out
    text_viewer -e -w -t "Error! ${PLATFORM}-${EMULATOR}-${CORE}-${PORT}" -f 24 ${EMUELECLOG}
    blank_buffer
    exit 1
else
    echo "exit 0" >> $EMUELECLOG
    blank_buffer
    exit 0
fi
