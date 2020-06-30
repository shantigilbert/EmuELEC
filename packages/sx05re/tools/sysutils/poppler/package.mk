# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="poppler"
PKG_VERSION="0.89.0"
PKG_SHA256="fba230364537782cc5d43b08d693ef69c36586286349683c7b127156a8ef9b5c"
PKG_ARCH="any"
PKG_SITE="https://poppler.freedesktop.org"
PKG_URL="https://poppler.freedesktop.org/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Poppler is a PDF rendering library based on the xpdf-3.0 code base."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DENABLE_LIBOPENJPEG=none \
                       -DENABLE_GLIB=ON \
                       -DENABLE_QT5=off \
                       -DENABLE_CPP=off"

post_makeinstall_target() {
    mkdir -p $INSTALL/usr/config/emuelec/scripts/batocera
    ln -sf /usr/bin/pdftoppm $INSTALL/usr/config/emuelec/scripts/batocera/pdftoppm
    ln -sf /usr/bin/pdfinfo $INSTALL/usr/config/emuelec/scripts/batocera/pdfinfo
}
