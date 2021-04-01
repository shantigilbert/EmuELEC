/* Copyright (c) 2021
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
#
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
#
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
#
* Authored by: Kris Henriksen <krishenriksen.work@gmail.com>
#
* AnberPorts-Keyboard-Mouse
* 
* Part of the code is from from https://github.com/krishenriksen/AnberPorts/blob/master/AnberPorts-Keyboard-Mouse/main.c (mostly the fake keyboard)
* Fake Xbox code from: https://github.com/Emanem/js2xbox
* 
* Modified (badly) by: Shanti Gilbert for EmuELEC
* Modified further by: Nikolai Wuttke for EmuELEC (Added support for SDL and the SDLGameControllerdb.txt)
* 
* Any help improving this code would be greatly appreciated! 
* 
* TODO: Xbox360 mode: Fix triggers so that they report from 0 to 255 like real Xbox triggers
*       Xbox360 mode: Figure out why the axis are not correctly labeled?  SDL_CONTROLLER_AXIS_RIGHTX / SDL_CONTROLLER_AXIS_RIGHTY / SDL_CONTROLLER_AXIS_TRIGGERLEFT / SDL_CONTROLLER_AXIS_TRIGGERRIGHT
*       Keyboard mode: Add a config file option to load mappings from.
* 
* 
* Spaghetti code incoming, beware :)
*/

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

#include <linux/input.h>
#include <linux/uinput.h>

#include <libevdev-1.0/libevdev/libevdev-uinput.h>
#include <libevdev-1.0/libevdev/libevdev.h>

#include <fcntl.h>
#include <sstream>
#include <string.h>
#include <unistd.h>

#include <SDL.h>

static int uinp_fd = -1;
struct uinput_user_dev uidev;
bool kill_mode = false;
bool openbor_mode = false;
bool xbox360_mode = false;
char* AppToKill;
bool back_pressed = false;
bool start_pressed = false;
int back_jsdevice;
int start_jsdevice;

void UINPUT_SET_ABS_P(
  uinput_user_dev* dev,
  int axis,
  int min,
  int max,
  int fuzz,
  int flat)
{
  dev->absmax[axis] = max;
  dev->absmin[axis] = min;
  dev->absfuzz[axis] = fuzz;
  dev->absflat[axis] = flat;
}

void emit(int type, int code, int val)
{
  struct input_event ev;

  ev.type = type;
  ev.code = code;
  ev.value = val;
  /* timestamp values below are ignored */
  ev.time.tv_sec = 0;
  ev.time.tv_usec = 0;

  write(uinp_fd, &ev, sizeof(ev));
}

void emitKey(int code, bool is_pressed)
{
  emit(EV_KEY, code, is_pressed ? 1 : 0);
  emit(EV_SYN, SYN_REPORT, 0);
}

void emitAxisMotion(int code, int value)
{
  emit(EV_ABS, code, value);
  emit(EV_SYN, SYN_REPORT, 0);
}

void setupFakeKeyboardMouseDevice(uinput_user_dev& device, int fd)
{
  strncpy(device.name, "Fake Keyboard", UINPUT_MAX_NAME_SIZE);
  device.id.vendor = 0x1234;  /* sample vendor */
  device.id.product = 0x5678; /* sample product */

  for (int i = 0; i < 256; i++) {
    ioctl(fd, UI_SET_KEYBIT, i);
  }

  // Keys or Buttons
  ioctl(fd, UI_SET_EVBIT, EV_KEY);
}

