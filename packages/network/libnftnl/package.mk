# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libnftnl"
PKG_VERSION="1.2.3"
PKG_SHA256="e916ea9b79f9518560b9a187251a7c042442a9ecbce7f36be7908888605d0255"
PKG_LICENSE="GPL"
PKG_SITE="https://netfilter.org/projects/libnftnl"
PKG_URL="https://netfilter.org/projects/libnftnl/files/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain libmnl"
PKG_LONGDESC="A userspace library providing a low-level netlink programming interface (API) to the in-kernel nf_tables subsystem."

PKG_CONFIGURE_OPTS_TARGET="--disable-shared --enable-static"
