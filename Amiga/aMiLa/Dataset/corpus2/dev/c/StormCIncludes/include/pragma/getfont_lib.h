#ifndef _INCLUDE_PRAGMA_GETFONT_LIB_H
#define _INCLUDE_PRAGMA_GETFONT_LIB_H

#ifndef CLIB_GETFONT_PROTOS_H
#include <clib/getfont_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/getfont.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GetFontBase,0x01E,GETFONT_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GetFontBase GETFONT_GetClass     01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_GETFONT_LIB_H  */
