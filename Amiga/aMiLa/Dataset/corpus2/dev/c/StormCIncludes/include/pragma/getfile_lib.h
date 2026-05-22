#ifndef _INCLUDE_PRAGMA_GETFILE_LIB_H
#define _INCLUDE_PRAGMA_GETFILE_LIB_H

#ifndef CLIB_GETFILE_PROTOS_H
#include <clib/getfile_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/getfile.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GetFileBase,0x01E,GETFILE_GetClass())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GetFileBase GETFILE_GetClass     01E 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_GETFILE_LIB_H  */
