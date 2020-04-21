# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Peter Vicman (peter.vicman@gmail.com)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="apache-ant"
PKG_VERSION="1.10.7"
PKG_SHA256="c8d68b396d9e44b49668bafe0c82f8c89497915254b5395d73d6f6e41d7a0e25"
PKG_LICENSE="Apache License 2.0"
PKG_SITE="https://ant.apache.org/"
PKG_URL="https://archive.apache.org/dist/ant/source/${PKG_NAME}-${PKG_VERSION}-src.tar.xz"
PKG_DEPENDS_HOST="jdk-x86_64-zulu:host"
PKG_LONGDESC="Apache Ant is a Java library and command-line tool that help building software."
PKG_TOOLCHAIN="manual"

make_host() {
  (
  export JAVA_HOME=$(get_build_dir jdk-x86_64-zulu)

  ./bootstrap.sh
  ./bootstrap/bin/ant -f fetch.xml -Ddest=optional
  ./build.sh -Ddist.dir=${PKG_BUILD}/binary dist
  )
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp binary/bin/ant ${TOOLCHAIN}/bin
    cp -r binary/lib ${TOOLCHAIN}
}
