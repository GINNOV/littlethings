#ifndef _INCLUDE_PRAGMA_POPCYCLE_LIB_H
#define _INCLUDE_PRAGMA_POPCYCLE_LIB_H

#ifndef CLIB_POPCYCLE_PROTOS_H
#include <clib/popcycle_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/popcycle.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(PopCycleBase,0x01E,POPCYCLE_GetClass())
#pragma amicall(PopCycleBase,0x024,AllocPopCycleNodeA(a0))
#pragma amicall(PopCycleBase,0x02A,FreePopCycleNode(a0))
#pragma amicall(PopCycleBase,0x030,SetPopCycleNodeAttrsA(a0,a1))
#pragma amicall(PopCycleBase,0x036,GetPopCycleNodeAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall PopCycleBase POPCYCLE_GetClass    01E 00
#pragma  libcall PopCycleBase AllocPopCycleNodeA   024 801
#pragma  libcall PopCycleBase FreePopCycleNode     02A 801
#pragma  libcall PopCycleBase SetPopCycleNodeAttrsA 030 9802
#pragma  libcall PopCycleBase GetPopCycleNodeAttrsA 036 9802
#endif
#ifdef __STORM__
#pragma tagcall(PopCycleBase,0x024,AllocPopCycleNode(a0))
#pragma tagcall(PopCycleBase,0x030,SetPopCycleNodeAttrs(a0,a1))
#pragma tagcall(PopCycleBase,0x036,GetPopCycleNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall PopCycleBase AllocPopCycleNode    024 801
#pragma  tagcall PopCycleBase SetPopCycleNodeAttrs 030 9802
#pragma  tagcall PopCycleBase GetPopCycleNodeAttrs 036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_POPCYCLE_LIB_H  */
