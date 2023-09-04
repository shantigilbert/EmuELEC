# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Peter Vicman (peter.vicman@gmail.com)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="apache-ant"
PKG_VERSION="1.10.13"
PKG_SHA512="26e56bf670c22c8093fe51ec952fa51e813b1ab4200cb09fcd68fa291c5f6f626d7c6a42b4d3358b38111466e249d4bc6089b8c4093383759d6f8a08d39bc32d"
PKG_LICENSE="Apache License 2.0"
PKG_SITE="https://ant.apache.org/"
PKG_URL="https://downloads.apache.org/ant/binaries/${PKG_NAME}-${PKG_VERSION}-bin.tar.xz"
PKG_DEPENDS_UNPACK="jdk-x86_64-zulu"
PKG_LONGDESC="Apache Ant is a Java library and command-line tool that help building software."
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/apache-ant/bin
  mkdir -p ${TOOLCHAIN}/apache-ant/lib
    cp bin/ant ${TOOLCHAIN}/apache-ant/bin
    cp lib/*.jar ${TOOLCHAIN}/apache-ant/lib
  mkdir -p ${TOOLCHAIN}/bin
    ln -sf ${TOOLCHAIN}/apache-ant/bin/ant ${TOOLCHAIN}/bin/ant
}
