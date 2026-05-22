#ifndef _INCLUDE_PRAGMA_LAYOUT_LIB_H
#define _INCLUDE_PRAGMA_LAYOUT_LIB_H

#ifndef CLIB_LAYOUT_PROTOS_H
#include <clib/layout_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/layout.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(LayoutBase,0x01E,LAYOUT_GetClass())
#pragma amicall(LayoutBase,0x024,ActivateLayoutGadget(a0,a1,a2,d0))
#pragma amicall(LayoutBase,0x02A,FlushLayoutDomainCache(a0))
#pragma amicall(LayoutBase,0x030,RethinkLayout(a0,a1,a2,d0))
#pragma amicall(LayoutBase,0x036,LayoutLimits(a0,a1,a2,a3))
#pragma amicall(LayoutBase,0x03C,PAGE_GetClass())
#pragma amicall(LayoutBase,0x042,SetPageGadgetAttrsA(a0,a1,a2,a3,a4))
#pragma amicall(LayoutBase,0x048,RefreshPageGadget(a0,a1,a2,a3))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall LayoutBase LAYOUT_GetClass      01E 00
#pragma  libcall LayoutBase ActivateLayoutGadget 024 0A9804
#pragma  libcall LayoutBase FlushLayoutDomainCache 02A 801
#pragma  libcall LayoutBase RethinkLayout        030 0A9804
#pragma  libcall LayoutBase LayoutLimits         036 BA9804
#pragma  libcall LayoutBase PAGE_GetClass        03C 00
#pragma  libcall LayoutBase SetPageGadgetAttrsA  042 CBA9805
#pragma  libcall LayoutBase RefreshPageGadget    048 BA9804
#endif
#ifdef __STORM__
#pragma tagcall(LayoutBase,0x042,SetPageGadgetAttrs(a0,a1,a2,a3,a4))
#endif
#ifdef __SASC_60
#pragma  tagcall LayoutBase SetPageGadgetAttrs   042 CBA9805
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LAYOUT_LIB_H  */
