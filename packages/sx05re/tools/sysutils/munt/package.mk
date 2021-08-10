# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 0riginally created by Escalade (https://github.com/escalade)
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="munt"
PKG_VERSION="0e4d6ccfdfc0bfe3dd994196450bf893559d07b2"
PKG_SHA256="4b4f7ed240c2388744e96457aae146628dc1cce8bf93ba560745b1bc39b91838"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/munt/munt"
PKG_URL="https://github.com/munt/munt/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="A software synthesiser emulating pre-GM MIDI devices such as the Roland MT-32."

PKG_CMAKE_OPTS_TARGET="-Dmunt_WITH_MT32EMU_QT=0 \
                       -Dmunt_WITH_MT32EMU_SMF2WAV=0 \
                       -Dlibmt32emu_SHARED=1"
