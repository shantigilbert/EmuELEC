# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="btrfs-progs"
PKG_VERSION="6.0"
PKG_SHA256="f09320fa59adc9c85574506de15d339638c0aba116e2ce9044c3711d4ca1fbd8"
PKG_REV="110"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://btrfs.wiki.kernel.org/index.php/Main_Page"
PKG_URL="https://github.com/kdave/btrfs-progs/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain util-linux zlib systemd lzo"
PKG_SECTION="tools"
PKG_SHORTDESC="tools for the btrfs filesystem"
PKG_LONGDESC="tools for the btrfs filesystem"
PKG_TOOLCHAIN="configure"

PKG_BUILD_FLAGS="-sysroot"

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="BTRFS Tools"
PKG_ADDON_TYPE="xbmc.python.script"

PKG_CONFIGURE_OPTS_TARGET="--disable-backtrace \
                           --disable-convert \
                           --disable-documentation \
                           --disable-python \
                           --disable-zstd"

pre_configure_target() {
  ./autogen.sh
}

addon() {
  mkdir -p ${ADDON_BUILD}/${PKG_ADDON_ID}/bin/
    cp -P ${PKG_INSTALL}/usr/bin/{btrfs,btrfsck,btrfstune,fsck.btrfs,mkfs.btrfs} ${ADDON_BUILD}/${PKG_ADDON_ID}/bin
}
