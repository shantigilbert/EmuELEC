# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="swaybg"
PKG_VERSION="1.1.1"
PKG_SHA256="71cc8fc2cb7ae5ad3af772ab286b0b42f1c7cb17bea131e78c2d40a2fb8e6c59"
PKG_LICENSE="MIT"
PKG_SITE="https://swaywm.org/"
PKG_URL="https://github.com/swaywm/swaybg/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols cairo pango gdk-pixbuf"
PKG_LONGDESC="Wallpaper tool for Wayland compositors"

PKG_MESON_OPTS_TARGET="-Dgdk-pixbuf=enabled \
                       -Dman-pages=disabled"

pre_configure_target() {
  # swaybg does not build without -Wno flags as all warnings being treated as errors
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-maybe-uninitialized")
}
