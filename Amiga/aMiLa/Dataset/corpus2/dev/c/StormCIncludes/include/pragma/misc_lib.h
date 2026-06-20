#ifndef _INCLUDE_PRAGMA_MISC_LIB_H
#define _INCLUDE_PRAGMA_MISC_LIB_H

#ifndef CLIB_MISC_PROTOS_H
#include <clib/misc_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/misc.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MiscBase,0x006,AllocMiscResource(d0,a1))
#pragma amicall(MiscBase,0x00C,FreeMiscResource(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MiscBase AllocMiscResource    006 9002
#pragma  libcall MiscBase FreeMiscResource     00C 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MISC_LIB_H  */
