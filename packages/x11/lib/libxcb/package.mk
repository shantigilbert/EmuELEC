# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="libxcb"
PKG_VERSION="1.13"
PKG_SHA256="188c8752193c50ff2dbe89db4554c63df2e26a2e47b0fa415a70918b5b851daa"
PKG_LICENSE="OSS"
PKG_SITE="http://xcb.freedesktop.org"
PKG_URL="http://xcb.freedesktop.org/dist/$PKG_NAME-$PKG_VERSION.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros Python2:host xcb-proto libpthread-stubs libXau"
PKG_LONGDESC="X C-language Bindings library."
PKG_BUILD_FLAGS="+pic"

PKG_CONFIGURE_OPTS_TARGET="--enable-static \
                           --enable-shared \
                           --disable-screensaver \
                           --disable-xprint \
                           --disable-selinux \
                           --disable-xvmc"

pre_configure_target() {
  PYTHON_LIBDIR=$SYSROOT_PREFIX/usr/lib/$PKG_PYTHON_VERSION
  PYTHON_TOOLCHAIN_PATH=$PYTHON_LIBDIR/site-packages

  PKG_CONFIG="$PKG_CONFIG --define-variable=pythondir=$PYTHON_TOOLCHAIN_PATH"
  PKG_CONFIG="$PKG_CONFIG --define-variable=xcbincludedir=$SYSROOT_PREFIX/usr/share/xcb"
}
