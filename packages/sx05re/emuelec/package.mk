# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec"
PKG_VERSION=""
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain emuelec-emulationstation retroarch"
PKG_SECTION="emuelec"
PKG_SHORTDESC="EmuELEC Meta Package"
PKG_LONGDESC="EmuELEC Meta Package"
PKG_IS_ADDON="no"
PKG_AUTORECONF="no"
PKG_TOOLCHAIN="make"

# Thanks to magicseb  Reicast SA now WORKS :D
PKG_EXPERIMENTAL="munt nestopiaCV quasi88 xmil np2kai hypseus dosbox-x"
PKG_EMUS="$LIBRETRO_CORES advancemame PPSSPPSDL reicastsa reicastsa_old amiberry hatarisa openbor dosbox-sdl2 mupen64plus-nx mba.mini.plus scummvmsa residualvm commander-genius stellasa VVVVVV devilutionX sdlpop"
PKG_TOOLS="common-shaders scraper Skyscraper MC libretro-bash-launcher SDL_GameControllerDB linux-utils xmlstarlet CoreELEC-Debug-Scripts sixaxis jslisten evtest mpv poppler bluetool"
PKG_RETROPIE_DEP="bash pyudev dialog six git dbus-python pygobject coreutils"
PKG_DEPENDS_TARGET+=" $PKG_EMUS $PKG_TOOLS $PKG_RETROPIE_DEP $PKG_EXPERIMENTAL"

# Removed cores for space and/or performance
# PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET mame2015 fba4arm $LIBRETRO_EXTRA_CORES"

# These packages are only meant for S922x, S905x2 and A311D devices as they run poorly on S905, S912, etc"
if [ "$PROJECT" == "Amlogic-ng" ]; then
PKG_DEPENDS_TARGET+=" $LIBRETRO_S922X_CORES mame2016 xow"
fi

if [ "$DEVICE" == "OdroidGoAdvance" ]; then
	PKG_DEPENDS_TARGET+=" kmscon odroidgoa-utils"
	
	#we disable some cores that are not working or work poorly on OGA
	for discore in opera mesen-s virtualjaguar yabasanshiro quicknes reicastsa_old reicastsa; do
		PKG_DEPENDS_TARGET=$(echo $PKG_DEPENDS_TARGET | sed "s|$discore||")
	done
else
	PKG_DEPENDS_TARGET+=" fbterm"
fi

make_target() {
if [ "$PROJECT" == "Amlogic-ng" ]; then
	cp -r $PKG_DIR/fbfix* $PKG_BUILD/
	cd $PKG_BUILD/fbfix
	$CC -O2 fbfix.c -o fbfix
fi
}

