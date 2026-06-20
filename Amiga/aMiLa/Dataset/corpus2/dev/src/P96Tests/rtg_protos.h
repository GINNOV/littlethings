#ifndef  CLIB_RTG_PROTOS_H
#define  CLIB_RTG_PROTOS_H

/*
**	$VER: rtg_protos.h 39.31 (29.4.93)
**	Includes Release 40.15
**
**	C prototypes. For use with 32 bit integers only.
*/

struct BoardInfo	*rtgInitBoard(char *BoardName, struct TagItem *Tags);
struct BoardInfo	*rtgInitBoardTags(char *BoardName, ULONG Tags, ...);

BOOL	rtgCreateDisplayInfoData(struct BoardInfo	*bi);
struct ModeInfo *rtgModifyMode(struct ModeInfo *mode, ULONG DisplayID);

struct BitMapExtra *rtgLookUpBitMapExtra(struct BitMap *bm);
struct BitMapExtra *rtgGetBitMapExtra(void);
void rtgAddBitMapExtra(struct BitMapExtra *bme);
void rtgRemoveBitMapExtra(struct BitMapExtra *bme);
void rtgBlitRect(struct RenderInfo *gri, WORD  xsrc, WORD ysrc, WORD xdest, WORD ydest, WORD xsize, WORD ysize, UBYTE mask, RGBFTYPE RGBFormat);
void rtgInvertRect(struct RenderInfo *gri, WORD x, WORD y, WORD xsize, WORD ysize, UBYTE mask, RGBFTYPE RGBFormat);
void rtgFillRect(struct RenderInfo *gri, WORD x, WORD y, WORD xsize, WORD ysize, ULONG pen, UBYTE mask, RGBFTYPE RGBFormat);
void rtgBlitTemplate(struct RenderInfo *gri, struct Template *tmp, WORD x, WORD y, WORD xsize, WORD ysize, UBYTE mask, RGBFTYPE RGBFormat);
void rtgBlitRectNoMaskComplete(struct RenderInfo *sri, struct RenderInfo *dri, WORD xsrc, WORD ysrc, WORD xdest, WORD ydest, WORD xsize, WORD ysize, UBYTE opcode, RGBFTYPE RGBFormat);
void rtgInvertEllipse(struct RenderInfo *gri, WORD x, WORD y, WORD a, WORD b, UBYTE mask, RGBFTYPE RGBFormat);
void rtgDrawEllipse(struct RenderInfo *gri, WORD x, WORD y, WORD a, WORD b, ULONG pen, UBYTE mask, RGBFTYPE RGBFormat);
void rtgSaveMouseRect(struct BoardInfo *bi, struct BitMapExtra *bme, struct Rectangle *rect, WORD x, WORD y);
void rtgRestoreMouseRect(struct BoardInfo *bi, struct BitMapExtra *bme, struct Rectangle *rect, WORD x, WORD y);
void rtgPaintMouse(struct BoardInfo *bi, struct BitMapExtra *bme);

LONG rtgOldStyleLock(BOOL Exclusive);
void rtgOldStyleUnlock(LONG Handle);

ULONG rtgEncodeColor(UBYTE Red, UBYTE Green, UBYTE Blue, RGBFTYPE RGBFormat);

struct SpecialFeature *rtgCreateSpecialFeature(struct Screen *Screen, ULONG Type, struct TagItem *Tags);
struct SpecialFeature *rtgCreateSpecialFeatureTags(struct Screen *Screen, ULONG Type, ULONG Tags, ...);
BOOL rtgDeleteSpecialFeature(struct SpecialFeature *spec);
BOOL rtgSetSpecialFeatureAttrs(struct SpecialFeature *spec, struct TagItem *Tags);
BOOL rtgSetSpecialFeatureAttrsTags(struct SpecialFeature *spec, ULONG Tags, ...);
BOOL rtgGetSpecialFeatureAttrs(struct SpecialFeature *spec, struct TagItem *Tags);
BOOL rtgGetSpecialFeatureAttrsTags(struct SpecialFeature *spec, ULONG Tags, ...);

struct BitMap *rtgAllocBitMap(struct BoardInfo *bi, ULONG Width, ULONG Height, struct TagItem *Tags);
struct BitMap *rtgAllocBitMapTags(struct BoardInfo *bi, ULONG Width, ULONG Height, ULONG Tags, ...);
BOOL rtgFreeBitMap(struct BoardInfo *bi, struct BitMap *bm, struct TagItem *Tags);
BOOL rtgFreeBitMapTags(struct BoardInfo *bi, struct BitMap *bm, ULONG Tags, ...);
ULONG rtgGetBitMapAttr(struct BoardInfo *bi, struct BitMap *bm, ULONG attribute);

struct LibResolution *rtgLookUpResolution(ULONG DisplayID);
void rtgAddHashResolution(struct LibResolution *res);
BOOL rtgRemoveHashResolution(struct LibResolution *res);

void rtgClipPixel(struct RastPort *rp, WORD x, WORD y, void (*func)());
void rtgClipRectangle(struct RastPort *rp, WORD x, WORD y, WORD width, WORD height, void (*func)());
void rtgClipRectangleWithSource(APTR SrcDesc, WORD srcx, WORD srcy, struct RastPort *rp, WORD dstx, WORD dsty, WORD width, WORD height, void (*func)());

APTR rtgLookUpHashExtra(APTR Hash);
BOOL rtgCreateHashExtra(APTR Hash, APTR HashExtra);
BOOL rtgDisposeHashExtra(APTR Hash);

void rtgLock(struct p96SemaphoreHandle *Handle, BOOL Exclusive);
void rtgUnlock(struct p96SemaphoreHandle *Handle);

void rtgPutPixel(APTR Memory, UWORD BytesPerRow, UWORD x, UWORD y, ULONG color, ULONG rgbformat);
ULONG rtgGetPixel(APTR Memory, UWORD BytesPerRow, UWORD x, UWORD y, ULONG rgbformat);
BOOL rtgExtractColorPlane(struct RenderInfo *ri, UWORD SrcX, UWORD SrcY, UWORD *Plane, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, UWORD BytesPerRow, ULONG Color);

void rtgAddMonitorInfoHook(struct Hook *hk);
void rtgRemMonitorInfoHook(struct Hook *hk);

#endif	 /* CLIB_RTG_PROTOS_H */
