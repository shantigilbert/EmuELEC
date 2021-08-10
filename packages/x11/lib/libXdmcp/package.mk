# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)

PKG_NAME="libXdmcp"
PKG_VERSION="1.1.3"
#PKG_SHA256="5d2a8f77c0feca4a4d8a5494694d2e137cb2e180b08fa15104c5a99d503cb9ef"
PKG_LICENSE="OSS"
PKG_SITE="http://xorg.freedesktop.org/releases/individual/lib"
PKG_URL="$PKG_SITE/libXdmcp-$PKG_VERSION.tar.bz2"
PKG_DEPENDS_TARGET="toolchain util-macros Python2:host xcb-proto libpthread-stubs libXau"
PKG_LONGDESC="X C-language Bindings library."
PKG_TOOLCHAIN="configure"
