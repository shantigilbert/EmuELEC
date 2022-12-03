# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxkbfile"
PKG_VERSION="1.1.1"
PKG_SHA256="8623dc26e7aac3c5ad8a25e57b566f4324f5619e5db38457f0804ee4ed953443"
PKG_LICENSE="OSS"
PKG_SITE="https://www.X.org"
PKG_URL="https://xorg.freedesktop.org/archive/individual/lib/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain util-macros libX11"
PKG_LONGDESC="Libxkbfile provides an interface to read and manipulate description files for XKB, the X11 keyboard configuration extension."

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
