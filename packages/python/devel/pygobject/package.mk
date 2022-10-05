# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pygobject"
PKG_VERSION="3.28.3"
PKG_SHA256="3dd3e21015d06e00482ea665fc1733b77e754a6ab656a5db5d7f7bfaf31ad0b0"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.pygtk.org/"
PKG_URL="http://ftp.gnome.org/pub/GNOME/sources/pygobject/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain Python3 glib libffi gobject-introspection pgi"
PKG_LONGDESC="A convenient wrapper for the GObject+ library for use in Python programs."
PKG_TOOLCHAIN="autotools"
PKG_IS_ADDON="no"

PKG_CONFIGURE_OPTS_TARGET="--disable-cairo \
                           --enable-shared \
                           --with-python=${TOOLCHAIN}/bin/${PKG_PYTHON_VERSION}"

pre_configure_target() {
  export PYTHON_INCLUDES="$(${SYSROOT_PREFIX}/usr/bin/python3-config --includes)"
}

post_unpack() {
  sed -i "s|@CODE_COVERAGE_RULES@||" ${PKG_BUILD}/Makefile.am

  # https://docs.python.org/3/whatsnew/3.9.html
  #   the tp_print slot of PyTypeObject has been removed
  sed -i "s|                              offsetof(PyTypeObject, tp_print) ||" ${PKG_BUILD}/gi/pygobject-object.c
}

post_makeinstall_target() {
  python_remove_source

  rm -rf ${INSTALL}/usr/bin
  rm -rf ${INSTALL}/usr/share/pygobject
}
