#ifndef _INCLUDE_PRAGMA_REALTIME_LIB_H
#define _INCLUDE_PRAGMA_REALTIME_LIB_H

#ifndef CLIB_REALTIME_PROTOS_H
#include <clib/realtime_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/realtime.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RealTimeBase,0x01E,LockRealTime(d0))
#pragma amicall(RealTimeBase,0x024,UnlockRealTime(a0))
#pragma amicall(RealTimeBase,0x02A,CreatePlayerA(a0))
#pragma amicall(RealTimeBase,0x030,DeletePlayer(a0))
#pragma amicall(RealTimeBase,0x036,SetPlayerAttrsA(a0,a1))
#pragma amicall(RealTimeBase,0x03C,SetConductorState(a0,d0,d1))
#pragma amicall(RealTimeBase,0x042,ExternalSync(a0,d0,d1))
#pragma amicall(RealTimeBase,0x048,NextConductor(a0))
#pragma amicall(RealTimeBase,0x04E,FindConductor(a0))
#pragma amicall(RealTimeBase,0x054,GetPlayerAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RealTimeBase LockRealTime         01E 001
#pragma  libcall RealTimeBase UnlockRealTime       024 801
#pragma  libcall RealTimeBase CreatePlayerA        02A 801
#pragma  libcall RealTimeBase DeletePlayer         030 801
#pragma  libcall RealTimeBase SetPlayerAttrsA      036 9802
#pragma  libcall RealTimeBase SetConductorState    03C 10803
#pragma  libcall RealTimeBase ExternalSync         042 10803
#pragma  libcall RealTimeBase NextConductor        048 801
#pragma  libcall RealTimeBase FindConductor        04E 801
#pragma  libcall RealTimeBase GetPlayerAttrsA      054 9802
#endif
#ifdef __STORM__
#pragma tagcall(RealTimeBase,0x02A,CreatePlayer(a0))
#pragma tagcall(RealTimeBase,0x036,SetPlayerAttrs(a0,a1))
#pragma tagcall(RealTimeBase,0x054,GetPlayerAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall RealTimeBase CreatePlayer         02A 801
#pragma  tagcall RealTimeBase SetPlayerAttrs       036 9802
#pragma  tagcall RealTimeBase GetPlayerAttrs       054 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_REALTIME_LIB_H  */
