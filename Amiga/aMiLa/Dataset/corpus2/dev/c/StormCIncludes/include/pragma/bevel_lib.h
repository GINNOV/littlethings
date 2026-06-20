#ifndef _INCLUDE_PRAGMA_BEVEL_LIB_H
#define _INCLUDE_PRAGMA_BEVEL_LIB_H

#ifndef CLIB_BEVEL_PROTOS_H
#include <clib/bevel_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/bevel.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(BevelBase,0x01E,BEVEL_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall BevelBase BEVEL_GetClass       01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_BEVEL_LIB_H  */
