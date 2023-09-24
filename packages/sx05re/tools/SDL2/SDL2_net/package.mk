# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2_net"
PKG_VERSION="2.2.0"
PKG_SHA256="4e4a891988316271974ff4e9585ed1ef729a123d22c08bd473129179dc857feb"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/projects/SDL_net/"
PKG_URL="https://www.libsdl.org/projects/SDL_net/release/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_LONGDESC="SDL2_net: network library" 
PKG_DEPENDS_HOST="SDL2:host toolchain:host"
