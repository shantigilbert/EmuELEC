# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="libsndfile"
PKG_VERSION="1.0.31"
PKG_SHA256="8cdee0acb06bb0a3c1a6ca524575643df8b1f3a55a0893b4dd9f829d08263785"
PKG_LICENSE="LGPL-2.1-or-later"
PKG_SITE="https://libsndfile.github.io/libsndfile/"
PKG_URL="https://github.com/libsndfile/libsndfile/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib flac libogg libvorbis opus"
PKG_LONGDESC="A C library for reading and writing sound files containing sampled audio data."
PKG_BUILD_FLAGS="+pic"

# As per notes in configure.ac:
#  One or more of the external libraries (ie libflac, libogg, libvorbis and libopus)
#  is either missing ... Unfortunately, for ease of maintenance, the external libs
#  are an all or nothing affair.
# So all of flac, libogg, libvorbis, opus are required.

PKG_CMAKE_OPTS_TARGET="-DBUILD_PROGRAMS=OFF \
                       -DBUILD_EXAMPLES=OFF \
                       -DBUILD_REGTEST=OFF \
                       -DBUILD_TESTING=OFF \
                       -DBUILD_SHARED_LIBS=ON \
                       -DENABLE_EXTERNAL_LIBS=ON \
                       -DINSTALL_MANPAGES=OFF \
                       -DINSTALL_PKGCONFIG_MODULE=ON"
