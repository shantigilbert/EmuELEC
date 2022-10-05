# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.tv)

# Detect newer kernel installs and abort to prevent downgrades
if [ "$(uname -r)" != "3.14.29" ]; then
    echo "Downgrading to 3.14 kernel is not supported!"
    sleep 10
    exit 1
fi

case $1 in
   @PROJECT@|S905*|S912*)
       exit 0
    ;;
   *)
       exit 1
    ;;
esac
