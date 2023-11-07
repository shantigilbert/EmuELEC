# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="lib32-fluidsynth"
PKG_VERSION="$(get_pkg_version fluidsynth)"
PKG_NEED_UNPACK="$(get_pkg_directory fluidsynth)"
PKG_LICENSE="GPL"
PKG_SITE="http://fluidsynth.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-glib lib32-libsndfile"
PKG_PATCH_DIRS+=" $(get_pkg_directory fluidsynth)/patches"
PKG_LONGDESC="FluidSynth renders midi music files as raw audio data, for playing or conversion."
PKG_BUILD_FLAGS="lib32 +pic"

PKG_CMAKE_OPTS_TARGET="-DLIB_SUFFIX= \
                       -Denable-libsndfile=1 \
                       -Denable-pkgconfig=1 \
                       -Denable-pulseaudio=0 \
                       -Denable-readline=0"

unpack() {
  ${SCRIPTS}/get fluidsynth
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/fluidsynth/fluidsynth-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
