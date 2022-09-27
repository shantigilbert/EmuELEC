# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="nv-codec-headers"
PKG_VERSION="11.1.5.1"
PKG_SHA256="d095fbd56aa93772471a323be0ebe65504a0f43f06c76a30b6d25da77b06ae9c"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/FFmpeg/nv-codec-headers"
PKG_URL="https://github.com/FFmpeg/nv-codec-headers/archive/n${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="FFmpeg version of headers required to interface with Nvidias codec APIs."
PKG_TOOLCHAIN="make"

makeinstall_target(){
  make DESTDIR=${SYSROOT_PREFIX} PREFIX=/usr install
}
