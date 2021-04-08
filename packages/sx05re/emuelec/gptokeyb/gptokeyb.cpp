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

#include "parser.h"

const int FAKE_MOUSE_SCALE = 512;
const int FAKE_MOUSE_SPEED = 16;

static int uinp_fd = -1;
struct uinput_user_dev uidev;
bool kill_mode = false;
bool openbor_mode = false;
bool xbox360_mode = false;
char* AppToKill;
bool config_mode = false;
char* config_file;
bool back_pressed = false;
bool start_pressed = false;
int back_jsdevice;
int start_jsdevice;

int mouseX = 0;
int mouseY = 0;

short back = KEY_ESC;
short start = KEY_ENTER;
short guide = KEY_ENTER;
short a = KEY_X;
short b = KEY_Z;
short x = KEY_C;
short y = KEY_A;
short l1 = KEY_RIGHTSHIFT;
short l2 = BTN_LEFT;
short l3 = BTN_LEFT;
short r1 = KEY_LEFTSHIFT;
short r2 = BTN_RIGHT;
short r3 = BTN_RIGHT;
short up = KEY_UP;
short down = KEY_DOWN;
short left = KEY_LEFT;
short right = KEY_RIGHT;

int left_analog_mouse = 0;
int right_analog_mouse = 0;

short left_analog_up = KEY_W;
short left_analog_down = KEY_S;
short left_analog_left = KEY_A;
short left_analog_right = KEY_D;
short right_analog_up = KEY_END;
short right_analog_down = KEY_HOME;
short right_analog_left = KEY_LEFT;
short right_analog_right = KEY_RIGHT;

bool left_analog_was_up = false;
bool left_analog_was_down = false;
bool left_analog_was_left = false;
bool left_analog_was_right = false;
bool right_analog_was_up = false;
bool right_analog_was_down = false;
bool right_analog_was_left = false;
bool right_analog_was_right = false;

int deadzone_y = 15000;
int deadzone_x = 15000;

int current_left_analog_x = 0;
int current_left_analog_y = 0;
int current_right_analog_x = 0;
int current_right_analog_y = 0;

int applyDeadzone(int value, int deadzone)
{
  if (std::abs(value) > deadzone) {
    return value;
  } else {
    return 0;
  }
}

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

void emitMouseMotion(int x, int y)
{
  if (x != 0) {
    emit(EV_REL, REL_X, x);
  }
  if (y != 0) {
    emit(EV_REL, REL_Y, y);
  }

  if (x != 0 || y != 0) {
    emit(EV_SYN, SYN_REPORT, 0);
  }
}

void handleAnalogTrigger(bool is_triggered, bool& was_triggered, int key)
{
  if (is_triggered && !was_triggered) {
    emitKey(key, true);
  } else if (!is_triggered && was_triggered) {
    emitKey(key, false);
  }

  was_triggered = is_triggered;
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
  ioctl(fd, UI_SET_EVBIT, EV_SYN);

  // Fake mouse
  ioctl(fd, UI_SET_EVBIT, EV_REL);
  ioctl(fd, UI_SET_RELBIT, REL_X);
  ioctl(fd, UI_SET_RELBIT, REL_Y);
  ioctl(fd, UI_SET_KEYBIT, BTN_LEFT);
  ioctl(fd, UI_SET_KEYBIT, BTN_RIGHT);
}

