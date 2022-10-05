# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libinput"
PKG_VERSION="1.21.0"
PKG_SHA256="3173d83e0f5a686606d2780129c802b865b6a0750c86db88d56097afc016a2dd"
PKG_LICENSE="GPL"
PKG_SITE="https://www.freedesktop.org/wiki/Software/libinput/"
PKG_URL="https://gitlab.freedesktop.org/libinput/libinput/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain systemd libevdev mtdev"
PKG_LONGDESC="libinput is a library to handle input devices in Wayland compositors and to provide a generic X.Org input driver."

PKG_MESON_OPTS_TARGET="-Dlibwacom=false \
                       -Ddebug-gui=false \
                       -Dtests=false \
                       -Ddocumentation=false"
