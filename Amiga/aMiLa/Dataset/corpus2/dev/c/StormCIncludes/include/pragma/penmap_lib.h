#ifndef _INCLUDE_PRAGMA_PENMAP_LIB_H
#define _INCLUDE_PRAGMA_PENMAP_LIB_H

#ifndef CLIB_PENMAP_PROTOS_H
#include <clib/penmap_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/penmap.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(PenMapBase,0x01E,PENMAP_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall PenMapBase PENMAP_GetClass      01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_PENMAP_LIB_H  */
