#!/bin/bash

if [[ ! -f /storage/roms/ports/CaveStory/Doukutsu.exe ]] || [[ ! -d /storage/roms/ports/CaveStory/data ]]; then
    /emuelec/scripts/fbterm.sh "echo Could not find Doukutsu.exe or the data directory, please make sure you copied the game into /storage/roms/ports/CaveStory.; sleep 10" &
    error_process="$!"
    sleep 10
    # Kill fbterm and all children
    pkill -P "$!"
    exit 1
fi

/emuelec/scripts/emuelecRunEmu.sh "/storage/roms/ports/CaveStory/Doukutsu.exe" -Pports "${2}" -Cnxengine "-SC${0}"
