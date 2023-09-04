# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="icu"
PKG_VERSION="72-1"
# could not find in github the checksum
#PKG_SHA256="43cbad628d98f37a3f95f6c34579f9144ef4bde60248fa6004a4f006d7487e69"
PKG_LICENSE="Custom"
PKG_SITE="https://icu.unicode.org"
# this link is not broken
PKG_URL="https://codeload.github.com/unicode-org/icu/tar.gz/refs/tags/release-${PKG_VERSION}"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain icu:host"
PKG_LONGDESC="International Components for Unicode library."
PKG_TOOLCHAIN="configure"

configure_package() {
  PKG_CONFIGURE_SCRIPT="${PKG_BUILD}/icu4c/source/configure"
  PKG_CONFIGURE_OPTS_TARGET="--disable-layout \
                             --disable-layoutex \
                             --enable-renaming \
                             --disable-samples \
                             --disable-tests \
                             --disable-tools \
                             --with-cross-build=${PKG_BUILD}/.${HOST_NAME}"
