#!/bin/bash

# Source predefined functions and variables
. /etc/profile

function portmaster_confirm() {
    text_viewer -y -w -t "Install Portmaster" -f 24 -m "This will install Portmaster and enable it on Emulationstation\n\nNOTE: You need to have an active internet connection and you will need to restart ES after this script ends, continue?"
        if [[ $? == 21 ]]; then
            if portmaster_install; then
                text_viewer -y -w -t "Install Portmaster Complete!" -f 24 -m "Portmaster installation is done!.\n\n Don't forget to restart Emulationstation! Would you like to restart it now?"
                    if [[ $? == 21 ]]; then
                        systemctl restart emustation
                    fi
            else
                text_viewer -e -w -t "Install Portmaster FAILED!" -f 24 -m "Portmaster installation was not completed!, Are you sure you are connected to the internet?"
            fi
      fi
    ee_console disable
 }

function portmaster_install() {
ee_console enable

LINK="https://github.com/PortsMaster/PortMaster-GUI/releases/latest/download/PortMaster.zip"
LINKTMP=$(mktemp -d);
LINKDEST="${LINKTMP}/PortMaster.zip"

wget -O ${LINKDEST} ${LINK}

[[ ! -f ${LINKDEST} ]] && return 1
unzip -o "${LINKDEST}" -d "/storage/roms/ports"
cp "/storage/roms/ports/PortMaster/PortMaster.sh" "/emuelec/ports"
rm -rf ${LINKTMP}

echo "Done, restart ES"
ee_console disable
rm /tmp/display > /dev/null 2>&1
return 0
}
portmaster_confirm
