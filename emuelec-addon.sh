#!/bin/bash

# This script is based on https://github.com/ToKe79/retroarch-kodi-addon-LibreELEC/blob/master/retroarch-kodi.sh
# It has been adapted to EmuELEC by Shanti Gilbert and modified to install emulationstation and other emulators.
# Fair warning, this script is really hacky, probably very bad practices and other bad habbits,
# You have been warned! If you are a bash expert you will probably cringe, but instead of that maybe you could help to make it better? 

build_it() {
REPO_DIR=""
FORCEUPDATE="yes"
PROJECT="$1"

[ -z "$SCRIPT_DIR" ] && SCRIPT_DIR=$(pwd)

# make sure you change these lines to point to your EmuELEC git clone
EMUELEC="${SCRIPT_DIR}"
[ -z "$GIT_BRANCH" ] && GIT_BRANCH="master"
SX05RE_PATH="packages/sx05re"
EMUELEC_PATH="${SX05RE_PATH}/emuelec"
EMUELEC_ADDON_VERSION="3.6"

LOG="${SCRIPT_DIR}/emuelec-kodi_`date +%Y%m%d_%H%M%S`.log"

# Exit if not in the right branch 
if [ -d "$EMUELEC" ] ; then
	cd "$EMUELEC"
	git checkout ${GIT_BRANCH} &>>"$LOG"
		branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
	if [ $branch != $GIT_BRANCH ]; then 
	   echo "ERROR: Could not automatically switch branch to $GIT_BRANCH. Please make sure you are in branch $GIT_BRANCH before running this script"
	   echo "Wrong GIT branch, wanted $GIT_BRANCH got $branch" &>>"$LOG"
	   exit 1
   fi 
fi 

[ -z "$DISTRO" ] && DISTRO=EmuELEC
[ -z "$PROJECT" ] && PROJECT=Amlogic
[ -z "$ARCH" ] && ARCH=arm
[ -z "$PROVIDER" ] && PROVIDER="CoreELEC"
[ -z "$VERSION" ] && VERSION=$(cat $SCRIPT_DIR/distributions/$DISTRO/version | grep LIBREELEC_VERSION | grep -oP '"\K[^"\047]+(?=["\047])')

if [ ${VERSION} = "devel" ]; then
VERSION=$(cat $SCRIPT_DIR/distributions/$DISTRO/version | grep OS_VERSION | grep -oP '"\K[^"\047]+(?=["\047])')-${VERSION}
fi

[ -z "$REPO_DIR" ] && REPO_DIR="${SCRIPT_DIR}/repo/${EMUELEC_ADDON_VERSION}"

BUILD_SUBDIR="build.${DISTRO}-${PROJECT}.${ARCH}-${VERSION}"
SCRIPT="scripts/build"
PACKAGES_SUBDIR="packages"
PROJECT_DIR="${SCRIPT_DIR}/emuelec_addon_workdir"
TARGET_DIR="${PROJECT_DIR}/`date +%Y-%m-%d_%H%M%S`"
BASE_NAME="$PROVIDER.$DISTRO"

LIBRETRO_BASE="retroarch retroarch-assets retroarch-overlays core-info common-shaders openal-soft"

    # Get cores from EmuELEC options file
    OPTIONS_FILE="${SCRIPT_DIR}/distributions/${DISTRO}/options"
    [ -f "$OPTIONS_FILE" ] && source "$OPTIONS_FILE" || { echo "$OPTIONS_FILE: not found! Aborting." ; exit 1 ; }
    [ -z "$LIBRETRO_CORES" ] && { echo "LIBRETRO_CORES: empty. Aborting!" ; exit 1 ; }

PKG_EMUS="emulationstation-addon advancemame reicastsa amiberry hatarisa mupen64plus-nx"

# PPSSPPSDL and openbor do not work on CoreELEC S922x (Amlogic-ng), we use PPSSPP from libretro and remove openbor
if [ $PROJECT = "Amlogic" ]; then
PKG_EMUS="$PKG_EMUS PPSSPPSDL openbor"	
fi

PACKAGES_Sx05RE="$PKG_EMUS \
				emuelec \
				empty \
				sixpair \
				joyutils \
				SDL2-git \
				freeimage \
				vlc \
				freetype \
				es-theme-ComicBook \
				bash \
				SDL_GameControllerDB \
				libvorbisidec \
				jslisten \
				python-evdev \
				libpng16 \
				mpg123-compat \
				SDL2_image \
				SDL2_ttf \
				libmpeg2 \
				flac \
				mpv \
				portaudio \
				SDL \
				SDL_net \
				capsimg"
				

  PACKAGES_ALL="$LIBRETRO_CORES"

LIBRETRO_EXTRA_CORES="citra beetle-psx beetle-saturn beetle-bsnes bsnes-mercury bsnes dinothawr higan-sfc-balanced higan-sfc lutro mame2003-midway mrboom easyrpg dolphin openlara pocketcdg virtualjaguar"

PACKAGES_ALL="$LIBRETRO_BASE $PACKAGES_ALL $PACKAGES_Sx05RE" 
DISABLED_CORES="libretro-database $LIBRETRO_EXTRA_CORES"

if [ -n "$DISABLED_CORES" ] ; then
	for core in $DISABLED_CORES ; do
		PACKAGES_ALL=$(sed "s/\<$core\>//g" <<< $PACKAGES_ALL)
	done
fi

# Add packages for S922x
if [ "$PROJECT" == "Amlogic-ng" ]; then
PACKAGES_ALL+=" $LIBRETRO_S922X_CORES mame2016"
fi

	ADDON_NAME=${BASE_NAME}.${PROJECT}_${ARCH}
	RA_NAME_SUFFIX=${PROJECT}.${ARCH}

ADDON_NAME="script.emuelec.${PROJECT}.launcher"
ADDON_DIR="${PROJECT_DIR}/${ADDON_NAME}"


  ARCHIVE_NAME="${ADDON_NAME}-${EMUELEC_ADDON_VERSION}-${PROJECT}.zip"


read -d '' message <<EOF
Building EmuELEC KODI add-on for CoreELEC:

DISTRO=${DISTRO}
PROJECT=${PROJECT}
ARCH=${ARCH}
VERSION=${VERSION}
GIT_BRANCH=${GIT_BRANCH}

Working in: ${SCRIPT_DIR}
Temporary project folder: ${TARGET_DIR}

Target zip: ${REPO_DIR}/${ADDON_NAME}/${ARCHIVE_NAME}
EOF

echo "$message"
echo

# make sure the old add-on is deleted
if [ -d ${REPO_DIR} ]; then
echo "Removing old add-on at ${REPO_DIR}"
rm -rf ${REPO_DIR}/${ADDON_NAME}
fi

if [ -d ${PROJECT_DIR} ]; then
echo "Removing old project add-on at ${PROJECT_DIR}"
rm -rf ${PROJECT_DIR}
fi

# Checks folders
for folder in ${REPO_DIR} ${REPO_DIR}/${ADDON_NAME} ${REPO_DIR}/${ADDON_NAME}/resources ; do
	[ ! -d "$folder" ] && { mkdir -p "$folder" && echo "Created folder '$folder'" || { echo "Could not create folder '$folder'!" ; exit 1 ; } ; } || echo "Folder '$folder' exists."
done
echo

if [ -d "$EMUELEC" ] ; then
	cd "$EMUELEC"
	echo "Building packages:"
	for package in $PACKAGES_ALL ; do
		echo -ne "\t$package "
		if [ $package = "emulationstation" ]; then
		EMUELEC_ADDON="Yes" DISTRO=$DISTRO PROJECT=$PROJECT ARCH=$ARCH ./scripts/clean $package &>>"$LOG"
		fi
			EMUELEC_ADDON="Yes" DISTRO=$DISTRO PROJECT=$PROJECT ARCH=$ARCH ./$SCRIPT $package &>>"$LOG"
		if [ $? -eq 0 ] ; then
			echo "(ok)"
	else
			echo "(failed)"
			echo "Error building package '$package'!"
			exit 1
		fi
	done
	echo
	if [ ! -d "$TARGET_DIR" ] ; then
		echo -n "Creating target folder '$TARGET_DIR'..."
		mkdir -p "$TARGET_DIR" &>>"$LOG"
		if [ $? -eq 0 ] ; then
			echo "done."
		else
			echo "failed!"
			echo "Could not create folder '$TARGET_DIR'!"
			exit 1
		fi
	fi
	echo
	echo "Copying packages:"
		for package in $PACKAGES_ALL ; do
			echo -ne "\t$package "
			SRC="$(find ${PACKAGES_SUBDIR} -wholename ${PACKAGES_SUBDIR}/*/${package}/package.mk -print -quit)"
			if [ -f "$SRC" ] ; then
				#PKG_VERSION=`cat $SRC | grep -oP 'PKG_VERSION="\K[^"]+'`
				# its better to just source the package.mk completeley to deal with the conditional bits
				EMUELEC_ADDON="Yes" DISTRO=$DISTRO PROJECT=$PROJECT ARCH=$ARCH source $SRC
			else
				echo "(failed- no package.mk)"
				exit 1
			fi			
			PKG_FOLDER="${BUILD_SUBDIR}/${package}-${PKG_VERSION}/.install_pkg"
			if [ -d "$PKG_FOLDER" ] ; then
				cp -Rf "${PKG_FOLDER}/"* "${TARGET_DIR}/" &>>"$LOG"
				[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
			else
				echo "(skipped - not found or not compatible)"
				echo "skipped $PKG_FOLDER" &>>"$LOG"
				continue
			fi
		done

	echo
else
	echo "Folder '$EMUELEC' does not exist! Aborting!" >&2
	exit 1
fi
if [ -f "$ADDON_DIR" ] ; then
	echo -n "Removing previous addon..."
	rm -rf "${ADDON_DIR}" &>>"$LOG"
	[ $? -eq 0 ] && echo "done." || { echo "failed!" ; echo "Error removing folder '${ADDON_DIR}'!" ; exit 1 ; }
	echo
fi
echo -n "Creating addon folder..."
mkdir -p "${ADDON_DIR}" &>>"$LOG"
[ $? -eq 0 ] && echo "done." || { echo "failed!" ; echo "Error creating folder '${ADDON_DIR}'!" ; exit 1 ; }

echo
cd "${ADDON_DIR}"
echo "Creating folder structure..."
for f in config resources bin; do
	echo -ne "\t$f "
	mkdir -p $f &>>"$LOG"
	[ $? -eq 0 ] && echo -e "(ok)" || { echo -e "(failed)" ; exit 1 ; }
done
echo
 if [ "$FORCEUPDATE" == "yes" ]; then
	echo -ne "Creating forceupdate..."
	touch "${ADDON_DIR}/forceupdate"
	[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
 fi

echo -ne "Creating empty joypads dir"
mkdir -p "${ADDON_DIR}/resources/joypads" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo "Moving config files to addon..."
echo -ne "\tconfig dir"
cp -rf "${TARGET_DIR}/usr/config" "${ADDON_DIR}/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

#fix addon specific scripts
echo -ne "\tconfig dir"
cp -rf ${SCRIPT_DIR}/${SX05RE_PATH}/emulationstation-addon/config/* "${ADDON_DIR}/config/emulationstation/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tProfile"
cp -rf "${SCRIPT_DIR}/${EMUELEC_PATH}/profile.d" "${ADDON_DIR}" 
mv "${ADDON_DIR}/profile.d/99-emuelec.conf" "${ADDON_DIR}/profile.d/99-emuelec.profile" &>>"$LOG"
sed -i -e "s|export PATH.*|export PATH=\"/storage/.kodi/addons/${ADDON_NAME}/bin:/storage/.emulationstation/scripts:\$PATH\"|" "${ADDON_DIR}/profile.d/99-emuelec.profile"
sed -i -e "s|/ee_arch|/storage/.kodi/addons/${ADDON_NAME}/config/ee_arch|" "${ADDON_DIR}/profile.d/99-emuelec.profile"
echo "$PROJECT" > "${ADDON_DIR}/config/ee_arch"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tretroarch.cfg "
mv -v "${ADDON_DIR}/config/retroarch/retroarch.cfg" "${ADDON_DIR}/config/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tbinaries "
mv -v "${TARGET_DIR}/usr/bin" "${ADDON_DIR}/" &>>"$LOG"
rm -rf "${ADDON_DIR}/bin/assets"
mv -v "${ADDON_DIR}/config/ppsspp/assets" "${ADDON_DIR}/bin" &>>"$LOG"
mv -v "${ADDON_DIR}"/config/emuelec/scripts/*.sh "${ADDON_DIR}/bin" &>>"$LOG"
mv -v "${ADDON_DIR}"/config/emuelec/bin/* "${ADDON_DIR}/bin" &>>"$LOG"
rm -rf "${ADDON_DIR}/config/emuelec/script"* &>>"$LOG"
rm -rf "${ADDON_DIR}/config/emuelec/bin" &>>"$LOG"
mv -v "${ADDON_DIR}/config/emuelec/configs/jslisten.cfg" "${ADDON_DIR}/config" &>>"$LOG"
mv -v "${ADDON_DIR}/config/emuelec/bezels" "${ADDON_DIR}/config" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tlibraries and cores "
mv -v "${TARGET_DIR}/usr/lib" "${ADDON_DIR}/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\taudio filters "
mv -v "${TARGET_DIR}/usr/share/audio_filters" "${ADDON_DIR}/resources/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tvideo filters "
mv -v "${TARGET_DIR}/usr/share/video_filters" "${ADDON_DIR}/resources/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tshaders "
mv -v "${TARGET_DIR}/usr/share/common-shaders" "${ADDON_DIR}/resources/shaders" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tassets "
mv -v "${TARGET_DIR}/usr/share/retroarch-assets" "${ADDON_DIR}/resources/assets" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\toverlays "
  for i in borders effects gamepads ipad keyboards misc; do
    rm -rf "${TARGET_DIR}/usr/share/retroarch-overlays/$i"
  done
mv -v "${TARGET_DIR}/usr/share/retroarch-overlays" "${ADDON_DIR}/resources/overlays" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tadvacemame Config "
rm -rf "${TARGET_DIR}/usr/share/advance/advmenu.rc"
mv -v "${TARGET_DIR}/usr/share/advance" "${ADDON_DIR}/config" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tVLC libs "
rm "${ADDON_DIR}/lib/vlc"
mv -v "${TARGET_DIR}/usr/config/vlc" "${ADDON_DIR}/lib/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo "Removing unneeded files "
  for i in killes.sh filemanagerlauncher find.sh force_update.sh env.sh gamelist-cleaner.sh fbterm.sh joy2key.py startfe.sh killkodi.sh emulationstation.sh emustation-config clearconfig.sh reicast.sh smb.conf vlc out123 cvlc mpg123-* *png*; do
    echo -ne "\t$i"
    rm -rf "${ADDON_DIR}/bin/"${i} &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
  done
  for i in autostart.sh custom_start.sh emuelec asound.conf vlc; do
    echo -ne "\t$i"
    rm -rf "${ADDON_DIR}/config/"${i} &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
  done

echo -ne "\tOrphan info files"
for f in ${ADDON_DIR}/lib/libretro/*.info; do 
name=${f%.*}
if [ ! -f "$name.so" ]; then
rm $f
fi
done
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tUnused assets "
  for i in automatic dot-art flatui neoactive pixel retroactive retrosystem systematic convert.sh NPMApng2PMApng.py; do
  rm -rf "${ADDON_DIR}/resources/assets/xmb/$i"
  done
  
  for i in branding glui nuklear nxrgui pkg switch wallpapers zarch COPYING; do
    rm -rf "${ADDON_DIR}/resources/assets/$i"
  done
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tlib files "
find ${ADDON_DIR}/lib -maxdepth 1 -type l -exec rm -f {} \;
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
echo

echo "Creating files..."
echo -ne "\temuelecsound.conf "
read -d '' content <<EOF
pcm.!default {
type plug
slave {
pcm "hw:0,0"
}
}
EOF
echo "$content" > config/emuelecsound.conf
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\treicast.sh "
read -d '' content <<EOF
#!/bin/sh

. /storage/.kodi/addons/${ADDON_NAME}/config/ee_env.sh

#set reicast BIOS dir to point to /storage/roms/bios/dc
if [ ! -L /storage/.local/share/reicast/data ]; then
	mkdir -p /storage/.local/share/reicast 
	rm -rf /storage/.local/share/reicast/data
	ln -s /storage/roms/bios/dc /storage/.local/share/reicast/data
fi

if [ ! -L /storage/.local/share/reicast/mappings ]; then
mkdir -p /storage/.local/share/reicast/
ln -sf /storage/.kodi/addons/${ADDON_NAME}/config/reicast/mappings /storage/.local/share/reicast/mappings
ln -sf /storage/.kodi/addons/${ADDON_NAME}/config/reicast /storage/.config/reicast
fi


# try to automatically set the gamepad in emu.cfg
y=1


for D in \`find /dev/input/by-id/ | grep event-joystick\`; do
  str=\$(ls -la \$D)
  i=\$((\${#str}-1))
  DEVICE=\$(echo "\${str:\$i:1}")
  CFG="/storage/.config/reicast/emu.cfg"
   sed -i -e "s/^evdev_device_id_\$y =.*\$/evdev_device_id_\$y = \$DEVICE/g" \$CFG
   y=\$((y+1))
 if [\$y -lt 4]; then
  break
 fi 
done

/storage/.kodi/addons/${ADDON_NAME}/bin/reicast "\$1"
EOF
echo "$content" > bin/reicast.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
chmod +x bin/reicast.sh
echo -ne "\temuelec.sh "
read -d '' content <<EOF
#!/bin/sh

. /etc/profile

oe_setup_addon ${ADDON_NAME}

systemd-run \$ADDON_DIR/bin/emuelec.start
EOF
echo "$content" > bin/emuelec.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
chmod +x bin/emuelec.sh
echo -ne "\temustation-config "
read -d '' content <<EOF
#!/bin/sh

#name of the file we need to put in the roms folder in your USB or SDCARD 
ROMFILE="emuelecroms"

# we look for the file in the rompath
FULLPATHTOROMS="\$(find /media/*/roms/ -name \$ROMFILE -maxdepth 1 | head -n 1)"
ROMS_FOLDER="/storage/.kodi/addons/${ADDON_NAME}/roms"

if [[ -z "\${FULLPATHTOROMS}" ]]; then
# echo "can't find roms"

    if [ ! -e /storage/roms ]; then
      rm /storage/roms
      ln -sf "\$ROMS_FOLDER" /storage/roms
    fi
    else
	if [ -L "/storage/roms" ]; then
		rm /storage/roms
		#echo "move the roms folder"
	fi
 
       # we strip the name of the file.
       PATHTOROMS=\${FULLPATHTOROMS%\$ROMFILE}

       #we create the symlink to the roms in our USB
       ln -sTf \$PATHTOROMS /storage/roms
 fi

exit 0
EOF
echo "$content" > bin/emustation-config
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
chmod +x bin/emustation-config

echo -ne "\tes_input.cfg "
rm config/emulationstation/es_input.cfg
read -d '' content <<EOF
<?xml version="1.0"?>
<inputList>
  <inputAction type="onfinish">
    <command>/storage/.kodi/addons/${ADDON_NAME}/bin/bash /storage/.emulationstation/scripts/inputconfiguration.sh</command>
  </inputAction>
  <inputConfig type="joystick" deviceName="Sony PLAYSTATION(R)3 Controller">
	<input name="a" type="button" id="13" value="1" />
	<input name="b" type="button" id="14" value="1" />
	<input name="down" type="button" id="6" value="1" />
	<input name="hotkeyenable" type="button" id="16" value="1" />
	<input name="left" type="button" id="7" value="1" />
	<input name="leftanalogdown" type="axis" id="1" value="1" />
	<input name="leftanalogleft" type="axis" id="0" value="-1" />
	<input name="leftanalogright" type="axis" id="0" value="1" />
	<input name="leftanalogup" type="axis" id="1" value="-1" />
	<input name="leftshoulder" type="button" id="10" value="1" />
	<input name="leftthumb" type="button" id="1" value="1" />
	<input name="lefttrigger" type="button" id="8" value="1" />
	<input name="right" type="button" id="5" value="1" />
	<input name="rightanalogdown" type="axis" id="3" value="1" />
	<input name="rightanalogleft" type="axis" id="2" value="-1" />
	<input name="rightanalogright" type="axis" id="2" value="1" />
	<input name="rightanalogup" type="axis" id="3" value="-1" />
	<input name="rightshoulder" type="button" id="11" value="1" />
	<input name="rightthumb" type="button" id="2" value="1" />
	<input name="righttrigger" type="button" id="9" value="1" />
	<input name="select" type="button" id="0" value="1" />
	<input name="start" type="button" id="3" value="1" />
	<input name="up" type="button" id="4" value="1" />
	<input name="x" type="button" id="12" value="1" />
	<input name="y" type="button" id="15" value="1" />
</inputConfig>
</inputList>
EOF
echo "$content" > config/emulationstation/es_input.cfg
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tGamepad Workarounds "
cp ${SCRIPT_DIR}/${EMUELEC_PATH}/gamepads/*.cfg resources/joypads/
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tee_env.sh "
read -d '' content <<EOF
#!/bin/sh

. /etc/profile

oe_setup_addon ${ADDON_NAME}

export PATH="\$ADDON_DIR/bin:\$PATH"
export LD_LIBRARY_PATH="\$ADDON_DIR/lib:\$LD_LIBRARY_PATH"

# create symlinks to libraries
# ln -sf libxkbcommon.so.0.0.0 \$ADDON_DIR/lib/libxkbcommon.so
# ln -sf libxkbcommon.so.0.0.0 \$ADDON_DIR/lib/libxkbcommon.so.0
# ln -sf libvdpau.so.1.0.0 \$ADDON_DIR/lib/libvdpau.so
# ln -sf libvdpau.so.1.0.0 \$ADDON_DIR/lib/libvdpau.so.1
# ln -sf libvdpau_trace.so.1.0.0 \$ADDON_DIR/lib/vdpau/libvdpau_trace.so
# ln -sf libvdpau_trace.so.1.0.0 \$ADDON_DIR/lib/vdpau/libvdpau_trace.so.1
# ln -sf libdrm.so.2.4.0 \$ADDON_DIR/lib/libdrm.so.2
# ln -sf libexif.so.12.3.3 \$ADDON_DIR/lib/libexif.so.12

ln -sf libopenal.so.1.19.1 \$ADDON_DIR/lib/libopenal.so.1
ln -sf libSDL2-2.0.so.0.9.0 \$ADDON_DIR/lib/libSDL2-2.0.so.0
ln -sf libfreeimage-3.18.0.so \$ADDON_DIR/lib/libfreeimage.so.3
ln -sf libvlc.so.5.6.0 \$ADDON_DIR/lib/libvlc.so.5
ln -sf libvlccore.so.9.0.0 \$ADDON_DIR/lib/libvlccore.so.9
ln -sf libvorbisidec.so.1.0.3 \$ADDON_DIR/lib/libvorbisidec.so.1
ln -sf libpng16.so.16.36.0 \$ADDON_DIR/lib/libpng16.so.16
ln -sf libmpg123.so.0.44.8 \$ADDON_DIR/lib/libmpg123.so.0
ln -sf libout123.so.0.2.2 \$ADDON_DIR/lib/libout123.so.0
ln -sf libSDL2_image-2.0.so.0.2.2 \$ADDON_DIR/lib/libSDL2_image-2.0.so.0
ln -sf libSDL2_ttf-2.0.so.0.14.0 \$ADDON_DIR/lib/libSDL2_ttf-2.0.so.0
ln -sf libFLAC.so.8.3.0 \$ADDON_DIR/lib/libFLAC.so.8
ln -sf libmpeg2convert.so.0.0.0 \$ADDON_DIR/lib/libmpeg2convert.so.0
ln -sf libmpeg2.so.0.1.0 \$ADDON_DIR/lib/libmpeg2.so.0
ln -sf libSDL-1.2.so.0.11.5 \$ADDON_DIR/lib/libSDL-1.2.so.0
ln -sf libSDL_net-1.2.so.0.8.0 \$ADDON_DIR/lib/libSDL_net-1.2.so.0
ln -sf libcapsimage.so.5.1 \$ADDON_DIR/lib/libcapsimage.so.5
mkdir -p /tmp/cache

EOF
echo "$content" > config/ee_env.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tee_retroarch.sh "
read -d '' content <<EOF
#!/bin/sh

. /storage/.kodi/addons/${ADDON_NAME}/config/ee_env.sh

RA_CONFIG_DIR="/storage/.config/retroarch/"
RA_CONFIG_FILE="\$RA_CONFIG_DIR/retroarch.cfg"
RA_CONFIG_SUBDIRS="savestates savefiles remappings playlists system thumbnails"
RA_EXE="\$ADDON_DIR/bin/retroarch"
ROMS_FOLDER="/storage/.kodi/addons/${ADDON_NAME}/roms"
DOWNLOADS="downloads"
RA_PARAMS="--config=\$RA_CONFIG_FILE --menu"
LOGFILE="\$ADDON_DIR/logs/emuelec_addon.log"

sed -i '/emuelec_exit_to_kodi = /d' \$RA_CONFIG_FILE
echo 'emuelec_exit_to_kodi = "true"' >> \$RA_CONFIG_FILE

	if [ \$ra_log -eq 1 ] ; then
		\$RA_EXE \$RA_PARAMS >\$LOGFILE 2>&1
	else
		\$RA_EXE \$RA_PARAMS
	fi
	
EOF
echo "$content" > bin/ee_retroarch.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\temuelec.start "
read -d '' content <<EOF
#!/bin/sh

. /storage/.kodi/addons/${ADDON_NAME}/config/ee_env.sh

RA_CONFIG_DIR="/storage/.config/retroarch/"
RA_CONFIG_FILE="\$RA_CONFIG_DIR/retroarch.cfg"
RA_CONFIG_SUBDIRS="savestates savefiles remappings playlists system thumbnails"
RA_EXE="\$ADDON_DIR/bin/retroarch"
ROMS_FOLDER="/storage/roms"
DOWNLOADS="downloads"
RA_PARAMS="--config=\$RA_CONFIG_FILE --menu"
LOGFILE="\$ADDON_DIR/logs/emuelec_addon.log"

sed -i '/emuelec_exit_to_kodi = /d' \$RA_CONFIG_FILE

if [[ ! -d \$ADDON_DIR/logs ]]; then
	mkdir -p \$ADDON_DIR/logs
fi 

# external/usb rom mounting
sh \$ADDON_DIR/bin/emustation-config

 if [ \$ra_es -eq 1 ] ; then
   RA_EXE="\$ADDON_DIR/bin/emulationstation"
   RA_PARAMS=""
   LOGFILE="/storage/emulationstation.log"
 fi

[ ! -d "\$RA_CONFIG_DIR" ] && mkdir -p "\$RA_CONFIG_DIR"
  
 if [ ! -d "\$ROMS_FOLDER" ] && [ ! -L "\$ROMS_FOLDER" ]; then
    mkdir -p "\$ROMS_FOLDER"
    
     all_roms="downloads \
BGM \
3do \
amstradcpc \
arcade \
atari2600 \
atari5200 \
atari7800 \
atari800 \
atarilynx \
atarilynx \
atarilynx \
atarist \
atomiswave \
coleco \
c64 \
amiga \
pc \
famicom \
fds \
capcom \
fbneo \
gb \
gba \
gbc \
gameandwatch \
intellivision \
mame \
msx \
msx2 \
neogeo \
ngp \
ngpc \
nes \
n64 \
openbor \
psx \
psp \
scummvm \
sega32x \
segacd \
dreamcast \
gamegear \
genesis \
mastersystem \
megadrive \
naomi \
neocd \
saturn \
sg-1000 \
sfc \
snes \
tg16 \
tg16cd \
sc-3000 \
sgfx \
pcengine \
pcenginecd \
pcfx \
vectrex \
videopac \
virtualboy \
wonderswan \
wonderswancolor \
x68000 \
zxspectrum \
atarijaguar \
odyssey \
zx81" 
 
     for romfolder in \$(echo \$all_roms | tr "," " "); do
        mkdir -p "\$ROMS_FOLDER/\$romfolder"
     done
  fi
 [ ! -d "\$ROMS_FOLDER/\$DOWNLOADS" ] && mkdir -p "\$ROMS_FOLDER/\$DOWNLOADS"

for subdir in \$RA_CONFIG_SUBDIRS ; do
	[ ! -d "\$RA_CONFIG_DIR/\$subdir" ] && mkdir -p "\$RA_CONFIG_DIR/\$subdir"
done

if [ ! -f "\$RA_CONFIG_FILE" ]; then
	if [ -f "\$ADDON_DIR/config/retroarch.cfg" ]; then
		cp "\$ADDON_DIR/config/retroarch.cfg" "\$RA_CONFIG_FILE"
	fi
fi

# delete symlinks to avoid doubles

if [ -d /storage/.emulationstation ]; then
rm -rf /storage/.emulationstation
fi 

if [ -L /tmp/joypads ]; then
rm /tmp/joypads
fi

if [ ! -L /storage/.config/emuelec/bin ]; then
ln -sf /storage/.config/emuelec/bin \$ADDON_DIR/bin
fi

if [ ! -L /storage/.config/amiberry ]; then
ln -sf \$ADDON_DIR/config/amiberry /storage/.config/amiberry
rm \$ADDON_DIR/config/amiberry/capsimg.so
rm \$ADDON_DIR/config/amiberry/controller
rm \$ADDON_DIR/config/amiberry/kickstarts
ln -sf /tmp/joypads \$ADDON_DIR/config/amiberry/controller
ln -sf /storage/roms/bios/Kickstarts \$ADDON_DIR/config/amiberry/kickstarts
ln -sf \$ADDON_DIR/lib/libcapsimage.so.5.1 \$ADDON_DIR/config/amiberry/capsimg.so
fi

mkdir -p /storage/.local/lib/

ln -sTf \$ADDON_DIR/resources/joypads/ /tmp/joypads
ln -sTf \$ADDON_DIR/lib/python2.7 /storage/.local/lib/python2.7

# Check if configuration for ES is copied to storage
if [ ! -L "/storage/.emulationstation" ]; then
ln -sf \$ADDON_DIR/config/emulationstation /storage/.emulationstation
# mkdir /storage/.emulationstation
# cp -rf \$ADDON_DIR/config/emulationstation/* /storage/.emulationstation
fi

if [ -f "\$ADDON_DIR/forceupdate" ]; then
cp -rf "\$ADDON_DIR/config/retroarch.cfg" "\$RA_CONFIG_FILE"
rm "\$ADDON_DIR/forceupdate"
fi

if [ -d /storage/.config/amiberry ]; then
	rm /storage/.config/amiberry
fi

if [ ! -L /storage/.config/amiberry ]; then
	ln -sf /storage/.config/amiberry \$ADDON_DIR/storage/.config/amiberry
fi

# Make sure all scripts are executable
chmod +x /storage/.emulationstation/scripts/*.sh
chmod +x \$ADDON_DIR/bin/*

[ \$ra_verbose -eq 1 ] && RA_PARAMS="--verbose \$RA_PARAMS"

cp -rf \$ADDON_DIR/config/emuelecsound.conf /storage/.config/asound.conf

# Detect used device in Kodi and change asound.conf accordingly 0,0 is HDMI 0,1 is front output on the N2 (probably on others as well)
if grep -Fxq '"audiooutput.audiodevice">ALSA:@"' /storage/.kodi/userdata/guisettings.xml; then
sed -i "s|hw:0,0|hw:0,1|" /storage/.config/asound.conf
fi

if [ "\$ra_stop_kodi" -eq 1 ] ; then
	systemctl stop kodi

/storage/.kodi/addons/${ADDON_NAME}/bin/setres.sh

# Run intro video only on the first run
if [[ ! -f \$ADDON_DIR/config/novideo ]]; then
	SPLASH="\$ADDON_DIR/config/splash/emuelec_intro_1080p.mp4"
	\$ADDON_DIR/bin/mpv \$SPLASH > /dev/null 2>&1
	touch \$ADDON_DIR/config/novideo
fi

	if [ \$ra_log -eq 1 ] ; then
		\$RA_EXE \$RA_PARAMS >\$LOGFILE 2>&1
	else
		\$RA_EXE \$RA_PARAMS
	fi
    rm /storage/.config/asound.conf

   if grep -q 'emuelec_exit_to_kodi = "true"' \$RA_CONFIG_FILE; then
	systemctl stop kodi
	else
	rm /storage/.config/asound.conf
	systemctl start kodi
  fi

else
	pgrep kodi.bin | xargs kill -SIGSTOP

	/storage/.kodi/addons/${ADDON_NAME}/bin/setres.sh

	if [ \$ra_log -eq 1 ] ; then
		\$RA_EXE \$RA_PARAMS >\$LOGFILE 2>&1
	else
		\$RA_EXE \$RA_PARAMS
	fi
	rm /storage/.config/asound.conf
	pgrep kodi.bin | xargs kill -SIGCONT
fi

exit 0
EOF
echo "$content" > bin/emuelec.start
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
chmod +x bin/emuelec.start

echo -ne "\taddon.xml "
read -d '' addon <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<addon id="${ADDON_NAME}" name="EmuELEC (${EMUELEC_ADDON_VERSION})" version="${EMUELEC_ADDON_VERSION}" provider-name="${PROVIDER}">
	<requires>
		<import addon="xbmc.python" version="2.1.0"/>
	</requires>
	<extension point="xbmc.python.pluginsource" library="default.py">
		<provides>executable game</provides>
	</extension>
	<extension point="xbmc.addon.metadata">
		<summary lang="en">EmuELEC addon. Provides binary, cores and basic settings to launch it</summary>
		<description lang="en">EmuELEC addon is based on ToKe79 Retroarch/Lakka addon. Provides binary, cores and basic settings to launch EmuELEC. </description>
		<disclaimer lang="en">This is an unofficial add-on. Please don't ask for support in CoreELEC,Lakka or ToKe79 github, forums or irc channels.</disclaimer>
		<platform>linux</platform>
		<assets>
			<icon>resources/icon.png</icon>
			<fanart>resources/fanart.png</fanart>
		</assets>
	</extension>
</addon>
EOF
echo "$addon" > addon.xml
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tdefault.py "
read -d '' content <<EOF
import xbmc, xbmcgui, xbmcplugin, xbmcaddon
import os
import util

dialog = xbmcgui.Dialog()
dialog.notification('EmuELEC', 'Launching....', xbmcgui.NOTIFICATION_INFO, 5000)

ADDON_ID = '${ADDON_NAME}'

addon = xbmcaddon.Addon(id=ADDON_ID)
addon_dir = xbmc.translatePath( addon.getAddonInfo('path') )
addonfolder = addon.getAddonInfo('path')

icon    = addonfolder + 'resources/icon.png'
fanart  = addonfolder + 'resources/fanart.png'

util.runRetroarchMenu()
EOF
echo "$content" > default.py
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tutil.py "
read -d '' content <<EOF
import os, xbmc, xbmcaddon

ADDON_ID = '${ADDON_NAME}'
BIN_FOLDER="bin"
RETROARCH_EXEC="emuelec.sh"

addon = xbmcaddon.Addon(id=ADDON_ID)

def runRetroarchMenu():
	addon_dir = xbmc.translatePath( addon.getAddonInfo('path') )
	bin_folder = os.path.join(addon_dir,BIN_FOLDER)
	retroarch_exe = os.path.join(bin_folder,RETROARCH_EXEC)
	os.system(retroarch_exe)
EOF
echo "$content" > util.py
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsettings.xml "
read -d '' content <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<settings>
	<category label="General">
		<setting id="ra_stop_kodi" label="Stop KODI (free memory) before launching EmuELEC" type="enum" default="1" values="No|Yes" />
		<setting id="ra_log" label="Logging of EmuELEC output" type="enum" default="0" values="No|Yes" />
		<setting id="ra_verbose" label="Verbose logging (for debugging)" type="enum" default="0" values="No|Yes" />
		<setting id="ra_es" label="Run Emulationstation instead of Retroarch" type="enum" default="1" values="No|Yes" />
	</category>
</settings>
EOF
echo "$content" > resources/settings.xml
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsettings-default.xml "
read -d '' content <<EOF
<settings>
	<setting id="ra_stop_kodi" value="1" />
	<setting id="ra_log" value="0" />
	<setting id="ra_verbose" value="0" />
	<setting id="ra_es" value="1" />
</settings>
EOF
echo "$content"  > settings-default.xml
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tfanart.png"
cp "${SCRIPT_DIR}/${EMUELEC_PATH}/addon/fanart.png" resources/
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\ticon.png"
cp "${SCRIPT_DIR}/${EMUELEC_PATH}/addon/icon.png" resources/
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tdowloading dldrastic.sh"
wget -q -O dldrastic.sh https://gist.githubusercontent.com/shantigilbert/f95c44628321f0f4cce4f542a2577950/raw/
sed -i "s|script.sx05re.launcher|${ADDON_NAME}|" dldrastic.sh
sed -i "s|sx05re.log|emuelec.log|" dldrastic.sh
cp dldrastic.sh config/emulationstation/scripts/dldrastic.sh
rm dldrastic.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
echo

RA_CFG_DIR="\/storage\/\.config\/retroarch"
RA_CORES_DIR="\/storage\/\.kodi\/addons\/${ADDON_NAME}\/lib\/libretro"
RA_RES_DIR="\/storage\/\.kodi\/addons\/${ADDON_NAME}\/resources"

echo -ne "Making modifications to es_systems.cfg..."
CFG="config/emulationstation/es_systems.cfg"
sed -i -e "s/\/usr/\/storage\/.kodi\/addons\/${ADDON_NAME}/" $CFG
sed -i -e "s|/emuelec/scripts/|/storage/.kodi/addons/${ADDON_NAME}/bin/bash /storage/.kodi/addons/${ADDON_NAME}/bin/|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to z_getkillkeys.sh..."
CFG="config/emulationstation/scripts/configscripts/z_getkillkeys.sh"
sed -i -e "s|/emuelec/configs/|/storage/.kodi/addons/${ADDON_NAME}/config/|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to bezels.sh..."
CFG="bin/bezels.sh"
sed -i -e "s|/tmp/overlays/bezels|/storage/.kodi/addons/${ADDON_NAME}/config/bezels|" $CFG
sed -i -e "s|/emuelec/bezels|/storage/.kodi/addons/${ADDON_NAME}/config/bezels|" $CFG
mv -v "${ADDON_DIR}/resources/overlays/bezels/"* "${ADDON_DIR}/config/bezels" &>>"$LOG"
rm -rf "${ADDON_DIR}/resources/overlays/bezels"  &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to show_splash.sh..."
CFG="bin/show_splash.sh"
sed -i -e "s|/storage/.config/emuelec/configs|/storage/.kodi/addons/${ADDON_NAME}/config|" $CFG
sed -i -e "s|/storage/.config|/storage/.kodi/addons/${ADDON_NAME}/config|" $CFG
sed -i -e "s|/usr/config/splash/|/storage/.kodi/addons/${ADDON_NAME}/config/splash/|" $CFG
sed -i -e "s|/emuelec/bezels|/storage/.kodi/addons/${ADDON_NAME}/config/bezels|" $CFG
sed -i -e "s|/emuelec/bezels|/storage/.kodi/addons/${ADDON_NAME}/config/bezels|" $CFG
sed -i -e "s|/storage/overlays/splash|/storage/.kodi/addons/${ADDON_NAME}/config/splash|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to inputconfiguration.sh..."
CFG="config/emulationstation/scripts/inputconfiguration.sh"
sed -i -e "s/\/usr\/bin\/bash/\/storage\/.kodi\/addons\/${ADDON_NAME}\/bin\/bash/" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to amiberry.start..."
CFG="bin/amiberry.start"
sed -i "s|. /etc/profile|. /storage/.kodi/addons/${ADDON_NAME}/config/ee_env.sh|" $CFG
sed -i "s|SDL_AUDIODRIVER=alsa|export SDL_AUDIODRIVER=alsa|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to hatari.start..."
CFG="bin/hatari.start"
sed -i "s|. /etc/profile|. /storage/.kodi/addons/${ADDON_NAME}/config/ee_env.sh|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to z_getkillkeys.sh..."
CFG="config/emulationstation/scripts/configscripts/z_getkillkeys.sh"
sed -i "s|/emuelec/configs/|/storage/.kodi/addons/$ADDON_NAME/config/|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to setres.sh..."
CFG="bin/setres.sh"
sed -i '9,12d;17,21d;28,31d' $CFG
sed -i "s|-e /ee_s905|! -e /ee_s905|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to emuelecRunEmu.sh..."
CFG="bin/emuelecRunEmu.sh"
cp -rf "config/emulationstation/scripts/emuelecRunEmu.sh" "bin/emuelecRunEmu.sh"
rm "config/emulationstation/scripts/emuelecRunEmu.sh"
sed -i -e "s|/tmp/cores/|${RA_CORES_DIR}/|" $CFG
sed -i -e "s/\/usr/\/storage\/.kodi\/addons\/${ADDON_NAME}/" $CFG
sed -i -e "s/\/tmp\/cores/${RA_CORES_DIR}/" $CFG
sed -i -e "s|/usr/bin/bash|/storage/.kodi/addons/${ADDON_NAME}/bin/bash|g" $CFG
sed -i -e "s|/emuelec/scripts/|/storage/.kodi/addons/${ADDON_NAME}/bin/|g" $CFG
sed -i -e "s|/emuelec/bin/|/storage/.kodi/addons/${ADDON_NAME}/bin/|g" $CFG
sed -i -e "s|/emuelec/configs/|/storage/.kodi/addons/${ADDON_NAME}/config/|g" $CFG
sed -i -e 's,\[\[ $arguments != \*"KEEPMUSIC"\* \]\],[ `echo $arguments | grep -c "KEEPMUSIC"` -eq 0 ],g' $CFG
sed -i -e 's,\[\[ $arguments != \*"NOLOG"\* \]\],[ `echo $arguments | grep -c "NOLOG"` -eq 0 ],g' $CFG
sed -i -e 's|\[\[ \! -f "/ee_s905" \]\] && ||g' $CFG
sed -i -e 's|/storage/.config/storage/.|/storage/.|g' $CFG
sed -i -e "s/sed -i \"s|pcm/# sed -i \"s|pcm/" $CFG
sed -i -e 's|set_audio alsa|/storage/.emulationstation/scripts/bgm.sh stop|g' $CFG
sed -i -e 's|set_audio pulseaudio|/storage/.emulationstation/scripts/bgm.sh start|g' $CFG
sed -i -e 's|get_ee_setting bezels.enabled|get_es_setting bool BEZELS|g' $CFG
sed -i -e 's|get_ee_setting splash.enabled|get_es_setting bool SPLASH|g' $CFG
sed -i -e 's|"$BEZ" == "1"|"$BEZ" == "true"|g' $CFG
sed -i -e 's|"$SPL" == "1"|"$SPL" == "true"|g' $CFG
sed -i -e 's|program=\\"/storage/.kodi/addons/.*/bin/killall|program=\\"/usr/bin/killall|' $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to BGM.sh..."
CFG="config/emulationstation/scripts/bgm.sh"
if [ $PROJECT = "Amlogic" ]; then
sed -i -e "s|systemd-run \$MUSICPLAYER -r 32000 -Z \$BGMPATH|( MPG123_MODDIR=\"/storage/.kodi/addons/${ADDON_NAME}/lib/mpg123\" /storage/.kodi/addons/${ADDON_NAME}/bin/\$MUSICPLAYER -o alsa -r 32000 -Z \$BGMPATH ) \&|g" $CFG
else
sed -i -e "s|systemd-run \$MUSICPLAYER -Z \$BGMPATH|( MPG123_MODDIR=\"/storage/.kodi/addons/${ADDON_NAME}/lib/mpg123\" /storage/.kodi/addons/${ADDON_NAME}/bin/\$MUSICPLAYER -o alsa -Z \$BGMPATH ) \&|g" $CFG
fi
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "Making modifications to advmame.sh..."
CFG="bin/advmame.sh"
sed -i -e "s|/emuelec/scripts/set_advmame_joy.sh|/usr/bin/bash /emuelec/scripts/set_advmame_joy.sh|" $CFG
sed -i -e "s/\/usr\/share/\/storage\/.kodi\/addons\/${ADDON_NAME}\/config/" $CFG
sed -i -e "s/\/usr\/bin/\/storage\/.kodi\/addons\/${ADDON_NAME}\/bin/" $CFG
sed -i -e "s/device_alsa_device default/device_alsa_device sdl/" "config/advance/advmame.rc"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

# PPSSPP does not work on CoreELEC Amlogic-ng so we change es_settings.cfg to use ppssp libretro

if [ $PROJECT = "Amlogic" ]; then
	echo -ne "Making modifications to ppsspp.sh..."
	CFG="bin/ppsspp.sh"
	sed -i -e "s|/usr/bin/setres.sh|/storage/.kodi/addons/${ADDON_NAME}/bin/setres.sh|" $CFG
	[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
else
	echo -ne "Making modifications to es_settings.cfg..."
	CFG="config/emulationstation/es_settings.cfg"
	sed -i -e "s|PPSSPPSA|Libretro_ppsspp|" $CFG
	sed -i "s|,PPSSPPSA||" "config/emulationstation/scripts/getcores.sh"
	[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
fi

# OpenBOR does not work on CoreELEC on S922x
if [ $PROJECT = "Amlogic-ng" ]; then
echo -ne "Removing OpenBOR from es_systems.cfg"
CFG="config/emulationstation/es_systems.cfg"
xmlstarlet ed -L -P -d "/systemList/system[name='openbor']" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
else 
echo -ne "Making modifications to openbor.sh..."
CFG="bin/openbor.sh"
sed -i -e "s|/usr/bin/setres.sh|/storage/.kodi/addons/${ADDON_NAME}/bin/setres.sh|" $CFG
sed -i -e "s|/storage/.config/openbor/master.cfg|/storage/.kodi/addons/${ADDON_NAME}/config/openbor/master.cfg|" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }
fi

echo "Making modifications to retroarch.cfg..."
CFG="config/retroarch.cfg"

echo -ne "\toverlays "
sed -i "s/\/tmp\/overlays/${RA_RES_DIR}\/overlays/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsavefiles "
sed -i "s/\/storage\/savefiles/${RA_CFG_DIR}\/savefiles/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsavestates "
sed -i "s/\/storage\/savestates/${RA_CFG_DIR}\/savestates/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tremappings "
sed -i "s/\/storage\/remappings/${RA_CFG_DIR}\/remappings/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tplaylists "
sed -i "s/\/storage\/playlists/${RA_CFG_DIR}\/playlists/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tcores "
sed -i "s/\/tmp\/cores/${RA_CORES_DIR}/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsystem "
sed -i "s/\/storage\/system/${RA_CFG_DIR}\/system/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tassets "
sed -i "s/\/tmp\/assets/${RA_RES_DIR}\/assets/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tthumbnails "
sed -i "s/\/storage\/thumbnails/${RA_CFG_DIR}\/thumbnails/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tshaders "
sed -i "s/\/tmp\/shaders/${RA_RES_DIR}\/shaders/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tvideo_filters "
sed -i "s/\/usr\/share\/video_filters/${RA_RES_DIR}\/video_filters/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\taudio_filters "
sed -i "s/\/usr\/share\/audio_filters/${RA_RES_DIR}\/audio_filters/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tretroarch-assets "
sed -i "s/\/usr\/share\/retroarch-assets/${RA_RES_DIR}\/assets/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tjoypads "
sed -i "s/\/tmp\/joypads/${RA_RES_DIR}\/joypads/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tdatabase "
sed -i "s/\/tmp\/database/${RA_RES_DIR}\/database/g" $CFG
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo -n "Fixing paths..."
find bin/ -name *.sh -exec sed -i "s|/emuelec/scripts/|/storage/.kodi/addons/${ADDON_NAME}/bin/|g" {} \;
find bin/ -name *.sh -exec sed -i "s|/emuelec/bin/|/storage/.kodi/addons/${ADDON_NAME}/bin/|g" {} \;
[ $? -eq 0 ] && echo "done." || { echo "failed!" ; exit 1 ; }

echo -ne "Setting permissions..."
chmod +x ${ADDON_DIR}/bin/* &>>"$LOG"
chmod +x ${ADDON_DIR}/config/emulationstation/scripts/*.sh &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo "Fixing logs path"
sed -ri -e "s|/emuelec/logs|/storage/.kodi/addons/${ADDON_NAME}/logs|g" $(grep -Elr --binary-files=without-match "/emuelec/logs" "${PROJECT_DIR}/${ADDON_NAME}")
sed -i -e "s|#{log_addon}#|ln -sf /storage/.config/emuelec/logs/es_log.txt /storage/.kodi/addons/${ADDON_NAME}/logs/es_log.txt\nln -sf /storage/.config/emuelec/logs/es_log.txt.bak /storage/.kodi/addons/${ADDON_NAME}/logs/es_log.txt.bak|g" ${PROJECT_DIR}/${ADDON_NAME}/bin/emuelecRunEmu.sh
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo -n "Creating archive..."
cd ..
zip -y -r "${ARCHIVE_NAME}" "${ADDON_NAME}" &>>"$LOG"
[ $? -eq 0 ] && echo "done." || { echo "failed!" ; exit 1 ; }

echo
echo "Creating repository files..."

echo -ne "\tzip "
mv -vf "${ARCHIVE_NAME}" "${REPO_DIR}/${ADDON_NAME}/" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tsymlink "
ln -vsf "${ARCHIVE_NAME}" "${REPO_DIR}/${ADDON_NAME}/${ADDON_NAME}-LATEST.zip" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\ticon.png "
cp "${SCRIPT_DIR}/${EMUELEC_PATH}/addon/icon.png" "${REPO_DIR}/${ADDON_NAME}/resources/icon.png"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tfanart.png "
cp "${SCRIPT_DIR}/${EMUELEC_PATH}/addon/fanart.png" "${REPO_DIR}/${ADDON_NAME}/resources/fanart.png"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\taddon.xml "
echo "$addon" > "${REPO_DIR}/${ADDON_NAME}/addon.xml"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo "Cleaning up..."
cd "${SCRIPT_DIR}"

## echo -ne "\tEmulationstation"
##	EMUELEC_ADDON=Yes DISTRO=$DISTRO PROJECT=$PROJECT ARCH=$ARCH ./scripts/clean emulationstation &>>"$LOG"
## [ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tproject folder "
rm -vrf "${PROJECT_DIR}" &>>"$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo -ne "\tlog file "
rm -rf "$LOG"
[ $? -eq 0 ] && echo "(ok)" || { echo "(failed)" ; exit 1 ; }

echo
echo "Finished."
echo

} 

build_it Amlogic
build_it Amlogic-ng
