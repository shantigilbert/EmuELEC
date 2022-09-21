#!/bin/bash

# IMPORTANT: js0 is always used as default, but you can change this in ee_kill.cfg

FOUND=0
EE_CFG="/emuelec/configs/jslisten.cfg"
EE_DEV="$(cat $EE_CFG | grep ee_evdev | awk -F= '{print $2}' | tr -d \")"

[ $EE_DEV == "auto" ] && EE_DEV=$(basename /dev/input/js*)

for file in /tmp/joypads/*.cfg; do
	file2=$(basename "$file")
	EE_GAMEPAD="${file2%.*}"

if cat /proc/bus/input/devices | grep -E -A 4 "$EE_GAMEPAD" | grep $EE_DEV > /dev/null; then
	FOUND=1
	break
fi
done

if [ $FOUND = 1 ]; then
	# Update jslisten.cfg with the corresponding keys
	EE_GAMEPAD="/tmp/joypads/$file2"
	KEY1=$(cat "$EE_GAMEPAD" | grep -E 'hotkey_btn' | cut -d '"' -f2)
	KEY2=$(cat "$EE_GAMEPAD" | grep -E 'input_exit_emulator_btn' | cut -d '"' -f2)
	
	sed -i '/button1=.*/d' ${EE_CFG}
	sed -i '/button2=.*/d' ${EE_CFG}
	echo "button1=${KEY1}" >> ${EE_CFG}	
	echo "button2=${KEY2}" >> ${EE_CFG}	

	DEVICE=$(cat "$EE_GAMEPAD" | grep -E 'input_device' | cut -d '"' -f2)
	echo "Kill combo set to ${KEY1}+${KEY2} from $EE_GAMEPAD Dev: $EE_DEV"
else
	echo "Dev: $EE_DEV not connected or it hasn't been configured in ES"
fi
