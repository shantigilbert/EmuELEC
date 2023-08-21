# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="sdl12-compat"
PKG_VERSION="fdd66e3eed6a422dd20d61f357ff5a2806bf8f06"
PKG_SHA256="1abebff2a6a2dbcb6c66cd0e5694e74b15cc2f50abee6f9b34b9d31e3bb72d9b"
PKG_ARCH="any"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libsdl-org/sdl12-compat"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus SDL2"
PKG_DEPENDS_HOST="SDL2:host yasm:host"
PKG_SECTION="multimedia"
PKG_SHORTDESC="SDL: A cross-platform Graphic API"
PKG_LONGDESC="An SDL-1.2 compatibility layer that uses SDL 2.0 behind the scenes. "

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET+=" -DSDL12TESTS=off"
}

pre_configure_host() {
PKG_CMAKE_OPTS_HOST+=" -DSDL12TESTS=off"
}
