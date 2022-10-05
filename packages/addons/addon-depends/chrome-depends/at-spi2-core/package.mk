# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2017 Escalade
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="at-spi2-core"
PKG_VERSION="2.45.1"
PKG_SHA256="ba95f346e93108fbb3462c62437081d582154db279b4052dedc52a706828b192"
PKG_LICENSE="OSS"
PKG_SITE="http://www.gnome.org/"
PKG_URL="https://download.gnome.org/sources/at-spi2-core/${PKG_VERSION:0:4}/at-spi2-core-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain atk dbus glib libXtst"
PKG_LONGDESC="Protocol definitions and daemon for D-Bus at-spi."

PKG_MESON_OPTS_TARGET="-Ddocs=false \
                       -Dintrospection=no \
                       -Ddbus_daemon=/usr/bin/dbus-daemon"

pre_configure_target() {
  TARGET_LDFLAGS="${LDFLAGS} -lXext"
}
