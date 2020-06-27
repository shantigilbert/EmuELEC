# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Based on libreelec pycryptodome package

PKG_NAME="tcpbridge"
PKG_VERSION="1.1.1"
PKG_SHA256="d970c3635a2f0115cccbc0b7c0f27f8b8cd6981ef8cbd5b95fc7b224a6313133"
PKG_LICENSE="GPL"
PKG_SITE="https://pypi.org/project/tcpbridge"
PKG_URL="https://files.pythonhosted.org/packages/source/${PKG_NAME:0:1}/$PKG_NAME/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="Python2 dbus-python"
PKG_LONGDESC="TCP bridge for data transfer."
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
