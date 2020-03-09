#!/bin/sh

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

dir="$1"
name=${dir##*/}
name=${name%.*}

if [[ -f "$dir/$name.commands" ]]; then
    params=$(<"$dir/$name.commands")
fi

cd ~/.config/emuelec/configs/hypseus/

hypseus "$name" vldp -framefile "$dir/$name.txt" -fullscreen -useoverlaysb 2 $params
