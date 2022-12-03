# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="openssh"
PKG_VERSION="9.1p1"
PKG_SHA256="19f85009c7e3e23787f0236fbb1578392ab4d4bf9f8ec5fe6bc1cd7e8bfdd288"
PKG_LICENSE="OSS"
PKG_SITE="https://www.openssh.com/"
PKG_URL="https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl zlib"
PKG_LONGDESC="An open re-implementation of the SSH package."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+lto"

PKG_CONFIGURE_OPTS_TARGET="ac_cv_header_rpc_types_h=no \
                           --sysconfdir=/etc/ssh \
                           --libexecdir=/usr/lib/openssh \
                           --disable-strip \
                           --disable-lastlog \
                           --with-sandbox=no \
                           --disable-utmp \
                           --disable-utmpx \
                           --disable-wtmp \
                           --disable-wtmpx \
                           --without-rpath \
                           --with-ssl-engine \
                           --with-privsep-user=nobody \
                           --disable-pututline \
                           --disable-pututxline \
                           --disable-etc-default-login \
                           --with-keydir=/storage/.cache/ssh \
                           --without-pam"

pre_configure_target() {
  export LD="${CC}"
  export LDFLAGS="${TARGET_CFLAGS} ${TARGET_LDFLAGS}"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/lib/openssh/ssh-keysign
  rm -rf ${INSTALL}/usr/lib/openssh/ssh-pkcs11-helper
  if [ ! ${SFTP_SERVER} = "yes" ]; then
    rm -rf ${INSTALL}/usr/lib/openssh/sftp-server
  fi
  rm -rf ${INSTALL}/usr/bin/ssh-add
  rm -rf ${INSTALL}/usr/bin/ssh-agent
  rm -rf ${INSTALL}/usr/bin/ssh-keyscan

  sed -e "s|^#PermitRootLogin.*|PermitRootLogin yes|g" \
      -e "s|^#StrictModes.*|StrictModes no|g" \
      -i ${INSTALL}/etc/ssh/sshd_config

  debug_strip ${INSTALL}/usr
}

post_install() {
  enable_service sshd.service
}