void setupFakeXbox360Device(uinput_user_dev& device, int fd)
{
  strncpy(device.name, "Microsoft X-Box 360 pad", UINPUT_MAX_NAME_SIZE);
  device.id.vendor = 0x045e;  /* sample vendor */
  device.id.product = 0x028e; /* sample product */

  if (
    ioctl(fd, UI_SET_EVBIT, EV_KEY) ||
    ioctl(fd, UI_SET_EVBIT, EV_SYN) ||
    ioctl(fd, UI_SET_EVBIT, EV_ABS) ||
    // X-Box 360 pad buttons
    ioctl(fd, UI_SET_KEYBIT, BTN_A) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_B) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_X) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_Y) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_TL) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_TR) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_THUMBL) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_THUMBR) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_SELECT) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_START) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_MODE) ||
    // absolute (sticks)
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_LEFTX) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_LEFTY) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_RIGHTX) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_RIGHTY) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_TRIGGERLEFT) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_TRIGGERRIGHT) ||
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0X) ||
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0Y)
  ) {
    printf("Failed to configure fake Xbox 360 controller\n");
    exit(-1);
  }

  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_LEFTX, -32768, 32768, 16, 128);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_LEFTY, -32768, 32768, 16, 128);
  UINPUT_SET_ABS_P(
    &device, SDL_CONTROLLER_AXIS_RIGHTX, -32768, 32768, 16, 128);
  UINPUT_SET_ABS_P(
    &device, SDL_CONTROLLER_AXIS_RIGHTY, -32768, 32768, 16, 128);
  UINPUT_SET_ABS_P(&device, ABS_HAT0X, -1, 1, 0, 0);
  UINPUT_SET_ABS_P(&device, ABS_HAT0Y, -1, 1, 0, 0);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_TRIGGERLEFT, 0, 255, 0, 0);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_TRIGGERRIGHT, 0, 255, 0, 0);
}

