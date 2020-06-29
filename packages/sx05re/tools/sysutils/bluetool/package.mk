# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Based on libreelec pycryptodome package

PKG_NAME="bluetool"
PKG_VERSION="0.2.3"
PKG_SHA256="09aca1174ea9d8b402f2231aa2277726174c30482710fc887ebbda7eb820f614"
PKG_LICENSE="GPL"
PKG_SITE="https://pypi.org/project/bluetool"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="Python2 dbus-python tcpbridge"
PKG_LONGDESC="A simple Python API for Bluetooth D-Bus calls. Allows easy pairing, connecting and scanning.Also provides a TCP-to-RFCOMM socket bridge for data transfer."
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  cd $PKG_BUILD
  rm -rf .$TARGET_NAME

  export PYTHONXCPREFIX="$SYSROOT_PREFIX/usr"
  export LDSHARED="$CC -shared"
}

make_target() {
  python setup.py build
}

makeinstall_target() {
  python setup.py install --root=$INSTALL --prefix=/usr
}
