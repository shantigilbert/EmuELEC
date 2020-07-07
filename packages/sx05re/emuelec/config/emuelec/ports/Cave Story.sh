#!/bin/bash

if [[ ! -f /storage/roms/ports/CaveStory/Doukutsu.exe ]]; then
    /emuelec/scripts/fbterm.sh "echo Could not find Doukutsu.exe, please make sure you copied the game into /storage/roms/ports/CaveStory.; sleep 10"
    exit 1
fi

if [[ ! -d /storage/roms/ports/CaveStory/data ]]; then
    /emuelec/scripts/fbterm.sh "echo Could not find the data directory, please make sure you copied the game data into /storage/roms/ports/CaveStory/data.; sleep 10"
    exit 1
fi

/emuelec/scripts/emuelecRunEmu.sh "/storage/roms/ports/CaveStory/Doukutsu.exe" -Pports "${2}" -Cnxengine "-SC${0}"
