# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="grep"
PKG_VERSION="3.7"
PKG_SHA256="c22b0cf2d4f6bbe599c902387e8058990e1eee99aef333a203829e5fd3dbb342"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://ftp.gnu.org/gnu/${PKG_NAME}"
PKG_URL="${PKG_SITE}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="Grep"
PKG_TOOLCHAIN="auto"
PKG_NEED_UNPACK="$(get_pkg_directory busybox)"


