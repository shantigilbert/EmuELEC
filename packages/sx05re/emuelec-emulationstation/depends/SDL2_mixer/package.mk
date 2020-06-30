# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="SDL2_mixer"
PKG_VERSION="2.0.4"
PKG_SHA256=""
PKG_LICENSE="GPLv3"
PKG_SITE="http://www.libsdl.org/projects/SDL_mixer/release"
PKG_URL="$PKG_SITE/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib SDL2-git mpg123-compat"
PKG_LONGDESC="SDL_mixer 2.0.1"

pre_configure_target() {

  PKG_CONFIGURE_OPTS_TARGET="--disable-fluidsynth \
							 --disable-music-flac \
							 --disable-music-mod-modplug \
							 --disable-music-ogg-tremor \
							 --enable-music-mp3"
							 

}
