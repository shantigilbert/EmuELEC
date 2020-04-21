# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Team CoreELEC (https://coreelec.org)

PKG_NAME="inject_bl301"
PKG_VERSION="fb0d9e501fd64f8ccc96f3838fd055d73192fb47"
PKG_SHA256="f4ab31ec3ac6d7ce3be7b6bc2ccea6a70ba969415ea7663cb83aba79c3741d16"
PKG_LICENSE="proprietary"
PKG_SITE="https://coreelec.org"
PKG_URL="https://sources.coreelec.org/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain bl301"
PKG_LONGDESC="Tool to inject bootloader blob BL301.bin on internal eMMC"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  cp -av ${PKG_DIR}/config/bl301.conf ${PKG_BUILD}/bl301.conf
  for f in $(find $(get_build_dir bl301) -mindepth 1 -name 'coreelec_config.c'); do
    cat ${f} | awk -F'[(),"]' '/.config_id\s*=\s*HASH/ {printf("%s %s\n", $2, $3)}' | \
      while read id name; do
        if ! grep -Fwq "${id}" ${PKG_BUILD}/bl301.conf; then
          echo -e '\n['${id}']' >> ${PKG_BUILD}/bl301.conf;
          cat ${f%.*}.h | awk -v id="HASHSTR_${id} " '$0 ~ id {printf("config_id=%s\n", $3)}' >> ${PKG_BUILD}/bl301.conf;
          echo -e "config_name=${name}" >> ${PKG_BUILD}/bl301.conf;
        fi
      done
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/sbin
  mkdir -p ${INSTALL}/usr/lib/coreelec
  mkdir -p ${INSTALL}/etc/inject_bl301
    install -m 0755 inject_bl301 ${INSTALL}/usr/sbin/inject_bl301
    install -m 0755 ${PKG_DIR}/scripts/check-bl301.sh ${INSTALL}/usr/lib/coreelec/check-bl301
    install -m 0755 ${PKG_DIR}/scripts/update-bl301.sh ${INSTALL}/usr/lib/coreelec/update-bl301
    install -m 0644 ${PKG_BUILD}/bl301.conf ${INSTALL}/etc/inject_bl301/bl301.conf
}

post_install() {
  enable_service update-bl301.service
}
