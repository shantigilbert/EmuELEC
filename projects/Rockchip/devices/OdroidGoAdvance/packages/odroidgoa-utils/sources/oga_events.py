#!/usr/bin/env python3

import evdev
import asyncio
import time
from subprocess import check_output

pwrkey = evdev.InputDevice("/dev/input/event0")
odroidgo2_joypad = evdev.InputDevice("/dev/input/event2")

need_to_swallow_pwr_key = False # After a resume, we swallow the pwr input that triggered the resume

class Power:
    pwr = 116

class Joypad:
    l1 = 310
    r1 = 311

    up = 544
    down = 545
    left = 546
    right = 547

    f1 = 704
    f2 = 705
    f3 = 706


def runcmd(cmd, *args, **kw):
    print(f">>> {cmd}")
    check_output(cmd, *args, **kw)

async def handle_event(device):
    async for event in device.async_read_loop():
        global need_to_swallow_pwr_key
        if device.name == "rk8xx_pwrkey":
            keys = odroidgo2_joypad.active_keys()
            if event.value == 1 and event.code == Power.pwr: # pwr on release
                if need_to_swallow_pwr_key == False:
                    need_to_swallow_pwr_key = True
                    if Joypad.f1 in keys:
                        runcmd("/bin/systemctl poweroff || true", shell=True)
                    else:
                        runcmd("/bin/systemctl suspend || true", shell=True)
                else:
                    need_to_swallow_pwr_key = False


        elif device.name == "odroidgo2_joypad":
            keys = odroidgo2_joypad.active_keys()
            print(keys)
            if event.value == 1 and Joypad.f1 in keys:
                if event.code == Joypad.up:
                    runcmd("/emuelec/scripts/odroidgoa_utils.sh vol +", shell=True)
                elif event.code == Joypad.down:
                    runcmd("/emuelec/scripts/odroidgoa_utils.sh vol -", shell=True)
                elif event.code == Joypad.right:
                    runcmd("/emuelec/scripts/odroidgoa_utils.sh bright +", shell=True)
                elif event.code == Joypad.left:
                    runcmd("/emuelec/scripts/odroidgoa_utils.sh bright -", shell=True)
                elif event.code == Joypad.r1:
                    runcmd("/emuelec/scripts/odroidgoa_utils.sh toggleaudio", shell=True)

        if event.code != 0:
            print(device.name, event)

def run():
    asyncio.ensure_future(handle_event(pwrkey))
    asyncio.ensure_future(handle_event(odroidgo2_joypad))

    loop = asyncio.get_event_loop()
    loop.run_forever()

if __name__ == "__main__": # admire
    run()
