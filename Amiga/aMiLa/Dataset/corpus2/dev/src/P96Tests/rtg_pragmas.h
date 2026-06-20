#ifndef _INCLUDE_PRAGMA_RTG_LIB_H
#define _INCLUDE_PRAGMA_RTG_LIB_H

#ifndef CLIB_RTG_PROTOS_H
#include <clib/rtg_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(RTGBase,0x01e,rtgInitBoard(a0,a1))
#pragma amicall(RTGBase,0x024,rtgCreateDisplayInfoData(a0))
#pragma amicall(RTGBase,0x03c,rtgLookUpBitMapExtra(a0))
#pragma amicall(RTGBase,0x042,rtgGetBitMapExtra())
#pragma amicall(RTGBase,0x048,rtgAddBitMapExtra(a0))
#pragma amicall(RTGBase,0x04e,rtgRemoveBitMapExtra(a0))
#pragma amicall(RTGBase,0x054,rtgFillRect(a1,d0,d1,d2,d3,d4,d5,d7))
#pragma amicall(RTGBase,0x05a,rtgInvertRect(a1,d0,d1,d2,d3,d4,d7))
#pragma amicall(RTGBase,0x060,rtgBlitRect(a1,d0,d1,d2,d3,d4,d5,d6,d7))
#pragma amicall(RTGBase,0x066,rtgSaveMouseRect(a0,a1,a2,d0,d1))
#pragma amicall(RTGBase,0x06c,rtgRestoreMouseRect(a0,a1,a2,d0,d1))
#pragma amicall(RTGBase,0x072,rtgPaintMouse(a0,a1))
#pragma amicall(RTGBase,0x078,rtgOldStyleLock(d0))
#pragma amicall(RTGBase,0x07e,rtgOldStyleUnlock(d0))
#pragma amicall(RTGBase,0x084,rtgEncodeColor(d1,d2,d3,d0))
#pragma amicall(RTGBase,0x08a,rtgBlitTemplate(a1,a2,d0,d1,d2,d3,d4,d7))
#pragma amicall(RTGBase,0x090,rtgModifyMode(a0,d0))
#pragma amicall(RTGBase,0x096,rtgDrawEllipse(a1,d0,d1,d2,d3,d4,d5,d7))
#pragma amicall(RTGBase,0x09c,rtgInvertEllipse(a1,d0,d1,d2,d3,d4,d7))
#pragma amicall(RTGBase,0x0ae,rtgBlitRectNoMaskComplete(a1,a2,d0,d1,d2,d3,d4,d5,d6,d7))
#pragma amicall(RTGBase,0x0c0,rtgCreateSpecialFeature(a0,d0,a1))
#pragma amicall(RTGBase,0x0c6,rtgDeleteSpecialFeature(a1))
#pragma amicall(RTGBase,0x0cc,rtgSetSpecialFeatureAttrs(a1,a2))
#pragma amicall(RTGBase,0x0d2,rtgAllocBitMap(a0,d0,d1,a1))
#pragma amicall(RTGBase,0x0d8,rtgFreeBitMap(a0,a1,a2))
#pragma amicall(RTGBase,0x0de,rtgGetBitMapAttr(a0,a1,d0))
#pragma amicall(RTGBase,0x0e4,rtgGetSpecialFeatureAttrs(a1,a2))
#pragma amicall(RTGBase,0x0ea,rtgLookUpResolution(d0))
#pragma amicall(RTGBase,0x0f0,rtgAddHashResolution(a0))
#pragma amicall(RTGBase,0x0f6,rtgRemoveHashResolution(a0))
#pragma amicall(RTGBase,0x0fc,rtgClipPixel(a1,d0,d1,a2))
#pragma amicall(RTGBase,0x102,rtgClipRectangle(a1,d0,d1,d2,d3,a2))
#pragma amicall(RTGBase,0x108,rtgClipRectangleWithSource(a0,d0,d1,a1,d2,d3,d4,d5,a2,d6,d7))
#pragma amicall(RTGBase,0x10e,rtgLookUpHashExtra(a0))
#pragma amicall(RTGBase,0x114,rtgCreateHashExtra(a0,a1))
#pragma amicall(RTGBase,0x11a,rtgDisposeHashExtra(a0))
#pragma amicall(RTGBase,0x120,rtgLock(a0,d0))
#pragma amicall(RTGBase,0x126,rtgUnlock(a0))
#pragma amicall(RTGBase,0x12c,rtgPutPixel(a0,d2,d0,d1,d3,d4))
#pragma amicall(RTGBase,0x132,rtgGetPixel(a0,d2,d0,d1,d3))
#pragma amicall(RTGBase,0x138,rtgExtractColorPlane(a0,d0,d1,a1,d2,d3,d4,d5,d6,d7))
#pragma amicall(RTGBase,0x1b6,rtgAddMonitorInfoHook(a0))
#pragma amicall(RTGBase,0x1bc,rtgRemMonitorInfoHook(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall RTGBase rtgInitBoard           01e 9802
#pragma  libcall RTGBase rtgCreateDisplayInfoData 024 801
#pragma  libcall RTGBase rtgLookUpBitMapExtra   03c 801
#pragma  libcall RTGBase rtgGetBitMapExtra      042 00
#pragma  libcall RTGBase rtgAddBitMapExtra      048 801
#pragma  libcall RTGBase rtgRemoveBitMapExtra   04e 801
#pragma  libcall RTGBase rtgFillRect            054 7543210908
#pragma  libcall RTGBase rtgInvertRect          05a 743210907
#pragma  libcall RTGBase rtgBlitRect            060 76543210909
#pragma  libcall RTGBase rtgSaveMouseRect       066 10a9805
#pragma  libcall RTGBase rtgRestoreMouseRect    06c 10a9805
#pragma  libcall RTGBase rtgPaintMouse          072 9802
#pragma  libcall RTGBase rtgOldStyleLock        078 001
#pragma  libcall RTGBase rtgOldStyleUnlock      07e 001
#pragma  libcall RTGBase rtgEncodeColor         084 032104
#pragma  libcall RTGBase rtgBlitTemplate        08a 743210a908
#pragma  libcall RTGBase rtgModifyMode          090 0802
#pragma  libcall RTGBase rtgDrawEllipse         096 7543210908
#pragma  libcall RTGBase rtgInvertEllipse       09c 743210907
#pragma  libcall RTGBase rtgBlitRectNoMaskComplete 0ae 76543210a90a
#pragma  libcall RTGBase rtgCreateSpecialFeature 0c0 90803
#pragma  libcall RTGBase rtgDeleteSpecialFeature 0c6 901
#pragma  libcall RTGBase rtgSetSpecialFeatureAttrs 0cc a902
#pragma  libcall RTGBase rtgAllocBitMap         0d2 910804
#pragma  libcall RTGBase rtgFreeBitMap          0d8 a9803
#pragma  libcall RTGBase rtgGetBitMapAttr       0de 09803
#pragma  libcall RTGBase rtgGetSpecialFeatureAttrs 0e4 a902
#pragma  libcall RTGBase rtgLookUpResolution    0ea 001
#pragma  libcall RTGBase rtgAddHashResolution   0f0 801
#pragma  libcall RTGBase rtgRemoveHashResolution 0f6 801
#pragma  libcall RTGBase rtgClipPixel           0fc a10904
#pragma  libcall RTGBase rtgClipRectangle       102 a3210906
#pragma  libcall RTGBase rtgClipRectangleWithSource 108 76a543291080b
#pragma  libcall RTGBase rtgLookUpHashExtra     10e 801
#pragma  libcall RTGBase rtgCreateHashExtra     114 9802
#pragma  libcall RTGBase rtgDisposeHashExtra    11a 801
#pragma  libcall RTGBase rtgLock                120 0802
#pragma  libcall RTGBase rtgUnlock              126 801
#pragma  libcall RTGBase rtgPutPixel            12c 43102806
#pragma  libcall RTGBase rtgGetPixel            132 3102805
#pragma  libcall RTGBase rtgExtractColorPlane   138 76543291080a
#pragma  libcall RTGBase rtgAddMonitorInfoHook  1b6 801
#pragma  libcall RTGBase rtgRemMonitorInfoHook  1bc 801
#endif
#ifdef __STORM__
#pragma tagcall(RTGBase,0x01e,rtgInitBoardTags(a0,a1))
#pragma tagcall(RTGBase,0x0c0,rtgCreateSpecialFeatureTags(a0,d0,a1))
#pragma tagcall(RTGBase,0x0cc,rtgSetSpecialFeatureAttrsTags(a1,a2))
#pragma tagcall(RTGBase,0x0d2,rtgAllocBitMapTags(a0,d0,d1,a1))
#pragma tagcall(RTGBase,0x0d8,rtgFreeBitMapTags(a0,a1,a2))
#pragma tagcall(RTGBase,0x0e4,rtgGetSpecialFeatureAttrsTags(a1,a2))
#endif
#ifdef __SASC_60
#pragma  tagcall RTGBase rtgInitBoardTags       01e 9802
#pragma  tagcall RTGBase rtgCreateSpecialFeatureTags 0c0 90803
#pragma  tagcall RTGBase rtgSetSpecialFeatureAttrsTags 0cc a902
#pragma  tagcall RTGBase rtgAllocBitMapTags     0d2 910804
#pragma  tagcall RTGBase rtgFreeBitMapTags      0d8 a9803
#pragma  tagcall RTGBase rtgGetSpecialFeatureAttrsTags 0e4 a902
#endif

#endif	/*  _INCLUDE_PRAGMA_RTG_LIB_H  */
