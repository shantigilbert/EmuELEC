# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="shared-mime-info"
PKG_VERSION="2.1"
PKG_SHA256="37df6475da31a8b5fc63a54ba0770a3eefa0a708b778cb6366dccee96393cb60"
PKG_LICENSE="GPL2"
PKG_SITE="https://freedesktop.org/wiki/Software/shared-mime-info/"
PKG_URL="https://gitlab.freedesktop.org/xdg/${PKG_NAME}/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_HOST="toolchain:host glib:host libxml2:host gettext:host itstool:host"
PKG_DEPENDS_TARGET="toolchain glib libxml2 gettext shared-mime-info:host"
PKG_LONGDESC="The shared-mime-info package contains the core database of common types."
PKG_BUILD_FLAGS="-parallel"

configure_package() {
  # Sway Support
  if [ ! "${WINDOWMANAGER}" = "sway" ]; then
    PKG_BUILD_FLAGS+=" -sysroot"
  fi
}

PKG_MESON_OPTS_HOST="-Dupdate-mimedb=false"
PKG_MESON_OPTS_TARGET="-Dupdate-mimedb=false"

post_makeinstall_target() {
  # Create /usr/share/mime/mime.cache
  if [ "${WINDOWMANAGER}" = "sway" ]; then
    ${TOOLCHAIN}/bin/update-mime-database ${INSTALL}/usr/share/mime
  fi
}
