/* $VER: dinclude:pragmas/lowlevel_pragmas.h 1.0 (15.8.98) */
#ifndef LowLevelBase_PRAGMA_H
#define LowLevelBase_PRAGMA_H

#pragma libcall LowLevelBase ReadJoyPort 1e 001
#pragma libcall LowLevelBase GetLanguageSelection 24 00
#pragma libcall LowLevelBase GetKey 30 00
#pragma libcall LowLevelBase QueryKeys 36 1802
#pragma libcall LowLevelBase AddKBInt 3c 9802
#pragma libcall LowLevelBase RemKBInt 42 901
#pragma libcall LowLevelBase SystemControlA 48 901
#pragma libcall LowLevelBase AddTimerInt 4e 9802
#pragma libcall LowLevelBase RemTimerInt 54 901
#pragma libcall LowLevelBase StopTimerInt 5a 901
#pragma libcall LowLevelBase StartTimerInt 60 10903
#pragma libcall LowLevelBase ElapsedTime 66 801
#pragma libcall LowLevelBase AddVBlankInt 6c 9802
#pragma libcall LowLevelBase RemVBlankInt 72 901
#pragma libcall LowLevelBase SetJoyPortAttrsA 84 9002

#endif
