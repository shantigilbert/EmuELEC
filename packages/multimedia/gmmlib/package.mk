# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="gmmlib"
PKG_VERSION="22.2.0"
PKG_SHA256="0b2253894c6fc8455b6d7c5e87e6504a76d6f60ea192e1445c2f93164bf529c0"
PKG_ARCH="x86_64"
PKG_LICENSE="MIT"
PKG_SITE="https://01.org/linuxmedia"
PKG_URL="https://github.com/intel/gmmlib/archive/intel-gmmlib-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="gmmlib: The Intel(R) Graphics Memory Management Library provides device specific and buffer management for the Intel(R) Graphics Compute Runtime for OpenCL(TM) and the Intel(R) Media Driver for VAAPI."

PKG_CMAKE_OPTS_TARGET="-DBUILD_TYPE=release \
                       -DRUN_TEST_SUITE=OFF"
