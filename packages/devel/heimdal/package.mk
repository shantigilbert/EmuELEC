# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2017 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="heimdal"
PKG_VERSION="7.7.0"
PKG_SHA256="f7d414d0914abb0e151a276b4de22cf4977fd6c28bd9ecdd990407b1138a945c"
PKG_LICENSE="BSD-3c"
PKG_SITE="http://www.h5l.org/"
PKG_URL="https://github.com/heimdal/heimdal/archive/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host Python3:host ncurses:host"
PKG_LONGDESC="Kerberos 5, PKIX, CMS, GSS-API, SPNEGO, NTLM, Digest-MD5 and, SASL implementation."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="-parallel"

PKG_CONFIGURE_OPTS_HOST="ac_cv_prog_COMPILE_ET=no \
                         --enable-static --disable-shared \
                         --without-openldap \
                         --without-capng \
                         --without-sqlite3 \
                         --without-libintl \
                         --without-openssl \
                         --without-berkeley-db \
                         --without-readline \
                         --without-libedit \
                         --without-hesiod \
                         --without-x \
                         --disable-otp \
                         --disable-heimdal-documentation"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -PR lib/asn1/asn1_compile ${TOOLCHAIN}/bin/heimdal_asn1_compile
    cp -PR lib/com_err/compile_et ${TOOLCHAIN}/bin/heimdal_compile_et
}
