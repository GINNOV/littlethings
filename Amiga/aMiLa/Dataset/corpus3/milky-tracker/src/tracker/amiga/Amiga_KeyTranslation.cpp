/*
 *  tracker/amiga/Amiga_KeyTranslation.cpp
 *
 *  Copyright 2020 neoman
 *
 *  This file is part of Milkytracker.
 *
 *  Milkytracker is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Milkytracker is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Milkytracker.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "Amiga_KeyTranslation.h"
#include <devices/inputevent.h>

//
// http://amigadev.elowar.com/read/ADCD_2.1/Libraries_Manual_guide/node0479.html
//
pp_uint16 toVK(const AmigaKeyInputData& key)
{
    bool shiftPressed = key.qual & (IEQUALIFIER_LSHIFT | IEQUALIFIER_RSHIFT);

    // a-z -> A-Z
    if(key.sym >= 0x61 && key.sym <= 0x7a) {
        return key.sym - 0x20;
    }

    switch(key.code) {
    case 0x0f: return shiftPressed ? VK_INSERT : VK_NUMPAD0;
    case 0x1d: return shiftPressed ? VK_END    : VK_NUMPAD1;
    case 0x1e: return VK_NUMPAD2;
    case 0x1f: return shiftPressed ? VK_NEXT   : VK_NUMPAD3;
    case 0x2d: return VK_NUMPAD4;
    case 0x2e: return VK_NUMPAD5;
    case 0x2f: return VK_NUMPAD6;
    case 0x3c: return shiftPressed ? VK_DELETE : VK_DECIMAL;
    case 0x3d: return shiftPressed ? VK_HOME   : VK_NUMPAD7;
    case 0x3e: return VK_NUMPAD8;
    case 0x3f: return shiftPressed ? VK_PRIOR  : VK_NUMPAD9;

    case 0x40: return VK_SPACE;
    case 0x41: return VK_BACK;
    case 0x42: return VK_TAB;
    case 0x43: return VK_SEPARATOR; // Keypad Enter!
    case 0x44: return VK_RETURN;
    case 0x45: return VK_ESCAPE;
    case 0x46: return VK_DELETE;

    case 0x4A: return VK_SUBTRACT;

    case 0x4c: return VK_UP;
    case 0x4d: return VK_DOWN;
    case 0x4e: return VK_RIGHT;
    case 0x4f: return VK_LEFT;

    case 0x50: return VK_F1;
    case 0x51: return VK_F2;
    case 0x52: return VK_F3;
    case 0x53: return VK_F4;
    case 0x54: return VK_F5;
    case 0x55: return VK_F6;
    case 0x56: return VK_F7;
    case 0x57: return VK_F8;
    case 0x58: return VK_F9;
    case 0x59: return VK_F10; // @todo F11? F12? etc.

    case 0x5c: return VK_DIVIDE;
    case 0x5d: return VK_MULTIPLY;
    case 0x5e: return VK_ADD;

    case 0x5f: return VK_HELP;

    case 0x60: return VK_SHIFT;
    case 0x61: return VK_SHIFT;

    case 0x62: return VK_CAPITAL;

    case 0x63: return VK_LCONTROL;
    case 0x64: return VK_ALT;
    case 0x65: return VK_RCONTROL; // Remap Right ALT to "Play Song"
    case 0x66: return VK_LMENU;
    case 0x67: return VK_RMENU; // Remap Right Amiga to "Play Pattern"
    }

    if(key.sym != -1) {
        return key.sym;
    }

    return VK_UNDEFINED;
}

pp_uint16 toSC(const AmigaKeyInputData& key)
{
    //
    // Milky scancodes are oriented to a german keyboard so this
    // following source code is made according to that too.
    //

	switch (key.code) {
    case 0x00: return SC_WTF;
    case 0x01: return SC_1;
    case 0x02: return SC_2;
    case 0x03: return SC_3;
    case 0x04: return SC_4;
    case 0x05: return SC_5;
    case 0x06: return SC_6;
    case 0x07: return SC_7;
    case 0x08: return SC_8;
    case 0x09: return SC_9;
    case 0x0a: return SC_0;
    case 0x0b: return SC_SS;
    case 0x0c: return SC_TICK;

    case 0x10: return SC_Q;
    case 0x11: return SC_W;
    case 0x12: return SC_E;
    case 0x13: return SC_R;
    case 0x14: return SC_T;
    case 0x15: return SC_Z;
    case 0x16: return SC_U;
    case 0x17: return SC_I;
    case 0x18: return SC_O;
    case 0x19: return SC_P;
    case 0x1a: return SC_UE;
    case 0x1b: return SC_PLUS;

    case 0x62: return SC_CAPSLOCK;
    case 0x20: return SC_A;
    case 0x21: return SC_S;
    case 0x22: return SC_D;
    case 0x23: return SC_F;
    case 0x24: return SC_G;
    case 0x25: return SC_H;
    case 0x26: return SC_J;
    case 0x27: return SC_K;
    case 0x28: return SC_L;
    case 0x29: return SC_OE;
    case 0x2a: return SC_AE;
    // case 0x2b: return SC_SHARP; // @todo

    case 0x30: return SC_SMALLERGREATER;
    case 0x31: return SC_Y;
    case 0x32: return SC_X;
    case 0x33: return SC_C;
    case 0x34: return SC_V;
    case 0x35: return SC_B;
    case 0x36: return SC_N;
    case 0x37: return SC_M;
    case 0x38: return SC_COMMA;
    case 0x39: return SC_PERIOD;
    case 0x3a: return SC_MINUS;
    }

    return 0;
}
