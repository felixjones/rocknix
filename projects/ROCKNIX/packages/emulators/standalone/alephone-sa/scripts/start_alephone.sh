#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

ROM="$1"
LOG="/var/log/alephone.log"

set_kill set "-9 alephone"

SCENARIO=""
if [ -d "${ROM}" ]; then
  SCENARIO="${ROM}"
elif [ -f "${ROM}" ]; then
  SCENARIO="$(sed -n 's/^SCENARIO=//p' "${ROM}" | head -1)"
  [ -z "${SCENARIO}" ] && SCENARIO="$(dirname "${ROM}")"
fi

if [ -z "${SCENARIO}" ] || [ ! -d "${SCENARIO}" ]; then
  echo "start_alephone.sh: no scenario directory in '${ROM}'" | tee -a "${LOG}" >&2
  exit 1
fi

export SDL_GAMECONTROLLERCONFIG_FILE="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"

# The libmali gpudriver masks libGL.so with /dev/null. As the engine links libGL
# it cannot even load there, so when GL is masked re-exec in a private mount
# namespace, lift the mask so only Aleph One sees the real Mesa libGL, and run
# the software renderer (--nogl). Where libGL is a real library, use GL and let
# the engine fall back on its own if a context cannot be created.
if [ -z "${ALEPHONE_INNER}" ] && [ ! -s "$(readlink -f /usr/lib/libGL.so.1 2>/dev/null)" ]; then
  export ALEPHONE_INNER=1
  exec unshare --mount --propagation private "$0" "$@"
fi

NOGL=""
if [ -n "${ALEPHONE_INNER}" ]; then
  for gl in /usr/lib/libGL.so /usr/lib/libGL.so.1 /usr/lib32/libGL.so /usr/lib32/libGL.so.1; do
    umount "$(readlink -f "${gl}" 2>/dev/null)" 2>/dev/null
    umount "${gl}" 2>/dev/null
  done
  NOGL="--nogl"
fi

/usr/bin/alephone ${NOGL} -f "${SCENARIO}" >"${LOG}" 2>&1