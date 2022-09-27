# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="glslang"
# The SPIRV-Tools & SPIRV-Headers have to be specific versions matching the pkg version
# https://raw.githubusercontent.com/KhronosGroup/glslang/${PKG_VERSION}/known_good.json
# if you update glslang make sure spirv-tools & spirv-headers versions a known good
PKG_VERSION="11.10.0"
PKG_SHA256="8ffc19c435232d09299dd2c91e247292b3508c1b826a3497c60682e4bbf2d602"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/glslang"
PKG_URL="https://github.com/KhronosGroup/glslang/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host Python3:host spirv-tools:host spirv-headers:host"
PKG_LONGDESC="Khronos-reference front end for GLSL/ESSL, partial front end for HLSL, and a SPIR-V generator."

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST="-DBUILD_SHARED_LIBS=OFF \
                       -DBUILD_EXTERNAL=ON \
                       -DENABLE_SPVREMAPPER=OFF \
                       -DENABLE_GLSLANG_JS=OFF \
                       -DENABLE_RTTI=OFF \
                       -DENABLE_EXCEPTIONS=OFF \
                       -DENABLE_OPT=ON \
                       -DENABLE_PCH=ON \
                       -DENABLE_CTEST=OFF \
                       -DENABLE_RTTI=OFF \
                       -Wno-dev"

  mkdir -p ${PKG_BUILD}/External/spirv-tools/external/spirv-headers
    cp -R $(get_build_dir spirv-tools)/* ${PKG_BUILD}/External/spirv-tools
    cp -R $(get_build_dir spirv-headers)/* ${PKG_BUILD}/External/spirv-tools/external/spirv-headers
}
