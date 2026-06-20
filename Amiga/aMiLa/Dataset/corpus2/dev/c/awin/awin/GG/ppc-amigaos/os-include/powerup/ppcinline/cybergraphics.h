/* Automatically generated header! Do not edit! */

#ifndef _PPCINLINE_CYBERGRAPHICS_H
#define _PPCINLINE_CYBERGRAPHICS_H

#ifndef __PPCINLINE_MACROS_H
#include <powerup/ppcinline/macros.h>
#endif /* !__PPCINLINE_MACROS_H */

#ifndef CYBERGRAPHICS_BASE_NAME
#define CYBERGRAPHICS_BASE_NAME CyberGfxBase
#endif /* !CYBERGRAPHICS_BASE_NAME */

#define AllocCModeListTagList(ModeListTags) \
	LP1(0x48, struct List *, AllocCModeListTagList, struct TagItem *, ModeListTags, a1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define AllocCModeListTags(tags...) \
	({ULONG _tags[] = { tags }; AllocCModeListTagList((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define BestCModeIDTagList(BestModeIDTags) \
	LP1(0x3c, ULONG, BestCModeIDTagList, struct TagItem *, BestModeIDTags, a0, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define BestCModeIDTags(tags...) \
	({ULONG _tags[] = { tags }; BestCModeIDTagList((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define CModeRequestTagList(ModeRequest, ModeRequestTags) \
	LP2(0x42, ULONG, CModeRequestTagList, APTR, ModeRequest, a0, struct TagItem *, ModeRequestTags, a1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define CModeRequestTags(a0, tags...) \
	({ULONG _tags[] = { tags }; CModeRequestTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define CVideoCtrlTagList(ViewPort_, TagList) \
	LP2NR(0xa2, CVideoCtrlTagList, struct ViewPort *, ViewPort_, a0, struct TagItem *, TagList, a1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define CVideoCtrlTags(a0, tags...) \
	({ULONG _tags[] = { tags }; CVideoCtrlTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define DoCDrawMethodTagList(Hook_, RastPort_, TagList) \
	LP3NR(0x9c, DoCDrawMethodTagList, struct Hook *, Hook_, a0, struct RastPort *, RastPort_, a1, struct TagItem *, TagList, a2, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define DoCDrawMethodTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; DoCDrawMethodTagList((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define ExtractColor(RastPort_, BitMap_, Colour, SrcX, SrcY, Width, Height) \
	LP7(0xba, ULONG, ExtractColor, struct RastPort *, RastPort_, a0, struct BitMap *, BitMap_, a1, ULONG, Colour, d0, ULONG, SrcX, d1, ULONG, SrcY, d2, ULONG, Width, d3, ULONG, Height, d4, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define FillPixelArray(RastPort_, DestX, DestY, SizeX, SizeY, ARGB) \
	LP6(0x96, ULONG, FillPixelArray, struct RastPort *, RastPort_, a1, UWORD, DestX, d0, UWORD, DestY, d1, UWORD, SizeX, d2, UWORD, SizeY, d3, ULONG, ARGB, d4, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define FreeCModeList(ModeList) \
	LP1NR(0x4e, FreeCModeList, struct List *, ModeList, a0, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define GetCyberIDAttr(CyberIDAttr, CyberDisplayModeID) \
	LP2(0x66, ULONG, GetCyberIDAttr, ULONG, CyberIDAttr, d0, ULONG, CyberDisplayModeID, d1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define GetCyberMapAttr(CyberGfxBitmap, CyberAttrTag) \
	LP2(0x60, ULONG, GetCyberMapAttr, struct BitMap *, CyberGfxBitmap, a0, ULONG, CyberAttrTag, d0, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define InvertPixelArray(RastPort_, DestX, DestY, SizeX, SizeY) \
	LP5(0x90, ULONG, InvertPixelArray, struct RastPort *, RastPort_, a1, UWORD, DestX, d0, UWORD, DestY, d1, UWORD, SizeX, d2, UWORD, SizeY, d3, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define IsCyberModeID(displayID) \
	LP1(0x36, BOOL, IsCyberModeID, ULONG, displayID, d0, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define LockBitMapTagList(BitMap, TagList) \
	LP2(0xa8, APTR, LockBitMapTagList, APTR, BitMap, a0, struct TagItem *, TagList, a1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define LockBitMapTags(a0, tags...) \
	({ULONG _tags[] = { tags }; LockBitMapTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define MovePixelArray(SrcX, SrcY, RastPort_, DestX, DestY, SizeX, SizeY) \
	LP7(0x84, ULONG, MovePixelArray, UWORD, SrcX, d0, UWORD, SrcY, d1, struct RastPort *, RastPort_, a1, UWORD, DestX, d2, UWORD, DestY, d3, UWORD, SizeX, d4, UWORD, SizeY, d5, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ReadPixelArray(destRect, destX, destY, destMod, RastPort_, SrcX, SrcY, SizeX, SizeY, DestFormat) \
	LP10(0x78, ULONG, ReadPixelArray, APTR, destRect, a0, UWORD, destX, d0, UWORD, destY, d1, UWORD, destMod, d2, struct RastPort *, RastPort_, a1, UWORD, SrcX, d3, UWORD, SrcY, d4, UWORD, SizeX, d5, UWORD, SizeY, d6, UBYTE, DestFormat, d7, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ReadRGBPixel(RastPort_, x, y) \
	LP3(0x6c, ULONG, ReadRGBPixel, struct RastPort *, RastPort_, a1, UWORD, x, d0, UWORD, y, d1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define ScalePixelArray(srcRect, SrcW, SrcH, SrcMod, RastPort_, DestX, DestY, DestW, DestH, SrcFormat) \
	LP10(0x5a, LONG, ScalePixelArray, APTR, srcRect, a0, UWORD, SrcW, d0, UWORD, SrcH, d1, UWORD, SrcMod, d2, struct RastPort *, RastPort_, a1, UWORD, DestX, d3, UWORD, DestY, d4, UWORD, DestW, d5, UWORD, DestH, d6, UBYTE, SrcFormat, d7, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define UnLockBitMap(Handle) \
	LP1NR(0xae, UnLockBitMap, APTR, Handle, a0, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define UnLockBitMapTagList(Handle, TagList) \
	LP2NR(0xb4, UnLockBitMapTagList, APTR, Handle, a0, struct TagItem *, TagList, a1, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define UnLockBitMapTags(a0, tags...) \
	({ULONG _tags[] = { tags }; UnLockBitMapTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define WriteLUTPixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort_, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat) \
	LP11(0xc6, ULONG, WriteLUTPixelArray, APTR, srcRect, a0, UWORD, SrcX, d0, UWORD, SrcY, d1, UWORD, SrcMod, d2, struct RastPort *, RastPort_, a1, APTR, ColorTab, a2, UWORD, DestX, d3, UWORD, DestY, d4, UWORD, SizeX, d5, UWORD, SizeY, d6, UBYTE, CTFormat, d7, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define WritePixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort_, DestX, DestY, SizeX, SizeY, SrcFormat) \
	LP10(0x7e, ULONG, WritePixelArray, APTR, srcRect, a0, UWORD, SrcX, d0, UWORD, SrcY, d1, UWORD, SrcMod, d2, struct RastPort *, RastPort_, a1, UWORD, DestX, d3, UWORD, DestY, d4, UWORD, SizeX, d5, UWORD, SizeY, d6, UBYTE, SrcFormat, d7, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define WriteRGBPixel(RastPort_, x, y, argb) \
	LP4(0x72, LONG, WriteRGBPixel, struct RastPort *, RastPort_, a1, UWORD, x, d0, UWORD, y, d1, ULONG, argb, d2, \
	, CYBERGRAPHICS_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#endif /* !_PPCINLINE_CYBERGRAPHICS_H */
