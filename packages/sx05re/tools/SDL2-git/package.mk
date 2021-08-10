# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2-git"
PKG_VERSION="2.0.9" # 2.0.9 Do not update!
PKG_SHA256="255186dc676ecd0c1dbf10ec8a2cc5d6869b5079d8a38194c2aecdff54b324b1"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus $OPENGLES pulseaudio"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."

if [ ${PROJECT} = "Amlogic-ng" ] || [ ${PROJECT} = "Amlogic" ]; then
  PKG_PATCH_DIRS="Amlogic"
fi

if [ "$DEVICE" == "OdroidGoAdvance" ]; then
  PKG_PATCH_DIRS="OdroidGoAdvance"
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libdrm mali-bifrost librga"
fi

pre_configure_target(){
  PKG_CMAKE_OPTS_TARGET="-DSDL_STATIC=OFF \
                         -DLIBC=ON \
                         -DGCC_ATOMICS=ON \
                         -DALTIVEC=OFF \
                         -DOSS=OFF \
                         -DALSA=ON \
                         -DALSA_SHARED=ON \
                         -DJACK=OFF \
                         -DJACK_SHARED=OFF \
                         -DESD=OFF \
                         -DESD_SHARED=OFF \
                         -DARTS=OFF \
                         -DARTS_SHARED=OFF \
                         -DNAS=OFF \
                         -DNAS_SHARED=OFF \
                         -DLIBSAMPLERATE=OFF \
                         -DLIBSAMPLERATE_SHARED=OFF \
                         -DSNDIO=OFF \
                         -DDISKAUDIO=OFF \
                         -DDUMMYAUDIO=OFF \
                         -DVIDEO_WAYLAND=OFF \
                         -DVIDEO_WAYLAND_QT_TOUCH=ON \
                         -DWAYLAND_SHARED=OFF \
                         -DVIDEO_MIR=OFF \
                         -DMIR_SHARED=OFF \
                         -DVIDEO_COCOA=OFF \
                         -DVIDEO_DIRECTFB=OFF \
                         -DVIDEO_VIVANTE=OFF \
                         -DDIRECTFB_SHARED=OFF \
                         -DFUSIONSOUND=OFF \
                         -DFUSIONSOUND_SHARED=OFF \
                         -DVIDEO_DUMMY=OFF \
                         -DINPUT_TSLIB=OFF \
                         -DPTHREADS=ON \
                         -DPTHREADS_SEM=ON \
                         -DDIRECTX=OFF \
                         -DSDL_DLOPEN=ON \
                         -DCLOCK_GETTIME=OFF \
                         -DRPATH=OFF \
                         -DRENDER_D3D=OFF \
                         -DVIDEO_X11=OFF \
                         -DVIDEO_OPENGLES=ON \
                         -DVIDEO_VULKAN=OFF \
                         -DPULSEAUDIO=ON"
if [ "$DEVICE" == "OdroidGoAdvance" ]; then
PKG_CMAKE_OPTS_TARGET="$PKG_CMAKE_OPTS_TARGET -DVIDEO_KMSDRM=ON"
else
PKG_CMAKE_OPTS_TARGET="$PKG_CMAKE_OPTS_TARGET -DVIDEO_MALI=ON -DVIDEO_KMSDRM=OFF"
fi
}

post_makeinstall_target() {
  sed -e "s:\(['=\" ]\)/usr:\\1$SYSROOT_PREFIX/usr:g" -i $SYSROOT_PREFIX/usr/bin/sdl2-config
  rm -rf $INSTALL/usr/bin
}
