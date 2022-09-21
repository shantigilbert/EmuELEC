# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libvncserver"
PKG_VERSION="0.9.13"
PKG_SHA256="0ae5bb9175dc0a602fe85c1cf591ac47ee5247b87f2bf164c16b05f87cbfa81a"
PKG_LICENSE="GPL"
PKG_SITE="https://libvnc.github.io/"
PKG_URL="https://github.com/LibVNC/libvncserver/archive/LibVNCServer-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libjpeg-turbo libpng openssl systemd"
PKG_LONGDESC="A C library that allow you to easily implement VNC server or client functionality."

PKG_CMAKE_OPTS_TARGET="-DWITH_GCRYPT=0 \
                       -DWITH_GNUTLS=0 \
                       -DWITH_GTK=0 \
                       -DWITH_SDL=0 \
                       -DWITH_TIGHTVNC_FILETRANSFER=0"