void setupFakeXbox360Device(uinput_user_dev& device, int fd)
{
  strncpy(device.name, "Microsoft X-Box 360 pad", UINPUT_MAX_NAME_SIZE);
  device.id.vendor = 0x045e;  /* sample vendor */
  device.id.product = 0x028e; /* sample product */

  if (
    ioctl(fd, UI_SET_EVBIT, EV_KEY) || ioctl(fd, UI_SET_EVBIT, EV_SYN) ||
    ioctl(fd, UI_SET_EVBIT, EV_ABS) ||
    // X-Box 360 pad buttons
    ioctl(fd, UI_SET_KEYBIT, BTN_A) || ioctl(fd, UI_SET_KEYBIT, BTN_B) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_X) || ioctl(fd, UI_SET_KEYBIT, BTN_Y) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_TL) || ioctl(fd, UI_SET_KEYBIT, BTN_TR) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_THUMBL) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_THUMBR) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_SELECT) ||
    ioctl(fd, UI_SET_KEYBIT, BTN_START) || ioctl(fd, UI_SET_KEYBIT, BTN_MODE) ||
    // absolute (sticks)
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_LEFTX) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_LEFTY) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_RIGHTX) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_RIGHTY) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_TRIGGERLEFT) ||
    ioctl(fd, UI_SET_ABSBIT, SDL_CONTROLLER_AXIS_TRIGGERRIGHT) ||
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0X) ||
    ioctl(fd, UI_SET_ABSBIT, ABS_HAT0Y)) {
    printf("Failed to configure fake Xbox 360 controller\n");
    exit(-1);
  }

  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_LEFTX, -32768, 32767, 16, 128);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_LEFTY, -32768, 32767, 16, 128);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_RIGHTX, -32768, 32767, 16, 128);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_RIGHTY, -32768, 32767, 16, 128);
  UINPUT_SET_ABS_P(&device, ABS_HAT0X, -1, 1, 0, 0);
  UINPUT_SET_ABS_P(&device, ABS_HAT0Y, -1, 1, 0, 0);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_TRIGGERLEFT, 0, 255, 0, 0);
  UINPUT_SET_ABS_P(&device, SDL_CONTROLLER_AXIS_TRIGGERRIGHT, 0, 255, 0, 0);
}

