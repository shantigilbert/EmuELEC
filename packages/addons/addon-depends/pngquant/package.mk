# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pngquant"
PKG_VERSION="2.17.0"
PKG_SHA256="a27cf0e64db499ccb3ddae9b36036e881f78293e46ec27a9e7a86a3802fcda66"
PKG_LICENSE="GPLv3"
PKG_SITE="https://pngquant.org"
PKG_URL="https://pngquant.org/pngquant-${PKG_VERSION}-src.tar.gz"
PKG_DEPENDS_HOST="toolchain:host libpng:host zlib:host"
PKG_LONGDESC="A lossy PNG compressor."

configure_host() {
  :
}

make_host() {
  cd ${PKG_BUILD}
  BIN=${PKG_BUILD}/pngquant make

  ${STRIP} ${PKG_BUILD}/pngquant
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp ${PKG_BUILD}/pngquant ${TOOLCHAIN}/bin
}
