#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile

# fat32 is default
ROM_FS_TYPE="vfat"

ESRESTART="${1}"

EXTERNALDRIVE="${2}"
[[ -z "${EXTERNALDRIVE}" ]] && EXTERNALDRIVE=$(get_ee_setting global.externalmount)
[[ -z "${EXTERNALDRIVE}" || "${EXTERNALDRIVE}" == "auto" ]] && EXTERNALDRIVE=""

# Get EEROMS filetype
if [ -e "/flash/ee_fstype" ]; then
    EE_FS_TYPE=$(cat "/flash/ee_fstype")
    
    case $EE_FS_TYPE in
    "ntfs"|"ext4"|"exfat")
        ROM_FS_TYPE=${EE_FS_TYPE}
    ;;
    *)
        # Failsafe
        ROM_FS_TYPE="vfat"
    ;;
    esac 
fi

EE_FS_TYPE=${ROM_FS_TYPE}

# Wait for the time specified in ee_load.delay setting in emuelec.conf
LOADTIME=$(get_ee_setting ee_load.delay)
[ ! -z "${LOADTIME}" ] && sleep ${LOADTIME}

# Kodi seems to set its own FB settings for 720p, so we revert them to one that work on ES, I use all resolutions just in case :)
setres.sh

# Look for samba mounts to /storage/roms, MAKE ABSOLUTELY SURE YOUR MOUNT INFORMATION IS CORRECT OR ELSE YOU WILL GET NO ROMS AT ALL!
if  compgen -G /storage/.config/system.d/storage-roms*.mount > /dev/null; then

[[ -L "/storage/roms" ]] && rm /storage/roms
    umount /storage/roms > /dev/null 2>&1
    mkdir -p /var/media/EEROMS
    mount -t ${EE_FS_TYPE} "LABEL=EEROMS" /var/media/EEROMS > /dev/null 2>&1

    for f in /storage/.config/system.d/storage-roms*.mount; do
        systemctl enable $(basename ${f}) > /dev/null 2>&1
        systemctl start $(basename ${f}) > /dev/null 2>&1
        systemctl is-active --quiet $(basename ${f}) && echo "Mounted ${f} from samba roms"
        
    done
else

# Sanity check 
umount "/storage/roms/ports_scripts" > /dev/null 2>&1
umount "/var/media/EEROMS/roms/ports_scripts" > /dev/null 2>&1

# Lets try and find some roms on a mounted USB drive
# name of the file we need to put in the roms folder in your USB or SDCARD
ROMFILE="emuelecroms"

# Only run the USB check if the ROMFILE does not exists in /storage/roms, this can help for manually created symlinks or network shares
# or if you want to skip the USB rom mount for whatever reason
if  [ ! -f "/storage/roms/$ROMFILE" ] || [ "${ESRESTART}" == "yes" ]; then

# if the file is not present then we look for the file in connected USB media, and only return the first match 
ROMSPATH="/media/*/roms/"
[[ ! -z "${EXTERNALDRIVE}" ]] && ROMSPATH="/var/media/${EXTERNALDRIVE}/roms/"
FULLPATHTOROMS="$(find ${ROMSPATH} -name ${ROMFILE}* -maxdepth 1 | head -n 1)"

echo "Using path ${FULLPATHTOROMS}"

if [[ -z "${FULLPATHTOROMS}" ]]; then
TRY=0
RETRY=$(get_ee_setting ee_mount.retry)
    if [ "${RETRY}" -ge  1 ]; then
        while [ "${TRY}" -le "${RETRY}" ] ; do
            FULLPATHTOROMS="$(find ${ROMSPATH} -name ${ROMFILE}* -maxdepth 1 | head -n 1)"
            [[ ! -z "${FULLPATHTOROMS}" ]] && break;
            TRY=$((TRY+1))
            sleep 1
        done
    fi
fi

# stop samba while we search where the ROMS folder will be pointing
systemctl stop smbd

if [[ -z "${FULLPATHTOROMS}" ]]; then
# Can't find the ROMFILE, if the symlink exists, then remove it and mount the roms partition
[[ -L "/storage/roms" ]] && rm /storage/roms
# "/storage/roms" should never be a directory, move the directory instead of deleting it in case it has ROMS
[[ ! -L "/storage/roms" && -d "/storage/roms" ]] && mv /storage/roms /storage/roms_backup

if /usr/bin/busybox mountpoint -q /var/media/EEROMS ; then
      umount /var/media/EEROMS > /dev/null 2>&1
      rmdir /var/media/EEROMS > /dev/null 2>&1
fi
      mkdir -p /storage/roms
      mount -t ${EE_FS_TYPE} "LABEL=EEROMS" /storage/roms
else
# unmount the roms partition and make a symlink to the external media, mount the roms partition in media

if /usr/bin/busybox mountpoint -q /storage/roms ; then
    umount /storage/roms > /dev/null 2>&1
    rmdir /storage/roms > /dev/null 2>&1
fi
    umount /var/media/EEROMS > /dev/null 2>&1
    mkdir -p /var/media/EEROMS
    mount -t ${EE_FS_TYPE} "LABEL=EEROMS" /var/media/EEROMS

# we strip the name of the file.
  PATHTOROMS=${FULLPATHTOROMS%$ROMFILE}

# this might be overkill but we need to double check that there is no symlink to roms folder already
# only delete the symlink if the ROMFILE is found.
# this could be bad if you manually create the symlink, but if you do that, then you know how to edit this file :) 
# but we need to find a better way
# "/storage/roms" should never be a directory, move the directory instead of deleting it in case it has ROMS
       
[[ -L "/storage/roms" ]] && rm /storage/roms
[[ ! -L "/storage/roms" && -d "/storage/roms" ]] && mv /storage/roms /storage/roms_backup

# All the sanity checks have passed, we have a ROMFILE so we create the symlink to the roms in our USB
## this could potentially be a mount bind, but for now symlink helps us identify if its external or not.
    ln -sTf "$PATHTOROMS" /storage/roms
  fi 
fi 

fi # samba 

systemctl start smbd

[[ "${ESRESTART}" == "yes" ]] && systemctl restart emustation
