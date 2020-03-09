# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="hypseus"
PKG_VERSION="41fc33edaa8273cbf1ad807b57d8c2a7ae143351"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPL3"
PKG_SITE="https://github.com/btolab/hypseus"
PKG_URL="$PKG_SITE.git"
PKG_DEPENDS_TARGET="toolchain SDL2-git libvorbis"
PKG_LONGDESC="Hypseus is a fork of Daphne. A program that lets one play the original versions of many laserdisc arcade games on one's PC."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" ./src"

pre_configure_target() {
mkdir -p $INSTALL/usr/config/emuelec/configs/hypseus
ln -fs /storage/roms/daphne/roms $INSTALL/usr/config/emuelec/configs/hypseus/roms
ln -fs /storage/roms/daphne/sound $INSTALL/usr/config/emuelec/configs/hypseus/sound
ln -fs /usr/share/daphne/fonts $INSTALL/usr/config/emuelec/configs/hypseus/fonts
ln -fs /usr/share/daphne/pics $INSTALL/usr/config/emuelec/configs/hypseus/pics
cp $PKG_BUILD/doc/hypinput.ini $INSTALL/usr/config/emuelec/configs/hypseus/
}

post_makeinstall_target() {
ln -fs /storage/.config/emuelec/configs/hypseus/hypinput.ini $INSTALL/usr/share/daphne/hypinput.ini
}
