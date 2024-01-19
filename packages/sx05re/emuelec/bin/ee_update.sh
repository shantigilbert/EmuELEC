#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# Sanity Check 
if [[ -f /storage/ee_updated ]]; then

# We need to always use the newest es_systems.cfg if there was a recent update, we also need to update the ports gamelist.xml and es_features.cfg
CVER=$(cat /storage/.config/EE_VERSION)
NVER=$(cat /usr/config/EE_VERSION)
BUILDATE=$(cat /usr/buildate)

ESDIR="/storage/.config/emulationstation"
OLDCFG="${ESDIR}/es_systems.cfg.${BUILDATE}.bak"
CFG="${ESDIR}/es_systems.cfg"

if [[ "${CVER}" != "${NVER}" ]]; then
    mv "/storage/.config/emuelec/ports/gamelist.xml" "/storage/.config/emuelec/ports/gamelist.xml.${BUILDATE}.bak"
    cp -rf "/usr/bin/ports/gamelist.xml" "/storage/.config/emuelec/ports/gamelist.xml"
    
    mv "${ESDIR}/es_features.cfg" "${ESDIR}/es_features.cfg.${BUILDATE}.bak"
    cp -rf "/usr/config/emulationstation/es_features.cfg" "${ESDIR}/es_features.cfg"
    
    cp -f "${CFG}" "${OLDCFG}"
    cp -f "/usr/config/emulationstation/es_systems.cfg" "${CFG}"

    echo "${NVER}" > /storage/.config/EE_VERSION
(
    if grep -q '<name>nds</name>' "${OLDCFG}"; then
        xmlstarlet ed --omit-decl --inplace \
            -s '//systemList' -t elem -n 'system' \
            -s '//systemList/system[last()]' -t elem -n 'name' -v 'nds'\
            -s '//systemList/system[last()]' -t elem -n 'fullname' -v 'Nintendo DS'\
            -s '//systemList/system[last()]' -t elem -n 'manufacturer' -v 'Nintendo'\
            -s '//systemList/system[last()]' -t elem -n 'release' -v '2004'\
            -s '//systemList/system[last()]' -t elem -n 'hardware' -v 'portable'\
            -s '//systemList/system[last()]' -t elem -n 'path' -v '/storage/roms/nds'\
            -s '//systemList/system[last()]' -t elem -n 'extension' -v '.nds .zip .NDS .ZIP'\
            -s '//systemList/system[last()]' -t elem -n 'command' -v "emuelecRunEmu.sh %ROM% -P%SYSTEM% --core=%CORE% --emulator=%EMULATOR% --controllers=\"%CONTROLLERSCONFIG%\""\
            -s '//systemList/system[last()]' -t elem -n 'platform' -v 'nds'\
            -s '//systemList/system[last()]' -t elem -n 'theme' -v 'nds'\
            ${CFG} 
    fi
) &

fi

REMAP_VERSION="/emuelec/configs/JOY_REMAP_VERSION"
if [[ ! -f "$REMAP_VERSION" ]]; then
	grep -Ev "^.*\.joy_btn.*=.*$" /emuelec/configs/emuelec.conf > /tmp/emuelec.conf.bak && mv /tmp/emuelec.conf.bak /emuelec/configs/emuelec.conf
	echo "2" > "${REMAP_VERSION}"
fi

    # everything is done, cleanup
    rm -rf /storage/ee_updated
fi
