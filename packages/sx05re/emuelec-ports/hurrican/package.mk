# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hurrican"
PKG_VERSION="18ecb8b702c7ddbb76a933f57c1048144dc6a42f"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/HurricanGame/Hurrican"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_mixer libepoxy libmodplug"
PKG_LONGDESC="A fork of Hurrican, freeware jump and shoot game created by Poke53280, with SDL2 enabled by default, support for libopenmpt and CRT simulation "
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" ./Hurrican -DCMAKE_BUILD_TYPE=Release -DRENDERER=GLES2"

if [ "${DEVICE}" == "OdroidGoAdvance" ] || [ "${DEVICE}" == "GameForce" ]; then
	PKG_CMAKE_OPTS_TARGET+=" -DDEFAULT_SCREENBPP=16"
fi

pre_configure_target() {
  git submodule update --init --recursive
  cd $PKG_BUILD/
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp hurrican $INSTALL/usr/bin
cp "${PKG_DIR}/scripts/hurrican.sh" $INSTALL/usr/bin

mkdir -p $INSTALL/usr/config/emuelec/configs
cp -rf ${PKG_DIR}/config/* $INSTALL/usr/config/emuelec/configs/
}
