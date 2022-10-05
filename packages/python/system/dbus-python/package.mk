# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="dbus-python"
PKG_VERSION="1.2.18"
PKG_SHA256="92bdd1e68b45596c833307a5ff4b217ee6929a1502f5341bae28fd120acf7260"
PKG_LICENSE="GPL"
PKG_SITE="https://freedesktop.org/wiki/Software/dbus"
PKG_URL="https://dbus.freedesktop.org/releases/dbus-python/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 dbus dbus-glib"
PKG_LONGDESC="D-BUS is a message bus, used for sending messages between applications."
PKG_BUILD_FLAGS="+lto"

pre_configure_target() {
  export PYTHON_CONFIG="${SYSROOT_PREFIX}/usr/bin/python3-config"
  export PYTHON_INCLUDES="$(${SYSROOT_PREFIX}/usr/bin/python3-config --includes)"
  export PYTHON_LIBS="$(${SYSROOT_PREFIX}/usr/bin/python3-config --ldflags --embed)"
}

post_makeinstall_target() {
  python_remove_source
}
