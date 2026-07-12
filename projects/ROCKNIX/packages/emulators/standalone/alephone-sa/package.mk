# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="alephone-sa"
PKG_VERSION="20250829"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/Aleph-One-Marathon/alephone"
PKG_URL="${PKG_SITE}/releases/download/release-${PKG_VERSION}/AlephOne-${PKG_VERSION}.tar.bz2"
PKG_SOURCE_NAME="AlephOne-${PKG_VERSION}.tar.bz2"
PKG_SHA256="e7c447034aa35dd85ca6836dd8367034c4f4512aa0d14e9781d7033946098806"
PKG_SOURCE_DIR="AlephOne-${PKG_VERSION}"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_image SDL2_ttf boost asio zlib libsndfile openal-soft libpng curl"
PKG_LONGDESC="Aleph One is the open source continuation of Bungie's Marathon 2 and Marathon Infinity game engines, playing the entire Marathon trilogy."
PKG_TOOLCHAIN="autotools"
GET_HANDLER_SUPPORT="archive"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

PKG_CONFIGURE_OPTS_TARGET="--without-zzip \
                           --without-miniupnpc \
                           --without-nfd \
                           --without-catch2 \
                           --without-vpx \
                           --without-matroska \
                           --without-ebml \
                           --without-vorbis \
                           --without-vorbisenc \
                           --without-libyuv"

pre_configure_target() {
  local asio_inc="$(get_install_dir asio)/usr/include"
  export CXXFLAGS="${CXXFLAGS} -DASIO_STANDALONE -I${asio_inc}"
  export CPPFLAGS="${CPPFLAGS} -DASIO_STANDALONE -I${asio_inc}"
  PKG_CONFIGURE_OPTS_TARGET+=" --with-boost-libdir=${SYSROOT_PREFIX}/usr/lib --with-boost-filesystem=boost_filesystem"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp "$(find ${PKG_BUILD} -name alephone -type f -perm -u+x | head -1)" ${INSTALL}/usr/bin/alephone
  cp ${PKG_DIR}/scripts/start_alephone.sh ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/alephone ${INSTALL}/usr/bin/start_alephone.sh

  mkdir -p ${INSTALL}/usr/lib/autostart/common
  cp ${PKG_DIR}/sources/autostart/common/* ${INSTALL}/usr/lib/autostart/common/
  chmod 0755 ${INSTALL}/usr/lib/autostart/common/*

  local themesys="${INSTALL}/usr/share/themes/es-theme-art-book-next/_inc/systems"
  mkdir -p "${themesys}/artwork-default" "${themesys}/logos"
  cp ${PKG_DIR}/artwork/alephone.png "${themesys}/artwork-default/alephone.png"
  cp ${PKG_DIR}/artwork/alephone.svg "${themesys}/logos/alephone.svg"
}