#ifndef _INCLUDE_PRAGMA_BATTCLOCK_LIB_H
#define _INCLUDE_PRAGMA_BATTCLOCK_LIB_H

#ifndef CLIB_BATTCLOCK_PROTOS_H
#include <clib/battclock_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/battclock.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(BattClockBase,0x006,ResetBattClock())
#pragma amicall(BattClockBase,0x00C,ReadBattClock())
#pragma amicall(BattClockBase,0x012,WriteBattClock(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall BattClockBase ResetBattClock       006 00
#pragma  libcall BattClockBase ReadBattClock        00C 00
#pragma  libcall BattClockBase WriteBattClock       012 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BATTCLOCK_LIB_H  */
