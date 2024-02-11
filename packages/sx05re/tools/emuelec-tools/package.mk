# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-tools"
PKG_VERSION=""
PKG_LICENSE="various"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SHORTDESC="EmuELEC tools metapackage"
PKG_SECTION="virtual"

PKG_DEPENDS_TARGET+=" ffmpeg \
                      libjpeg-turbo \
                      common-shaders \
                      Skyscraper \
                      MC \
                      libretro-bash-launcher \
                      SDL_GameControllerDB \
                      util-linux \
                      xmlstarlet \
                      sixaxis \
                      jslisten \
                      evtest \
                      mpv \
                      poppler \
                      bluetool \
                      patchelf \
                      fbgrab \
                      sdljoytest \
                      bash \
                      pyudev \
                      dialog \
                      six \
                      git \
                      dbus-python \
                      pygobject \
                      coreutils \
                      wget \
                      TvTextViewer \
                      imagemagick \
                      htop \
                      libevdev \
                      gptokeyb \
                      exfat \
                      351Files \
                      box64 \
                      iotop \
                      usb-modeswitch \
                      vim \
                      rclone \
                      grep \
                      eemount \
                      dasbus \
                      diffutils \
                      fbfix"

if [ "${PROJECT}" == "Amlogic-ce" ]; then
                      PKG_DEPENDS_TARGET+=" CoreELEC-Debug-Scripts"
fi
