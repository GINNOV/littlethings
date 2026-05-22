#ifndef _INCLUDE_PRAGMA_VIRTUAL_LIB_H
#define _INCLUDE_PRAGMA_VIRTUAL_LIB_H

#ifndef CLIB_VIRTUAL_PROTOS_H
#include <clib/virtual_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/virtual.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(VirtualBase, 0x1E, VIRTUAL_GetClass())
#pragma amicall(VirtualBase, 0x24, RefreshVirtualGadget(a0,a1,a2,a3))
#pragma amicall(VirtualBase, 0x2A, RethinkVirtualSize(a0,a1,a2,a3,d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall VirtualBase VIRTUAL_GetClass     01E 00
#pragma  libcall VirtualBase RefreshVirtualGadget 024 BA9804
#pragma  libcall VirtualBase RethinkVirtualSize   02A BA9805
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LAYOUT_LIB_H  */