makeinstall_target() {
   
	if [ "$PROJECT" == "Amlogic-ng" ]; then
	mkdir -p $INSTALL/usr/config/emuelec/bin
	cp $PKG_BUILD/fbfix/fbfix $INSTALL/usr/config/emuelec/bin
	fi

  mkdir -p $INSTALL/usr/config/
    cp -rf $PKG_DIR/config/* $INSTALL/usr/config/
    ln -sf /storage/.config/emuelec $INSTALL/emuelec
    find $INSTALL/usr/config/emuelec/ -type f -exec chmod o+x {} \;
	
	if [ "$PROJECT" == "Amlogic" ]; then 
		rm $INSTALL/usr/config/asound.conf-amlogic-ng
	else
		rm $INSTALL/usr/config/asound.conf
		mv $INSTALL/usr/config/asound.conf-amlogic-ng $INSTALL/usr/config/asound.conf
	fi 
  
  mkdir -p $INSTALL/usr/config/emuelec/logs
  ln -sf /var/log $INSTALL/usr/config/emuelec/logs/var-log
    
  mkdir -p $INSTALL/usr/bin/
  
  # leave for compatibility
  if [ "$PROJECT" == "Amlogic" ]; then
      echo "s905" > $INSTALL/ee_s905
  fi
  
  if [ "$DEVICE" == "OdroidGoAdvance" ]; then
      echo "$DEVICE" > $INSTALL/ee_arch
  else
      echo "$PROJECT" > $INSTALL/ee_arch
  fi

  FILES=$INSTALL/usr/config/emuelec/scripts/*
	for f in $FILES 
	do
	FI=$(basename $f)
	ln -sf "/storage/.config/emuelec/scripts/$FI" $INSTALL/usr/bin/
  done

  mkdir -p $INSTALL/usr/share/retroarch-overlays
    cp -r $PKG_DIR/overlay/* $INSTALL/usr/share/retroarch-overlays
  
  mkdir -p $INSTALL/usr/share/common-shaders
    cp -r $PKG_DIR/shaders/* $INSTALL/usr/share/common-shaders
    
  mkdir -p $INSTALL/usr/share/libretro-database
     touch $INSTALL/usr/share/libretro-database/dummy

# Move plymouth-lite bin to show splash screen
cp $(get_build_dir plymouth-lite)/.install_init/usr/bin/ply-image $INSTALL/usr/bin
}

post_install() {
# Remove unnecesary Retroarch Assets and overlays
  for i in branding glui nuklear nxrgui pkg switch wallpapers zarch COPYING; do
    rm -rf "$INSTALL/usr/share/retroarch-assets/$i"
  done
  
  for i in automatic dot-art flatui neoactive pixel retroactive retrosystem systematic convert.sh NPMApng2PMApng.py; do
  rm -rf "$INSTALL/usr/share/retroarch-assets/xmb/$i"
  done
  
  for i in borders effects gamepads ipad keyboards misc; do
    rm -rf "$INSTALL/usr/share/retroarch-overlays/$i"
  done

mkdir -p $INSTALL/etc/retroarch-joypad-autoconfig
cp -r $PKG_DIR/gamepads/* $INSTALL/etc/retroarch-joypad-autoconfig

# link default.target to emuelec.target
   ln -sf emuelec.target $INSTALL/usr/lib/systemd/system/default.target
   enable_service emuelec-autostart.service
  
# Thanks to vpeter we can now have bash :) 
  rm -f $INSTALL/usr/bin/{sh,bash,busybox,sort}
  cp $(get_build_dir busybox)/.install_pkg/usr/bin/busybox $INSTALL/usr/bin
  cp $(get_build_dir bash)/.install_pkg/usr/bin/bash $INSTALL/usr/bin
  cp $(get_build_dir coreutils)/.install_pkg/usr/bin/sort $INSTALL/usr/bin
  ln -sf bash $INSTALL/usr/bin/sh
 
  echo "chmod 4755 $INSTALL/usr/bin/bash" >> $FAKEROOT_SCRIPT
  echo "chmod 4755 $INSTALL/usr/bin/busybox" >> $FAKEROOT_SCRIPT
  find $INSTALL/usr/ -type f -iname "*.sh" -exec chmod +x {} \;
  
CORESFILE="$INSTALL/usr/config/emulationstation/scripts/getcores.sh"

if [ ${PROJECT} = "Amlogic-ng" ]; then    
	sed -i "s|,mba_mini_libretro|,mba_mini_libretro,mame2016_libretro|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
	sed -i "s|snes9x2005_plus_libretro|snes9x2005_plus_libretro,mesen-s_libretro|" $INSTALL/usr/config/emulationstation/scripts/getcores.sh
fi

if [ "${DEVICE}" = "OdroidGoAdvance" ]; then
	#remove unused options for OdroidGoA
	for discore in opera_libretro mesen-s_libretro virtualjaguar_libretro yabasanshiro_libretro quicknes_libretro REICASTSA_OLD REICASTSA; do
		sed -i "s|$discore||g" $CORESFILE
		sed -i "s|,,|,|g" $CORESFILE
		sed -i "s|,\"|\"|g" $CORESFILE
	done
fi
 
  # Remove scripts from OdroidGoAdvance build
	if [[ ${DEVICE} == "OdroidGoAdvance" ]]; then 
	for i in "01 - Get ES Themes" "03 - wifi" "10 - Force Update" "04 - Configure Reicast" "06 - Sselphs scraper" "07 - Skyscraper" "09 - system info"; do 
	xmlstarlet ed -L -P -d "/gameList/game[name='${i}']" $INSTALL/usr/config/emuelec/scripts/modules/gamelist.xml
	rm "$INSTALL/usr/config/emuelec/scripts/modules/${i}.sh"
	done
	fi 
  
} 
