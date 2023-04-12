# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet6-runtime"
PKG_VERSION="6.0.14"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="c25a09594965b241ee42ddb41d5fb68afab1b58e37a68317f2678a7cf7309a8b"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/10762208-8896-423a-b7f3-5084c7548ce7/620af5c42e5a4087478890294dbe39fb/aspnetcore-runtime-6.0.14-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="da7f9e231476cfb5f52f1f469a1ef22b5bb052a0ce53af97b21b70bca0abef0a"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/4fac9144-1998-4d99-8000-6f8c8a19e9a3/3d722a6e310cf82c898f91138971be5b/aspnetcore-runtime-6.0.14-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="721dc8e29892dcaaaab4bc7d2e8630a98d349f2d832855156f7b7898d1a55b07"
    PKG_URL="https://download.visualstudio.microsoft.com/download/pr/092f7e69-2e23-40b3-8f36-628d25ac7109/4995e4e141b26ea049163af84592222c/aspnetcore-runtime-6.0.14-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
