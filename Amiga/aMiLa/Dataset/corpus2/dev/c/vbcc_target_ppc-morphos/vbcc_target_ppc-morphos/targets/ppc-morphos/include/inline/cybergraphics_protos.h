#ifndef _VBCCINLINE_CYBERGRAPHICS_H
#define _VBCCINLINE_CYBERGRAPHICS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

BOOL __IsCyberModeID(void *, ULONG displayID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define IsCyberModeID(displayID) __IsCyberModeID(CyberGfxBase, (displayID))

ULONG __BestCModeIDTagList(void *, struct TagItem * BestModeIDTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define BestCModeIDTagList(BestModeIDTags) __BestCModeIDTagList(CyberGfxBase, (BestModeIDTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __BestCModeIDTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define BestCModeIDTags(...) __BestCModeIDTags(CyberGfxBase, __VA_ARGS__)
#endif

ULONG __CModeRequestTagList(void *, APTR ModeRequest, struct TagItem * ModeRequestTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CModeRequestTagList(ModeRequest, ModeRequestTags) __CModeRequestTagList(CyberGfxBase, (ModeRequest), (ModeRequestTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __CModeRequestTags(void *, APTR ModeRequest, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define CModeRequestTags(ModeRequest, ...) __CModeRequestTags(CyberGfxBase, (ModeRequest), __VA_ARGS__)
#endif

struct List * __AllocCModeListTagList(void *, struct TagItem * ModeListTags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AllocCModeListTagList(ModeListTags) __AllocCModeListTagList(CyberGfxBase, (ModeListTags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct List * __linearvarargs __AllocCModeListTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AllocCModeListTags(...) __AllocCModeListTags(CyberGfxBase, __VA_ARGS__)
#endif

void __FreeCModeList(void *, struct List * ModeList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define FreeCModeList(ModeList) __FreeCModeList(CyberGfxBase, (ModeList))

LONG __ScalePixelArray(void *, APTR srcRect, UWORD SrcW, UWORD SrcH, UWORD SrcMod, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD DestW, UWORD DestH, UBYTE SrcFormat) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define ScalePixelArray(srcRect, SrcW, SrcH, SrcMod, destRP, DestX, DestY, DestW, DestH, SrcFormat) __ScalePixelArray(CyberGfxBase, (srcRect), (SrcW), (SrcH), (SrcMod), (destRP), (DestX), (DestY), (DestW), (DestH), (SrcFormat))

ULONG __GetCyberMapAttr(void *, struct BitMap * CyberGfxBitmap, ULONG CyberAttrTag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define GetCyberMapAttr(CyberGfxBitmap, CyberAttrTag) __GetCyberMapAttr(CyberGfxBase, (CyberGfxBitmap), (CyberAttrTag))

ULONG __GetCyberIDAttr(void *, ULONG CyberIDAttr, ULONG CyberDisplayModeID) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define GetCyberIDAttr(CyberIDAttr, CyberDisplayModeID) __GetCyberIDAttr(CyberGfxBase, (CyberIDAttr), (CyberDisplayModeID))

ULONG __ReadRGBPixel(void *, struct RastPort * srcRP, UWORD x, UWORD y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define ReadRGBPixel(srcRP, x, y) __ReadRGBPixel(CyberGfxBase, (srcRP), (x), (y))

LONG __WriteRGBPixel(void *, struct RastPort * destRP, UWORD x, UWORD y, ULONG argb) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define WriteRGBPixel(destRP, x, y, argb) __WriteRGBPixel(CyberGfxBase, (destRP), (x), (y), (argb))

ULONG __ReadPixelArray(void *, APTR destRect, UWORD destX, UWORD destY, UWORD destMod, struct RastPort * srcRP, UWORD SrcX, UWORD SrcY, UWORD SizeX, UWORD SizeY, UBYTE DestFormat) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define ReadPixelArray(destRect, destX, destY, destMod, srcRP, SrcX, SrcY, SizeX, SizeY, DestFormat) __ReadPixelArray(CyberGfxBase, (destRect), (destX), (destY), (destMod), (srcRP), (SrcX), (SrcY), (SizeX), (SizeY), (DestFormat))

ULONG __WritePixelArray(void *, APTR srcRect, UWORD SrcX, UWORD SrcY, UWORD SrcMod, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, UBYTE SrcFormat) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define WritePixelArray(srcRect, SrcX, SrcY, SrcMod, destRP, DestX, DestY, SizeX, SizeY, SrcFormat) __WritePixelArray(CyberGfxBase, (srcRect), (SrcX), (SrcY), (SrcMod), (destRP), (DestX), (DestY), (SizeX), (SizeY), (SrcFormat))

ULONG __MovePixelArray(void *, UWORD SrcX, UWORD SrcY, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define MovePixelArray(SrcX, SrcY, destRP, DestX, DestY, SizeX, SizeY) __MovePixelArray(CyberGfxBase, (SrcX), (SrcY), (destRP), (DestX), (DestY), (SizeX), (SizeY))

ULONG __InvertPixelArray(void *, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define InvertPixelArray(destRP, DestX, DestY, SizeX, SizeY) __InvertPixelArray(CyberGfxBase, (destRP), (DestX), (DestY), (SizeX), (SizeY))

ULONG __FillPixelArray(void *, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, ULONG ARGB) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define FillPixelArray(destRP, DestX, DestY, SizeX, SizeY, ARGB) __FillPixelArray(CyberGfxBase, (destRP), (DestX), (DestY), (SizeX), (SizeY), (ARGB))

void __DoCDrawMethodTagList(void *, struct Hook * hook, struct RastPort * destRP, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define DoCDrawMethodTagList(hook, destRP, tagList) __DoCDrawMethodTagList(CyberGfxBase, (hook), (destRP), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __DoCDrawMethodTags(void *, struct Hook * hook, struct RastPort * destRP, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define DoCDrawMethodTags(hook, destRP, ...) __DoCDrawMethodTags(CyberGfxBase, (hook), (destRP), __VA_ARGS__)
#endif

void __CVideoCtrlTagList(void *, struct ViewPort * viewPort, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define CVideoCtrlTagList(viewPort, tagList) __CVideoCtrlTagList(CyberGfxBase, (viewPort), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __CVideoCtrlTags(void *, struct ViewPort * viewPort, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define CVideoCtrlTags(viewPort, ...) __CVideoCtrlTags(CyberGfxBase, (viewPort), __VA_ARGS__)
#endif

APTR __LockBitMapTagList(void *, APTR bitMap, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define LockBitMapTagList(bitMap, tagList) __LockBitMapTagList(CyberGfxBase, (bitMap), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __LockBitMapTags(void *, APTR bitMap, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define LockBitMapTags(bitMap, ...) __LockBitMapTags(CyberGfxBase, (bitMap), __VA_ARGS__)
#endif

void __UnLockBitMap(void *, APTR Handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define UnLockBitMap(Handle) __UnLockBitMap(CyberGfxBase, (Handle))

void __UnLockBitMapTagList(void *, APTR Handle, struct TagItem * tagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define UnLockBitMapTagList(Handle, tagList) __UnLockBitMapTagList(CyberGfxBase, (Handle), (tagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __UnLockBitMapTags(void *, APTR Handle, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define UnLockBitMapTags(Handle, ...) __UnLockBitMapTags(CyberGfxBase, (Handle), __VA_ARGS__)
#endif

ULONG __ExtractColor(void *, struct RastPort * srcRP, struct BitMap * bitMap, ULONG Colour, ULONG SrcX, ULONG SrcY, ULONG Width, ULONG Height) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define ExtractColor(srcRP, bitMap, Colour, SrcX, SrcY, Width, Height) __ExtractColor(CyberGfxBase, (srcRP), (bitMap), (Colour), (SrcX), (SrcY), (Width), (Height))

ULONG __WriteLUTPixelArray(void *, APTR srcRect, UWORD SrcX, UWORD SrcY, UWORD SrcMod, struct RastPort * destRP, APTR ColorTab, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, UBYTE CTFormat) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,40(2)\n"
	"\tstw\t10,12(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,16(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,20(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define WriteLUTPixelArray(srcRect, SrcX, SrcY, SrcMod, destRP, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat) __WriteLUTPixelArray(CyberGfxBase, (srcRect), (SrcX), (SrcY), (SrcMod), (destRP), (ColorTab), (DestX), (DestY), (SizeX), (SizeY), (CTFormat))

ULONG __WritePixelArrayAlpha(void *, APTR srcRect, UWORD SrcX, UWORD SrcY, UWORD SrcMod, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, ULONG GlobalAlpha) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define WritePixelArrayAlpha(srcRect, SrcX, SrcY, SrcMod, destRP, DestX, DestY, SizeX, SizeY, GlobalAlpha) __WritePixelArrayAlpha(CyberGfxBase, (srcRect), (SrcX), (SrcY), (SrcMod), (destRP), (DestX), (DestY), (SizeX), (SizeY), (GlobalAlpha))

void __BltTemplateAlpha(void *, UBYTE * source, LONG xSrc, LONG srcMod, struct RastPort * destRP, LONG xDest, LONG yDest, LONG xSize, LONG ySize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define BltTemplateAlpha(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize) __BltTemplateAlpha(CyberGfxBase, (source), (xSrc), (srcMod), (destRP), (xDest), (yDest), (xSize), (ySize))

void __ProcessPixelArray(void *, struct RastPort * destRP, ULONG DestX, ULONG DestY, ULONG SizeX, ULONG SizeY, ULONG Operation, LONG Value, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,16(2)\n"
	"\tstw\t10,20(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define ProcessPixelArray(destRP, DestX, DestY, SizeX, SizeY, Operation, Value, taglist) __ProcessPixelArray(CyberGfxBase, (destRP), (DestX), (DestY), (SizeX), (SizeY), (Operation), (Value), (taglist))

ULONG __BltBitMapAlpha(void *, struct BitMap * srcBitMap, WORD SrcX, WORD SrcY, struct BitMap * destBitMap, WORD DestX, WORD DestY, WORD SizeX, WORD SizeY, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define BltBitMapAlpha(srcBitMap, SrcX, SrcY, destBitMap, DestX, DestY, SizeX, SizeY, taglist) __BltBitMapAlpha(CyberGfxBase, (srcBitMap), (SrcX), (SrcY), (destBitMap), (DestX), (DestY), (SizeX), (SizeY), (taglist))

ULONG __BltBitMapRastPortAlpha(void *, struct BitMap * srcBitMap, WORD SrcX, WORD SrcY, struct RastPort * destRP, WORD DestX, WORD DestY, WORD SizeX, WORD SizeY, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,8(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,40(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define BltBitMapRastPortAlpha(srcBitMap, SrcX, SrcY, destRP, DestX, DestY, SizeX, SizeY, taglist) __BltBitMapRastPortAlpha(CyberGfxBase, (srcBitMap), (SrcX), (SrcY), (destRP), (DestX), (DestY), (SizeX), (SizeY), (taglist))

LONG __ScalePixelArrayAlpha(void *, APTR srcRect, UWORD SrcW, UWORD SrcH, UWORD SrcMod, struct RastPort * destRP, UWORD DestX, UWORD DestY, UWORD DestW, UWORD DestH, ULONG GlobalAlpha) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tstw\t9,12(2)\n"
	"\tstw\t10,16(2)\n"
	"\tlwz\t11,8(1)\n"
	"\tstw\t11,20(2)\n"
	"\tlwz\t11,12(1)\n"
	"\tstw\t11,24(2)\n"
	"\tlwz\t11,16(1)\n"
	"\tstw\t11,28(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define ScalePixelArrayAlpha(srcRect, SrcW, SrcH, SrcMod, destRP, DestX, DestY, DestW, DestH, GlobalAlpha) __ScalePixelArrayAlpha(CyberGfxBase, (srcRect), (SrcW), (SrcH), (SrcMod), (destRP), (DestX), (DestY), (DestW), (DestH), (GlobalAlpha))

#endif /*  _VBCCINLINE_CYBERGRAPHICS_H  */
