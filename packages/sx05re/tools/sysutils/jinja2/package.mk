# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="jinja2"
PKG_VERSION="077b7918a7642ff6742fe48a32e54d7875140894"
PKG_SHA256="e7c249311b817a86e43a3b4a9ab1f255d3ece2607cae0b58aa409f3f8b1803cc"
PKG_LICENSE="OSS"
PKG_SITE="https://github.com/pallets/jinja"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 distutilscross:host"
PKG_LONGDESC="Python 2 and 3 compatibility library "
PKG_TOOLCHAIN="manual"
PKG_DEPENDS_HOST="toolchain:host MarkupSafe:host"

make_host() {
  python3 setup.py build
}

makeinstall_host() {
  python3 setup.py install --prefix=$TOOLCHAIN
}
