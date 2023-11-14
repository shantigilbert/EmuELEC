# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="SDL2_mixer"
PKG_VERSION="2.6.3"
PKG_SHA256="7a6ba86a478648ce617e3a5e9277181bc67f7ce9876605eea6affd4a0d6eea8f"
PKG_LICENSE="GPLv3"
PKG_SITE="http://www.libsdl.org/projects/SDL_mixer/release"
PKG_URL="$PKG_SITE/$PKG_NAME-$PKG_VERSION.tar.gz"
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
                       -DSDL2MIXER_OGG=OFF \
                       -DSDL2MIXER_MOD_XMP=OFF \
                       -DSDL2MIXER_WAVPACK=OFF"
}

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="-DSDL2MIXER_MIDI_FLUIDSYNTH=OFF \
                       -DSDL2MIXER_FLAC=ON \
                       -DSDL2MIXER_MOD_MODPLUG=ON \
                       -DSDL2MIXER_VORBIS_TREMOR=ON \
                       -DSDL2MIXER_OGG=ON \
                       -DSDL2MIXER_MP3=ON \
                       -DSDL2MIXER_SAMPLES=OFF \
                       -DSDL2MIXER_MOD_MODPLUG_SHARED=OFF \
                       -DSDL2MIXER_MOD_XMP=OFF \
                       -DSDL2MIXER_WAVPACK=OFF"
}

