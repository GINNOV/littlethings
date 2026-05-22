#ifndef _INCLUDE_PRAGMA_AHI_LIB_H
#define _INCLUDE_PRAGMA_AHI_LIB_H

#ifndef CLIB_AHI_PROTOS_H
#include <clib/ahi_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/ahi.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(AHIBase,0x02A,AHI_AllocAudioA(a1))
#pragma amicall(AHIBase,0x030,AHI_FreeAudio(a2))
#pragma amicall(AHIBase,0x036,AHI_KillAudio())
#pragma amicall(AHIBase,0x03C,AHI_ControlAudioA(a2,a1))
#pragma amicall(AHIBase,0x042,AHI_SetVol(d0,d1,d2,a2,d3))
#pragma amicall(AHIBase,0x048,AHI_SetFreq(d0,d1,a2,d2))
#pragma amicall(AHIBase,0x04E,AHI_SetSound(d0,d1,d2,d3,a2,d4))
#pragma amicall(AHIBase,0x054,AHI_SetEffect(a0,a2))
#pragma amicall(AHIBase,0x05A,AHI_LoadSound(d0,d1,a0,a2))
#pragma amicall(AHIBase,0x060,AHI_UnloadSound(d0,a2))
#pragma amicall(AHIBase,0x066,AHI_NextAudioID(d0))
#pragma amicall(AHIBase,0x06C,AHI_GetAudioAttrsA(d0,a2,a1))
#pragma amicall(AHIBase,0x072,AHI_BestAudioIDA(a1))
#pragma amicall(AHIBase,0x078,AHI_AllocAudioRequestA(a0))
#pragma amicall(AHIBase,0x07E,AHI_AudioRequestA(a0,a1))
#pragma amicall(AHIBase,0x084,AHI_FreeAudioRequest(a0))
#pragma amicall(AHIBase,0x08A,AHI_PlayA(a2,a1))
#pragma amicall(AHIBase,0x090,AHI_SampleFrameSize(d0))
#pragma amicall(AHIBase,0x096,AHI_AddAudioMode(a0))
#pragma amicall(AHIBase,0x09C,AHI_RemoveAudioMode(d0))
#pragma amicall(AHIBase,0x0A2,AHI_LoadModeFile(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall AHIBase AHI_AllocAudioA      02A 901
#pragma  libcall AHIBase AHI_FreeAudio        030 A01
#pragma  libcall AHIBase AHI_KillAudio        036 00
#pragma  libcall AHIBase AHI_ControlAudioA    03C 9A02
#pragma  libcall AHIBase AHI_SetVol           042 3A21005
#pragma  libcall AHIBase AHI_SetFreq          048 2A1004
#pragma  libcall AHIBase AHI_SetSound         04E 4A321006
#pragma  libcall AHIBase AHI_SetEffect        054 A802
#pragma  libcall AHIBase AHI_LoadSound        05A A81004
#pragma  libcall AHIBase AHI_UnloadSound      060 A002
#pragma  libcall AHIBase AHI_NextAudioID      066 001
#pragma  libcall AHIBase AHI_GetAudioAttrsA   06C 9A003
#pragma  libcall AHIBase AHI_BestAudioIDA     072 901
#pragma  libcall AHIBase AHI_AllocAudioRequestA 078 801
#pragma  libcall AHIBase AHI_AudioRequestA    07E 9802
#pragma  libcall AHIBase AHI_FreeAudioRequest 084 801
#pragma  libcall AHIBase AHI_PlayA            08A 9A02
#pragma  libcall AHIBase AHI_SampleFrameSize  090 001
#pragma  libcall AHIBase AHI_AddAudioMode     096 801
#pragma  libcall AHIBase AHI_RemoveAudioMode  09C 001
#pragma  libcall AHIBase AHI_LoadModeFile     0A2 801
#endif
#ifdef __STORM__
#pragma tagcall(AHIBase,0x02A,AHI_AllocAudio(a1))
#pragma tagcall(AHIBase,0x03C,AHI_ControlAudio(a2,a1))
#pragma tagcall(AHIBase,0x06C,AHI_GetAudioAttrs(d0,a2,a1))
#pragma tagcall(AHIBase,0x072,AHI_BestAudioID(a1))
#pragma tagcall(AHIBase,0x078,AHI_AllocAudioRequest(a0))
#pragma tagcall(AHIBase,0x07E,AHI_AudioRequest(a0,a1))
#pragma tagcall(AHIBase,0x08A,AHI_Play(a2,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall AHIBase AHI_AllocAudio       02A 901
#pragma  tagcall AHIBase AHI_ControlAudio     03C 9A02
#pragma  tagcall AHIBase AHI_GetAudioAttrs    06C 9A003
#pragma  tagcall AHIBase AHI_BestAudioID      072 901
#pragma  tagcall AHIBase AHI_AllocAudioRequest 078 801
#pragma  tagcall AHIBase AHI_AudioRequest     07E 9802
#pragma  tagcall AHIBase AHI_Play             08A 9A02
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_AHI_LIB_H  */
