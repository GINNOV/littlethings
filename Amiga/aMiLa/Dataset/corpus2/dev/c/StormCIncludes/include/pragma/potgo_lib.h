#ifndef _INCLUDE_PRAGMA_POTGO_LIB_H
#define _INCLUDE_PRAGMA_POTGO_LIB_H

#ifndef CLIB_POTGO_PROTOS_H
#include <clib/potgo_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/potgo.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(PotgoBase,0x006,AllocPotBits(d0))
#pragma amicall(PotgoBase,0x00C,FreePotBits(d0))
#pragma amicall(PotgoBase,0x012,WritePotgo(d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall PotgoBase AllocPotBits         006 001
#pragma  libcall PotgoBase FreePotBits          00C 001
#pragma  libcall PotgoBase WritePotgo           012 1002
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_POTGO_LIB_H  */
