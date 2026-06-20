#ifndef _INCLUDE_PRAGMA_DTCLASS_LIB_H
#define _INCLUDE_PRAGMA_DTCLASS_LIB_H

#ifndef CLIB_DTCLASS_PROTOS_H
#include <clib/dtclass_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/dtclass.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DTClassBase,0x01E,ObtainEngine())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DTClassBase ObtainEngine         01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DTCLASS_LIB_H  */
