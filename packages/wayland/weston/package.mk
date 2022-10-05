# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="weston"
PKG_VERSION="10.0.2"
PKG_SHA256="89646ca0d9f8d413c2767e5c3828eaa3fa149c2a105b3729a6894fa7cf1549e7"
PKG_LICENSE="MIT"
PKG_SITE="https://wayland.freedesktop.org/"
PKG_URL="https://gitlab.freedesktop.org/wayland/weston/-/releases/${PKG_VERSION}/downloads/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libxkbcommon libinput cairo pango libjpeg-turbo dbus seatd"
PKG_LONGDESC="Reference implementation of a Wayland compositor"

PKG_MESON_OPTS_TARGET="-Dbackend-drm=true \
                       -Dbackend-drm-screencast-vaapi=false \
                       -Dbackend-headless=false \
                       -Dbackend-rdp=false \
                       -Dscreenshare=false \
                       -Dbackend-wayland=false \
                       -Dbackend-x11=false \
                       -Ddeprecated-backend-fbdev=false \
                       -Dbackend-default=drm \
                       -Drenderer-gl=true \
                       -Ddeprecated-weston-launch=false \
                       -Dxwayland=false \
                       -Dsystemd=true \
                       -Dremoting=false \
                       -Dpipewire=false \
                       -Dshell-desktop=true \
                       -Dshell-fullscreen=false \
                       -Dshell-ivi=false \
                       -Dshell-kiosk=false \
                       -Ddesktop-shell-client-default="weston-desktop-shell" \
                       -Ddeprecated-wl-shell=false \
                       -Dcolor-management-lcms=false \
                       -Dcolor-management-colord=false \
                       -Dlauncher-logind=false \
                       -Dlauncher-libseat=true \
                       -Dimage-jpeg=true \
                       -Dimage-webp=false \
                       -Dtools=['terminal']
                       -Ddemo-clients=false \
                       -Dsimple-clients=[] \
                       -Dresize-pool=false \
                       -Dwcap-decode=false \
                       -Dtest-junit-xml=false \
                       -Dtest-skip-is-failure=false \
                       -Dtest-gl-renderer=false \
                       -Ddoc=false"

pre_configure_target() {
  # weston does not build with NDEBUG (requires assert for tests)
  export TARGET_CFLAGS=$(echo ${TARGET_CFLAGS} | sed -e "s|-DNDEBUG||g")
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/weston
    cp ${PKG_DIR}/scripts/weston-config ${INSTALL}/usr/lib/weston

  mkdir -p ${INSTALL}/usr/share/weston
    cp ${PKG_DIR}/config/weston.ini ${INSTALL}/usr/share/weston
    find_file_path "splash/splash-2160.png" && cp ${FOUND_PATH} ${INSTALL}/usr/share/weston/libreelec-wallpaper-2160.png

  safe_remove ${INSTALL}/usr/share/wayland-sessions
}

post_install() {
  enable_service weston.service
}
