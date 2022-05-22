# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2017-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="u-boot"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_DEPENDS_TARGET="toolchain swig:host rkbin"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_VERSION="0677e140ba015b95ccd6d762ce51a4c6860a49ca"
PKG_SHA256="210b3c0f0e27a72be1aeff860a712bd2fc694c015f835ffd75dea6531502521a"
PKG_URL="https://github.com/hardkernel/u-boot/archive/$PKG_VERSION.tar.gz"
PKG_TOOLCHAIN="manual"

PKG_DEPENDS_TARGET+=" rkbin"
PKG_NEED_UNPACK+=" $(get_pkg_directory rkbin)"

PKG_IS_KERNEL_PKG="yes"
PKG_STAMP="$UBOOT_SYSTEM"

[ -n "$ATF_PLATFORM" ] && PKG_DEPENDS_TARGET+=" atf"

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"
[ -n "$DEVICE" ] && PKG_NEED_UNPACK+=" $PROJECT_DIR/$PROJECT/devices/$DEVICE/bootloader"

post_patch() {
  if [ -n "$UBOOT_SYSTEM" ] && find_file_path bootloader/config; then
    PKG_CONFIG_FILE="$PKG_BUILD/configs/$($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config)"
    if [ -f "$PKG_CONFIG_FILE" ]; then
      cat $FOUND_PATH >> "$PKG_CONFIG_FILE"
    fi
  fi
}

make_target() {
export KCFLAGS="-Wno-error=address-of-packed-member"
  if [ -z "$UBOOT_SYSTEM" ]; then
    echo "UBOOT_SYSTEM must be set to build an image"
    echo "see './scripts/uboot_helper' for more information"
  else
 	sed -i "s|CROSS_COMPILE_ARM64=.*|CROSS_COMPILE_ARM64=${TOOLCHAIN}/bin/${TARGET_NAME}-|" make.sh
 	sed -i "s|aarch64-linux-gnu|${TARGET_NAME}|g" make.sh
	sed -i "s|FlashBoot=../spl/u-boot-spl.bin|FlashBoot=${PKG_BUILD}/spl/u-boot-spl.bin|g" $(get_build_dir rkbin)/RKBOOT/RK3568-ODROIDM1.ini 
	sed -i "s|python2|python3|g" arch/arm/mach-rockchip/decode_bl31.py
	sed -i "s|python2|python3|g" make.sh
	sed -i "s|RKBIN_TOOLS=.*|RKBIN_TOOLS=$(get_build_dir rkbin)/tools|" make.sh
	sed -i "s|RK_SIGN_TOOL=\"rkbin/tools|RK_SIGN_TOOL=\"$(get_build_dir rkbin)/tools|" scripts/fit.sh

	cd ${PKG_BUILD}

		sed -i "s|PATH=$(get_build_dir rkbin)/bin/rk35/|PATH\=bin/rk35/|g" $(get_build_dir rkbin)/RKTRUST/RK3568TRUST.ini
		./make.sh $($ROOT/$SCRIPTS/uboot_helper $PROJECT $DEVICE $UBOOT_SYSTEM config | sed "s|_defconfig||")

		sed -i "s|SPL_BIN=\${RKBIN}.*|SPL_BIN=${PKG_BUILD}/spl/u-boot-spl.bin|g" make.sh
		./make.sh --idblock

		sed -i "s|PATH=bin/rk35/|PATH\=$(get_build_dir rkbin)/bin/rk35/|g" $(get_build_dir rkbin)/RKTRUST/RK3568TRUST.ini
		$(get_build_dir rkbin)/tools/trust_merger --verbose $(get_build_dir rkbin)/RKTRUST/RK3568TRUST.ini
	
		./make.sh loader $(get_build_dir rkbin)/RKBOOT/RK3568-ODROIDM1.ini 
		
	fi
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

    # Only install u-boot.img et al when building a board specific image
    if [ -n "$UBOOT_SYSTEM" ]; then
      find_file_path bootloader/install && . ${FOUND_PATH}
    fi

    # Always install the update script
    find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader

    # Always install the canupdate script
    if find_file_path bootloader/canupdate.sh; then
      cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
      sed -e "s/@PROJECT@/${DEVICE:-$PROJECT}/g" \
          -i $INSTALL/usr/share/bootloader/canupdate.sh
    fi
}
