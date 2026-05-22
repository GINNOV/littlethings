#ifndef _INCLUDE_PRAGMA_CIA_LIB_H
#define _INCLUDE_PRAGMA_CIA_LIB_H

#ifndef CLIB_CIA_PROTOS_H
#include <clib/cia_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/cia.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(CIABase,0x006,AddICRVector(d0,a1))
#pragma amicall(CIABase,0x00C,RemICRVector(d0,a1))
#pragma amicall(CIABase,0x012,AbleICR(d0))
#pragma amicall(CIABase,0x018,SetICR(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall CIABase AddICRVector         006 9002
#pragma  libcall CIABase RemICRVector         00C 9002
#pragma  libcall CIABase AbleICR              012 001
#pragma  libcall CIABase SetICR               018 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CIA_LIB_H  */
