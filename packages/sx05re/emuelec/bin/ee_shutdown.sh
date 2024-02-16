#!/bin/bash

systemctl stop emustation
systemctl stop retroarch
systemctl stop bluetooth
sleep 5
systemctl poweroff # --force
