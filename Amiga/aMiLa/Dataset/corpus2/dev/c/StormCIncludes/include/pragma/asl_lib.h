#ifndef _INCLUDE_PRAGMA_ASL_LIB_H
#define _INCLUDE_PRAGMA_ASL_LIB_H

#ifndef CLIB_ASL_PROTOS_H
#include <clib/asl_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/asl.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(AslBase,0x01E,AllocFileRequest())
#pragma amicall(AslBase,0x024,FreeFileRequest(a0))
#pragma amicall(AslBase,0x02A,RequestFile(a0))
#pragma amicall(AslBase,0x030,AllocAslRequest(d0,a0))
#pragma amicall(AslBase,0x036,FreeAslRequest(a0))
#pragma amicall(AslBase,0x03C,AslRequest(a0,a1))
#pragma amicall(AslBase,0x04E,AbortAslRequest(a0))
#pragma amicall(AslBase,0x054,ActivateAslRequest(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall AslBase AllocFileRequest     01E 00
#pragma  libcall AslBase FreeFileRequest      024 801
#pragma  libcall AslBase RequestFile          02A 801
#pragma  libcall AslBase AllocAslRequest      030 8002
#pragma  libcall AslBase FreeAslRequest       036 801
#pragma  libcall AslBase AslRequest           03C 9802
#pragma  libcall AslBase AbortAslRequest      04E 801
#pragma  libcall AslBase ActivateAslRequest   054 801
#endif
#ifdef __STORM__
#pragma tagcall(AslBase,0x030,AllocAslRequestTags(d0,a0))
#pragma tagcall(AslBase,0x03C,AslRequestTags(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall AslBase AllocAslRequestTags  030 8002
#pragma  tagcall AslBase AslRequestTags       03C 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_ASL_LIB_H  */
