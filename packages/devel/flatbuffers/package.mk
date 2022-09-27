# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="flatbuffers"
PKG_VERSION="2.0.6"
PKG_SHA256="e2dc24985a85b278dd06313481a9ca051d048f9474e0f199e372fea3ea4248c9"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/google/flatbuffers"
PKG_URL="https://github.com/google/flatbuffers/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="An efficient cross platform serialization library for games and other memory constrained apps."

PKG_CMAKE_OPTS_HOST="-DFLATBUFFERS_CODE_COVERAGE=OFF \
                     -DFLATBUFFERS_BUILD_TESTS=OFF \
                     -DFLATBUFFERS_INSTALL=ON \
                     -DFLATBUFFERS_BUILD_FLATLIB=OFF \
                     -DFLATBUFFERS_BUILD_FLATC=ON \
                     -DFLATBUFFERS_BUILD_FLATHASH=OFF \
                     -DFLATBUFFERS_BUILD_GRPCTEST=OFF \
                     -DFLATBUFFERS_BUILD_SHAREDLIB=OFF"

PKG_CMAKE_OPTS_TARGET="-DFLATBUFFERS_CODE_COVERAGE=OFF \
                       -DFLATBUFFERS_BUILD_TESTS=OFF \
                       -DFLATBUFFERS_INSTALL=ON \
                       -DFLATBUFFERS_BUILD_FLATLIB=ON \
                       -DFLATBUFFERS_BUILD_FLATC=OFF \
                       -DFLATBUFFERS_BUILD_FLATHASH=OFF \
                       -DFLATBUFFERS_BUILD_GRPCTEST=OFF \
                       -DFLATBUFFERS_BUILD_SHAREDLIB=OFF"

pre_configure_host() {
  export CXXFLAGS="${CXXFLAGS} -std=c++11"
}

post_makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp -PR ${PKG_BUILD}/.${HOST_NAME}/flatc ${TOOLCHAIN}/bin
}
