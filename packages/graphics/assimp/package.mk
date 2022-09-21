# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="assimp"
PKG_VERSION="5.2.4"
PKG_SHA256="6a4ff75dc727821f75ef529cea1c4fc0a7b5fc2e0a0b2ff2f6b7993fe6cb54ba"
PKG_LICENSE="BSD"
PKG_SITE="https://github.com/assimp/assimp"
PKG_URL="https://github.com/assimp/assimp/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib"
PKG_LONGDESC="A library to import and export various 3d-model-formats including scene-post-processing to generate missing render data."

PKG_CMAKE_OPTS_TARGET="-DASSIMP_BUILD_ASSIMP_TOOLS=OFF \
                       -DASSIMP_BUILD_TESTS=OFF \
                       -DASSIMP_WARNINGS_AS_ERRORS=OFF"
