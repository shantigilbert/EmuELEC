# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present kkoshelev (https://github.com/kkoshelev)
# Copyright (C) 2022-present fewtarius (https://github.com/fewtarius)
# Copyright (C) 2023-present NeoTheFox (https://github.com/NeoTheFox)
# Emuelec adaptation 2024-present DiegroSan

PKG_NAME="zerotier-one"
PKG_VERSION="1.12.2"
PKG_SITE="https://www.zerotier.com"
PKG_URL="https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain nlohmann-json jq"
PKG_SHORTDESC="A Smart Ethernet Switch for Earth"
PKG_TOOLCHAIN="manual"


pre_unpack() {
    mkdir -p ${PKG_BUILD}
    tar --strip-components=1 -xf $SOURCES/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${PKG_BUILD} ZeroTierOne-${PKG_VERSION}
}


make_target() {
    cd ${PKG_BUILD}
    make -f make-linux.mk ZT_SSO_SUPPORTED=0 one
}

makeinstall_target() {
    make DESTDIR=${INSTALL} install
    rm -rf ${INSTALL}/usr/share/man/
    mkdir -p ${INSTALL}/usr/sbin/
    cp -f ${PKG_DIR}/scripts/zerotier-join.sh ${INSTALL}/usr/sbin/
    cp -f ${PKG_DIR}/scripts/zerotier-off.sh ${INSTALL}/usr/sbin/
    cp -f ${PKG_DIR}/scripts/zerotier-on.sh ${INSTALL}/usr/sbin/

	mkdir -p ${INSTALL}/usr/bin
	cp -rf $PKG_DIR/bin ${INSTALL}/usr

    chmod +x ${INSTALL}/usr/bin/scripts/setup/zerotier-off.sh
    chmod +x ${INSTALL}/usr/bin/scripts/setup/zerotier-on.sh
    
    chmod +x ${INSTALL}/usr/sbin/zerotier-join.sh
    chmod +x ${INSTALL}/usr/sbin/zerotier-off.sh
    chmod +x ${INSTALL}/usr/sbin/zerotier-off.sh
    
    
    mkdir -p ${INSTALL}/usr/lib/systemd/system
    cp -f ${PKG_DIR}/system.d/zerotier-one.service ${INSTALL}/usr/lib/systemd/system/
    chmod 644 ${INSTALL}/usr/lib/systemd/system/zerotier-one.service
}

