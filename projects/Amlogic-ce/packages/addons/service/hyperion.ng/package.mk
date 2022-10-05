# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="hyperion.ng"
PKG_VERSION="2.0.13"
PKG_SHA256="ed286d43a470c7263e189fdfd224d6594d85d5b5880001d4274a80e1dd8ea465"
PKG_REV="110"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/hyperion-project/hyperion.ng"
PKG_URL="https://github.com/hyperion-project/hyperion.ng/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 avahi libusb qt-everywhere protobuf flatbuffers:host flatbuffers libcec libjpeg-turbo qmdnsengine"
PKG_SECTION="service"
PKG_SHORTDESC="Hyperion.NG: an AmbiLight controller"
PKG_LONGDESC="Hyperion.NG($PKG_VERSION) is an modern opensource AmbiLight implementation."

PKG_IS_ADDON="yes"
PKG_ADDON_NAME="Hyperion.NG"
PKG_ADDON_TYPE="xbmc.service"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_NO_SYSTEM_FROM_IMPORTED=ON \
                       -DCMAKE_BUILD_TYPE=Release \
                       -DUSE_SYSTEM_PROTO_LIBS=ON \
                       -DUSE_SYSTEM_FLATBUFFERS_LIBS=ON \
                       -DUSE_SYSTEM_QMDNS_LIBS=ON \
                       -DPLATFORM=amlogic \
                       -DENABLE_AMLOGIC=ON \
                       -DENABLE_DISPMANX=OFF \
                       -DENABLE_FB=ON \
                       -DENABLE_DEV_WS281XPWM=OFF \
                       -DENABLE_X11=OFF \
                       -DENABLE_V4L2=ON \
                       -DENABLE_OSX=OFF \
                       -DENABLE_DEV_SPI=ON \
                       -DENABLE_MDNS=ON \
                       -DENABLE_DEV_TINKERFORGE=OFF \
                       -DENABLE_TESTS=OFF \
                       -DENABLE_DEPLOY_DEPENDENCIES=OFF \
                       -Wno-dev"

addon() {
  mkdir -p $ADDON_BUILD/$PKG_ADDON_ID/bin
    cp $PKG_BUILD/.$TARGET_NAME/bin/* $ADDON_BUILD/$PKG_ADDON_ID/bin
}
