#ifndef _INCLUDE_PRAGMA_LAYERS_LIB_H
#define _INCLUDE_PRAGMA_LAYERS_LIB_H

#ifndef CLIB_LAYERS_PROTOS_H
#include <clib/layers_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/layers.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(LayersBase,0x01E,InitLayers(a0))
#pragma amicall(LayersBase,0x024,CreateUpfrontLayer(a0,a1,d0,d1,d2,d3,d4,a2))
#pragma amicall(LayersBase,0x02A,CreateBehindLayer(a0,a1,d0,d1,d2,d3,d4,a2))
#pragma amicall(LayersBase,0x030,UpfrontLayer(a0,a1))
#pragma amicall(LayersBase,0x036,BehindLayer(a0,a1))
#pragma amicall(LayersBase,0x03C,MoveLayer(a0,a1,d0,d1))
#pragma amicall(LayersBase,0x042,SizeLayer(a0,a1,d0,d1))
#pragma amicall(LayersBase,0x048,ScrollLayer(a0,a1,d0,d1))
#pragma amicall(LayersBase,0x04E,BeginUpdate(a0))
#pragma amicall(LayersBase,0x054,EndUpdate(a0,d0))
#pragma amicall(LayersBase,0x05A,DeleteLayer(a0,a1))
#pragma amicall(LayersBase,0x060,LockLayer(a0,a1))
#pragma amicall(LayersBase,0x066,UnlockLayer(a0))
#pragma amicall(LayersBase,0x06C,LockLayers(a0))
#pragma amicall(LayersBase,0x072,UnlockLayers(a0))
#pragma amicall(LayersBase,0x078,LockLayerInfo(a0))
#pragma amicall(LayersBase,0x07E,SwapBitsRastPortClipRect(a0,a1))
#pragma amicall(LayersBase,0x084,WhichLayer(a0,d0,d1))
#pragma amicall(LayersBase,0x08A,UnlockLayerInfo(a0))
#pragma amicall(LayersBase,0x090,NewLayerInfo())
#pragma amicall(LayersBase,0x096,DisposeLayerInfo(a0))
#pragma amicall(LayersBase,0x09C,FattenLayerInfo(a0))
#pragma amicall(LayersBase,0x0A2,ThinLayerInfo(a0))
#pragma amicall(LayersBase,0x0A8,MoveLayerInFrontOf(a0,a1))
#pragma amicall(LayersBase,0x0AE,InstallClipRegion(a0,a1))
#pragma amicall(LayersBase,0x0B4,MoveSizeLayer(a0,d0,d1,d2,d3))
#pragma amicall(LayersBase,0x0BA,CreateUpfrontHookLayer(a0,a1,d0,d1,d2,d3,d4,a3,a2))
#pragma amicall(LayersBase,0x0C0,CreateBehindHookLayer(a0,a1,d0,d1,d2,d3,d4,a3,a2))
#pragma amicall(LayersBase,0x0C6,InstallLayerHook(a0,a1))
#pragma amicall(LayersBase,0x0CC,InstallLayerInfoHook(a0,a1))
#pragma amicall(LayersBase,0x0D2,SortLayerCR(a0,d0,d1))
#pragma amicall(LayersBase,0x0D8,DoHookClipRects(a0,a1,a2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall LayersBase InitLayers           01E 801
#pragma  libcall LayersBase CreateUpfrontLayer   024 A432109808
#pragma  libcall LayersBase CreateBehindLayer    02A A432109808
#pragma  libcall LayersBase UpfrontLayer         030 9802
#pragma  libcall LayersBase BehindLayer          036 9802
#pragma  libcall LayersBase MoveLayer            03C 109804
#pragma  libcall LayersBase SizeLayer            042 109804
#pragma  libcall LayersBase ScrollLayer          048 109804
#pragma  libcall LayersBase BeginUpdate          04E 801
#pragma  libcall LayersBase EndUpdate            054 0802
#pragma  libcall LayersBase DeleteLayer          05A 9802
#pragma  libcall LayersBase LockLayer            060 9802
#pragma  libcall LayersBase UnlockLayer          066 801
#pragma  libcall LayersBase LockLayers           06C 801
#pragma  libcall LayersBase UnlockLayers         072 801
#pragma  libcall LayersBase LockLayerInfo        078 801
#pragma  libcall LayersBase SwapBitsRastPortClipRect 07E 9802
#pragma  libcall LayersBase WhichLayer           084 10803
#pragma  libcall LayersBase UnlockLayerInfo      08A 801
#pragma  libcall LayersBase NewLayerInfo         090 00
#pragma  libcall LayersBase DisposeLayerInfo     096 801
#pragma  libcall LayersBase FattenLayerInfo      09C 801
#pragma  libcall LayersBase ThinLayerInfo        0A2 801
#pragma  libcall LayersBase MoveLayerInFrontOf   0A8 9802
#pragma  libcall LayersBase InstallClipRegion    0AE 9802
#pragma  libcall LayersBase MoveSizeLayer        0B4 3210805
#pragma  libcall LayersBase CreateUpfrontHookLayer 0BA AB432109809
#pragma  libcall LayersBase CreateBehindHookLayer 0C0 AB432109809
#pragma  libcall LayersBase InstallLayerHook     0C6 9802
#pragma  libcall LayersBase InstallLayerInfoHook 0CC 9802
#pragma  libcall LayersBase SortLayerCR          0D2 10803
#pragma  libcall LayersBase DoHookClipRects      0D8 A9803
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LAYERS_LIB_H  */
