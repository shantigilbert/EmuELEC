# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="fbneoSA"
#PKG_VERSION="f16edfe129258ff22cc6a8b9dd536ebc47f759d6"
#PKG_VERSION="59e8f7f4bfb0993009e7e1e1d62e7af7000f61cb"
#PKG_VERSION="24f77006fffb402e7af42c0176598b62d6f4826e"
#PKG_VERSION="742a7aa167c9bb42c26183ae68501739be79e082"
#PKG_VERSION="bb0fc3427cc33335b8ec492259fc8e8a03d4a729"
#PKG_VERSION="d80b805393f6d2fb72b8ef85c76e8f0fbba8b864"
#PKG_VERSION="ce1ba20b6e64679b6f49b279d0e74ee3d8f77109"
#PKG_VERSION="f179eb0cf4050ea5d37ff65efb5efe56d5108be5"
PKG_VERSION="4fd53a0c6cb9e007f392795100281c73c7018a7f"
PKG_ARCH="aarch64"
PKG_LICENSE="Custom"
PKG_SITE="https://github.com/finalburnneo/FBNeo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 gl4es"
PKG_LONGDESC="https://github.com/finalburnneo/FBNeo/blob/master/src/license.txt"
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="make"

PKG_MAKE_OPTS_TARGET=" sdl2 RELEASEBUILD=1 FORCE_SYSTEM_LIBPNG=1"

pre_configure_target() {
sed -i "s|\`sdl2-config|\`${SYSROOT_PREFIX}/usr/bin/sdl2-config|g" makefile.sdl2
sed -i "s|objdir	= obj/|objdir	= ${PKG_BUILD}/obj/|" makefile.sdl2
sed -i "s|srcdir	= src/|srcdir	= ${PKG_BUILD}/src/|" makefile.sdl2
sed -i "s|CC	= gcc|#CC	= gcc|" makefile.sdl2
export LDFLAGS+=" -L$(get_install_dir gl4es)/usr/lib"
unset MAKELEVEL
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin
cp -rf ${PKG_BUILD}/fbneo $INSTALL/usr/bin
cp -rf ${PKG_BUILD}/src/license.txt $INSTALL/usr/bin/fbneo_license.txt
cp -rf ${PKG_DIR}/scripts/* $INSTALL/usr/bin
}
