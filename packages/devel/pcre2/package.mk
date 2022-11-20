# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pcre2"
PKG_VERSION="10.40"
PKG_SHA256="14e4b83c4783933dc17e964318e6324f7cae1bc75d8f3c79bc6969f00c159d68"
PKG_LICENSE="BSD"
PKG_SITE="http://www.pcre.org/"
PKG_URL="https://github.com/PCRE2Project/pcre2/releases/download/pcre2-${PKG_VERSION}/pcre2-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A set of functions that implement regular expression pattern matching using the same syntax."
PKG_BUILD_FLAGS="+pic"

PKG_CMAKE_OPTS_HOST="-DBUILD_SHARED_LIBS=OFF \
                     -DBUILD_STATIC_LIBS=ON \
                     -DPCRE2_STATIC_PIC=ON \
                     -DPCRE2_BUILD_PCRE2_8=ON \
                     -DPCRE2_BUILD_PCRE2_16=ON \
                     -DPCRE2_BUILD_PCRE2_32=ON \
                     -DPCRE2_SUPPORT_JIT=ON \
                     -DPCRE2_BUILD_TESTS=OFF \
                     -DPCRE2_SUPPORT_LIBEDIT=OFF \
                     -DPCRE2_SUPPORT_LIBREADLINE=OFF"

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF \
                       -DPCRE2_BUILD_PCRE2_16=ON \
                       -DPCRE2_SUPPORT_LIBREADLINE=OFF \
                       -DPCRE2_STATIC_PIC=ON"

PKG_CMAKE_OPTS_HOST="-DBUILD_SHARED_LIBS=OFF \
                       -DPCRE2_BUILD_PCRE2_16=ON \
                       -DPCRE2_SUPPORT_LIBREADLINE=OFF \
                       -DPCRE2_STATIC_PIC=ON"

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/bin
}
