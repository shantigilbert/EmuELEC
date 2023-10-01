
if ! test -f /storage/roms/ports/falloutce2/fallout2.cfg; then
  cp /usr/config/emuelec/configs/falloutce2/fallout2.cfg /storage/roms/ports/falloutce2/
fi

gptokeyb -c /emuelec/configs/gptokeyb/fallout.gptk &

fallout2-ce > /emuelec/logs/emuelec.log 2>&1

killall gptokeyb &