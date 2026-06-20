#ifndef _INCLUDE_PRAGMA_BITMAP_LIB_H
#define _INCLUDE_PRAGMA_BITMAP_LIB_H

#ifndef CLIB_BITMAP_PROTOS_H
#include <clib/bitmap_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/bitmap.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(BitMapBase,0x01E,BITMAP_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall BitMapBase BITMAP_GetClass      01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BITMAP_LIB_H  */
