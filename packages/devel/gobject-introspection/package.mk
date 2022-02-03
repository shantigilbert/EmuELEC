# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2020-present Team CoreELEC (https://coreelec.org)

PKG_NAME="gobject-introspection"
PKG_VERSION="1.56.0"
PKG_SHA256="dbf222ad56bc0f5a3b6cfc7be07b4b7c9a7e3a65761d5969b9fc800327c88312"
PKG_ARCH="any"
PKG_LICENSE="LGPL"
PKG_SITE="http://www.gtk.org/"
PKG_URL="https://github.com/GNOME/$PKG_NAME/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain libffi glib qemu:host gobject-introspection:host Python3"
PKG_DEPENDS_HOST="libffi:host glib:host"
PKG_SECTION="devel"
PKG_SHORTDESC="glib: C support library"
PKG_LONGDESC="GLib is a library which includes support routines for C such as lists, trees, hashes, memory allocation, and many other things."
PKG_TOOLCHAIN="autotools"

PKG_IS_ADDON="no"

PKG_CONFIGURE_OPTS_HOST="--disable-doctool \
                         --enable-shared \
                         --with-python=$TOOLCHAIN/bin/${PKG_PYTHON_VERSION}"

PKG_CONFIGURE_OPTS_TARGET="--disable-doctool"

post_unpack() {
  rm -f $PKG_BUILD/gtk-doc.make
  cat > $PKG_BUILD/gtk-doc.make <<EOF
EXTRA_DIST =
CLEANFILES =
EOF
}

pre_configure_host() {
  CFLAGS+=" -fPIC"
}

pre_configure_target() {
  PYTHON_INCLUDES="$($SYSROOT_PREFIX/usr/bin/python3-config --includes)"
  CPPFLAGS="-I$SYSROOT_PREFIX/usr/include/${PKG_PYTHON_VERSION}"
  CFLAGS+=" -fPIC"
  LDFLAGS+=" -Wl,--dynamic-linker=/usr/lib/ld-$(get_pkg_version glibc).so"

cat > $TOOLCHAIN/bin/g-ir-scanner-wrapper << EOF
#!/bin/sh
env LD_LIBRARY_PATH="$PKG_BUILD/.$TARGET_NAME/.libs:$SYSROOT_PREFIX/usr/lib:$SYSROOT_PREFIX/../lib:$TOOLCHAIN/lib" \
    GI_CROSS_LAUNCHER="$TOOLCHAIN/bin/qemu-$TARGET_ARCH -L $SYSROOT_PREFIX" \
    GI_LDD=$TOOLCHAIN/bin/ldd-cross \
    $TOOLCHAIN/bin/g-ir-scanner "\$@"
EOF

  chmod +x $TOOLCHAIN/bin/g-ir-scanner-wrapper

cat > $TOOLCHAIN/bin/g-ir-compiler-wrapper << EOF
#!/bin/sh
env LD_LIBRARY_PATH="$PKG_BUILD/.$TARGET_NAME/.libs:$SYSROOT_PREFIX/usr/lib:$SYSROOT_PREFIX/../lib:$TOOLCHAIN/lib" \
    GI_CROSS_LAUNCHER="$TOOLCHAIN/bin/qemu-$TARGET_ARCH -L $SYSROOT_PREFIX" \
    GI_LDD=$TOOLCHAIN/bin/ldd-cross \
    $TOOLCHAIN/bin/g-ir-compiler "\$@"
EOF

  chmod +x $TOOLCHAIN/bin/g-ir-compiler-wrapper

cat > $TOOLCHAIN/bin/ldd-cross << EOF
#!/bin/sh
$TOOLCHAIN/bin/qemu-$TARGET_ARCH $SYSROOT_PREFIX/usr/lib/ld-$(get_pkg_version glibc).so --list "\$1"
EOF

  chmod +x $TOOLCHAIN/bin/ldd-cross
}

make_target() {
  GI_CROSS_LAUNCHER="$TOOLCHAIN/bin/qemu-$TARGET_ARCH" \
  GI_LDD=$TOOLCHAIN/bin/ldd-cross \
  INTROSPECTION_SCANNER=$TOOLCHAIN/bin/g-ir-scanner-wrapper \
  INTROSPECTION_COMPILER=$TOOLCHAIN/bin/g-ir-compiler-wrapper \
  make
}

post_makeinstall_target() {
  rm -rf $INSTALL/usr/bin
  rm -rf $INSTALL/usr/lib/gobject-introspection
  rm -rf $INSTALL/usr/share
}
