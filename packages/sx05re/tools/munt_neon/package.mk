# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="munt_neon"
PKG_VERSION="5785a6c9321179cf0544128ea4f740bb59f1928b"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/asakous/munt"
PKG_URL="https://github.com/asakous/munt.git"
PKG_DEPENDS_TARGET="toolchain math_neon"
PKG_LONGDESC="A software synthesiser emulating pre-GM MIDI devices such as the Roland MT-32."
GET_HANDLER_SUPPORT="git"
PKG_CMAKE_OPTS_TARGET="-Dmunt_WITH_MT32EMU_QT=0 \
                       -Dmunt_WITH_MT32EMU_SMF2WAV=0 \
                       -Dlibmt32emu_SHARED=0"


pre_configure_target() {
sed -i -e "s/cortex-a7/cortex-a53/" $PKG_BUILD/mt32emu_alsadrv/Makefile
sed -i -e "s/\.\.\/libmathneon.a/\$\{SYSROOT_PREFIX}\/usr\/lib\/libmathneon.a/" $PKG_BUILD/mt32emu_alsadrv/Makefile
sed -i -e "s/\/usr\/share\/mt32-rom-data\//\/storage\/mt32-rom-data\//" $PKG_BUILD/mt32emu_alsadrv/src/alsadrv.cpp
sed -i -e "s/\.\.\/build\/mt32emu\/libmt32emu.a/\$\{PKG_BUILD\}\/\.armv8a-libreelec-linux-gnueabi\/mt32emu\/libmt32emu.a/" $PKG_BUILD/mt32emu_alsadrv/Makefile
export PKG_BUILD=${PKG_BUILD}
export SYSROOT_PREFIX=${SYSROOT_PREFIX}
}

makeinstall_target() {
PKG_LIBNAME="libmt32emu.a"
PKG_LIBPATH="$PKG_BUILD/.armv8a-libreelec-linux-gnueabi/mt32emu/libmt32emu.a"

  mkdir -p $INSTALL/usr/lib
  cp $PKG_LIBPATH $SYSROOT_PREFIX/usr/lib/$PKG_LIBNAME
  cp $PKG_LIBPATH $INSTALL/usr/lib
  cd $PKG_BUILD/mt32emu_alsadrv/
  make mt32d
  mkdir -p $INSTALL/usr/bin
  cp mt32d $INSTALL/usr/bin/mt32d
}


