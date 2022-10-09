# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dbussy"
PKG_VERSION="71616a370d3f59ef1681d26f5df77c1545d5bc04"   # 2022-09-03
PKG_SHA256="8ddae13387315c00bc316db1a2db8044073ad0d47f18d9840b3ba7f148b525ff"
PKG_LICENSE="LGPLv2.1+"
PKG_SITE="https://gitlab.com/ldo/dbussy"
PKG_URL="https://github.com/ldo/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 dbus"
PKG_LONGDESC="DBussy is a wrapper around libdbus, written in pure Python"
PKG_TOOLCHAIN="manual"

make_target() {
  python3 setup.py build
}

makeinstall_target() {
  python3 setup.py install --root=${INSTALL} --prefix=/usr
}

post_makeinstall_target() {
  python_remove_source
}
