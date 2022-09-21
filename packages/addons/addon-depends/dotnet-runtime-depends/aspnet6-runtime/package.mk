# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.7"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="b0f7908e4eb7819ff08fc3a4670c52a73035bbea11bebf7d2ef0c39e829cfdc8"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/b79c5fa9-a08d-4534-9424-4bacfc3cdc3d/449179d6fe8cda05f52b7be0f6828eb0/aspnetcore-runtime-6.0.7-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="66d49dfb0022645ff3f64cdcc733647d6d02578d1cee95a29d3845cd173deb88"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/228e3f86-84fa-4109-9655-2a381acbd6c1/eb174b5083bb639d8b219b7cb11fa50f/aspnetcore-runtime-6.0.7-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="61c2b79cc31e1d5df9a398766044177cecb7b9c2baad4ef9d011723ba21fd0ee"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/98271725-1784-407c-841a-64d87c674512/b433af33506c816e3b5838f5c65d990a/aspnetcore-runtime-6.0.7-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
