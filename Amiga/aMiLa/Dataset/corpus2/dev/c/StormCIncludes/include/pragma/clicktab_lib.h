#ifndef _INCLUDE_PRAGMA_CLICKTAB_LIB_H
#define _INCLUDE_PRAGMA_CLICKTAB_LIB_H

#ifndef CLIB_CLICKTAB_PROTOS_H
#include <clib/clicktab_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/clicktab.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ClickTabBase,0x01E,CLICKTAB_GetClass())
#pragma amicall(ClickTabBase,0x024,AllocClickTabNodeA(a0))
#pragma amicall(ClickTabBase,0x02A,FreeClickTabNode(a0))
#pragma amicall(ClickTabBase,0x030,SetClickTabNodeAttrsA(a0,a1))
#pragma amicall(ClickTabBase,0x036,GetClickTabNodeAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ClickTabBase CLICKTAB_GetClass    01E 00
#pragma  libcall ClickTabBase AllocClickTabNodeA   024 801
#pragma  libcall ClickTabBase FreeClickTabNode     02A 801
#pragma  libcall ClickTabBase SetClickTabNodeAttrsA 030 9802
#pragma  libcall ClickTabBase GetClickTabNodeAttrsA 036 9802
#endif
#ifdef __STORM__
#pragma tagcall(ClickTabBase,0x024,AllocClickTabNode(a0))
#pragma tagcall(ClickTabBase,0x030,SetClickTabNodeAttrs(a0,a1))
#pragma tagcall(ClickTabBase,0x036,GetClickTabNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall ClickTabBase AllocClickTabNode    024 801
#pragma  tagcall ClickTabBase SetClickTabNodeAttrs 030 9802
#pragma  tagcall ClickTabBase GetClickTabNodeAttrs 036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CLICKTAB_LIB_H  */
