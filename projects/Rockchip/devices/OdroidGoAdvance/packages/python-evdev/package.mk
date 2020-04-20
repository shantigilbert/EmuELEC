PKG_NAME="python-evdev"
PKG_VERSION="1.3.0"
PKG_SHA256="b1c649b4fed7252711011da235782b2c260b32e004058d62473471e5cd30634d"
PKG_LICENSE="OSS"
PKG_SITE="https://pypi.org/project/evdev"
PKG_URL="https://files.pythonhosted.org/packages/89/83/5f5635fd0d91a08ac355dd9ca9bde34bfa6b29a5c59f703ad83d1ad0bf34/evdev-1.3.0.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3:host distutilscross:host"
PKG_LONGDESC="Userspace evdev events"
PKG_TOOLCHAIN="manual"

pre_make_target() {
  export PYTHONXCPREFIX="${SYSROOT_PREFIX}/usr"
  export LDFLAGS="${LDFLAGS} -L${SYSROOT_PREFIX}/usr/lib -L${SYSROOT_PREFIX}/lib"
  export LDSHARED="${CC} -shared"
  find . -name setup.py -exec sed -i "s:/usr/include/linux/input.h :${SYSROOT_PREFIX}/usr/include/linux/input.h:g" \{} \;
  find . -name setup.py -exec sed -i "s:/usr/include/linux/input-event-codes.h :${SYSROOT_PREFIX}/usr/include/linux/input-event-codes.h:g" \{} \;
}

make_target() {
  python3 setup.py build \
  build_ecodes --evdev-headers ${SYSROOT_PREFIX}/usr/include/linux/input.h:${SYSROOT_PREFIX}/usr/include/linux/input-event-codes.h
}

makeinstall_target() {
  python3 setup.py install --root=${INSTALL} --prefix=/usr
}

post_makeinstall_target() {
  # Seems like there's an issue in the build system.
  # C Modules get built using the correct target toolchain but the generated *.so
  # files use the arch from the host system
  # tried to solve it but couldn't so I move them to the correct names for python
  # to grab them
  mv ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_ecodes.cpython-37-* \
    ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_ecodes.cpython-37-arm-linux-gnueabihf.so
  mv ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_input.cpython-37-* \
    ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_input.cpython-37-arm-linux-gnueabihf.so
  mv ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_uinput.cpython-37-* \
    ${INSTALL}/usr/lib/python3.7/site-packages/evdev/_uinput.cpython-37-arm-linux-gnueabihf.so
}

# post_makeinstall_target() {
  # find ${INSTALL}/usr/lib/python*/site-packages/  -name "*.py" -exec rm -rf {} ";"
# }