bool handleEvent(const SDL_Event& event)
{
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

          case SDL_CONTROLLER_BUTTON_DPAD_UP:
            emitAxisMotion(ABS_HAT0Y, is_pressed ? -1 : 0);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
            emitAxisMotion(ABS_HAT0Y, is_pressed ? 1 : 0);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
            emitAxisMotion(ABS_HAT0X, is_pressed ? -1 : 0);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
            emitAxisMotion(ABS_HAT0X, is_pressed ? 1 : 0);
            break;
        }
      } else {
        // Config / default mode
        switch (event.cbutton.button) {
          case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
            emitKey(left, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_UP:
            emitKey(up, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
            emitKey(right, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
            emitKey(down, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_A:
            emitKey(a, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_B:
            emitKey(b, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_X:
            emitKey(x, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_Y:
            emitKey(y, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_LEFTSHOULDER:
            emitKey(l1, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_RIGHTSHOULDER:
            emitKey(r1, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_LEFTSTICK:
            emitKey(l3, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_RIGHTSTICK:
            emitKey(r3, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_GUIDE:
            emitKey(r3, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_BACK: // aka select
            emitKey(back, is_pressed);
            break;

          case SDL_CONTROLLER_BUTTON_START:
            emitKey(start, is_pressed);
            break;
        }
      } //kill mode
    } break;

    case SDL_CONTROLLERAXISMOTION:
      if (xbox360_mode) {
        switch (event.caxis.axis) {
          case SDL_CONTROLLER_AXIS_LEFTX:
            emitAxisMotion(ABS_X, event.caxis.value);
            break;

          case SDL_CONTROLLER_AXIS_LEFTY:
            emitAxisMotion(ABS_Y, event.caxis.value);
            break;

          case SDL_CONTROLLER_AXIS_RIGHTX:
            emitAxisMotion(ABS_RX, event.caxis.value);
            break;

          case SDL_CONTROLLER_AXIS_RIGHTY:
            emitAxisMotion(ABS_RY, event.caxis.value);
            break;

          case SDL_CONTROLLER_AXIS_TRIGGERLEFT:
            // The target range for the triggers is 0..255 instead of
            // 0..32767, so we shift down by 7 as that does exactly the
            // scaling we need (32767 >> 7 is 255)
            emitAxisMotion(ABS_Z, event.caxis.value >> 7);
            break;

          case SDL_CONTROLLER_AXIS_TRIGGERRIGHT:
            emitAxisMotion(ABS_RZ, event.caxis.value >> 7);
            break;
        }
      } else {
        switch (event.caxis.axis) {
          case SDL_CONTROLLER_AXIS_LEFTX:
            current_left_analog_x =
              applyDeadzone(event.caxis.value, deadzone_x);
            break;

          case SDL_CONTROLLER_AXIS_LEFTY:
            current_left_analog_y =
              applyDeadzone(event.caxis.value, deadzone_y);
            break;

          case SDL_CONTROLLER_AXIS_RIGHTX:
            current_right_analog_x =
              applyDeadzone(event.caxis.value, deadzone_x);
            break;

          case SDL_CONTROLLER_AXIS_RIGHTY:
            current_right_analog_y =
              applyDeadzone(event.caxis.value, deadzone_y);
            break;
        }

        // fake mouse
        if (left_analog_mouse == 1) {
          mouseX = current_left_analog_x / FAKE_MOUSE_SCALE;
          mouseY = current_left_analog_y / FAKE_MOUSE_SCALE;
        } else if (right_analog_mouse == 1) {
          mouseX = current_right_analog_x / FAKE_MOUSE_SCALE;
          mouseY = current_right_analog_y / FAKE_MOUSE_SCALE;
        } else {
          // Analogs trigger keys
          handleAnalogTrigger(
            current_left_analog_y < 0, left_analog_was_up, left_analog_up);
          handleAnalogTrigger(
            current_left_analog_y > 0, left_analog_was_down, left_analog_down);
          handleAnalogTrigger(
            current_left_analog_x < 0, left_analog_was_left, left_analog_left);
          handleAnalogTrigger(
            current_left_analog_x > 0,
            left_analog_was_right,
            left_analog_right);
          handleAnalogTrigger(
            current_right_analog_y < 0, right_analog_was_up, right_analog_up);
          handleAnalogTrigger(
            current_right_analog_y > 0,
            right_analog_was_down,
            right_analog_down);
          handleAnalogTrigger(
            current_right_analog_x < 0,
            right_analog_was_left,
            right_analog_left);
          handleAnalogTrigger(
            current_right_analog_x > 0,
            right_analog_was_right,
            right_analog_right);
        }
      }
      break;
    case SDL_CONTROLLERDEVICEADDED:
      if (xbox360_mode == true || config_mode == true) {
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
      return false;
      break;
  }

  return true;
}

// convert ASCII chars to key codes
short char_to_keycode(char str[])
{
  short keycode;

  // arrow keys
  if (strcmp(str, "up") == 0)
    keycode = KEY_UP;
  else if (strcmp(str, "down") == 0)
    keycode = KEY_DOWN;
  else if (strcmp(str, "left") == 0)
    keycode = KEY_LEFT;
  else if (strcmp(str, "right") == 0)
    keycode = KEY_RIGHT;

  // special keys
  else if (strcmp(str, "mouse_left") == 0)
    keycode = BTN_LEFT;
  else if (strcmp(str, "mouse_right") == 0)
    keycode = BTN_RIGHT;
  else if (strcmp(str, "space") == 0)
    keycode = KEY_SPACE;
  else if (strcmp(str, "esc") == 0)
    keycode = KEY_ESC;
  else if (strcmp(str, "end") == 0)
    keycode = KEY_END;
  else if (strcmp(str, "home") == 0)
    keycode = KEY_HOME;
  else if (strcmp(str, "shift") == 0)
    keycode = KEY_LEFTSHIFT;
  else if (strcmp(str, "leftshift") == 0)
    keycode = KEY_LEFTSHIFT;
  else if (strcmp(str, "rightshift") == 0)
    keycode = KEY_RIGHTSHIFT;
  else if (strcmp(str, "ctrl") == 0)
    keycode = KEY_LEFTCTRL;
  else if (strcmp(str, "leftctrl") == 0)
    keycode = KEY_LEFTCTRL;
  else if (strcmp(str, "rightctrl") == 0)
    keycode = KEY_RIGHTCTRL;
  else if (strcmp(str, "alt") == 0)
    keycode = KEY_LEFTALT;
  else if (strcmp(str, "leftalt") == 0)
    keycode = KEY_LEFTALT;
  else if (strcmp(str, "rightalt") == 0)
    keycode = KEY_RIGHTALT;
  else if (strcmp(str, "backspace") == 0)
    keycode = KEY_BACKSPACE;
  else if (strcmp(str, "enter") == 0)
    keycode = KEY_ENTER;
  else if (strcmp(str, "pageup") == 0)
    keycode = KEY_PAGEUP;
  else if (strcmp(str, "pagedown") == 0)
    keycode = KEY_PAGEDOWN;
  else if (strcmp(str, "insert") == 0)
    keycode = KEY_INSERT;
  else if (strcmp(str, "delete") == 0)
    keycode = KEY_DELETE;
  else if (strcmp(str, "capslock") == 0)
    keycode = KEY_CAPSLOCK;
  else if (strcmp(str, "tab") == 0)
    keycode = KEY_TAB;

  // normal keyboard
  else if (strcmp(str, "a") == 0)
    keycode = KEY_A;
  else if (strcmp(str, "b") == 0)
    keycode = KEY_B;
  else if (strcmp(str, "c") == 0)
    keycode = KEY_C;
  else if (strcmp(str, "d") == 0)
    keycode = KEY_D;
  else if (strcmp(str, "e") == 0)
    keycode = KEY_E;
  else if (strcmp(str, "f") == 0)
    keycode = KEY_F;
  else if (strcmp(str, "g") == 0)
    keycode = KEY_G;
  else if (strcmp(str, "h") == 0)
    keycode = KEY_H;
  else if (strcmp(str, "i") == 0)
    keycode = KEY_I;
  else if (strcmp(str, "j") == 0)
    keycode = KEY_J;
  else if (strcmp(str, "k") == 0)
    keycode = KEY_K;
  else if (strcmp(str, "l") == 0)
    keycode = KEY_L;
  else if (strcmp(str, "m") == 0)
    keycode = KEY_M;
  else if (strcmp(str, "n") == 0)
    keycode = KEY_N;
  else if (strcmp(str, "o") == 0)
    keycode = KEY_O;
  else if (strcmp(str, "p") == 0)
    keycode = KEY_P;
  else if (strcmp(str, "q") == 0)
    keycode = KEY_Q;
  else if (strcmp(str, "r") == 0)
    keycode = KEY_R;
  else if (strcmp(str, "s") == 0)
    keycode = KEY_S;
  else if (strcmp(str, "t") == 0)
    keycode = KEY_T;
  else if (strcmp(str, "u") == 0)
    keycode = KEY_U;
  else if (strcmp(str, "v") == 0)
    keycode = KEY_V;
  else if (strcmp(str, "w") == 0)
    keycode = KEY_W;
  else if (strcmp(str, "x") == 0)
    keycode = KEY_X;
  else if (strcmp(str, "y") == 0)
    keycode = KEY_Y;
  else if (strcmp(str, "z") == 0)
    keycode = KEY_Z;

  else if (strcmp(str, "1") == 0)
    keycode = KEY_1;
  else if (strcmp(str, "2") == 0)
    keycode = KEY_2;
  else if (strcmp(str, "3") == 0)
    keycode = KEY_3;
  else if (strcmp(str, "4") == 0)
    keycode = KEY_4;
  else if (strcmp(str, "5") == 0)
    keycode = KEY_5;
  else if (strcmp(str, "6") == 0)
    keycode = KEY_6;
  else if (strcmp(str, "7") == 0)
    keycode = KEY_7;
  else if (strcmp(str, "8") == 0)
    keycode = KEY_8;
  else if (strcmp(str, "9") == 0)
    keycode = KEY_9;
  else if (strcmp(str, "0") == 0)
    keycode = KEY_0;

  else if (strcmp(str, "f1") == 0)
    keycode = KEY_F1;
  else if (strcmp(str, "f2") == 0)
    keycode = KEY_F2;
  else if (strcmp(str, "f3") == 0)
    keycode = KEY_F3;
  else if (strcmp(str, "f4") == 0)
    keycode = KEY_F4;
  else if (strcmp(str, "f5") == 0)
    keycode = KEY_F5;
  else if (strcmp(str, "f6") == 0)
    keycode = KEY_F6;
  else if (strcmp(str, "f7") == 0)
    keycode = KEY_F7;
  else if (strcmp(str, "f8") == 0)
    keycode = KEY_F8;
  else if (strcmp(str, "f9") == 0)
    keycode = KEY_F9;
  else if (strcmp(str, "f10") == 0)
    keycode = KEY_F10;

  else if (strcmp(str, "@") == 0)
    keycode = KEY_2; // with SHIFT
  else if (strcmp(str, "#") == 0)
    keycode = KEY_3; // with SHIFT
  //else if (strcmp(str, "€") == 0) keycode = KEY_5; // with ALTGR; not ASCII
  else if (strcmp(str, "%") == 0)
    keycode = KEY_5; // with SHIFT
  else if (strcmp(str, "&") == 0)
    keycode = KEY_7; // with SHIFT
  else if (strcmp(str, "*") == 0)
    keycode = KEY_8; // with SHIFT; alternative is KEY_KPASTERISK
  else if (strcmp(str, "-") == 0)
    keycode = KEY_MINUS; // alternative is KEY_KPMINUS
  else if (strcmp(str, "+") == 0)
    keycode = KEY_EQUAL; // with SHIFT; alternative is KEY_KPPLUS
  else if (strcmp(str, "(") == 0)
    keycode = KEY_9; // with SHIFT
  else if (strcmp(str, ")") == 0)
    keycode = KEY_0; // with SHIFT

  else if (strcmp(str, "!") == 0)
    keycode = KEY_1; // with SHIFT
  else if (strcmp(str, "\"") == 0)
    keycode = KEY_APOSTROPHE; // with SHIFT, dead key
  else if (strcmp(str, "\'") == 0)
    keycode = KEY_APOSTROPHE; // dead key
  else if (strcmp(str, ":") == 0)
    keycode = KEY_SEMICOLON; // with SHIFT
  else if (strcmp(str, ";") == 0)
    keycode = KEY_SEMICOLON;
  else if (strcmp(str, "/") == 0)
    keycode = KEY_SLASH;
  else if (strcmp(str, "?") == 0)
    keycode = KEY_SLASH; // with SHIFT
  else if (strcmp(str, ".") == 0)
    keycode = KEY_DOT;
  else if (strcmp(str, ",") == 0)
    keycode = KEY_COMMA;

  // special chars
  else if (strcmp(str, "~") == 0)
    keycode = KEY_GRAVE; // with SHIFT, dead key
  else if (strcmp(str, "`") == 0)
    keycode = KEY_GRAVE; // dead key
  else if (strcmp(str, "|") == 0)
    keycode = KEY_BACKSLASH; // with SHIFT
  else if (strcmp(str, "{") == 0)
    keycode = KEY_LEFTBRACE; // with SHIFT
  else if (strcmp(str, "}") == 0)
    keycode = KEY_RIGHTBRACE; // with SHIFT
  else if (strcmp(str, "$") == 0)
    keycode = KEY_4; // with SHIFT
  else if (strcmp(str, "^") == 0)
    keycode = KEY_6; // with SHIFT, dead key
  else if (strcmp(str, "_") == 0)
    keycode = KEY_MINUS; // with SHIFT
  else if (strcmp(str, "=") == 0)
    keycode = KEY_EQUAL;
  else if (strcmp(str, "[") == 0)
    keycode = KEY_LEFTBRACE;
  else if (strcmp(str, "]") == 0)
    keycode = KEY_RIGHTBRACE;
  else if (strcmp(str, "\\") == 0)
    keycode = KEY_BACKSLASH;
  else if (strcmp(str, "<") == 0)
    keycode = KEY_COMMA; // with SHIFT
  else if (strcmp(str, ">") == 0)
    keycode = KEY_DOT; // with SHIFT

  return keycode;
}

int main(int argc, char* argv[])
{
  if (argc > 1) {
    if (strcmp(argv[1], "xbox360") == 0) {
      xbox360_mode = true;
    } else if (strcmp(argv[1], "-c") == 0) {
      config_mode = true;
      config_file = argv[2];
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

      // if we are in config mode, read the file
      if (config_mode) {
        // parse config file
        config_option_t co;
        if ((co = read_config_file(config_file)) != NULL) {
          while (1) {
            if (strcmp(co->key, "back") == 0) {
              back = char_to_keycode(co->value);
            } else if (strcmp(co->key, "guide") == 0) {
              start = char_to_keycode(co->value);
            } else if (strcmp(co->key, "start") == 0) {
              start = char_to_keycode(co->value);
            } else if (strcmp(co->key, "a") == 0) {
              a = char_to_keycode(co->value);
            } else if (strcmp(co->key, "b") == 0) {
              b = char_to_keycode(co->value);
            } else if (strcmp(co->key, "x") == 0) {
              x = char_to_keycode(co->value);
            } else if (strcmp(co->key, "y") == 0) {
              y = char_to_keycode(co->value);
            } else if (strcmp(co->key, "l1") == 0) {
              l1 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "l2") == 0) {
              l2 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "l3") == 0) {
              l3 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "r1") == 0) {
              r1 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "r2") == 0) {
              r2 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "r3") == 0) {
              r3 = char_to_keycode(co->value);
            } else if (strcmp(co->key, "up") == 0) {
              up = char_to_keycode(co->value);
            } else if (strcmp(co->key, "down") == 0) {
              down = char_to_keycode(co->value);
            } else if (strcmp(co->key, "left") == 0) {
              left = char_to_keycode(co->value);
            } else if (strcmp(co->key, "right") == 0) {
              right = char_to_keycode(co->value);
            } else if (strcmp(co->key, "left_analog_up") == 0) {
              if (strcmp(co->value, "mouse_movement_up") == 0) {
                left_analog_mouse = 1;
              } else {
                left_analog_up = char_to_keycode(co->value);
              }
            } else if (strcmp(co->key, "left_analog_down") == 0) {
              left_analog_down = char_to_keycode(co->value);
            } else if (strcmp(co->key, "left_analog_left") == 0) {
              left_analog_left = char_to_keycode(co->value);
            } else if (strcmp(co->key, "left_analog_right") == 0) {
              left_analog_right = char_to_keycode(co->value);
            } else if (strcmp(co->key, "right_analog_up") == 0) {
              if (strcmp(co->value, "mouse_movement_up") == 0) {
                right_analog_mouse = 1;
              } else {
                right_analog_up = char_to_keycode(co->value);
              }
            } else if (strcmp(co->key, "right_analog_down") == 0) {
              right_analog_down = char_to_keycode(co->value);
            } else if (strcmp(co->key, "right_analog_left") == 0) {
              right_analog_left = char_to_keycode(co->value);
            } else if (strcmp(co->key, "right_analog_right") == 0) {
              right_analog_right = char_to_keycode(co->value);
            } else if (strcmp(co->key, "deadzone_y") == 0) {
              deadzone_y = atoi(co->value);
            } else if (strcmp(co->key, "deadzone_x") == 0) {
              deadzone_x = atoi(co->value);
            }

            if (co->prev != NULL) {
              co = co->prev;
            } else {
              break;
            }
          }
        }
      }
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
    if (mouseX != 0 || mouseY != 0) {
      while (running && SDL_PollEvent(&event)) {
        running = handleEvent(event);
      }

      emitMouseMotion(mouseX, mouseY);
      SDL_Delay(FAKE_MOUSE_SPEED);
    } else {
      if (!SDL_WaitEvent(&event)) {
        printf("SDL_WaitEvent() failed: %s\n", SDL_GetError());
        return -1;
      }

      running = handleEvent(event);
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
