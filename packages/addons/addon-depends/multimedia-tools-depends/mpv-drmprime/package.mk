# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="mpv-drmprime"
PKG_VERSION="0.34.1"
PKG_SHA256="32ded8c13b6398310fa27767378193dc1db6d78b006b70dbcbd3123a1445e746"
PKG_LICENSE="GPL"
PKG_SITE="https://mpv.io/"
PKG_URL="https://github.com/mpv-player/mpv/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain waf:host alsa ffmpeg libass libdrm"
PKG_LONGDESC="A media player based on MPlayer and mplayer2. It supports a wide variety of video file formats, audio and video codecs, and subtitle types."
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-sysroot"

PKG_MANUAL_OPTS_TARGET="--prefix=/usr \
                        --disable-libarchive \
                        --disable-lua \
                        --disable-javascript \
                        --disable-uchardet \
                        --disable-rubberband \
                        --disable-lcms2 \
                        --disable-vapoursynth \
                        --disable-jack \
                        --disable-wayland \
                        --disable-x11 \
                        --disable-vulkan \
                        --disable-caca \
                        --enable-drm \
                        --enable-gbm \
                        --enable-egl-drm"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${VAAPI_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libva"
  PKG_MANUAL_OPTS_TARGET+=" --enable-vaapi --enable-vaapi-drm"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-vaapi"
fi

if [ "${PULSEAUDIO_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" pulseaudio"
  PKG_MANUAL_OPTS_TARGET+=" --enable-pulse"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-pulse"
fi

if [ "${KODI_BLURAY_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" libbluray"
  PKG_MANUAL_OPTS_TARGET+=" --enable-libbluray"
else
  PKG_MANUAL_OPTS_TARGET+=" --disable-libbluray"
fi

configure_target() {
  waf configure ${PKG_MANUAL_OPTS_TARGET}
}

make_target() {
  waf build
}

makeinstall_target() {
  waf install --destdir=${INSTALL}
  rm -r ${INSTALL}/usr/share
}
