# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="box64"
PKG_VERSION="e10a78d67112b10806825732f4122d8ade9e6b4e"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box64"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain gl4es"
PKG_LONGDESC="Box64 - Linux Userspace x86_64 Emulator with a twist, targeted at ARM64 Linux devices"
PKG_TOOLCHAIN="cmake"

if [[ "${PROJECT}" == "Amlogic"* ]]; then
	PKG_CMAKE_OPTS_TARGET=" -DRK3399=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo"
else
	PKG_CMAKE_OPTS_TARGET=" -DRK3326=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo"
fi

makeinstall_target() {
  mkdir -p $INSTALL/usr/config/emuelec/bin/box64/lib
  cp $PKG_BUILD/x64lib/* $INSTALL/usr/config/emuelec/bin/box64/lib
  cp $PKG_BUILD/.${TARGET_NAME}/box64 $INSTALL/usr/config/emuelec/bin/box64/
  
  mkdir -p $INSTALL/etc/binfmt.d
  ln -sf /emuelec/configs/box64.conf $INSTALL/etc/binfmt.d/box64.conf
 
}