int main(int argc, char* argv[])
{

  if (argc > 1) {
    if (strcmp(argv[1], "openbor") == 0) {
      openbor_mode = true;
    } else if (strcmp(argv[1], "xbox360") == 0) {
      xbox360_mode = true;
    } else {
      kill_mode = argv[1];
      AppToKill = argv[2];
    }
  }

  // Create fake input device (not needed in kill mode)
  if (!kill_mode) {
    uinp_fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
    if (uinp_fd < 0) {
      printf("Unable to open /dev/uinput\n");
      return -1;
    }

    // Intialize the uInput device to NULL
    memset(&uidev, 0, sizeof(uidev));
    uidev.id.version = 1;
    uidev.id.bustype = BUS_USB;

    if (xbox360_mode) {
      printf("Running in Fake Xbox 360 Mode\n");
      setupFakeXbox360Device(uidev, uinp_fd);
    } else {
      printf("Running in Fake Keyboard mode\n");
      setupFakeKeyboardMouseDevice(uidev, uinp_fd);
    }

    // Create input device into input sub-system
    write(uinp_fd, &uidev, sizeof(uidev));

    if (ioctl(uinp_fd, UI_DEV_CREATE)) {
      printf("Unable to create UINPUT device.");
      return -1;
    }
  }

  // SDL initialization and main loop
  if (SDL_Init(SDL_INIT_GAMECONTROLLER) != 0) {
    printf("SDL_Init() failed: %s\n", SDL_GetError());
    return -1;
  }

  if (const char* db_file = SDL_getenv("SDL_GAMECONTROLLERCONFIG_FILE")) {
    SDL_GameControllerAddMappingsFromFile(db_file);
  }

  SDL_Event event;
  bool running = true;
  while (running) {
    if (!SDL_WaitEvent(&event)) {
      printf("SDL_WaitEvent() failed: %s\n", SDL_GetError());
      return -1;
    }
    /*printf("event.caxis.axis: %u\n", event.caxis.axis);
            printf("event.caxis.value: %u\n", event.caxis.value); 
          */
    switch (event.type) {
      case SDL_CONTROLLERBUTTONDOWN:
      case SDL_CONTROLLERBUTTONUP: {

        const bool is_pressed = event.type == SDL_CONTROLLERBUTTONDOWN;

        if (kill_mode) {
          // Kill mode
          switch (event.cbutton.button) {
            case SDL_CONTROLLER_BUTTON_GUIDE:
              back_jsdevice = event.cdevice.which;
              back_pressed = is_pressed;
              break;

            case SDL_CONTROLLER_BUTTON_START:
              start_jsdevice = event.cdevice.which;
              start_pressed = is_pressed;
              break;
          }

          if (start_pressed && back_pressed) {
            // printf("Killing: %s\n", AppToKill);
            if (start_jsdevice == back_jsdevice) {
              system((" killall  '" + std::string(AppToKill) + "' ").c_str());
              system("show_splash.sh exit");
              sleep(3);
              if (
                system((" pgrep '" + std::string(AppToKill) + "' ").c_str()) ==
                0) {
                printf("Forcefully Killing: %s\n", AppToKill);
                system(
                  (" killall  -9 '" + std::string(AppToKill) + "' ").c_str());
              }
              exit(0);
            }
          }
        } else if (openbor_mode) {
          // Fake Openbor mode
          switch (event.cbutton.button) {
            case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
              emitKey(KEY_LEFT, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_UP:
              emitKey(KEY_UP, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
              emitKey(KEY_RIGHT, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
              emitKey(KEY_DOWN, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_A:
              emitKey(KEY_A, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_B:
              emitKey(KEY_D, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_X:
              emitKey(KEY_S, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_Y:
              emitKey(KEY_F, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:
              emitKey(KEY_Z, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:
              emitKey(KEY_X, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_BACK: // aka select
              emitKey(KEY_F12, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_START:
              emitKey(KEY_ENTER, is_pressed);
              break;
          }
        } else if (xbox360_mode) {
          // Fake Xbox360 mode
          switch (event.cbutton.button) {
            case SDL_CONTROLLER_BUTTON_A:
              emitKey(BTN_A, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_B:
              emitKey(BTN_B, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_X:
              emitKey(BTN_X, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_Y:
              emitKey(BTN_Y, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:
              emitKey(BTN_TL, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:
              emitKey(BTN_TR, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_LEFTSTICK:
              emitKey(BTN_THUMBL, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_RIGHTSTICK:
              emitKey(BTN_THUMBR, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_BACK: // aka select
              emitKey(BTN_SELECT, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_GUIDE:
              emitKey(BTN_MODE, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_START:
              emitKey(BTN_START, is_pressed);
              break;
          }
        } else {
          // Fake Keyboard mode
          switch (event.cbutton.button) {
            case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
              emitKey(KEY_LEFT, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_UP:
              emitKey(KEY_UP, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
              emitKey(KEY_RIGHT, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
              emitKey(KEY_DOWN, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_A:
              emitKey(KEY_ENTER, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_B:
              emitKey(KEY_ESC, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_BACK: // aka select
              emitKey(KEY_PLAYPAUSE, is_pressed);
              break;

            case SDL_CONTROLLER_BUTTON_START:
              emitKey(KEY_ENTER, is_pressed);
              break;
          }
        } //kill mode
      } break;
      case SDL_JOYHATMOTION:
        if (xbox360_mode) {
          //printf("event.jhat.hat: %u\n", event.jhat.hat);
          //printf("event.jhat.value: %u\n\n", event.jhat.value);
          switch (event.jhat.value) {
            case 0:
              emitAxisMotion(ABS_HAT0Y, 0);
              emitAxisMotion(ABS_HAT0X, 0);
              break;
            case SDL_HAT_UP:
              //printf("Up!\n");
              emitAxisMotion(ABS_HAT0Y, -1);
              break;
            case SDL_HAT_DOWN:
              //printf("Down!\n");
              emitAxisMotion(ABS_HAT0Y, 1);
              break;
            case SDL_HAT_LEFT:
              //printf("Left!\n");
              emitAxisMotion(ABS_HAT0X, -1);
              break;
            case SDL_HAT_RIGHT:
              //printf("Right!\n");
              emitAxisMotion(ABS_HAT0X, 1);
              break;
          }
        }
        break;
      case SDL_JOYAXISMOTION:
        if (xbox360_mode) {
          int deadzone = 200;
          /*
        if( event.jaxis.value > 200 || event.jaxis.value < -200) {
						printf("Joystick   %02i axis %02i value %i\n", 
									 event.jaxis.which, event.jaxis.axis, event.jaxis.value);
		 }
*/

          // left analog
          if (
            event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTX &&
            event.jaxis.value < -deadzone) {
            // printf("Left !\n\n");
            emitAxisMotion(ABS_X, event.jaxis.value);
          } else if (
            event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTX &&
            event.jaxis.value > deadzone) {
            //printf("Right!\n\n");
            emitAxisMotion(ABS_X, event.jaxis.value);
          } else if (
            event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTY &&
            event.jaxis.value < -deadzone) {
            //printf("Up!\n\n");
            emitAxisMotion(ABS_Y, event.jaxis.value);
          } else if (
            event.caxis.axis == SDL_CONTROLLER_AXIS_LEFTY &&
            event.jaxis.value > deadzone) {
            //printf("Down!\n\n");
            emitAxisMotion(ABS_Y, event.jaxis.value);
          }
          // right analog
          // I use INT numbers because the CONS had incorrect axis?  SDL_CONTROLLER_AXIS_RIGHTX / SDL_CONTROLLER_AXIS_RIGHTY
          if (event.caxis.axis == 3 && event.jaxis.value < -deadzone) {
            // printf("Left !\n\n");
            emitAxisMotion(ABS_RX, event.jaxis.value);
          } else if (event.caxis.axis == 3 && event.jaxis.value > deadzone) {
            //printf("Right!\n\n");
            emitAxisMotion(ABS_RX, event.jaxis.value);
          } else if (event.caxis.axis == 4 && event.jaxis.value < -deadzone) {
            //printf("Up!\n\n");
            emitAxisMotion(ABS_RY, event.jaxis.value);
          } else if (event.caxis.axis == 4 && event.jaxis.value > deadzone) {
            //printf("Down!\n\n");
            emitAxisMotion(ABS_RY, event.jaxis.value);
          }

          // triggers // Same for SDL_CONTROLLER_AXIS_TRIGGERLEFT / SDL_CONTROLLER_AXIS_TRIGGERRIGHT, I use INT because of incorrect axis?
          // triggers return MORE than 255 and they do return a negative, so something is wrong
          if (event.caxis.axis == 2) {
            emitAxisMotion(ABS_Z, event.caxis.value);
          } else if (event.caxis.axis == 5) {
            emitAxisMotion(ABS_RZ, event.caxis.value);
          }
        } // xbox mode
        break;
      case SDL_CONTROLLERDEVICEADDED:
        if (xbox360_mode == true || openbor_mode == true) {
          SDL_GameControllerOpen(0);
          /* SDL_GameController* controller = SDL_GameControllerOpen(0);
       if (controller) {
                        const char *name = SDL_GameControllerNameForIndex(0);
                            printf("Joystick %i has game controller name '%s'\n", 0, name);
                    }
    */
        } else {
          SDL_GameControllerOpen(event.cdevice.which);
        }
        break;

      case SDL_CONTROLLERDEVICEREMOVED:
        if (
          SDL_GameController* controller =
            SDL_GameControllerFromInstanceID(event.cdevice.which)) {
          SDL_GameControllerClose(controller);
        }
        break;

      case SDL_QUIT:
        running = false;
        break;
    }
  }

  SDL_Quit();

  /*
    * Give userspace some time to read the events before we destroy the
    * device with UI_DEV_DESTROY.
    */
  sleep(1);

  /* Clean up */
  ioctl(uinp_fd, UI_DEV_DESTROY);
  close(uinp_fd);
  return 0;
}
