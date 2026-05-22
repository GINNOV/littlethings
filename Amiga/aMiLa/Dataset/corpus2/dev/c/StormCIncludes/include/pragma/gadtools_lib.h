#ifndef _INCLUDE_PRAGMA_GADTOOLS_LIB_H
#define _INCLUDE_PRAGMA_GADTOOLS_LIB_H

#ifndef CLIB_GADTOOLS_PROTOS_H
#include <clib/gadtools_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/gadtools.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GadToolsBase,0x01E,CreateGadgetA(d0,a0,a1,a2))
#pragma amicall(GadToolsBase,0x024,FreeGadgets(a0))
#pragma amicall(GadToolsBase,0x02A,GT_SetGadgetAttrsA(a0,a1,a2,a3))
#pragma amicall(GadToolsBase,0x030,CreateMenusA(a0,a1))
#pragma amicall(GadToolsBase,0x036,FreeMenus(a0))
#pragma amicall(GadToolsBase,0x03C,LayoutMenuItemsA(a0,a1,a2))
#pragma amicall(GadToolsBase,0x042,LayoutMenusA(a0,a1,a2))
#pragma amicall(GadToolsBase,0x048,GT_GetIMsg(a0))
#pragma amicall(GadToolsBase,0x04E,GT_ReplyIMsg(a1))
#pragma amicall(GadToolsBase,0x054,GT_RefreshWindow(a0,a1))
#pragma amicall(GadToolsBase,0x05A,GT_BeginRefresh(a0))
#pragma amicall(GadToolsBase,0x060,GT_EndRefresh(a0,d0))
#pragma amicall(GadToolsBase,0x066,GT_FilterIMsg(a1))
#pragma amicall(GadToolsBase,0x06C,GT_PostFilterIMsg(a1))
#pragma amicall(GadToolsBase,0x072,CreateContext(a0))
#pragma amicall(GadToolsBase,0x078,DrawBevelBoxA(a0,d0,d1,d2,d3,a1))
#pragma amicall(GadToolsBase,0x07E,GetVisualInfoA(a0,a1))
#pragma amicall(GadToolsBase,0x084,FreeVisualInfo(a0))
#pragma amicall(GadToolsBase,0x0AE,GT_GetGadgetAttrsA(a0,a1,a2,a3))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GadToolsBase CreateGadgetA        01E A98004
#pragma  libcall GadToolsBase FreeGadgets          024 801
#pragma  libcall GadToolsBase GT_SetGadgetAttrsA   02A BA9804
#pragma  libcall GadToolsBase CreateMenusA         030 9802
#pragma  libcall GadToolsBase FreeMenus            036 801
#pragma  libcall GadToolsBase LayoutMenuItemsA     03C A9803
#pragma  libcall GadToolsBase LayoutMenusA         042 A9803
#pragma  libcall GadToolsBase GT_GetIMsg           048 801
#pragma  libcall GadToolsBase GT_ReplyIMsg         04E 901
#pragma  libcall GadToolsBase GT_RefreshWindow     054 9802
#pragma  libcall GadToolsBase GT_BeginRefresh      05A 801
#pragma  libcall GadToolsBase GT_EndRefresh        060 0802
#pragma  libcall GadToolsBase GT_FilterIMsg        066 901
#pragma  libcall GadToolsBase GT_PostFilterIMsg    06C 901
#pragma  libcall GadToolsBase CreateContext        072 801
#pragma  libcall GadToolsBase DrawBevelBoxA        078 93210806
#pragma  libcall GadToolsBase GetVisualInfoA       07E 9802
#pragma  libcall GadToolsBase FreeVisualInfo       084 801
#pragma  libcall GadToolsBase GT_GetGadgetAttrsA   0AE BA9804
#endif
#ifdef __STORM__
#pragma tagcall(GadToolsBase,0x01E,CreateGadget(d0,a0,a1,a2))
#pragma tagcall(GadToolsBase,0x02A,GT_SetGadgetAttrs(a0,a1,a2,a3))
#pragma tagcall(GadToolsBase,0x030,CreateMenus(a0,a1))
#pragma tagcall(GadToolsBase,0x03C,LayoutMenuItems(a0,a1,a2))
#pragma tagcall(GadToolsBase,0x042,LayoutMenus(a0,a1,a2))
#pragma tagcall(GadToolsBase,0x078,DrawBevelBox(a0,d0,d1,d2,d3,a1))
#pragma tagcall(GadToolsBase,0x07E,GetVisualInfo(a0,a1))
#pragma tagcall(GadToolsBase,0x0AE,GT_GetGadgetAttrs(a0,a1,a2,a3))
#endif
#ifdef __SASC_60
#pragma  tagcall GadToolsBase CreateGadget         01E A98004
#pragma  tagcall GadToolsBase GT_SetGadgetAttrs    02A BA9804
#pragma  tagcall GadToolsBase CreateMenus          030 9802
#pragma  tagcall GadToolsBase LayoutMenuItems      03C A9803
#pragma  tagcall GadToolsBase LayoutMenus          042 A9803
#pragma  tagcall GadToolsBase DrawBevelBox         078 93210806
#pragma  tagcall GadToolsBase GetVisualInfo        07E 9802
#pragma  tagcall GadToolsBase GT_GetGadgetAttrs    0AE BA9804
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_GADTOOLS_LIB_H  */
