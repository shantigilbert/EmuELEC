# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="light"
PKG_VERSION="1.2.2"
PKG_SHA256="62e889ee9be80fe808a972ef4981acc39e83a20f9a84a66a82cd1f623c868d9c"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/haikarainen/light"
PKG_URL="$PKG_SITE/archive/v$PKG_VERSION.tar.gz"
#PKG_DEPENDS_TARGET="Light - A program to control backlights (and other hardware lights) in GNU/Linux"
PKG_LONGDESC="Light - A program to control backlights (and other hardware lights) in GNU/Linux"
PKG_TOOLCHAIN="configure"

pre_configure_target() {
	./autogen.sh
}
