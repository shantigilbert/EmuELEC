# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="box86"
PKG_VERSION="a62a9f6c7522507a8ca15c366812424654b20da1"
PKG_SHA256="0c28798e6d555081b24ab24aebc31472e818328499a2212e6c583f4144f22ea0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box86"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC="Box86 - Linux Userspace x86 Emulator with a twist, targeted at ARM Linux devices"
PKG_TOOLCHAIN="cmake"

if [[ "${PROJECT}" == "Amlogic"* ]]; then
	PKG_CMAKE_OPTS_TARGET=" -DRK3399=1 -DCMAKE_BUILD_TYPE=Release"
else
	PKG_CMAKE_OPTS_TARGET=" -DRK3326=1 -DCMAKE_BUILD_TYPE=Release"
fi

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/emuelec/bin/box86/lib
  cp $PKG_BUILD/x86lib/* $INSTALL/usr/config/emuelec/bin/box86/lib
  cp $PKG_BUILD/.${TARGET_NAME}/box86 $INSTALL/usr/config/emuelec/bin/box86/
  
  mkdir -p $INSTALL/etc/binfmt.d
  ln -sf /emuelec/configs/box86.conf $INSTALL/etc/binfmt.d/box86.conf
 
}
