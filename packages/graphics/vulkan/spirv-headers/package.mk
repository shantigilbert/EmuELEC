# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="spirv-headers"
# The SPIRV-Headers have to be specific versions matching the glslang pkg version
# https://github.com/KhronosGroup/glslang/blob/11.10.0/known_good.json
# if you update glslang make sure spirv-tools & spirv-headers versions a known good
PKG_VERSION="5a121866927a16ab9d49bed4788b532c7fcea766"
PKG_SHA256="ec8ecb471a62672697846c436501638ab25447ae9d4a6761e0bfe8a9a839502a"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/SPIRV-headers"
PKG_URL="https://github.com/KhronosGroup/SPIRV-headers/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST=""
PKG_LONGDESC="SPIRV-Headers"
PKG_TOOLCHAIN="manual"
