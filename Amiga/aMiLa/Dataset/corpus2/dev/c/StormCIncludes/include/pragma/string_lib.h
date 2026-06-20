#ifndef _INCLUDE_PRAGMA_STRING_LIB_H
#define _INCLUDE_PRAGMA_STRING_LIB_H

#ifndef CLIB_STRING_PROTOS_H
#include <clib/string_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/string.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(StringBase,0x01E,STRING_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall StringBase STRING_GetClass      01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_STRING_LIB_H  */
