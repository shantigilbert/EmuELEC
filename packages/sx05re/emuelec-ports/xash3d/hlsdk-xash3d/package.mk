# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (github.com/escalade)
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hlsdk-xash3d"
PKG_VERSION="8f5c36dc62b463044cffa3ddf40347905ea39f08"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/FWGS/hlsdk-xash3d"
PKG_URL="https://github.com/FWGS/hlsdk-xash3d.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Xash3D FWGS engine. Rebooted fork since big Xash3D 0.99"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-lto -gold"

makeinstall_target() {
  # Seems to be needed for some reason
  #if [ "${ARCH}" = "arm" ]; then
  #  CPPFLAGS+="-D__ARM_ARCH_7__"
  #fi

  # Compile xash3d
  cd ${PKG_BUILD}
  ARGS="--build-type=release \
	--64bits"
  ./waf configure ${ARGS}
  ./waf build -v
  ./waf install --destdir=${INSTALL}/usr/lib/xash3d
}
