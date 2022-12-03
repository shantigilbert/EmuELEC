# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.10"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="6ef235a35a3ea8773b0b0eba011d182af08d972deb331c2259db4277fd4f0a80"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/c37e7250-886d-47e1-840e-fc0ae2aad195/81f019f66f158b7ccb3511d2fa5dec53/aspnetcore-runtime-6.0.10-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="91c7008433d6859e9402427b2465b412c10525f86268e938ccb39cfadcacb004"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/eb049d47-1cd1-4a76-8b4c-3efee9890f2a/53441bce40b9ac8d073fb4742d823c3b/aspnetcore-runtime-6.0.10-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="17685d3e8fa7aa9c1a658f7ca5e176bec7bb4c189b0352ac5abfed98135b93d9"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/7d44ddeb-ad35-41a8-a581-03b151afbd80/6888586c28836b1e1f71df879184550b/aspnetcore-runtime-6.0.10-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
