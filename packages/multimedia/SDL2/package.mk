# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="SDL2"
PKG_VERSION="2.0.20"
PKG_SHA256="c56aba1d7b5b0e7e999e4a7698c70b63a3394ff9704b5f6e1c57e0c16f04dd06"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL2-$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus $OPENGLES pulseaudio"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_DEPENDS_HOST="toolchain:host distutilscross:host"

if [ "${DEVICE}" = "Amlogic-ng" ] || [ "${DEVICE}" = "Amlogic" ]; then
  PKG_PATCH_DIRS="Amlogic"
fi

if [ "$DEVICE" == "OdroidGoAdvance" ]; then
  PKG_PATCH_DIRS="OdroidGoAdvance"
fi

if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET libdrm mali-bifrost librga"
fi

pre_make_host() {
if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
	sed -i "s| -lrga||g" ${PKG_BUILD}/CMakeLists.txt
fi
}

pre_make_target() {
if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
# Since we removed "-lrga" from host we need to re-add it for target, hacky way of doing it but for now it works.
if ! `grep -rnw "${PKG_BUILD}/CMakeLists.txt" -e '-lrga'`; then
	sed -i "s|--no-undefined|--no-undefined -lrga|" ${PKG_BUILD}/CMakeLists.txt
fi
fi
}

PKG_CMAKE_OPTS_HOST="-DVIDEO_MALI=OFF -DKMSDRM=OFF"

pre_configure_target(){
  PKG_CMAKE_OPTS_TARGET="-DSDL_STATIC=OFF \
                         -DSDL_LIBC=ON \
                         -DSDL_GCC_ATOMICS=ON \
                         -DSDL_ALTIVEC=OFF \
                         -DSDL_OSS=OFF \
                         -DSDL_ALSA=ON \
                         -DSDL_ALSA_SHARED=ON \
                         -DSDL_JACK=OFF \
                         -DSDL_JACK_SHARED=OFF \
                         -DSDL_ESD=OFF \
                         -DSDL_ESD_SHARED=OFF \
                         -DSDL_ARTS=OFF \
                         -DSDL_ARTS_SHARED=OFF \
                         -DSDL_NAS=OFF \
                         -DSDL_NAS_SHARED=OFF \
                         -DSDL_LIBSAMPLERATE=OFF \
                         -DSDL_LIBSAMPLERATE_SHARED=OFF \
                         -DSDL_SNDIO=OFF \
                         -DSDL_DISKAUDIO=OFF \
                         -DSDL_DUMMYAUDIO=OFF \
                         -DSDL_DUMMYVIDEO=OFF \
                         -DSDL_WAYLAND=OFF \
                         -DSDL_WAYLAND_QT_TOUCH=ON \
                         -DSDL_WAYLAND_SHARED=OFF \
                         -DSDL_COCOA=OFF \
                         -DSDL_DIRECTFB=OFF \
                         -DSDL_VIVANTE=OFF \
                         -DSDL_DIRECTFB_SHARED=OFF \
                         -DSDL_FUSIONSOUND=OFF \
                         -DSDL_FUSIONSOUND_SHARED=OFF \
                         -DSDL_PTHREADS=ON \
                         -DSDL_PTHREADS_SEM=ON \
                         -DSDL_DIRECTX=OFF \
                         -DSDL_DLOPEN=ON \
                         -DSDL_CLOCK_GETTIME=OFF \
                         -DSDL_RPATH=OFF \
                         -DSDL_RENDER_D3D=OFF \
                         -DSDL_X11=OFF \
                         -DSDL_OPENGLES=ON \
                         -DSDL_VULKAN=OFF \
                         -DSDL_PULSEAUDIO=ON \
                         -DSDL_HIDAPI_JOYSTICK=OFF"
if [ "$DEVICE" == "OdroidGoAdvance" ] || [ "$DEVICE" == "GameForce" ]; then
PKG_CMAKE_OPTS_TARGET="$PKG_CMAKE_OPTS_TARGET -DSDL_KMSDRM=ON"
else
PKG_CMAKE_OPTS_TARGET="$PKG_CMAKE_OPTS_TARGET -DVIDEO_MALI=ON -DSDL_KMSDRM=OFF"
fi
}

post_makeinstall_target() {
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i $SYSROOT_PREFIX/usr/bin/sdl2-config
  rm -rf $INSTALL/usr/bin
}
