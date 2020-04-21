# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="brcmfmac_sdio-firmware-aml"
PKG_VERSION="182efe21ac5fc2e08621446150683f83b2d4e34e"
PKG_SHA256="4a12a3400ca0418bddb8cf2c7bc23f561b8eef62b010d5a97657104e6563f123"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/brcmfmac_sdio-firmware-aml"
PKG_URL="https://github.com/CoreELEC/brcmfmac_sdio-firmware-aml/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Firmware for brcm bluetooth chips used in some Amlogic based devices."

makeinstall_target() {
  DESTDIR=$INSTALL FWDIR=$INSTALL/$(get_kernel_overlay_dir) make install

  cd $INSTALL/$(get_full_firmware_dir)/brcm
  for f in *.hcd; do
    ln -sr $f $(grep --text -o 'BCM[24]\S*' $f).hcd 2>/dev/null || true
    ln -sr $f $(grep --text -o 'BCM[24]\S*' $f | cut -c4-).hcd 2>/dev/null || true
    ln -sr $f $(echo $f | sed -r 's/[^.]*/\U&/') 2>/dev/null || true
  done
  ln -sr bcm4335_V0343.0353.hcd bcm4335a0.hcd 2>/dev/null || true
  ln -sr bcm4335_V0343.0353.hcd BCM4335A0.hcd 2>/dev/null || true
}
