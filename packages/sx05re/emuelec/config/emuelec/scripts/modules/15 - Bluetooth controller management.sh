#!/bin/bash

source /emuelec/scripts/env.sh

joy2keyStart
python /emuelec/scriptmodules/supplementary/bluetoothcontroller.py ES 2>/dev/null
