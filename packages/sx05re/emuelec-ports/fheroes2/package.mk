# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fheroes2"
PKG_VERSION="eab9bde925a1d6435e436ce944cfe251a0f66a13"
PKG_ARCH="any"
PKG_SITE="https://github.com/ihhub/fheroes2"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_SHORTDESC="Free Heroes of Might and Magic II (fheroes2) is a recreation of HoMM2 game engine."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET=" -DENABLE_RELEASE=ON -DUSE_SDL_VERSION=SDL2 -DENABLE_IMAGE=ON -DCMAKE_BUILD_TYPE=Release"

makeinstall_target() {
mkdir -p ${INSTALL}/usr/share/fheroes2/files/data
mkdir -p ${INSTALL}/usr/bin
mkdir -p ${INSTALL}/usr/config/fheroes2

cp ${PKG_BUILD}/files/data/resurrection.h2d ${INSTALL}/usr/share/fheroes2/files/data 
cp ${PKG_BUILD}/.${TARGET_NAME}/fheroes2 ${INSTALL}/usr/bin
cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/fheroes2

}
