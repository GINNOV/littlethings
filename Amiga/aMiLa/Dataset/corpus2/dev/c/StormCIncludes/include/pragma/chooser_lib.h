#ifndef _INCLUDE_PRAGMA_CHOOSER_LIB_H
#define _INCLUDE_PRAGMA_CHOOSER_LIB_H

#ifndef CLIB_CHOOSER_PROTOS_H
#include <clib/chooser_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/chooser.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ChooserBase,0x01E,CHOOSER_GetClass())
#pragma amicall(ChooserBase,0x024,AllocChooserNodeA(a0))
#pragma amicall(ChooserBase,0x02A,FreeChooserNode(a0))
#pragma amicall(ChooserBase,0x030,SetChooserNodeAttrsA(a0,a1))
#pragma amicall(ChooserBase,0x036,GetChooserNodeAttrsA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ChooserBase CHOOSER_GetClass     01E 00
#pragma  libcall ChooserBase AllocChooserNodeA    024 801
#pragma  libcall ChooserBase FreeChooserNode      02A 801
#pragma  libcall ChooserBase SetChooserNodeAttrsA 030 9802
#pragma  libcall ChooserBase GetChooserNodeAttrsA 036 9802
#endif
#ifdef __STORM__
#pragma tagcall(ChooserBase,0x024,AllocChooserNode(a0))
#pragma tagcall(ChooserBase,0x030,SetChooserNodeAttrs(a0,a1))
#pragma tagcall(ChooserBase,0x036,GetChooserNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall ChooserBase AllocChooserNode     024 801
#pragma  tagcall ChooserBase SetChooserNodeAttrs  030 9802
#pragma  tagcall ChooserBase GetChooserNodeAttrs  036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CHOOSER_LIB_H  */
