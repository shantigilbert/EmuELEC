# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-2022 5schatten (https://github.com/5schatten)
# Copyright (C) 2022-present 7Ji (https://github.com/7Ji)

PKG_NAME="lib32-SDL2"
PKG_VERSION="$(get_pkg_version SDL2)"
PKG_NEED_UNPACK="$(get_pkg_directory SDL2)"
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://www.libsdl.org/"
PKG_URL=""
PKG_DEPENDS_TARGET="lib32-toolchain lib32-alsa-lib lib32-systemd-libs lib32-dbus lib32-${OPENGLES} lib32-libpulse"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_BUILD_FLAGS="lib32"


SDL2_DIRECTORY="$(get_pkg_directory SDL2)"
PKG_PATCH_DIRS+=" $SDL2_DIRECTORY/patches" 
PKG_RKMISC=
if [ "${PROJECT}" = "Amlogic-ce" ]; then
  PKG_PATCH_DIRS+=" $SDL2_DIRECTORY/patches/Amlogic"
elif [[ "${DEVICE}" =~ ^(OdroidGoAdvance|GameForce|RK356x|OdroidM1)$ ]]; then
  PKG_RKMISC="yes"
  PKG_DEPENDS_TARGET+=" lib32-libdrm lib32-mali-bifrost lib32-librga"
  if [ "${DEVICE}" = "OdroidGoAdvance" ]; then
    PKG_PATCH_DIRS+=" $SDL2_DIRECTORY/patches/OdroidGoAdvance"
  fi
else
  echo "${PKG_NAME}: Unsupported devices ${DEVICE} when only AmlNG, AmlOld, OGA, GF, RK356X, M1 is supported" 1>&2
  false
fi

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
                       
if [ "$PKG_RKMISC" ]; then
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_KMSDRM=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DVIDEO_MALI=ON -DSDL_KMSDRM=OFF"
fi

unpack() {
  ${SCRIPTS}/get SDL2
  mkdir -p ${PKG_BUILD}
  tar --strip-components=1 -xf ${SOURCES}/SDL2/SDL2-${PKG_VERSION}.tar.gz -C ${PKG_BUILD}
}

post_makeinstall_target() {
  sed -e "s:\(['=LI]\)/usr:\\1${SYSROOT_PREFIX}/usr:g" -i $SYSROOT_PREFIX/usr/bin/sdl2-config
  safe_remove ${INSTALL}/usr/bin
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/share
  mv ${INSTALL}/usr/lib ${INSTALL}/usr/lib32
}
