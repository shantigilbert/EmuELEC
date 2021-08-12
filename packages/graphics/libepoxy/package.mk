# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

# libepoxy (actually) needs to be built shared, to avoid
# (EE) Failed to load /usr/lib/xorg/modules/libglamoregl.so:
# /usr/lib/xorg/modules/libglamoregl.so: undefined symbol: epoxy_eglCreateImageKHR
# in Xorg.log

PKG_NAME="libepoxy"
PKG_VERSION="ecfa8e0f083084181d36966fa084aca9a6c97d53"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/anholt/libepoxy"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Epoxy is a library for handling OpenGL function pointer management for you."


PKG_MESON_OPTS_TARGET+="-Dtests=false -Ddocs=false"

if [ "$OPENGL" != "no" ]; then
  PKG_DEPENDS_TARGET+=" $OPENGL"
fi

if [ "$OPENGLES" != "no" ]; then
  PKG_DEPENDS_TARGET+=" $OPENGLES"
fi

if [ "$DISPLAYSERVER" != "x11" ]; then
  PKG_MESON_OPTS_TARGET+=" -Dx11=false"
fi
