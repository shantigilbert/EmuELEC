# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-emulationstation"
PKG_VERSION="4abe946efbcbb14513e0ddc51b51df7225db0d5c"
PKG_GIT_CLONE_BRANCH="EmuELEC"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/EmuELEC/emuelec-emulationstation"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git freetype curl freeimage vlc bash rapidjson ${OPENGLES} SDL2_mixer fping pyyaml"
PKG_SECTION="emuelec"
PKG_NEED_UNPACK="busybox"
PKG_SHORTDESC="Emulationstation emulator frontend"
PKG_BUILD_FLAGS="-gold"
GET_HANDLER_SUPPORT="git"

# themes for Emulationstation
PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET es-theme-EmuELEC-carbon"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_EMUELEC=1 -DDISABLE_KODI=1 -DENABLE_FILEMANAGER=1"

if [ "$DEVICE" == "OdroidGoAdvance" ]; then
sed -i "s|ExecStart=.*|ExecStart=/usr/bin/emulationstation --log-path /storage/.config/emuelec/logs --screenrotate 3 --resolution 480 320|" $PKG_DIR/system.d/emustation.service
else
sed -i "s|ExecStart=.*|ExecStart=/usr/bin/emulationstation --log-path /storage/.config/emuelec/logs|" $PKG_DIR/system.d/emustation.service
fi

makeinstall_target() {
	mkdir -p $INSTALL/usr/config/emuelec/configs/locale/i18n/charmaps
	cp -rf $PKG_BUILD/locale/lang/* $INSTALL/usr/config/emuelec/configs/locale/
	cp -PR "$(get_build_dir glibc)/localedata/charmaps/UTF-8" $INSTALL/usr/config/emuelec/configs/locale/i18n/charmaps/UTF-8
	
	mkdir -p $INSTALL/usr/lib
	ln -sf /storage/.config/emuelec/configs/locale $INSTALL/usr/lib/locale
	
	mkdir -p $INSTALL/usr/config/emulationstation/resources
    cp -rf $PKG_BUILD/resources/* $INSTALL/usr/config/emulationstation/resources/
    
	mkdir -p $INSTALL/usr/lib/python2.7
	cp -rf $PKG_DIR/bluez/* $INSTALL/usr/lib/python2.7
	
    mkdir -p $INSTALL/usr/bin
    ln -sf /storage/.config/emulationstation/resources $INSTALL/usr/bin/resources
    cp -rf $PKG_BUILD/emulationstation $INSTALL/usr/bin
    cp -PR "$(get_build_dir glibc)/.$TARGET_NAME/locale/localedef" $INSTALL/usr/bin

	mkdir -p $INSTALL/etc/emulationstation/
	ln -sf /storage/.config/emulationstation/themes $INSTALL/etc/emulationstation/
   
	mkdir -p $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/scripts $INSTALL/usr/config/emulationstation
	cp -rf $PKG_DIR/config/*.cfg $INSTALL/usr/config/emulationstation

# Remove systems that are not compatible with S905
	if [[ ${PROJECT} != "Amlogic-ng" ]]; then 	
	xmlstarlet ed -L -P -d "/systemList/system[name='3do']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	xmlstarlet ed -L -P -d "/systemList/system[name='saturn']" $INSTALL/usr/config/emulationstation/es_systems.cfg
	fi 
	
	chmod +x $INSTALL/usr/config/emulationstation/scripts/*
	chmod +x $INSTALL/usr/config/emulationstation/scripts/configscripts/*
	find $INSTALL/usr/config/emulationstation/scripts/ -type f -exec chmod o+x {} \; 
	
	if [ ${PROJECT} = "Amlogic-ng" ]; then    
	sed -i "s|,mba_mini_libretro|,mba_mini_libretro,mame2016_libretro|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	sed -i "s|snes9x2005_plus_libretro|snes9x2005_plus_libretro,mesen-s_libretro|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	fi
}

post_install() {  
	enable_service emustation.service
	mkdir -p $INSTALL/usr/share
	ln -sf /storage/.config/emuelec/configs/locale $INSTALL/usr/share/locale
	sed -i "s|ExecStart=.*|ExecStart=/usr/bin/emulationstation --log-path /storage/.config/emuelec/logs|" $PKG_DIR/system.d/emustation.service
}
