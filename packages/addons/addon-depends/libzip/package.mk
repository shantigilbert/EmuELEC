# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libzip"
PKG_VERSION="1.10.1"
PKG_SHA256="dc3c8d5b4c8bbd09626864f6bcf93de701540f761d76b85d7c7d710f4bd90318"
PKG_LICENSE="GPL"
PKG_SITE="http://www.nih.at/libzip/"
PKG_URL="http://www.nih.at/libzip/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain zlib zstd"
PKG_LONGDESC="A C library for reading, creating, and modifying zip archives."

PKG_CMAKE_OPTS_TARGET="-DENABLE_COMMONCRYPTO=OFF \
                       -DENABLE_GNUTLS=OFF \
                       -DENABLE_MBEDTLS=OFF \
                       -DENABLE_OPENSSL=OFF \
                       -DENABLE_WINDOWS_CRYPTO=OFF \
                       -DENABLE_ZSTD=OFF \
                       -DBUILD_TOOLS=OFF \
                       -DBUILD_REGRESS=OFF \
                       -DBUILD_EXAMPLES=OFF \
                       -DBUILD_DOC=OFF \
                       -DBUILD_SHARED_LIBS=OFF"
