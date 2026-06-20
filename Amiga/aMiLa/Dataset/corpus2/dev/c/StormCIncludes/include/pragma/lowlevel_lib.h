#ifndef _INCLUDE_PRAGMA_LOWLEVEL_LIB_H
#define _INCLUDE_PRAGMA_LOWLEVEL_LIB_H

#ifndef CLIB_LOWLEVEL_PROTOS_H
#include <clib/lowlevel_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/lowlevel.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(LowLevelBase,0x01E,ReadJoyPort(d0))
#pragma amicall(LowLevelBase,0x024,GetLanguageSelection())
#pragma amicall(LowLevelBase,0x030,GetKey())
#pragma amicall(LowLevelBase,0x036,QueryKeys(a0,d1))
#pragma amicall(LowLevelBase,0x03C,AddKBInt(a0,a1))
#pragma amicall(LowLevelBase,0x042,RemKBInt(a1))
#pragma amicall(LowLevelBase,0x048,SystemControlA(a1))
#pragma amicall(LowLevelBase,0x04E,AddTimerInt(a0,a1))
#pragma amicall(LowLevelBase,0x054,RemTimerInt(a1))
#pragma amicall(LowLevelBase,0x05A,StopTimerInt(a1))
#pragma amicall(LowLevelBase,0x060,StartTimerInt(a1,d0,d1))
#pragma amicall(LowLevelBase,0x066,ElapsedTime(a0))
#pragma amicall(LowLevelBase,0x06C,AddVBlankInt(a0,a1))
#pragma amicall(LowLevelBase,0x072,RemVBlankInt(a1))
#pragma amicall(LowLevelBase,0x084,SetJoyPortAttrsA(d0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall LowLevelBase ReadJoyPort          01E 001
#pragma  libcall LowLevelBase GetLanguageSelection 024 00
#pragma  libcall LowLevelBase GetKey               030 00
#pragma  libcall LowLevelBase QueryKeys            036 1802
#pragma  libcall LowLevelBase AddKBInt             03C 9802
#pragma  libcall LowLevelBase RemKBInt             042 901
#pragma  libcall LowLevelBase SystemControlA       048 901
#pragma  libcall LowLevelBase AddTimerInt          04E 9802
#pragma  libcall LowLevelBase RemTimerInt          054 901
#pragma  libcall LowLevelBase StopTimerInt         05A 901
#pragma  libcall LowLevelBase StartTimerInt        060 10903
#pragma  libcall LowLevelBase ElapsedTime          066 801
#pragma  libcall LowLevelBase AddVBlankInt         06C 9802
#pragma  libcall LowLevelBase RemVBlankInt         072 901
#pragma  libcall LowLevelBase SetJoyPortAttrsA     084 9002
#endif
#ifdef __STORM__
#pragma tagcall(LowLevelBase,0x048,SystemControl(a1))
#pragma tagcall(LowLevelBase,0x084,SetJoyPortAttrs(d0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall LowLevelBase SystemControl        048 901
#pragma  tagcall LowLevelBase SetJoyPortAttrs      084 9002
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LOWLEVEL_LIB_H  */
