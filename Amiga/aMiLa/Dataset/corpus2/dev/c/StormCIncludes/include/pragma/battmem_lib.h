#ifndef _INCLUDE_PRAGMA_BATTMEM_LIB_H
#define _INCLUDE_PRAGMA_BATTMEM_LIB_H

#ifndef CLIB_BATTMEM_PROTOS_H
#include <clib/battmem_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/battmem.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(BattMemBase,0x006,ObtainBattSemaphore())
#pragma amicall(BattMemBase,0x00C,ReleaseBattSemaphore())
#pragma amicall(BattMemBase,0x012,ReadBattMem(a0,d0,d1))
#pragma amicall(BattMemBase,0x018,WriteBattMem(a0,d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall BattMemBase ObtainBattSemaphore  006 00
#pragma  libcall BattMemBase ReleaseBattSemaphore 00C 00
#pragma  libcall BattMemBase ReadBattMem          012 10803
#pragma  libcall BattMemBase WriteBattMem         018 10803
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BATTMEM_LIB_H  */
