# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vim"
PKG_VERSION="9.0.1417"
PKG_SHA256="02c67859046f7c0206afb909061763cf40747c6bf40c22bb6efaf9c06be41591"
PKG_LICENSE="VIM"
PKG_SITE="http://www.vim.org/"
PKG_URL="https://github.com/vim/vim/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses"
PKG_LONGDESC="Vim is a highly configurable text editor built to enable efficient text editing."
PKG_BUILD_FLAGS="-sysroot"

PKG_CONFIGURE_OPTS_TARGET="vim_cv_getcwd_broken=no \
                           vim_cv_memmove_handles_overlap=yes \
                           vim_cv_stat_ignores_slash=yes \
                           vim_cv_terminfo=yes \
                           vim_cv_tgetent=zero \
                           vim_cv_toupper_broken=no \
                           vim_cv_tty_group=world \
                           vim_cv_tty_mode=0620 \
                           ac_cv_sizeof_int=4 \
                           ac_cv_small_wchar_t=no \
                           --datarootdir=/storage/.kodi/addons/virtual.system-tools/data \
                           --disable-canberra \
                           --disable-nls \
                           --enable-selinux=no \
                           --enable-gui=no \
                           --with-compiledby=LibreELEC \
                           --with-features=huge \
                           --with-tlib=ncurses \
                           --without-x"

PKG_MAKEINSTALL_OPTS_TARGET=VIMRTDIR=

pre_configure_target() {
  cd ..
  rm -rf .${TARGET_NAME}
}

make_target() {
  :
}

pre_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
}

post_makeinstall_target() {
  (
  cd ${INSTALL}/storage/.kodi/addons/virtual.system-tools/data/vim
  rm -r doc tutor gvimrc_example.vim
  mv vimrc_example.vim vimrc
  )
}
