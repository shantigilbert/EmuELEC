# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="emuelec-ports"
PKG_VERSION="1.0"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv3"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain jinja2:host pyyaml:host commander-genius devilutionX sdlpop VVVVVV opentyrian bermuda hodesdl hydracastlelabyrinth eduke rigelengine sonic2013 soniccd supertux supertuxkart chocolate-doom lzdoom supermariowar"
PKG_SECTION="emuelec"
PKG_SHORTDESC="EmuELEC Ports Meta Package"
PKG_TOOLCHAIN="manual"

make_target() {
mkdir -p $PKG_BUILD/scripts
python3 port_builder.py ports.yaml scripts
}

makeinstall_target() {
mkdir -p $INSTALL/usr/bin/ports
cp -rf $PKG_BUILD/scripts/* $INSTALL/usr/bin/ports

# Remove duplicate newlines just to be tidy
for file in "$INSTALL/usr/bin/ports/*.sh"; do
sed  -i '$!N; /^\(.*\)\n\1$/!P; D' $file
done

# Remove empty lines from gamelist.xml
sed -i '/^$/d' $INSTALL/usr/bin/ports/gamelist.xml

}
