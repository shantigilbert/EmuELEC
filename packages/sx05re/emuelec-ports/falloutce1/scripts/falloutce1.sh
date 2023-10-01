
if ! test -f /storage/roms/ports/falloutcd1/fallout.cfg; then
  cp /usr/config/emuelec/configs/falloutce1/fallout.cfg /storage/roms/ports/falloutce1/
fi

gptokeyb -c /emuelec/configs/gptokeyb/fallout.gptk &

fallout-ce > /emuelec/logs/emuelec.log 2>&1

killall gptokeyb &