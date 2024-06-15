# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_image"
PKG_VERSION="2.8.2"
PKG_LICENSE="GPL"
PKG_SITE="http://www.libsdl.org/"
PKG_URL="https://github.com/libsdl-org/SDL_image/releases/download/release-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2 libjpeg-turbo libpng"
PKG_LONGDESC="SDL_image is an image file loading library. "
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="--disable-sdltest \
                           --enable-bmp \
                           --enable-gif \
                           --enable-jpg \
                           --enable-lbm \
                           --enable-pcx \
                           --enable-png \
                           --enable-pnm \
                           --enable-tga \
                           --enable-tif \
                           --enable-xcf \
                           --enable-xpm \
                           --enable-xv \
                           --enable-webp"
