# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pygobject"
PKG_VERSION="3.36.1"
PKG_SHA256="d1bf42802d1cec113b5adaa0e7bf7f3745b44521dc2163588d276d5cd61d718f"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.pygtk.org/"
PKG_URL="http://ftp.gnome.org/pub/GNOME/sources/pygobject/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain Python3 glib libffi gobject-introspection pgi"
PKG_LONGDESC="A convenient wrapper for the GObject+ library for use in Python programs."
PKG_TOOLCHAIN="auto"
PKG_IS_ADDON="no"

PKG_MESON_OPTS_TARGET="-Dpycairo=false \
                           -Dtests=false \
                           -Dpython=${TOOLCHAIN}/bin/${PKG_PYTHON_VERSION}"

pre_configure_target() {
  export PYTHON_INCLUDES="$(${SYSROOT_PREFIX}/usr/bin/python3-config --includes)"
}
