# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="advancemame"
PKG_VERSION="9a0f48554381906808a5a562d2fefb02d06d0001"
PKG_SHA256="6442c58c5a84759664a37c03068ea7b4bd19dbb438d6d322dcb2b8a0e6f6a1dc"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/amadvance/advancemame"
PKG_URL="https://github.com/amadvance/advancemame/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_DIR="advancemame-${PKG_VERSION}*"
PKG_DEPENDS_TARGET="toolchain freetype slang alsa SDL2 ncurses"
PKG_SECTION="emuelec/mod"
PKG_SHORTDESC="A MAME and MESS port with an advanced video support"
PKG_LONGDESC="A MAME and MESS port with an advanced video support for Arcade Monitors, TVs, and PC Monitors"
PKG_AUTORECONF="yes"
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-parallel"

pre_configure_target() {
  export CFLAGS="$CFLAGS -O3 $(pkg-config --cflags slang) $(pkg-config --cflags ncurses)"
  export CXXFLAGS="$CXXFLAGS -O3 $(pkg-config --cflags slang) $(pkg-config --cflags ncurses)"
  export LDFLAGS="$LDFLAGS $(pkg-config --libs slang) $(pkg-config --libs ncurses)"
  
  cd ${PKG_BUILD}
  ./autogen.sh
  
  # Fix slang include path
  sed -i "s|#include <slang.h>|#include <${SYSROOT_PREFIX}/usr/include/slang.h>|" configure.ac
  
  # Replace @SLANGCFLAGS@, @NCURSESCFLAGS@, @SLANGLIBS@, and @NCURSESLIBS@ in Makefile.in files
  find . -name "Makefile.in" -exec sed -i 's/@SLANGCFLAGS@//g; s/@NCURSESCFLAGS@//g; s/@SLANGLIBS@//g; s/@NCURSESLIBS@//g' {} +
}

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                          --datadir=/usr/share/ \
                          --datarootdir=/usr/share/ \
                          --enable-fb \
                          --enable-freetype \
                          --with-freetype-prefix=${SYSROOT_PREFIX}/usr/ \
                          --enable-slang \
                          --enable-sdl2 \
                          --with-sdl-prefix=${SYSROOT_PREFIX}/usr"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/advmame
  
  # Install binary
  cp -f obj/mame/linux/blend/advmame ${INSTALL}/usr/bin/
  cp -f obj/j/linux/blend/advj ${INSTALL}/usr/bin/
  
  # Install support files
  cp -r support/category.ini ${INSTALL}/usr/config/emuelec/configs/advmame/
  cp -r support/sysinfo.dat ${INSTALL}/usr/config/emuelec/configs/advmame/
  cp -r support/history.dat ${INSTALL}/usr/config/emuelec/configs/advmame/
  cp -r support/hiscore.dat ${INSTALL}/usr/config/emuelec/configs/advmame/
  cp -r support/event.dat ${INSTALL}/usr/config/emuelec/configs/advmame/

  # Install config based on device
  if [ "${DEVICE}" == "OdroidGoAdvance" ]; then
    cp ${PKG_DIR}/config/advmame.rc_oga ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
  elif [ "${DEVICE}" == "GameForce" ]; then
    cp ${PKG_DIR}/config/advmame.rc_gf ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
  else
    cp ${PKG_DIR}/config/advmame.rc ${INSTALL}/usr/config/emuelec/configs/advmame/advmame.rc
  fi
}

