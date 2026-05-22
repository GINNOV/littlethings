#ifndef _INCLUDE_PRAGMA_DISK_LIB_H
#define _INCLUDE_PRAGMA_DISK_LIB_H

#ifndef CLIB_DISK_PROTOS_H
#include <clib/disk_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/disk.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DiskBase,0x006,AllocUnit(d0))
#pragma amicall(DiskBase,0x00C,FreeUnit(d0))
#pragma amicall(DiskBase,0x012,GetUnit(a1))
#pragma amicall(DiskBase,0x018,GiveUnit())
#pragma amicall(DiskBase,0x01E,GetUnitID(d0))
#pragma amicall(DiskBase,0x024,ReadUnitID(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DiskBase AllocUnit            006 001
#pragma  libcall DiskBase FreeUnit             00C 001
#pragma  libcall DiskBase GetUnit              012 901
#pragma  libcall DiskBase GiveUnit             018 00
#pragma  libcall DiskBase GetUnitID            01E 001
#pragma  libcall DiskBase ReadUnitID           024 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DISK_LIB_H  */
