# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_ttf"
PKG_VERSION="2.0.14"
PKG_SHA256="34db5e20bcf64e7071fe9ae25acaa7d72bdc4f11ab3ce59acc768ab62fe39276"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain freetype SDL2-git"
PKG_LONGDESC="This is a sample library which allows you to use TrueType fonts in your SDL applications"

if [ ! "$DISPLAYSERVER" = "x11" ]; then
  X11="--without-x"
fi

PKG_CONFIGURE_OPTS_TARGET="--with-freetype-prefix=$SYSROOT_PREFIX/usr $X11"
