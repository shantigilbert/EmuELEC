# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="vim"
PKG_VERSION="8.2.4065"
PKG_SHA256="afc4a51eeeddf81c810dc29e364e7babe1cfebafcf2fd15547b35f56b7f0cb14"
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
                           --datarootdir=/storage/.config/emuelec/configs/vimdata\
                           --disable-canberra \
                           --disable-nls \
                           --enable-selinux=no \
                           --enable-gui=no \
                           --with-compiledby=EmuELEC \
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
  mkdir -p ${INSTALL}/usr/config/emuelec/configs/vimdata
}

post_makeinstall_target() {
  (
  mv ${INSTALL}/storage/.config/emuelec/configs/vimdata/vim/vimrc_example.vim ${INSTALL}/usr/config/emuelec/configs/vimdata/vimrc
  rm -r ${INSTALL}/storage/
  )
}
