#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present Shanti Gilbert (https://github.com/shantigilbert)

# Source predefined functions and variables
. /etc/profile


# TODO, make this work :P modify abuse.gptk
gptokeyb -c /emuelec/configs/gptokeyb/abuse.gptk &
abuse

# Just in case
killall gptokeyb
