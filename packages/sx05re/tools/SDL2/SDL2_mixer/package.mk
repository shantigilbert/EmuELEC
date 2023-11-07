# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="SDL2_mixer"
PKG_VERSION="2.6.3"
PKG_SHA256=""
PKG_LICENSE="GPLv3"
PKG_URL="$PKG_SITE/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_URL="https://github.com/libsdl-org/SDL_mixer/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2 mpg123-compat libvorbis libvorbisidec libogg opusfile libmodplug flac fluidsynth"
PKG_LONGDESC="SDL2 mixer"
PKG_DEPENDS_HOST="toolchain:host SDL2:host"

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST="-DSDL2MIXER_OPUS=OFF \
                       -DSDL2MIXER_MOD=OFF \
                       -DSDL2MIXER_MP3=OFF \
                       -DSDL2MIXER_FLAC=OFF \
                       -DSDL2MIXER_MIDI=OFF \
                       -DSDL2MIXER_VORBIS=OFF \
                       -DSDL2MIXER_OGG=OFF"
}

pre_configure_target() {
  SDL2_CONFIG=${SYSROOT_PREFIX}/usr/bin/sdl2-config
  PKG_CONFIGURE_OPTS_TARGET="--disable-sdltest \
			     --disable-music-midi-fluidsynth \
			     --enable-music-flac \
			     --enable-music-mod-modplug \
			     --enable-music-ogg-tremor \
			     --enable-music-ogg \
			     --enable-music-mp3"
#  PKG_CMAKE_OPTS_TARGET="-DSDL2MIXER_OPUS=OFF"
}
