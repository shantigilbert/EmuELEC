PKG_NAME="enable-oga-sleep"
PKG_VERSION=""
PKG_SHA256=""
PKG_ARCH="any"
PKG_LICENSE="OSS"
PKG_DEPENDS_TARGET="rs97-commander-sdl2"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Sleep configuration"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
	mkdir -p $INSTALL/usr/config/sleep.conf.d
	cp * $INSTALL/usr/config/sleep.conf.d
}
