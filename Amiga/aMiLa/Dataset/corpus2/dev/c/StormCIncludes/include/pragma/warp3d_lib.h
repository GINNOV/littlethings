#ifndef _INCLUDE_PRAGMA_WARP3D_LIB_H
#define _INCLUDE_PRAGMA_WARP3D_LIB_H

#ifndef CLIB_WARP3D_PROTOS_H
#include <clib/Warp3D_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/Warp3D.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(Warp3DBase,0x01E,W3D_CreateContext(a0,a1))
#pragma amicall(Warp3DBase,0x024,W3D_DestroyContext(a0))
#pragma amicall(Warp3DBase,0x02A,W3D_GetState(a0,d1))
#pragma amicall(Warp3DBase,0x030,W3D_SetState(a0,d0,d1))
#pragma amicall(Warp3DBase,0x036,W3D_CheckDriver())
#pragma amicall(Warp3DBase,0x03C,W3D_LockHardware(a0))
#pragma amicall(Warp3DBase,0x042,W3D_UnLockHardware(a0))
#pragma amicall(Warp3DBase,0x048,W3D_WaitIdle(a0))
#pragma amicall(Warp3DBase,0x04E,W3D_CheckIdle(a0))
#pragma amicall(Warp3DBase,0x054,W3D_Query(a0,d0,d1))
#pragma amicall(Warp3DBase,0x05A,W3D_GetTexFmtInfo(a0,d0,d1))
#pragma amicall(Warp3DBase,0x060,W3D_AllocTexObj(a0,a1,a2))
#pragma amicall(Warp3DBase,0x066,W3D_FreeTexObj(a0,a1))
#pragma amicall(Warp3DBase,0x06C,W3D_ReleaseTexture(a0,a1))
#pragma amicall(Warp3DBase,0x072,W3D_FlushTextures(a0))
#pragma amicall(Warp3DBase,0x078,W3D_SetFilter(a0,a1,d0,d1))
#pragma amicall(Warp3DBase,0x07E,W3D_SetTexEnv(a0,a1,d1,a2))
#pragma amicall(Warp3DBase,0x084,W3D_SetWrapMode(a0,a1,d0,d1,a2))
#pragma amicall(Warp3DBase,0x08A,W3D_UpdateTexImage(a0,a1,a2,d1,a3))
#pragma amicall(Warp3DBase,0x090,W3D_UploadTexture(a0,a1))
#pragma amicall(Warp3DBase,0x096,W3D_DrawLine(a0,a1))
#pragma amicall(Warp3DBase,0x09C,W3D_DrawPoint(a0,a1))
#pragma amicall(Warp3DBase,0x0A2,W3D_DrawTriangle(a0,a1))
#pragma amicall(Warp3DBase,0x0A8,W3D_DrawTriFan(a0,a1))
#pragma amicall(Warp3DBase,0x0AE,W3D_DrawTriStrip(a0,a1))
#pragma amicall(Warp3DBase,0x0B4,W3D_SetAlphaMode(a0,d1,a1))
#pragma amicall(Warp3DBase,0x0BA,W3D_SetBlendMode(a0,d0,d1))
#pragma amicall(Warp3DBase,0x0C0,W3D_SetDrawRegion(a0,a1,d1,a2))
#pragma amicall(Warp3DBase,0x0C6,W3D_SetFogParams(a0,a1,d1))
#pragma amicall(Warp3DBase,0x0CC,W3D_SetColorMask(a0,d0,d1,d2,d3))
#pragma amicall(Warp3DBase,0x0D2,W3D_SetStencilFunc(a0,d0,d1,d2))
#pragma amicall(Warp3DBase,0x0D8,W3D_AllocZBuffer(a0))
#pragma amicall(Warp3DBase,0x0DE,W3D_FreeZBuffer(a0))
#pragma amicall(Warp3DBase,0x0E4,W3D_ClearZBuffer(a0,a1))
#pragma amicall(Warp3DBase,0x0EA,W3D_ReadZPixel(a0,d0,d1,a1))
#pragma amicall(Warp3DBase,0x0F0,W3D_ReadZSpan(a0,d0,d1,d2,a1))
#pragma amicall(Warp3DBase,0x0F6,W3D_SetZCompareMode(a0,d1))
#pragma amicall(Warp3DBase,0x0FC,W3D_AllocStencilBuffer(a0))
#pragma amicall(Warp3DBase,0x102,W3D_ClearStencilBuffer(a0,a1))
#pragma amicall(Warp3DBase,0x108,W3D_FillStencilBuffer(a0,d0,d1,d2,d3,d4,a1))
#pragma amicall(Warp3DBase,0x10E,W3D_FreeStencilBuffer(a0))
#pragma amicall(Warp3DBase,0x114,W3D_ReadStencilPixel(a0,d0,d1,a1))
#pragma amicall(Warp3DBase,0x11A,W3D_ReadStencilSpan(a0,d0,d1,d2,a1))
#pragma amicall(Warp3DBase,0x120,W3D_SetLogicOp(a0,d1))
#pragma amicall(Warp3DBase,0x126,W3D_Hint(a0,d0,d1))
#pragma amicall(Warp3DBase,0x12C,W3D_SetDrawRegionWBM(a0,a1,a2))
#pragma amicall(Warp3DBase,0x132,W3D_GetDriverState(a0))
#pragma amicall(Warp3DBase,0x138,W3D_Flush(a0))
#pragma amicall(Warp3DBase,0x13E,W3D_SetPenMask(a0,d1))
#pragma amicall(Warp3DBase,0x144,W3D_SetStencilOp(a0,d0,d1,d2))
#pragma amicall(Warp3DBase,0x14A,W3D_SetWriteMask(a0,d1))
#pragma amicall(Warp3DBase,0x150,W3D_WriteStencilPixel(a0,d0,d1,d2))
#pragma amicall(Warp3DBase,0x156,W3D_WriteStencilSpan(a0,d0,d1,d2,a1,a2))
#pragma amicall(Warp3DBase,0x15C,W3D_WriteZPixel(a0,d0,d1,a1))
#pragma amicall(Warp3DBase,0x162,W3D_WriteZSpan(a0,d0,d1,d2,a1,a2))
#pragma amicall(Warp3DBase,0x168,W3D_SetCurrentColor(a0,a1))
#pragma amicall(Warp3DBase,0x16E,W3D_SetCurrentPen(a0,d1))
#pragma amicall(Warp3DBase,0x174,W3D_UpdateTexSubImage(a0,a1,a2,d1,a3,a4,d0))
#pragma amicall(Warp3DBase,0x17A,W3D_FreeAllTexObj(a0))
#pragma amicall(Warp3DBase,0x180,W3D_GetDestFmt())
#pragma amicall(Warp3DBase,0x186,W3D_DrawLineStrip(a0,a1))
#pragma amicall(Warp3DBase,0x18C,W3D_DrawLineLoop(a0,a1))
#pragma amicall(Warp3DBase,0x192,W3D_GetDrivers())
#pragma amicall(Warp3DBase,0x198,W3D_QueryDriver(a0,d0,d1))
#pragma amicall(Warp3DBase,0x19E,W3D_GetDriverTexFmtInfo(a0,d0,d1))
#pragma amicall(Warp3DBase,0x1A4,W3D_RequestMode(a0))
#pragma amicall(Warp3DBase,0x1AA,W3D_SetScissor(a0,a1))
#pragma amicall(Warp3DBase,0x1B0,W3D_FlushFrame(a0))
#pragma amicall(Warp3DBase,0x1B6,W3D_TestMode(d0))
#pragma amicall(Warp3DBase,0x1BC,W3D_SetChromaTestBounds(a0,a1,d0,d1,d2))
#pragma amicall(Warp3DBase,0x1C2,W3D_ClearDrawRegion(a0,d0))
#pragma amicall(Warp3DBase,0x1C8,W3D_DrawTriangleV(a0,a1))
#pragma amicall(Warp3DBase,0x1CE,W3D_DrawTriFanV(a0,a1))
#pragma amicall(Warp3DBase,0x1D4,W3D_DrawTriStripV(a0,a1))
#pragma amicall(Warp3DBase,0x1DA,W3D_GetScreenmodeList())
#pragma amicall(Warp3DBase,0x1E0,W3D_FreeScreenmodeList(a0))
#pragma amicall(Warp3DBase,0x1E6,W3D_BestModeID(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall Warp3DBase W3D_CreateContext    01E 9802
#pragma  libcall Warp3DBase W3D_DestroyContext   024 801
#pragma  libcall Warp3DBase W3D_GetState         02A 1802
#pragma  libcall Warp3DBase W3D_SetState         030 10803
#pragma  libcall Warp3DBase W3D_CheckDriver      036 00
#pragma  libcall Warp3DBase W3D_LockHardware     03C 801
#pragma  libcall Warp3DBase W3D_UnLockHardware   042 801
#pragma  libcall Warp3DBase W3D_WaitIdle         048 801
#pragma  libcall Warp3DBase W3D_CheckIdle        04E 801
#pragma  libcall Warp3DBase W3D_Query            054 10803
#pragma  libcall Warp3DBase W3D_GetTexFmtInfo    05A 10803
#pragma  libcall Warp3DBase W3D_AllocTexObj      060 A9803
#pragma  libcall Warp3DBase W3D_FreeTexObj       066 9802
#pragma  libcall Warp3DBase W3D_ReleaseTexture   06C 9802
#pragma  libcall Warp3DBase W3D_FlushTextures    072 801
#pragma  libcall Warp3DBase W3D_SetFilter        078 109804
#pragma  libcall Warp3DBase W3D_SetTexEnv        07E A19804
#pragma  libcall Warp3DBase W3D_SetWrapMode      084 A109805
#pragma  libcall Warp3DBase W3D_UpdateTexImage   08A B1A9805
#pragma  libcall Warp3DBase W3D_UploadTexture    090 9802
#pragma  libcall Warp3DBase W3D_DrawLine         096 9802
#pragma  libcall Warp3DBase W3D_DrawPoint        09C 9802
#pragma  libcall Warp3DBase W3D_DrawTriangle     0A2 9802
#pragma  libcall Warp3DBase W3D_DrawTriFan       0A8 9802
#pragma  libcall Warp3DBase W3D_DrawTriStrip     0AE 9802
#pragma  libcall Warp3DBase W3D_SetAlphaMode     0B4 91803
#pragma  libcall Warp3DBase W3D_SetBlendMode     0BA 10803
#pragma  libcall Warp3DBase W3D_SetDrawRegion    0C0 A19804
#pragma  libcall Warp3DBase W3D_SetFogParams     0C6 19803
#pragma  libcall Warp3DBase W3D_SetColorMask     0CC 3210805
#pragma  libcall Warp3DBase W3D_SetStencilFunc   0D2 210804
#pragma  libcall Warp3DBase W3D_AllocZBuffer     0D8 801
#pragma  libcall Warp3DBase W3D_FreeZBuffer      0DE 801
#pragma  libcall Warp3DBase W3D_ClearZBuffer     0E4 9802
#pragma  libcall Warp3DBase W3D_ReadZPixel       0EA 910804
#pragma  libcall Warp3DBase W3D_ReadZSpan        0F0 9210805
#pragma  libcall Warp3DBase W3D_SetZCompareMode  0F6 1802
#pragma  libcall Warp3DBase W3D_AllocStencilBuffer 0FC 801
#pragma  libcall Warp3DBase W3D_ClearStencilBuffer 102 9802
#pragma  libcall Warp3DBase W3D_FillStencilBuffer 108 943210807
#pragma  libcall Warp3DBase W3D_FreeStencilBuffer 10E 801
#pragma  libcall Warp3DBase W3D_ReadStencilPixel 114 910804
#pragma  libcall Warp3DBase W3D_ReadStencilSpan  11A 9210805
#pragma  libcall Warp3DBase W3D_SetLogicOp       120 1802
#pragma  libcall Warp3DBase W3D_Hint             126 10803
#pragma  libcall Warp3DBase W3D_SetDrawRegionWBM 12C A9803
#pragma  libcall Warp3DBase W3D_GetDriverState   132 801
#pragma  libcall Warp3DBase W3D_Flush            138 801
#pragma  libcall Warp3DBase W3D_SetPenMask       13E 1802
#pragma  libcall Warp3DBase W3D_SetStencilOp     144 210804
#pragma  libcall Warp3DBase W3D_SetWriteMask     14A 1802
#pragma  libcall Warp3DBase W3D_WriteStencilPixel 150 210804
#pragma  libcall Warp3DBase W3D_WriteStencilSpan 156 A9210806
#pragma  libcall Warp3DBase W3D_WriteZPixel      15C 910804
#pragma  libcall Warp3DBase W3D_WriteZSpan       162 A9210806
#pragma  libcall Warp3DBase W3D_SetCurrentColor  168 9802
#pragma  libcall Warp3DBase W3D_SetCurrentPen    16E 1802
#pragma  libcall Warp3DBase W3D_UpdateTexSubImage 174 0CB1A9807
#pragma  libcall Warp3DBase W3D_FreeAllTexObj    17A 801
#pragma  libcall Warp3DBase W3D_GetDestFmt       180 00
#pragma  libcall Warp3DBase W3D_DrawLineStrip    186 9802
#pragma  libcall Warp3DBase W3D_DrawLineLoop     18C 9802
#pragma  libcall Warp3DBase W3D_GetDrivers       192 00
#pragma  libcall Warp3DBase W3D_QueryDriver      198 10803
#pragma  libcall Warp3DBase W3D_GetDriverTexFmtInfo 19E 10803
#pragma  libcall Warp3DBase W3D_RequestMode      1A4 801
#pragma  libcall Warp3DBase W3D_SetScissor       1AA 9802
#pragma  libcall Warp3DBase W3D_FlushFrame       1B0 801
#pragma  libcall Warp3DBase W3D_TestMode         1B6 001
#pragma  libcall Warp3DBase W3D_SetChromaTestBounds 1BC 2109805
#pragma  libcall Warp3DBase W3D_ClearDrawRegion  1C2 0802
#pragma  libcall Warp3DBase W3D_DrawTriangleV    1C8 9802
#pragma  libcall Warp3DBase W3D_DrawTriFanV      1CE 9802
#pragma  libcall Warp3DBase W3D_DrawTriStripV    1D4 9802
#pragma  libcall Warp3DBase W3D_GetScreenmodeList 1DA 00
#pragma  libcall Warp3DBase W3D_FreeScreenmodeList 1E0 801
#pragma  libcall Warp3DBase W3D_BestModeID       1E6 801
#endif
#ifdef __STORM__
#pragma tagcall(Warp3DBase,0x01E,W3D_CreateContextTags(a0,a1))
#pragma tagcall(Warp3DBase,0x060,W3D_AllocTexObjTags(a0,a1,a2))
#pragma tagcall(Warp3DBase,0x1A4,W3D_RequestModeTags(a0))
#pragma tagcall(Warp3DBase,0x1E6,W3D_BestModeIDTags(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall Warp3DBase W3D_CreateContextTags 01E 9802
#pragma  tagcall Warp3DBase W3D_AllocTexObjTags  060 A9803
#pragma  tagcall Warp3DBase W3D_RequestModeTags  1A4 801
#pragma  tagcall Warp3DBase W3D_BestModeIDTags   1E6 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_WARP3D_LIB_H  */
