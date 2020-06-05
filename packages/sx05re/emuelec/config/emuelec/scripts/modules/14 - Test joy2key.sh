#!/usr/bin/env bash
JOY2KEY_DEV="/dev/input/js0"
python3 "/emuelec/bin/joy2key.py" "$JOY2KEY_DEV" kcub1 kcuf1 kcuu1 kcud1 0x0a 0x09
dialog --title "Is this working?" --yesno "Is this working?" 7 60
