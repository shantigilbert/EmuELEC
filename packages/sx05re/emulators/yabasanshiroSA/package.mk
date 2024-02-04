PKG_NAME="yabasanshiroSA"
PKG_VERSION="c7618d2ecbf77b1e8188fa8af4fa1cfb34833a72"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/devmiyax/yabause"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 boost openal-soft ${OPENGLES} zlib"
PKG_LONGDESC="Yabause is a Sega Saturn emulator and took over as Yaba Sanshiro"
PKG_TOOLCHAIN="cmake-make"
GET_HANDLER_SUPPORT="git"
PKG_GIT_CLONE_BRANCH="pi4-1-9-0"
PKG_BUILD_FLAGS="+speed"

post_unpack() {
  # use host versions
  sed -i "s|COMMAND m68kmake|COMMAND ${PKG_BUILD}/m68kmake_host|" ${PKG_BUILD}/yabause/src/musashi/CMakeLists.txt
  sed -i "s|COMMAND ./bin2c|COMMAND ${PKG_BUILD}/bin2c_host|" ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/CMakeLists.txt
}

pre_make_target() {
  # runs on host so make them manually if package is not crosscompile friendly
  ${HOST_CC} ${PKG_BUILD}/yabause/src/retro_arena/nanogui-sdl/resources/bin2c.c -o ${PKG_BUILD}/bin2c_host
  ${HOST_CC} ${PKG_BUILD}/yabause/src/musashi/m68kmake.c -o ${PKG_BUILD}/m68kmake_host
}

pre_configure_target() {
PKG_CMAKE_OPTS_TARGET="${PKG_BUILD}/yabause \
                         -DYAB_PORTS=retro_arena \
                         -DYAB_WANT_DYNAREC_DEVMIYAX=ON \
                         -DYAB_WANT_ARM7=ON \
                         -DCMAKE_TOOLCHAIN_FILE=${PKG_BUILD}/yabause/src/retro_arena/n2.cmake \
                         -DYAB_WANT_VULKAN=OFF \
                         -DOPENGL_INCLUDE_DIR=${SYSROOT_PREFIX}/usr/include \
                         -DOPENGL_opengl_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                         -DOPENGL_glx_LIBRARY=${SYSROOT_PREFIX}/usr/lib \
                         -DLIBPNG_LIB_DIR=${SYSROOT_PREFIX}/usr/lib \
                         -Dpng_STATIC_LIBRARIES=${SYSROOT_PREFIX}/usr/lib/libpng16.a \
                         -DCMAKE_BUILD_TYPE=Release"
}

makeinstall_target() {
mkdir -p ${INSTALL}/usr/bin
cp -a ${PKG_BUILD}/src/retro_arena/yabasanshiro ${INSTALL}/usr/bin
cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

mkdir -p ${INSTALL}/usr/config/emuelec/configs/yabasanshiro
cp ${PKG_DIR}/config/* ${INSTALL}/usr/config/emuelec/configs/yabasanshiro
} 
