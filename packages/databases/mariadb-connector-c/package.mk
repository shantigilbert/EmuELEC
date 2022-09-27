# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mariadb-connector-c"
PKG_VERSION="3.3.2"
PKG_SHA256="fb1a37a5bfeccc3e95bb455f5a5523c57d2c4337a204e28d1e23af5cbbe848a9"
PKG_LICENSE="LGPL"
PKG_SITE="https://mariadb.org/"
PKG_URL="https://github.com/mariadb-corporation/mariadb-connector-c/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib openssl"
PKG_LONGDESC="mariadb-connector: library to conntect to mariadb/mysql database server"
PKG_BUILD_FLAGS="-gold"

PKG_CMAKE_OPTS_TARGET="-DWITH_EXTERNAL_ZLIB=ON
                       -DCLIENT_PLUGIN_DIALOG=STATIC
                       -DCLIENT_PLUGIN_MYSQL_CLEAR_PASSWORD=STATIC
                       -DCLIENT_PLUGIN_MYSQL_OLD_PASSWORD=STATIC
                       -DCLIENT_PLUGIN_REMOTE_IO=OFF
                      "

post_makeinstall_target() {
  # keep modern authentication plugins
  PLUGINP=${INSTALL}/usr/lib/mariadb/plugin
  mkdir -p ${INSTALL}/.tmp
  mv ${PLUGINP}/{caching_sha2_password,client_ed25519,sha256_password}.so ${INSTALL}/.tmp

  # drop all unneeded
  rm -rf ${INSTALL}/usr

  mkdir -p ${PLUGINP}
  mv ${INSTALL}/.tmp/* ${PLUGINP}/
  rmdir ${INSTALL}/.tmp
}
