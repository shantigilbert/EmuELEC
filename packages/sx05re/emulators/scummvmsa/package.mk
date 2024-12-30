# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="scummvmsa"
PKG_VERSION="0318b6b7ba863c7f5ee3a68b08d5a8251a9ce5b3"
PKG_SHA256="93723bf2a877308574a8e3c17b2def1b385e9a704b4faf821916e0cc3081c934"
PKG_REV="1"
PKG_LICENSE="GPL2"
PKG_SITE="https://github.com/scummvm/scummvm"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_net freetype fluidsynth-git libmad"
PKG_SHORTDESC="Script Creation Utility for Maniac Mansion Virtual Machine"
PKG_LONGDESC="ScummVM is a program which allows you to run certain classic graphical point-and-click adventure games, provided you already have their data files."

pre_configure_target() { 
TARGET_CONFIGURE_OPTS=" --disable-opengl-game --disable-opengl-game-classic --disable-opengl-game-shaders --host=${TARGET_NAME} --backend=sdl --enable-vkeybd --enable-optimizations --opengl-mode=gles2 --with-sdl-prefix=${SYSROOT_PREFIX}/usr/bin"
}

post_makeinstall_target() {
mkdir -p ${INSTALL}/usr/config/scummvm/extra 
	cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/scummvm/
	cp -rf ${PKG_BUILD}/backends/vkeybd/packs/*.zip ${INSTALL}/usr/config/scummvm/extra

mv ${INSTALL}/usr/local/bin ${INSTALL}/usr/
	cp -rf ${PKG_DIR}/bin/* ${INSTALL}/usr/bin
	
for i in metainfo pixmaps appdata applications doc icons man; do
    rm -rf "${INSTALL}/usr/local/share/${i}"
  done

 
}

