# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.12"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="d91c9786560d092a549073cedbe8adfe00a39abc18ae7b0e5c78f37899e0421b"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/b675e6e9-652b-42a6-a9eb-2813b90b41e0/88ba0bd190041c1db8a681bef7376ab7/aspnetcore-runtime-6.0.13-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="b1bb76eb6f65ded5cb81bb2919c194bf2ce0e6c9d1b34535193bd232585d7a13"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/8685fc94-b18a-4012-bda7-9ecc28e9d4a8/569d9a735ae79b4ce67393dfd96c3d90/aspnetcore-runtime-6.0.13-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="65fae434b8aeb03a3853e7d71ffaf763de2a05738bc606f04be2992eba8c26f3"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/a2234b85-9050-4f90-9fc1-695a428167ee/8d5c3cf8f557e14c7c43965b7cef9c41/aspnetcore-runtime-6.0.13-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
