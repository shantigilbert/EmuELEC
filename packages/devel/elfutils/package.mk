# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="elfutils"
PKG_VERSION="0.187"
PKG_SHA256="e70b0dfbe610f90c4d1fe0d71af142a4e25c3c4ef9ebab8d2d72b65159d454c8"
PKG_LICENSE="GPL"
PKG_SITE="https://sourceware.org/elfutils/"
PKG_URL="https://sourceware.org/elfutils/ftp/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_HOST="make:host zlib:host"
PKG_DEPENDS_TARGET="toolchain zlib elfutils:host"
PKG_LONGDESC="A collection of utilities to handle ELF objects."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic"

if [ "${LIBREELEC_VERSION}" = "devel" ]; then
  PKG_PROGRAMS="--enable-programs --program-prefix="
  PKG_PROGRAMS_LIST="readelf"
else
  PKG_PROGRAMS="--disable-programs"
  PKG_PROGRAMS_LIST=
fi

PKG_CONFIGURE_OPTS_HOST="utrace_cv_cc_biarch=false \
                         --disable-programs \
                         --disable-nls \
                         --disable-debuginfod \
                         --disable-libdebuginfod \
                         --with-zlib \
                         --without-bzlib \
                         --without-lzma"

PKG_CONFIGURE_OPTS_TARGET="utrace_cv_cc_biarch=false \
                           ${PKG_PROGRAMS} \
                           --disable-nls \
                           --disable-debuginfod \
                           --disable-libdebuginfod \
                           --with-zlib \
                           --without-bzlib \
                           --without-lzma"

post_makeinstall_target() {
  # don't install progs into sysroot
  rm -fr ${SYSROOT_PREFIX}/usr/bin

  if [ -n "${PKG_PROGRAMS_LIST}" ]; then
    for PKG_TEMP in $(find ${INSTALL}/usr/bin -type f); do
      listcontains "${PKG_PROGRAMS_LIST}" ${PKG_TEMP#${INSTALL}/usr/bin/} || rm ${PKG_TEMP}
    done
  fi
}
