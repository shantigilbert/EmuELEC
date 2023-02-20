# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="media_modules-aml"
PKG_VERSION="7b252f21e45aa9fd34e5df25bfc2a7079de0739a"
PKG_SHA256="21901d679b72046e1952f8529dda981b8b975f42fac0cd8463f393f2a4bc34cc"
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL="https://github.com/CoreELEC/media_modules-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="${PKG_NAME}: Linux driver"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}/drivers \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG12=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG2_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG4=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MPEG4_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VC1=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H264_MVC=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_H265=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_VP9=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MJPEG=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_MJPEG_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_REAL=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS_MULTI=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AVS2=m \
    CONFIG_AMLOGIC_MEDIA_VDEC_AV1=m \
    CONFIG_AMLOGIC_MEDIA_VENC_H264=m \
    CONFIG_AMLOGIC_MEDIA_VENC_JPEG=m \
    CONFIG_AMLOGIC_MEDIA_VENC_H265=m
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
    find ${PKG_BUILD}/ -name \*.ko -not -path '*/\.*' -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/video
    cp -PR ${PKG_BUILD}/firmware/*.bin ${INSTALL}/$(get_full_firmware_dir)/video
}
