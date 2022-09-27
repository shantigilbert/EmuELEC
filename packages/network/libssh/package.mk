# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libssh"
PKG_VERSION="0.9.6"
PKG_SHA256="86bcf885bd9b80466fe0e05453c58b877df61afa8ba947a58c356d7f0fab829b"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.libssh.org/"
PKG_URL="https://www.libssh.org/files/$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib openssl"
PKG_LONGDESC="Library for accessing ssh client services through C libraries."

PKG_CMAKE_OPTS_TARGET="-DBUILD_SHARED_LIBS=OFF \
                       -DWITH_SERVER=OFF \
                       -DWITH_GCRYPT=OFF \
                       -DWITH_GSSAPI=OFF \
                       -DWITH_GEX=OFF \
                       -DWITH_INTERNAL_DOC=OFF"

makeinstall_target() {
# install static library only
  mkdir -p ${SYSROOT_PREFIX}/usr/lib
    cp ${PKG_BUILD}/.${TARGET_NAME}/src/libssh.a ${SYSROOT_PREFIX}/usr/lib

  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp ${PKG_BUILD}/.${TARGET_NAME}/libssh.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig

  mkdir -p ${SYSROOT_PREFIX}/usr/include/libssh
    cp ${PKG_BUILD}/include/libssh/{callbacks.h,legacy.h,libssh.h,server.h,sftp.h,ssh2.h} \
       ${PKG_BUILD}/.${TARGET_NAME}/include/libssh/libssh_version.h \
    ${SYSROOT_PREFIX}/usr/include/libssh
}
