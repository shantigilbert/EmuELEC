# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL_sound"
PKG_VERSION="f0d57c9b72d8"
PKG_SHA256="2d98c599d8bd120e75a9366d4d5c0b1284fee04cfdae4152898e0950544aa8eb"
PKG_LICENSE="GPLv3"
PKG_SITE="https://www.icculus.org/SDL_sound/"
PKG_URL="http://hg.icculus.org/icculus/SDL_sound/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2-git"
PKG_LONGDESC="SDL_sound library"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --disable-speex \
                           ac_cv_path_SDL2_CONFIG=$SYSROOT_PREFIX/usr/bin/sdl2-config"

post_unpack() {
  touch $PKG_BUILD/README
}

pre_configure_target() {
  export LDFLAGS="$LDFLAGS -lm"
}

post_makeinstall_target() {
  ln -sf ${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr/include/SDL/SDL_sound.h ${PKG_ORIG_SYSROOT_PREFIX:-${SYSROOT_PREFIX}}/usr/include/SDL2/SDL_sound.h
}
