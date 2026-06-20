#ifndef _INCLUDE_PRAGMA_LISTBROWSER_LIB_H
#define _INCLUDE_PRAGMA_LISTBROWSER_LIB_H

#ifndef CLIB_LISTBROWSER_PROTOS_H
#include <clib/listbrowser_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/listbrowser.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ListBrowserBase,0x01E,LISTBROWSER_GetClass())
#pragma amicall(ListBrowserBase,0x024,AllocListBrowserNodeA(d0,a0))
#pragma amicall(ListBrowserBase,0x02A,FreeListBrowserNode(a0))
#pragma amicall(ListBrowserBase,0x030,SetListBrowserNodeAttrsA(a0,a1))
#pragma amicall(ListBrowserBase,0x036,GetListBrowserNodeAttrsA(a0,a1))
#pragma amicall(ListBrowserBase,0x03C,ListBrowserSelectAll(a0))
#pragma amicall(ListBrowserBase,0x042,ShowListBrowserNodeChildren(a0,d0))
#pragma amicall(ListBrowserBase,0x048,HideListBrowserNodeChildren(a0))
#pragma amicall(ListBrowserBase,0x04E,ShowAllListBrowserChildren(a0))
#pragma amicall(ListBrowserBase,0x054,HideAllListBrowserChildren(a0))
#pragma amicall(ListBrowserBase,0x05A,FreeListBrowserList(a0))
/* undocumented functions; 3 of them also appear to have tagcall equivalents.
#pragma amicall(ListBrowserBase,0x060,AllocLBColumnInfoA(d0,a0))
#pragma amicall(ListBrowserBase,0x066,SetLBColumnInfoAttrsA(a1,a0))
#pragma amicall(ListBrowserBase,0x06C,GetLBColumnInfoAttrsA(a1,a0))
#pragma amicall(ListBrowserBase,0x072,FreeLBColumnInfo(a0))
#pragma amicall(ListBrowserBase,0x078,ListBrowserClearAll(a0)) */
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ListBrowserBase LISTBROWSER_GetClass 01E 00
#pragma  libcall ListBrowserBase AllocListBrowserNodeA 024 8002
#pragma  libcall ListBrowserBase FreeListBrowserNode  02A 801
#pragma  libcall ListBrowserBase SetListBrowserNodeAttrsA 030 9802
#pragma  libcall ListBrowserBase GetListBrowserNodeAttrsA 036 9802
#pragma  libcall ListBrowserBase ListBrowserSelectAll 03C 801
#pragma  libcall ListBrowserBase ShowListBrowserNodeChildren 042 0802
#pragma  libcall ListBrowserBase HideListBrowserNodeChildren 048 801
#pragma  libcall ListBrowserBase ShowAllListBrowserChildren 04E 801
#pragma  libcall ListBrowserBase HideAllListBrowserChildren 054 801
#pragma  libcall ListBrowserBase FreeListBrowserList  05A 801
/* undocumented functions; 3 of them also appear to have tagcall equivalents.
#pragma  libcall ListBrowserBase AllocLBColumnInfoA   060 8002
#pragma  libcall ListBrowserBase SetLBColumnInfoAttrsA 066 8902
#pragma  libcall ListBrowserBase GetLBColumnInfoAttrsA 06C 8902
#pragma  libcall ListBrowserBase FreeLBColumnInfo     072 801
#pragma  libcall ListBrowserBase ListBrowserClearAll  078 801 */
#endif
#ifdef __STORM__
#pragma tagcall(ListBrowserBase,0x024,AllocListBrowserNode(d0,a0))
#pragma tagcall(ListBrowserBase,0x030,SetListBrowserNodeAttrs(a0,a1))
#pragma tagcall(ListBrowserBase,0x036,GetListBrowserNodeAttrs(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall ListBrowserBase AllocListBrowserNode 024 8002
#pragma  tagcall ListBrowserBase SetListBrowserNodeAttrs 030 9802
#pragma  tagcall ListBrowserBase GetListBrowserNodeAttrs 036 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LISTBROWSER_LIB_H  */
