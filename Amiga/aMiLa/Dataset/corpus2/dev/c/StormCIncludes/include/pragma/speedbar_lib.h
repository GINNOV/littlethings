#ifndef _INCLUDE_PRAGMA_SPEEDBAR_LIB_H
#define _INCLUDE_PRAGMA_SPEEDBAR_LIB_H

#ifndef CLIB_SPEEDBAR_PROTOS_H
#include <clib/speedbar_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/speedbar.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(SpeedBarBase,0x01E,SPEEDBAR_GetClass())
#pragma amicall(SpeedBarBase,0x024,AllocSpeedButtonNodeA(d0,a0))
#pragma amicall(SpeedBarBase,0x02A,FreeSpeedButtonNode(a0))
#pragma amicall(SpeedBarBase,0x030,SetSpeedButtonNodeAttrsA(a0,a1))
#pragma amicall(SpeedBarBase,0x036,GetSpeedButtonNodeAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall SpeedBarBase SPEEDBAR_GetClass    01E 00
#pragma  libcall SpeedBarBase AllocSpeedButtonNodeA 024 8002
#pragma  libcall SpeedBarBase FreeSpeedButtonNode  02A 801
#pragma  libcall SpeedBarBase SetSpeedButtonNodeAttrsA 030 9802
#pragma  libcall SpeedBarBase GetSpeedButtonNodeAttrsA 036 9802
#endif
#ifdef __STORM__
#pragma tagcall(SpeedBarBase,0x024,AllocSpeedButtonNode(d0,a0))
#pragma tagcall(SpeedBarBase,0x030,SetSpeedButtonNodeAttrs(a0,a1))
#pragma tagcall(SpeedBarBase,0x036,GetSpeedButtonNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall SpeedBarBase AllocSpeedButtonNode 024 8002
#pragma  tagcall SpeedBarBase SetSpeedButtonNodeAttrs 030 9802
#pragma  tagcall SpeedBarBase GetSpeedButtonNodeAttrs 036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_SPEEDBAR_LIB_H  */
