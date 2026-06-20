#ifndef APP_RawKeyDecoder_H
#define APP_RawKeyDecoder_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/RawKeyDecoder.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <devices/inputevent.h>
}


class IntuiMessageC;
/*******************************************************************************

      « RawKeyDecoder class »

   A RawKeyDecoder object takes a single IntuiMessageC object of CLASS_RAWKEY 
   and decodes the rawkey codes within.
   One object need to be created once to decode all incoming messages with the 
   method 'decode(IntuiMessageC*)' which fills in the corresponding key code 
   and qualifier. These can be read with the methods 'qualifier()' and 'key()'. 
   The return values are from the enumeration types listed below.
   With Kickstart® 2.0 IDCMP_RAWKEY and IDCMP_VANILLAKEY can be specified both, 
   which is recommended to be done. Only the keystrokes that have no vanilla 
   key need to be decoded with a RawKeyDecoder.

 ******************************************************************************/

// enumeration types for type safety reasons
enum RKD_IEQualifier // returned by ::qualifier()
{
   LEFTSHIFT = IEQUALIFIER_LSHIFT,
   RIGHTSHIFT = IEQUALIFIER_RSHIFT,
   CAPSLOCK = IEQUALIFIER_CAPSLOCK,
   CONTROL = IEQUALIFIER_CONTROL,
   LEFTALT = IEQUALIFIER_LALT,
   RIGHTALT = IEQUALIFIER_RALT,
   LEFTCOMMAND = IEQUALIFIER_LCOMMAND,
   RIGHTCOMMAND = IEQUALIFIER_RCOMMAND,
   NUMERICPAD = IEQUALIFIER_NUMERICPAD,
   REPEAT = IEQUALIFIER_REPEAT,
   RKDQ_EMPTY = 65535
};
enum RKD_KeyCode  // returned by ::key()
{
   CURSOR_UP  =     'A',
   CURSOR_DOWN =    'B',
   CURSOR_RIGHT =   'C',
   CURSOR_LEFT =    'D',
   KEY_F1 = 0,
   KEY_F2,
   KEY_F3,
   KEY_F4,
   KEY_F5,
   KEY_F6,
   KEY_F7,
   KEY_F8,
   KEY_F9,
   KEY_F10,
   HELP,
   // add further codes here
   RKDC_EMPTY = 65535
};

class RawKeyDecoder
{
   public:
      RawKeyDecoder();
      RawKeyDecoder(const IntuiMessageC* imsg);

      BOOL isEmpty()
         { return (keycode==RKDC_EMPTY); }
      void clear()
         {  keyQualifier = RKDQ_EMPTY; keycode = RKDC_EMPTY; }

      void decode(const IntuiMessageC* imsg);
      // have an incoming IntuiMessageC decoded

      // after decoding read the result
      RKD_IEQualifier qualifier()
         { return keyQualifier; }
      RKD_KeyCode key()
         { return keycode; }

   private:
      RKD_IEQualifier keyQualifier;
      RKD_KeyCode keycode;
};
#endif
