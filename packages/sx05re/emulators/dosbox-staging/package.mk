# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="dosbox-staging"
PKG_VERSION="c1b6f8c7eaf7060c8282f9d1712a655f27f52cac"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/dosbox-staging/dosbox-staging"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain linux meson:host glibc glib systemd dbus alsa-lib SDL2-git SDL2_net SDL_sound libpng zlib libvorbis flac libogg fluidsynth-git munt opusfile"
PKG_LONGDESC="DOS/x86 emulator focusing on ease of use "
PKG_BUILD_FLAGS="+lto"

pre_configure_target() {
PKG_MESON_OPTS_TARGET=" -Duse_opengl=false"
}

post_makeinstall_target () {
	mkdir -p ${INSTALL}/usr/config/dosbox
	cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
	cp -a ${PKG_DIR}/config/*  ${INSTALL}/usr/config/dosbox/
	rm -rf $INSTALL/usr/share
}
