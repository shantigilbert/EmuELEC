# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.8"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="8a8d7ebfd2a6a806e57b6bfa1fd71b99a789c947c66c30c081824b1a00123c78"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/83695c9b-c954-459e-b9bf-2f1ac269e34e/1316ff4a6fe4c6916e7ecb3623d67cee/aspnetcore-runtime-6.0.8-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="8e53a2bf2d145c8983b85db1e1010bdf257f0d30beedaaa34a602e69ca4d74bf"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/cf567026-a29a-41aa-bc3a-e4e1ad0df480/0925d411e8e09e31ba7a39a3eb0e29af/aspnetcore-runtime-6.0.8-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="2bd3c32aacacbb6963df523e1022bc1989f7f1efc0de87d458cd3721dfafc42b"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/5cc06c3a-4d8a-4fb2-8f7a-ecd23cd8c4e0/dd386c0e3a41ea54f459907c834acedf/aspnetcore-runtime-6.0.8-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
