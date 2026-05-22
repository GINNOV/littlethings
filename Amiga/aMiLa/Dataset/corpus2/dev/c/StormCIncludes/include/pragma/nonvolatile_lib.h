#ifndef _INCLUDE_PRAGMA_NONVOLATILE_LIB_H
#define _INCLUDE_PRAGMA_NONVOLATILE_LIB_H

#ifndef CLIB_NONVOLATILE_PROTOS_H
#include <clib/nonvolatile_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/nonvolatile.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(NVBase,0x01E,GetCopyNV(a0,a1,d1))
#pragma amicall(NVBase,0x024,FreeNVData(a0))
#pragma amicall(NVBase,0x02A,StoreNV(a0,a1,a2,d0,d1))
#pragma amicall(NVBase,0x030,DeleteNV(a0,a1,d1))
#pragma amicall(NVBase,0x036,GetNVInfo(d1))
#pragma amicall(NVBase,0x03C,GetNVList(a0,d1))
#pragma amicall(NVBase,0x042,SetNVProtection(a0,a1,d2,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall NVBase GetCopyNV            01E 19803
#pragma  libcall NVBase FreeNVData           024 801
#pragma  libcall NVBase StoreNV              02A 10A9805
#pragma  libcall NVBase DeleteNV             030 19803
#pragma  libcall NVBase GetNVInfo            036 101
#pragma  libcall NVBase GetNVList            03C 1802
#pragma  libcall NVBase SetNVProtection      042 129804
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_NONVOLATILE_LIB_H  */
