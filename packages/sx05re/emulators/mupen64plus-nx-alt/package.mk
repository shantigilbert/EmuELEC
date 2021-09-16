# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="mupen64plus-nx-alt"
PKG_VERSION="7280cc27a55cc20ac16d4b6b403ca6fb22ee44c3"
PKG_SHA256="eab353fe5834d256af96f1fdac328b0656bdeeebde111860067a88bf5442bfe2"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mupen64plus-libretro-nx"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain nasm:host $OPENGLES"
PKG_SECTION="libretro"
PKG_LONGDESC="Improved mupen64plus libretro core reimplementation"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto"


pre_configure_target() {
  sed -e "s|^GIT_VERSION ?.*$|GIT_VERSION := \" ${PKG_VERSION:0:7}\"|" -i Makefile

if [ $ARCH == "arm" ]; then
	if [ ${PROJECT} = "Amlogic-ng" ]; then
		PKG_MAKE_OPTS_TARGET+=" platform=AMLG12B"
	elif [ "${PROJECT}" = "Amlogic" ]; then
		PKG_MAKE_OPTS_TARGET+=" platform=amlogic"
	elif [ "${DEVICE}" = "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
		sed -i "s|cortex-a53|cortex-a35|g" Makefile
		PKG_MAKE_OPTS_TARGET+=" platform=odroidgoa"
	fi
else
	if [ ${PROJECT} = "Amlogic-ng" ]; then
		PKG_MAKE_OPTS_TARGET+=" platform=odroid64 BOARD=N2"
	elif [ "${PROJECT}" = "Amlogic" ]; then 
		PKG_MAKE_OPTS_TARGET+=" platform=amlogic64"
	elif [ "${DEVICE}" = "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
		PKG_MAKE_OPTS_TARGET+=" platform=amlogic64"
	fi
fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp mupen64plus_next_libretro.so $INSTALL/usr/lib/libretro/mupen64plus_next_alt_libretro.so
}
