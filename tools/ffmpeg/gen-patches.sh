#!/bin/bash

# base ffmpeg version
KODI_FFMPEG_REPO="https://github.com/xbmc/FFmpeg"
KODI_FFMPEG_VERSION="4.4.1-Nexus-Alpha1"

ALL_FEATURE_SETS="v4l2-drmprime v4l2-request libreelec rpi"

if [ $# -eq 0 ]; then
  echo "usage: $0 all|featureset [githash]"
  echo "available feature sets: ${ALL_FEATURE_SETS}"
  exit 1
fi

FFMPEG_ROOT="$(pwd)"
LE_ROOT="$(cd $(dirname $0)/../.. ; pwd)"

# get kodi's ffmpeg version
git fetch "${KODI_FFMPEG_REPO}" "${KODI_FFMPEG_VERSION}"
KODI_REV=$(git rev-parse FETCH_HEAD)

create_patch() {
  FEATURE_SET="$1"
  REFTYPE="branch"
  case "${FEATURE_SET}" in
    v4l2-drmprime)
      REPO="https://github.com/jernejsk/FFmpeg"
      REFSPEC="v4l2-drmprime-v6-4.4.1-Nexus-Alpha1"
      ;;
    v4l2-request)
      REPO="https://github.com/jernejsk/FFmpeg"
      REFSPEC="v4l2-request-hwaccel-4.4.1-Nexus-Alpha1"
      ;;
    libreelec)
      REPO="https://github.com/LibreELEC/FFmpeg"
      REFSPEC="4.4-libreelec-misc"
      ;;
    rpi)
      REPO="https://github.com/jc-kynesim/rpi-ffmpeg"
      REFSPEC="dev/4.4/rpi_import_1"
      ;;
    *)
      echo "illegal feature set ${FEATURE_SET}"
      exit 1
      ;;
  esac

  PATCH_DIR="packages/multimedia/ffmpeg/patches/${FEATURE_SET}"
  PATCH_FILE="${PATCH_DIR}/ffmpeg-001-${FEATURE_SET}.patch"
  mkdir -p "${LE_ROOT}/${PATCH_DIR}"

  git fetch "${REPO}" "${REFSPEC}"
  if [ $# -ge 2 ]; then
    REV="$2"
  else
    REV=$(git rev-parse FETCH_HEAD)
  fi
  BASE_REV=$(git merge-base "${KODI_REV}" "${REV}")

  if [ -f "${LE_ROOT}/${PATCH_FILE}" ]; then
    ACTION="update"
  else
    ACTION="create"
  fi

  if [ "${FEATURE_SET}" = "rpi" ]; then
    # branch has non-linear history, format-patch doesn't work
    git diff "${BASE_REV}..${REV}" > "${LE_ROOT}/${PATCH_FILE}"
  else
    git format-patch --stdout --no-signature "${BASE_REV}..${REV}" > "${LE_ROOT}/${PATCH_FILE}"
  fi

  MSG=$(mktemp)

  cat << EOF > "${MSG}"
ffmpeg: ${ACTION} ${FEATURE_SET} patch

Patch created using revisions ${BASE_REV:0:7}..${REV:0:7}
from ${REFTYPE} ${REFSPEC} of ${REPO}
EOF

  cd "${LE_ROOT}"
  git add "${PATCH_FILE}"
  git commit -F "${MSG}" ${GIT_COMMIT_ARGS}
  cd "${FFMPEG_ROOT}"
  rm "${MSG}"
}

if [ "$1" = "all" ]; then
  for SET in ${ALL_FEATURE_SETS}; do
    create_patch "${SET}"
  done
else
  create_patch "$@"
fi



