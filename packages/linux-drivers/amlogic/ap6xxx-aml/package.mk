# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2017-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="ap6xxx-aml"
PKG_VERSION="f7a4641c4a83c9cea8e8b36b1303b843b9ecbf2a"
PKG_SHA256="00a03ceef99f9c2b060c10d9261c57490ff52ac03167991f48b464726771abf8"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/khadas/android_hardware_wifi_broadcom_drivers_ap6xxx"
PKG_URL="https://github.com/khadas/android_hardware_wifi_broadcom_drivers_ap6xxx/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="$LINUX_DEPENDS"
PKG_LONGDESC="ap6xxx: Linux drivers for AP6xxx WLAN chips used in some devices based on Amlogic SoCs"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make -C $(kernel_path) M=$PKG_BUILD/bcmdhd.1.363.59.144.x.cn \
    ARCH=$TARGET_KERNEL_ARCH \
    CROSS_COMPILE=$TARGET_KERNEL_PREFIX \
    CONFIG_BCMDHD_DISABLE_WOWLAN=y
}

makeinstall_target() {
  mkdir -p $INSTALL/$(get_full_module_dir)/$PKG_NAME
    find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' -exec cp {} $INSTALL/$(get_full_module_dir)/$PKG_NAME \;
}
