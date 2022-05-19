# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2022-present Langerz82 (https://github.com/Langerz82)

PKG_NAME="retrorun"
PKG_VERSION="d324cb6a50c74323b2c53a89bad749ac0207e584"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/navy1978/retrorun-go2"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain libgo2 libdrm libpng"
PKG_TOOLCHAIN="make"

pre_make_target() {
  mkdir -p src/go2
  cp -f $SYSROOT_PREFIX/usr/include/go2/*.h src/go2
}

pre_configure_target() {
	CFLAGS+=" -I$(get_build_dir libdrm)/include/drm"
	CFLAGS+=" -I$(get_build_dir linux)/include/uapi"
	CFLAGS+=" -I$(get_build_dir linux)/tools/include"

	PKG_MAKE_OPTS_TARGET=" config=release ARCH="

	sed -i "s|/storage/.config/distribution/|/storage/.config/retrorun/|g" ${PKG_BUILD}/src/main.cpp
}

makeinstall_target() {
	mkdir -p ${INSTALL}/usr/bin
	if [ "${ARCH}" == "arm" ]; then
		cp -f retrorun "${INSTALL}/usr/bin/retrorun32"
  else
    cp -f retrorun ${INSTALL}/usr/bin/retrorun
	fi

  cp $PKG_DIR/retrorun.sh $INSTALL/usr/bin

  mkdir -p $INSTALL/usr/config/retrorun/configs
  cp -vP $PKG_DIR/retrorun.cfg $INSTALL/usr/config/retrorun/configs
}
