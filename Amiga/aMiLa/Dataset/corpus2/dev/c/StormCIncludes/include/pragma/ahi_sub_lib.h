#ifndef _INCLUDE_PRAGMA_AHI_SUB_LIB_H
#define _INCLUDE_PRAGMA_AHI_SUB_LIB_H

#ifndef CLIB_AHI_SUB_PROTOS_H
#include <clib/ahi_sub_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/ahi_sub.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(AHIsubBase,0x01E,AHIsub_AllocAudio(a1,a2))
#pragma amicall(AHIsubBase,0x024,AHIsub_FreeAudio(a2))
#pragma amicall(AHIsubBase,0x02A,AHIsub_Disable(a2))
#pragma amicall(AHIsubBase,0x030,AHIsub_Enable(a2))
#pragma amicall(AHIsubBase,0x036,AHIsub_Start(d0,a2))
#pragma amicall(AHIsubBase,0x03C,AHIsub_Update(d0,a2))
#pragma amicall(AHIsubBase,0x042,AHIsub_Stop(d0,a2))
#pragma amicall(AHIsubBase,0x048,AHIsub_SetVol(d0,d1,d2,a2,d3))
#pragma amicall(AHIsubBase,0x04E,AHIsub_SetFreq(d0,d1,a2,d2))
#pragma amicall(AHIsubBase,0x054,AHIsub_SetSound(d0,d1,d2,d3,a2,d4))
#pragma amicall(AHIsubBase,0x05A,AHIsub_SetEffect(a0,a2))
#pragma amicall(AHIsubBase,0x060,AHIsub_LoadSound(d0,d1,a0,a2))
#pragma amicall(AHIsubBase,0x066,AHIsub_UnloadSound(d0,a2))
#pragma amicall(AHIsubBase,0x06C,AHIsub_GetAttr(d0,d1,d2,a1,a2))
#pragma amicall(AHIsubBase,0x072,AHIsub_HardwareControl(d0,d1,a2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall AHIsubBase AHIsub_AllocAudio    01E A902
#pragma  libcall AHIsubBase AHIsub_FreeAudio     024 A01
#pragma  libcall AHIsubBase AHIsub_Disable       02A A01
#pragma  libcall AHIsubBase AHIsub_Enable        030 A01
#pragma  libcall AHIsubBase AHIsub_Start         036 A002
#pragma  libcall AHIsubBase AHIsub_Update        03C A002
#pragma  libcall AHIsubBase AHIsub_Stop          042 A002
#pragma  libcall AHIsubBase AHIsub_SetVol        048 3A21005
#pragma  libcall AHIsubBase AHIsub_SetFreq       04E 2A1004
#pragma  libcall AHIsubBase AHIsub_SetSound      054 4A321006
#pragma  libcall AHIsubBase AHIsub_SetEffect     05A A802
#pragma  libcall AHIsubBase AHIsub_LoadSound     060 A81004
#pragma  libcall AHIsubBase AHIsub_UnloadSound   066 A002
#pragma  libcall AHIsubBase AHIsub_GetAttr       06C A921005
#pragma  libcall AHIsubBase AHIsub_HardwareControl 072 A1003
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_AHI_SUB_LIB_H  */
