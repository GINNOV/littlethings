#ifndef _INCLUDE_PRAGMA_RAMDRIVE_LIB_H
#define _INCLUDE_PRAGMA_RAMDRIVE_LIB_H

#ifndef CLIB_RAMDRIVE_PROTOS_H
#include <clib/ramdrive_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/ramdrive.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RamdriveDevice,0x02A,KillRAD0())
#pragma amicall(RamdriveDevice,0x030,KillRAD(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RamdriveDevice KillRAD0             02A 00
#pragma  libcall RamdriveDevice KillRAD              030 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_RAMDRIVE_LIB_H  */
