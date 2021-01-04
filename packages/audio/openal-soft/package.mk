# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="openal-soft"
PKG_VERSION="1.20.1"
PKG_SHA256="c32d10473457a8b545aab50070fe84be2b5b041e1f2099012777ee6be0057c13"
PKG_LICENSE="GPL"
PKG_SITE="http://www.openal.org/"
PKG_URL="https://github.com/kcat/openal-soft/archive/$PKG_NAME-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib openal-soft:host"
PKG_LONGDESC="OpenAL the Open Audio Library"

configure_package() {
  PKG_CMAKE_OPTS_HOST="-DALSOFT_BACKEND_OSS=off \
                       -DALSOFT_BACKEND_WAVE=off \
                       -DALSOFT_BACKEND_PULSEAUDIO=on \
                       -DALSOFT_EXAMPLES=off \
                       -DALSOFT_TESTS=off \
                       -DALSOFT_UTILS=off"

  PKG_CMAKE_OPTS_TARGET="-DALSOFT_NATIVE_TOOLS_PATH=$PKG_BUILD/.$HOST_NAME/native-tools \
                         -DALSOFT_BACKEND_OSS=off \
                         -DALSOFT_BACKEND_WAVE=off \
                         -DALSOFT_BACKEND_PULSEAUDIO=on \
                         -DALSOFT_EXAMPLES=off \
                         -DALSOFT_TESTS=off \
                         -DALSOFT_UTILS=off"
}

post_makeinstall_target() {
  mkdir -p $INSTALL/etc/openal
  sed s/^#drivers.*/drivers=alsa/ $INSTALL/usr/share/openal/alsoftrc.sample > $INSTALL/etc/openal/alsoft.conf
  rm -rf $INSTALL/usr/share/openal
}
