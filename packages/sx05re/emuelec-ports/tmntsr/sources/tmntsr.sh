#!/bin/bash

. /etc/profile

ROMSDIRECTORY="/storage/roms"

GAMEASSEMBLY="TMNT.exe"
GAMEDIR="${ROMSDIRECTORY}/ports/tmntsr"

# switch to the gamedata folder
cd "${GAMEDIR}/gamedata"

# check if required files are installed
if [[ ! -f "${GAMEDIR}/gamedata/${GAMEASSEMBLY}" ]]; then
    text_viewer -e -w -t "ERROR!" -f 24 -m "TMNT:SR Game Data does not exist on ${GAMEDIR}/gamedata\n\nYou need to provide your own game data from your copy of the game"
    exit 0
fi

# Setup mono
MONODIR="/emuelec/mono"
MONOFILE="${ROMSDIRECTORY}/ports/mono-6.12.0.122-aarch64.squashfs"

if [ ! -e "${MONOFILE}" ]; then
MONOURL="https://github.com/PortsMaster/PortMaster-Hosting/releases/download/large-files/mono-6.12.0.122-aarch64.squashfs"
    text_viewer -y -w -f 24 -t "MONO does not exists!" -m "It seems this is the first time you are launching TMNT:SR or the MONO file does not exists\n\nMONO is about 260 MB, and you need to be connected to the internet\n\nIMPORTANT: THIS IS NOT THE GAME DATA! YOU STILL NEED TO PROVIDE THIS FROM YOUR COPY OF TMNT:SR\n\nDownload and continue?"
        if [[ $? == 21 ]]; then
            ee_console enable
            wget "${MONOURL}" -O "${MONOFILE}" -q --show-progress > /dev/tty0 2>&1
            ee_console disable
        else
            exit 0
        fi
else
    mkdir -p "${MONODIR}"
    umount "${MONOFILE}" || true
    mount "${MONOFILE}" "${MONODIR}"
fi

# Setup path and other environment variables
export XDG_DATA_HOME=/emuelec/configs
export MONO_PATH="${GAMEDIR}/dlls":"${GAMEDIR}/gamedata":"${GAMEDIR}/monomod"
export LD_LIBRARY_PATH="${GAMEDIR}/libs":"${MONODIR}/lib":"$LD_LIBRARY_PATH"
export PATH="${MONODIR}/bin":"$PATH"

# Setup savedir
if [ ! -L ${XDG_DATA_HOME}/Tribute\ Games/TMNT ]; then
rm -rf ${XDG_DATA_HOME}/Tribute\ Games/TMNT
mkdir -p ${XDG_DATA_HOME}/Tribute\ Games/
ln -sfv "${GAMEDIR}/savedata" ${XDG_DATA_HOME}/Tribute\ Games/TMNT
fi

# Remove all the dependencies in favour of system libs - e.g. the included 
rm -f System*.dll mscorlib.dll FNA.dll Mono.*.dll

# Copy the port files if not yet done
if [[ ! -f "${GAMEDIR}/MMLoader.exe" ]]; then
    ee_console enable
    echo "Copying port files, this will only be done on the first run. Please wait..."
    tar –xvzf /emuelec/configs/tmntsr.tar.xz –C "${ROMSDIRECTORY}/ports"
    ee_console disable
fi

# Configure the renderpath
export FNA3D_FORCE_DRIVER=OpenGL
export FNA3D_OPENGL_FORCE_ES3=1
export FNA3D_OPENGL_FORCE_VBO_DISCARD=1
export FNA_SDL2_FORCE_BASE_PATH=0
regen_checksum=no

sha1sum -sc "${GAMEDIR}/gamedata/.ver_checksum"
if [ $? -ne 0 ]; then
	echo "Checksum fail or unpatched binary found, patching game..." > /dev/tty0 2>&1
	rm -f "${GAMEDIR}/gamedata/.astc_done"
	rm -f "${GAMEDIR}/gamedata/.patch_done"
fi

# For Amlogic-NG we need the textures at full size so skip the conversion
touch "${GAMEDIR}/gamedata/.astc_done"

# Textures not converted? let's perform first time setup
if [[ ! -f "${GAMEDIR}/gamedata/.astc_done" ]]; then
	echo "Performing first time setup..." > /dev/tty0 2>&1
	echo "This may take upwards of 15 minutes (RK3326), go grab a pizza slice or two." > /dev/tty0 2>&1

	# Re-encode a few common textures as ASTC 4x4 due to RAM constraints.
	mono "${GAMEDIR}/FNARepacker.exe" "${GAMEDIR}/gamedata/Content/" > >(tee ${GAMEDIR}/astc_log.txt) 2>&1
	
	# Mark step as done
	touch "${GAMEDIR}/gamedata/.astc_done"
	regen_checksum=yes
fi

# MONOMODDED files not found, let's perform patching
if [[ ! -f "${GAMEDIR}/gamedata/.patch_done" ]]; then
	echo "Performing game patching..." > /dev/tty0 2>&1

	# Configure MonoMod settings
	export MONOMOD_MODS="${GAMEDIR}/patches"
	export MONOMOD_DEPDIRS="${MONO_PATH}":"${GAMEDIR}/monomod"

	# Patch the ParisEngine/gameassembly files
	mono "${GAMEDIR}/monomod/MonoMod.exe" "${GAMEDIR}/gamedata/ParisEngine.dll" > >(tee ${GAMEDIR}/monomod_log.txt) 2>&1
	mono "${GAMEDIR}/monomod/MonoMod.exe" "${GAMEDIR}/gamedata/${GAMEASSEMBLY}" > >(tee -a ${GAMEDIR}/monomod_log.txt) 2>&1
	if [ $? -ne 0 ]; then
		echo "Failure performing first time setup, report this." > /dev/tty0 2>&1
		sleep 5
		exit -1
	fi

	# Mark step as done
	touch "${GAMEDIR}/gamedata/.patch_done"
	regen_checksum=yes
fi

# Regenerate sha1sum checks
if [[ x${regen_checksum} -eq xyes ]]; then
	sha1sum "${GAMEDIR}/gamedata/"{ParisEngine.dll,TMNT.exe} > "${GAMEDIR}/gamedata/.ver_checksum"
	sha1sum "${GAMEDIR}/patches/"*.dll >> "${GAMEDIR}/gamedata/.ver_checksum"
fi

mono ../MMLoader.exe MONOMODDED_${GAMEASSEMBLY} > >(tee ${GAMEDIR}/log.txt) 2>&1
umount "${MONODIR}"
