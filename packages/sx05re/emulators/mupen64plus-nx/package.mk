# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plus-nx"
PKG_VERSION="ea1c677c1e61ce1d95809c09cf26ffa75cd7e9dc"
PKG_SHA256="b2b06332523aef0fb44cb3b97cfab2122b627ca4ef11708b0e40c8699a2b288e"
if [ $PROJECT = "Amlogic" ]; then
PKG_VERSION="b785150465048fa88f812e23462f318e66af0be0"
PKG_SHA256="456c433f45b0e2ba15a587978234e3e1300301d431b6823747ad0e779331c97e"
fi
PKG_REV="1"
PKG_ARCH="arm"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro-nx"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain nasm:host $OPENGLES"
PKG_SECTION="libretro"
PKG_SHORTDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_LONGDESC="mupen64plus + RSP-HLE + GLideN64 + libretro"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {
  sed -e "s|^GIT_VERSION ?.*$|GIT_VERSION := \" ${PKG_VERSION:0:7}\"|" -i Makefile

if [ ${PROJECT} = "Amlogic-ng" ]; then
	PKG_MAKE_OPTS_TARGET+=" platform=AMLG12B"
	sed -i "s|GLES = 1|GLES3 = 1|g" Makefile
	sed -i "s|-lGLESv2|-lGLESv3|g" Makefile
elif [ "${PROJECT}" = "Amlogic" ]; then
	PKG_MAKE_OPTS_TARGET+=" platform=amlogic"
elif [ "${DEVICE}" = "OdroidGoAdvance" ]; then
	sed -i "s|GLES = 1|GLES3 = 1|g" Makefile
	sed -i "s|-lGLESv2|-lGLESv3|g" Makefile
	sed -i "s|cortex-a53|cortex-a35|g" Makefile
	PKG_MAKE_OPTS_TARGET+=" platform=RK3328"
fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mupen64plus_next_libretro.so $INSTALL/usr/lib/libretro/
}
