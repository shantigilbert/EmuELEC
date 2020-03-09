# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Frank Hartung (supervisedthinking (@) gmail.com)

PKG_NAME="amiberry"
PKG_VERSION="dbbc33f7822c70f5de575d0bbec8e4208d0c6a91"
PKG_ARCH="arm"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/midwan/amiberry"
PKG_URL="https://github.com/midwan/amiberry.git"
PKG_DEPENDS_TARGET="toolchain linux glibc bzip2 zlib SDL2-git SDL2_image SDL2_ttf capsimg freetype libxml2 flac libogg mpg123-compat libpng libmpeg2"
PKG_LONGDESC="Amiberry is an optimized Amiga emulator for ARM-based boards."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"
PKG_GIT_CLONE_BRANCH="master"

pre_configure_target() {
  cd ${PKG_BUILD}
  export SYSROOT_PREFIX=${SYSROOT_PREFIX}

  case ${PROJECT} in
    Amlogic)
        AMIBERRY_PLATFORM="AMLGX"
      ;;
    Amlogic-ng)
        AMIBERRY_PLATFORM="AMLG12B"
      ;;
  esac
 
if [ "$DEVICE" == "OdroidGoAdvance" ]; then
PKG_DEPENDS_TARGET=" $PKG_DEPENDS_TARGET libgo2"
AMIBERRY_PLATFORM="RK3326"
fi

sed -i "s|AS     = as|AS     \?= as|" Makefile
PKG_MAKE_OPTS_TARGET+=" all PLATFORM=${AMIBERRY_PLATFORM} SDL_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config"
}

makeinstall_target() {
  # Create directories
  mkdir -p ${INSTALL}/usr/bin
  mkdir -p ${INSTALL}/usr/lib
  mkdir -p ${INSTALL}/usr/config/amiberry
  # mkdir -p ${INSTALL}/usr/config/amiberry/controller

  # Copy ressources
  cp -a ${PKG_DIR}/config/*           ${INSTALL}/usr/config/amiberry/
  cp -a data                          ${INSTALL}/usr/config/amiberry/
  cp -a savestates                    ${INSTALL}/usr/config/amiberry/
  cp -a screenshots                   ${INSTALL}/usr/config/amiberry/
  cp -a whdboot                       ${INSTALL}/usr/config/amiberry/
  ln -s /storage/roms/bios 			  ${INSTALL}/usr/config/amiberry/kickstarts

  # Create links to Retroarch controller files
  # ln -s /usr/share/retroarch/autoconfig/udev/8Bitdo_Pro_SF30_BT_B.cfg "${INSTALL}/usr/config/amiberry/controller/8Bitdo SF30 Pro.cfg"
  ln -s "/tmp/joypads" "${INSTALL}/usr/config/amiberry/controller"

  # Copy binary, scripts & link libcapsimg
  cp -a amiberry* ${INSTALL}/usr/bin/amiberry
  cp -a ${PKG_DIR}/scripts/*          ${INSTALL}/usr/bin
  ln -sf /usr/lib/libcapsimage.so.5.1 ${INSTALL}/usr/config/amiberry/capsimg.so
  
  if [ "$DEVICE" == "OdroidGoAdvance" ]; then
  echo "rotation_angle=-90" >> ${INSTALL}/usr/config/amiberry/conf/adfdir.conf
  UAE="${INSTALL}/usr/config/amiberry/conf/*.uae"
  for i in $UAE; do echo -e "gfx_center_vertical=smart\ngfx_center_horizontal=smart" >> $i; done
  fi
}
