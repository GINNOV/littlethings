#ifndef _INCLUDE_PRAGMA_ICON_LIB_H
#define _INCLUDE_PRAGMA_ICON_LIB_H

#ifndef CLIB_ICON_PROTOS_H
#include <clib/icon_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/icon.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(IconBase,0x036,FreeFreeList(a0))
#pragma amicall(IconBase,0x048,AddFreeList(a0,a1,a2))
#pragma amicall(IconBase,0x04E,GetDiskObject(a0))
#pragma amicall(IconBase,0x054,PutDiskObject(a0,a1))
#pragma amicall(IconBase,0x05A,FreeDiskObject(a0))
#pragma amicall(IconBase,0x060,FindToolType(a0,a1))
#pragma amicall(IconBase,0x066,MatchToolValue(a0,a1))
#pragma amicall(IconBase,0x06C,BumpRevision(a0,a1))
#pragma amicall(IconBase,0x078,GetDefDiskObject(d0))
#pragma amicall(IconBase,0x07E,PutDefDiskObject(a0))
#pragma amicall(IconBase,0x084,GetDiskObjectNew(a0))
#pragma amicall(IconBase,0x08A,DeleteDiskObject(a0))
#pragma amicall(IconBase,0x096,DupDiskObjectA(a0,a1))
#pragma amicall(IconBase,0x09C,IconControlA(a0,a1))
#pragma amicall(IconBase,0x0A2,DrawIconStateA(a0,a1,a2,d0,d1,d2,a3))
#pragma amicall(IconBase,0x0A8,GetIconRectangleA(a0,a1,a2,a3,a4))
#pragma amicall(IconBase,0x0AE,NewDiskObject(d0))
#pragma amicall(IconBase,0x0B4,GetIconTagList(a0,a1))
#pragma amicall(IconBase,0x0BA,PutIconTagList(a0,a1,a2))
#pragma amicall(IconBase,0x0C0,LayoutIconA(a0,a1,a2))
#pragma amicall(IconBase,0x0C6,ChangeToSelectedIconColor(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall IconBase FreeFreeList         036 801
#pragma  libcall IconBase AddFreeList          048 A9803
#pragma  libcall IconBase GetDiskObject        04E 801
#pragma  libcall IconBase PutDiskObject        054 9802
#pragma  libcall IconBase FreeDiskObject       05A 801
#pragma  libcall IconBase FindToolType         060 9802
#pragma  libcall IconBase MatchToolValue       066 9802
#pragma  libcall IconBase BumpRevision         06C 9802
#pragma  libcall IconBase GetDefDiskObject     078 001
#pragma  libcall IconBase PutDefDiskObject     07E 801
#pragma  libcall IconBase GetDiskObjectNew     084 801
#pragma  libcall IconBase DeleteDiskObject     08A 801
#pragma  libcall IconBase DupDiskObjectA       096 9802
#pragma  libcall IconBase IconControlA         09C 9802
#pragma  libcall IconBase DrawIconStateA       0A2 B210A9807
#pragma  libcall IconBase GetIconRectangleA    0A8 CBA9805
#pragma  libcall IconBase NewDiskObject        0AE 001
#pragma  libcall IconBase GetIconTagList       0B4 9802
#pragma  libcall IconBase PutIconTagList       0BA A9803
#pragma  libcall IconBase LayoutIconA          0C0 A9803
#pragma  libcall IconBase ChangeToSelectedIconColor 0C6 801
#endif
#ifdef __STORM__
#pragma tagcall(IconBase,0x096,DupDiskObject(a0,a1))
#pragma tagcall(IconBase,0x09C,IconControl(a0,a1))
#pragma tagcall(IconBase,0x0A2,DrawIconState(a0,a1,a2,d0,d1,d2,a3))
#pragma tagcall(IconBase,0x0A8,GetIconRectangle(a0,a1,a2,a3,a4))
#pragma tagcall(IconBase,0x0B4,GetIconTags(a0,a1))
#pragma tagcall(IconBase,0x0BA,PutIconTags(a0,a1,a2))
#pragma tagcall(IconBase,0x0C0,LayoutIcon(a0,a1,a2))
#endif
#ifdef __SASC_60
#pragma  tagcall IconBase DupDiskObject        096 9802
#pragma  tagcall IconBase IconControl          09C 9802
#pragma  tagcall IconBase DrawIconState        0A2 B210A9807
#pragma  tagcall IconBase GetIconRectangle     0A8 CBA9805
#pragma  tagcall IconBase GetIconTags          0B4 9802
#pragma  tagcall IconBase PutIconTags          0BA A9803
#pragma  tagcall IconBase LayoutIcon           0C0 A9803
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_ICON_LIB_H  */
