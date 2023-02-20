# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="vector06sdl"
PKG_VERSION="feadc1f42d3a08bed8bc4d80003c40225d040147"
PKG_SHA256="3358f60bb4ce25851236af9a90cdf7467a319b3cb17dc4c64623f1abfbec5f1e"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/svofski/vector06sdl"
PKG_URL="${PKG_SITE}/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain freetype slang alsa"
PKG_LONGDESC="Opensource Vector-06C emulator in C++"

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="-DCMAKE_SYSTEM_PROCESSOR=arm -DSDL2_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libSDL2.so -DSDL2_IMAGE_LIBRARY=${SYSROOT_PREFIX}/usr/lib/libSDL2_image.so"
#PKG_CONFIGURE_OPTS_TARGET=" --disable-pulseaudio --disable-esd --disable-video-mir --disable-video-wayland --disable-video-x11 --disable-video-opengl"
}
