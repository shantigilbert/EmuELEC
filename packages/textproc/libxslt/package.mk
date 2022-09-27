# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libxslt"
PKG_VERSION="1.1.35"
PKG_SHA256="2da1c2954f8a4e844f9d4e9110d1b31d45e7a5f8e9edc61823984861505e6e5d"
PKG_LICENSE="MIT"
PKG_SITE="http://xmlsoft.org/xslt/"
PKG_URL="https://gitlab.gnome.org/GNOME/${PKG_NAME}/-/archive/v${PKG_VERSION}/${PKG_NAME}-v${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_HOST="libxml2:host"
PKG_DEPENDS_TARGET="toolchain libxml2"
PKG_LONGDESC="A XSLT C library."
PKG_BUILD_FLAGS="+pic"
PKG_TOOLCHAIN="autotools"

PKG_CONFIGURE_OPTS_HOST="  ac_cv_header_ansidecl_h=no \
                           ac_cv_header_xlocale_h=no \
                           --enable-static \
                           --disable-shared \
                           --without-python \
                           --with-libxml-prefix=${TOOLCHAIN} \
                           --without-crypto"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_header_ansidecl_h=no \
                           ac_cv_header_xlocale_h=no \
                           --enable-static \
                           --disable-shared \
                           --without-python \
                           --with-libxml-prefix=${SYSROOT_PREFIX}/usr \
                           --without-crypto"

post_makeinstall_target() {
  sed -e "s:\(['= ]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i ${SYSROOT_PREFIX}/usr/bin/xslt-config

  rm -rf ${INSTALL}/usr/bin/xsltproc
  rm -rf ${INSTALL}/usr/lib/xsltConf.sh
}
