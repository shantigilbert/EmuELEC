# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emulationstation-addon"
PKG_VERSION="c6d655d020e1401dea6355185b3da2a4fa415f89"
PKG_GIT_CLONE_BRANCH="EmuELEC"
if [[ ${EMUELEC_ADDON} ]]; then
PKG_VERSION="6b02c9158233aa35030d3105c5c59c2ee06db4c9"
PKG_GIT_CLONE_BRANCH="EmuELEC_Addon"
fi
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/shantigilbert/EmulationStation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git freetype curl freeimage vlc bash rapidjson ${OPENGLES} gcc"
PKG_SECTION="emuelec"
PKG_NEED_UNPACK="busybox"
PKG_SHORTDESC="Emulationstation emulator frontend with EmuELEC changes"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"


# themes for Emulationstation
PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET es-theme-ComicBook"

post_makeinstall_target() {

	mkdir -p $INSTALL/usr/lib
	cp $(get_build_dir gcc)/.install_pkg/usr/lib/libgomp* $INSTALL/usr/lib
	
	mkdir -p $INSTALL/usr/config/emulationstation/resources
	cp -rf $PKG_BUILD/resources/* $INSTALL/usr/config/emulationstation/resources/
	ln -sf /storage/.config/emulationstation/resources $INSTALL/usr/bin/resources

	mkdir -p $INSTALL/etc/emulationstation/
	ln -sf /storage/.config/emulationstation/themes $INSTALL/etc/emulationstation/
    
	mkdir -p $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/scripts $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/*.cfg $INSTALL/usr/config/emulationstation
	
	# Remove systems that are not compatible with S905
	if [ ${PROJECT} = "Amlogic" ]; then 	
	xmlstarlet ed -L -P -d "/systemList/system[name='3do']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	xmlstarlet ed -L -P -d "/systemList/system[name='segasaturn']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	fi
	
	chmod +x $INSTALL/usr/config/emulationstation/scripts/*
	chmod +x $INSTALL/usr/config/emulationstation/scripts/configscripts/*
	find $INSTALL/usr/config/emulationstation/scripts/ -type f -exec chmod o+x {} \; 

	if [ ${PROJECT} = "Amlogic-ng" ]; then    
	sed -i "s|-r 32000 -Z|-Z|" $INSTALL/usr/config/emulationstation/scripts/bgm.sh
	sed -i "s|Libretro_mba_mini|Libretro_mba_mini,Libretro_mame2016|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	sed -i "s|Libretro_snes9x2005_plus|Libretro_snes9x2005_plus,Libretro_mesen-s|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	fi
}

