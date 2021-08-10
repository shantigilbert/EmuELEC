# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="devilutionX"
PKG_VERSION="cb62e7bf2d9797d74363c7350eaf631144d2d2a5"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="unlicense"
PKG_SITE="https://github.com/diasurgical/devilutionX"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git SDL2_mixer SDL2_ttf libsodium"
PKG_LONGDESC="Diablo build for modern operating systems "
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="-lto"

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET=" -DBINARY_RELEASE=1 -DCMAKE_BUILD_TYPE="Release" -DDEBUG=OFF -DPREFILL_PLAYER_NAME=ON"
sed -i "s|;-static-libstdc++>|;-lstdc++>|" $PKG_BUILD/CMakeLists.txt
}

makeinstall_target() { 
mkdir -p $INSTALL/usr/bin
cp -rf $PKG_BUILD/.$TARGET_NAME/devilutionx $INSTALL/usr/bin
cp -rf $PKG_BUILD/Packaging/resources/CharisSILB.ttf $PKG_BUILD/.$TARGET_NAME/devilutionx $INSTALL/usr/bin

mkdir -p ${INSTALL}/usr/share/fonts/truetype
cp ../Packaging/resources/*.ttf ${INSTALL}/usr/share/fonts/truetype/
mkfontscale ${INSTALL}/usr/share/fonts/truetype
mkfontdir ${INSTALL}/usr/share/fonts/truetype
    
ninja -t clean
  cmake ${CMAKE_GENERATOR_NINJA} ${TARGET_CMAKE_OPTS} ${PKG_CMAKE_OPTS_TARGET} -DHELLFIRE=1 $(dirname ${PKG_CMAKE_SCRIPT})
  ninja ${NINJA_OPTS}

  cp devilutionx $INSTALL/usr/bin/devilutionx.hf

 
}
