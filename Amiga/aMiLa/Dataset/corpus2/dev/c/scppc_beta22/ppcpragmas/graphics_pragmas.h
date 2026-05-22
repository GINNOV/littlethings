/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_GRAPHICS_H
#define _PPCPRAGMA_GRAPHICS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__GRAPHICS_H
#include <ppcinline/graphics.h>
#endif
#else

#ifndef POWERUP_PPCLIB_INTERFACE_H
#include <powerup/ppclib/interface.h>
#endif

#ifndef POWERUP_GCCLIB_PROTOS_H
#include <powerup/gcclib/powerup_protos.h>
#endif

#ifndef NO_PPCINLINE_STDARG
#define NO_PPCINLINE_STDARG
#endif/* SAS C PPC inlines */

#ifndef GRAPHICS_BASE_NAME
#define GRAPHICS_BASE_NAME GfxBase
#endif /* !GRAPHICS_BASE_NAME */

#define	AddAnimOb(anOb, anKey, rp)	_AddAnimOb(GRAPHICS_BASE_NAME, anOb, anKey, rp)

static __inline void
_AddAnimOb(void *GfxBase, struct AnimOb *anOb, struct AnimOb **anKey, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) anOb;
	MyCaos.a1		=(ULONG) anKey;
	MyCaos.a2		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AddBob(bob, rp)	_AddBob(GRAPHICS_BASE_NAME, bob, rp)

static __inline void
_AddBob(void *GfxBase, struct Bob *bob, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bob;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AddFont(textFont)	_AddFont(GRAPHICS_BASE_NAME, textFont)

static __inline void
_AddFont(void *GfxBase, struct TextFont *textFont)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) textFont;
	MyCaos.caos_Un.Offset	=	(-480);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AddVSprite(vSprite, rp)	_AddVSprite(GRAPHICS_BASE_NAME, vSprite, rp)

static __inline void
_AddVSprite(void *GfxBase, struct VSprite *vSprite, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vSprite;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AllocBitMap(sizex, sizey, depth, flags, friend_bitmap)	_AllocBitMap(GRAPHICS_BASE_NAME, sizex, sizey, depth, flags, friend_bitmap)

static __inline struct BitMap *
_AllocBitMap(void *GfxBase, unsigned long sizex, unsigned long sizey, unsigned long depth, unsigned long flags, struct BitMap *friend_bitmap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) sizex;
	MyCaos.d1		=(ULONG) sizey;
	MyCaos.d2		=(ULONG) depth;
	MyCaos.d3		=(ULONG) flags;
	MyCaos.a0		=(ULONG) friend_bitmap;
	MyCaos.caos_Un.Offset	=	(-918);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct BitMap *)PPCCallOS(&MyCaos));
}

#define	AllocDBufInfo(vp)	_AllocDBufInfo(GRAPHICS_BASE_NAME, vp)

static __inline struct DBufInfo *
_AllocDBufInfo(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-966);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct DBufInfo *)PPCCallOS(&MyCaos));
}

#define	AllocRaster(width, height)	_AllocRaster(GRAPHICS_BASE_NAME, width, height)

static __inline PLANEPTR
_AllocRaster(void *GfxBase, unsigned long width, unsigned long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) width;
	MyCaos.d1		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-492);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((PLANEPTR)PPCCallOS(&MyCaos));
}

#define	AllocSpriteDataA(bm, tags)	_AllocSpriteDataA(GRAPHICS_BASE_NAME, bm, tags)

static __inline struct ExtSprite *
_AllocSpriteDataA(void *GfxBase, struct BitMap *bm, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a2		=(ULONG) bm;
	MyCaos.a1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-1020);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct ExtSprite *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AllocSpriteData(a0, tags...) \
	({ULONG _tags[] = { tags }; AllocSpriteDataA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AndRectRegion(region, rectangle)	_AndRectRegion(GRAPHICS_BASE_NAME, region, rectangle)

static __inline void
_AndRectRegion(void *GfxBase, struct Region *region, struct Rectangle *rectangle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.a1		=(ULONG) rectangle;
	MyCaos.caos_Un.Offset	=	(-504);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AndRegionRegion(srcRegion, destRegion)	_AndRegionRegion(GRAPHICS_BASE_NAME, srcRegion, destRegion)

static __inline BOOL
_AndRegionRegion(void *GfxBase, struct Region *srcRegion, struct Region *destRegion)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRegion;
	MyCaos.a1		=(ULONG) destRegion;
	MyCaos.caos_Un.Offset	=	(-624);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	Animate(anKey, rp)	_Animate(GRAPHICS_BASE_NAME, anKey, rp)

static __inline void
_Animate(void *GfxBase, struct AnimOb **anKey, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) anKey;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AreaDraw(rp, x, y)	_AreaDraw(GRAPHICS_BASE_NAME, rp, x, y)

static __inline LONG
_AreaDraw(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AreaEllipse(rp, xCenter, yCenter, a, b)	_AreaEllipse(GRAPHICS_BASE_NAME, rp, xCenter, yCenter, a, b)

static __inline LONG
_AreaEllipse(void *GfxBase, struct RastPort *rp, long xCenter, long yCenter, long a, long b)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xCenter;
	MyCaos.d1		=(ULONG) yCenter;
	MyCaos.d2		=(ULONG) a;
	MyCaos.d3		=(ULONG) b;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AreaEnd(rp)	_AreaEnd(GRAPHICS_BASE_NAME, rp)

static __inline LONG
_AreaEnd(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AreaMove(rp, x, y)	_AreaMove(GRAPHICS_BASE_NAME, rp, x, y)

static __inline LONG
_AreaMove(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AskFont(rp, textAttr)	_AskFont(GRAPHICS_BASE_NAME, rp, textAttr)

static __inline void
_AskFont(void *GfxBase, struct RastPort *rp, struct TextAttr *textAttr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) textAttr;
	MyCaos.caos_Un.Offset	=	(-474);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	AskSoftStyle(rp)	_AskSoftStyle(GRAPHICS_BASE_NAME, rp)

static __inline ULONG
_AskSoftStyle(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	AttachPalExtra(cm, vp)	_AttachPalExtra(GRAPHICS_BASE_NAME, cm, vp)

static __inline LONG
_AttachPalExtra(void *GfxBase, struct ColorMap *cm, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.a1		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-834);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AttemptLockLayerRom(layer)	_AttemptLockLayerRom(GRAPHICS_BASE_NAME, layer)

static __inline BOOL
_AttemptLockLayerRom(void *GfxBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a5		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-654);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	BestModeIDA(tags)	_BestModeIDA(GRAPHICS_BASE_NAME, tags)

static __inline ULONG
_BestModeIDA(void *GfxBase, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-1050);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define BestModeID(tags...) \
	({ULONG _tags[] = { tags }; BestModeIDA((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	BitMapScale(bitScaleArgs)	_BitMapScale(GRAPHICS_BASE_NAME, bitScaleArgs)

static __inline void
_BitMapScale(void *GfxBase, struct BitScaleArgs *bitScaleArgs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bitScaleArgs;
	MyCaos.caos_Un.Offset	=	(-678);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	BltBitMap(srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA)	_BltBitMap(GRAPHICS_BASE_NAME, srcBitMap, xSrc, ySrc, destBitMap, xDest, yDest, xSize, ySize, minterm, mask, tempA)

static __inline LONG
_BltBitMap(void *GfxBase, struct BitMap *srcBitMap, long xSrc, long ySrc, struct BitMap *destBitMap, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, unsigned long mask, PLANEPTR tempA)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcBitMap;
	MyCaos.d0		=(ULONG) xSrc;
	MyCaos.d1		=(ULONG) ySrc;
	MyCaos.a1		=(ULONG) destBitMap;
	MyCaos.d2		=(ULONG) xDest;
	MyCaos.d3		=(ULONG) yDest;
	MyCaos.d4		=(ULONG) xSize;
	MyCaos.d5		=(ULONG) ySize;
	MyCaos.d6		=(ULONG) minterm;
	MyCaos.d7		=(ULONG) mask;
	MyCaos.a2		=(ULONG) tempA;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	BltBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm)	_BltBitMapRastPort(GRAPHICS_BASE_NAME, srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm)

static __inline void
_BltBitMapRastPort(void *GfxBase, struct BitMap *srcBitMap, long xSrc, long ySrc, struct RastPort *destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcBitMap;
	MyCaos.d0		=(ULONG) xSrc;
	MyCaos.d1		=(ULONG) ySrc;
	MyCaos.a1		=(ULONG) destRP;
	MyCaos.d2		=(ULONG) xDest;
	MyCaos.d3		=(ULONG) yDest;
	MyCaos.d4		=(ULONG) xSize;
	MyCaos.d5		=(ULONG) ySize;
	MyCaos.d6		=(ULONG) minterm;
	MyCaos.caos_Un.Offset	=	(-606);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	BltClear(memBlock, byteCount, flags)	_BltClear(GRAPHICS_BASE_NAME, memBlock, byteCount, flags)

static __inline void
_BltClear(void *GfxBase, PLANEPTR memBlock, unsigned long byteCount, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) memBlock;
	MyCaos.d0		=(ULONG) byteCount;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-300);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	BltMaskBitMapRastPort(srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask)	_BltMaskBitMapRastPort(GRAPHICS_BASE_NAME, srcBitMap, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm, bltMask)

static __inline void
_BltMaskBitMapRastPort(void *GfxBase, struct BitMap *srcBitMap, long xSrc, long ySrc, struct RastPort *destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm, PLANEPTR bltMask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcBitMap;
	MyCaos.d0		=(ULONG) xSrc;
	MyCaos.d1		=(ULONG) ySrc;
	MyCaos.a1		=(ULONG) destRP;
	MyCaos.d2		=(ULONG) xDest;
	MyCaos.d3		=(ULONG) yDest;
	MyCaos.d4		=(ULONG) xSize;
	MyCaos.d5		=(ULONG) ySize;
	MyCaos.d6		=(ULONG) minterm;
	MyCaos.a2		=(ULONG) bltMask;
	MyCaos.caos_Un.Offset	=	(-636);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	BltPattern(rp, mask, xMin, yMin, xMax, yMax, maskBPR)	_BltPattern(GRAPHICS_BASE_NAME, rp, mask, xMin, yMin, xMax, yMax, maskBPR)

static __inline void
_BltPattern(void *GfxBase, struct RastPort *rp, PLANEPTR mask, long xMin, long yMin, long xMax, long yMax, unsigned long maskBPR)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) mask;
	MyCaos.d0		=(ULONG) xMin;
	MyCaos.d1		=(ULONG) yMin;
	MyCaos.d2		=(ULONG) xMax;
	MyCaos.d3		=(ULONG) yMax;
	MyCaos.d4		=(ULONG) maskBPR;
	MyCaos.caos_Un.Offset	=	(-312);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	BltTemplate(source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize)	_BltTemplate(GRAPHICS_BASE_NAME, source, xSrc, srcMod, destRP, xDest, yDest, xSize, ySize)

static __inline void
_BltTemplate(void *GfxBase, PLANEPTR source, long xSrc, long srcMod, struct RastPort *destRP, long xDest, long yDest, long xSize, long ySize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) source;
	MyCaos.d0		=(ULONG) xSrc;
	MyCaos.d1		=(ULONG) srcMod;
	MyCaos.a1		=(ULONG) destRP;
	MyCaos.d2		=(ULONG) xDest;
	MyCaos.d3		=(ULONG) yDest;
	MyCaos.d4		=(ULONG) xSize;
	MyCaos.d5		=(ULONG) ySize;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CBump(copList)	_CBump(GRAPHICS_BASE_NAME, copList)

static __inline void
_CBump(void *GfxBase, struct UCopList *copList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) copList;
	MyCaos.caos_Un.Offset	=	(-366);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CMove(copList, destination, data)	_CMove(GRAPHICS_BASE_NAME, copList, destination, data)

static __inline void
_CMove(void *GfxBase, struct UCopList *copList, APTR destination, long data)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) copList;
	MyCaos.d0		=(ULONG) destination;
	MyCaos.d1		=(ULONG) data;
	MyCaos.caos_Un.Offset	=	(-372);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CWait(copList, v, h)	_CWait(GRAPHICS_BASE_NAME, copList, v, h)

static __inline void
_CWait(void *GfxBase, struct UCopList *copList, long v, long h)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) copList;
	MyCaos.d0		=(ULONG) v;
	MyCaos.d1		=(ULONG) h;
	MyCaos.caos_Un.Offset	=	(-378);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CalcIVG(v, vp)	_CalcIVG(GRAPHICS_BASE_NAME, v, vp)

static __inline UWORD
_CalcIVG(void *GfxBase, struct View *v, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) v;
	MyCaos.a1		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-828);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	ChangeExtSpriteA(vp, oldsprite, newsprite, tags)	_ChangeExtSpriteA(GRAPHICS_BASE_NAME, vp, oldsprite, newsprite, tags)

static __inline LONG
_ChangeExtSpriteA(void *GfxBase, struct ViewPort *vp, struct ExtSprite *oldsprite, struct ExtSprite *newsprite, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) oldsprite;
	MyCaos.a2		=(ULONG) newsprite;
	MyCaos.a3		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-1026);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ChangeExtSprite(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; ChangeExtSpriteA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ChangeSprite(vp, sprite, newData)	_ChangeSprite(GRAPHICS_BASE_NAME, vp, sprite, newData)

static __inline void
_ChangeSprite(void *GfxBase, struct ViewPort *vp, struct SimpleSprite *sprite, PLANEPTR newData)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) sprite;
	MyCaos.a2		=(ULONG) newData;
	MyCaos.caos_Un.Offset	=	(-420);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ChangeVPBitMap(vp, bm, db)	_ChangeVPBitMap(GRAPHICS_BASE_NAME, vp, bm, db)

static __inline void
_ChangeVPBitMap(void *GfxBase, struct ViewPort *vp, struct BitMap *bm, struct DBufInfo *db)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.a2		=(ULONG) db;
	MyCaos.caos_Un.Offset	=	(-942);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearEOL(rp)	_ClearEOL(GRAPHICS_BASE_NAME, rp)

static __inline void
_ClearEOL(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearRectRegion(region, rectangle)	_ClearRectRegion(GRAPHICS_BASE_NAME, region, rectangle)

static __inline BOOL
_ClearRectRegion(void *GfxBase, struct Region *region, struct Rectangle *rectangle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.a1		=(ULONG) rectangle;
	MyCaos.caos_Un.Offset	=	(-522);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ClearRegion(region)	_ClearRegion(GRAPHICS_BASE_NAME, region)

static __inline void
_ClearRegion(void *GfxBase, struct Region *region)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.caos_Un.Offset	=	(-528);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearScreen(rp)	_ClearScreen(GRAPHICS_BASE_NAME, rp)

static __inline void
_ClearScreen(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ClipBlit(srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm)	_ClipBlit(GRAPHICS_BASE_NAME, srcRP, xSrc, ySrc, destRP, xDest, yDest, xSize, ySize, minterm)

static __inline void
_ClipBlit(void *GfxBase, struct RastPort *srcRP, long xSrc, long ySrc, struct RastPort *destRP, long xDest, long yDest, long xSize, long ySize, unsigned long minterm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRP;
	MyCaos.d0		=(ULONG) xSrc;
	MyCaos.d1		=(ULONG) ySrc;
	MyCaos.a1		=(ULONG) destRP;
	MyCaos.d2		=(ULONG) xDest;
	MyCaos.d3		=(ULONG) yDest;
	MyCaos.d4		=(ULONG) xSize;
	MyCaos.d5		=(ULONG) ySize;
	MyCaos.d6		=(ULONG) minterm;
	MyCaos.caos_Un.Offset	=	(-552);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseFont(textFont)	_CloseFont(GRAPHICS_BASE_NAME, textFont)

static __inline void
_CloseFont(void *GfxBase, struct TextFont *textFont)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) textFont;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseMonitor(monitorSpec)	_CloseMonitor(GRAPHICS_BASE_NAME, monitorSpec)

static __inline BOOL
_CloseMonitor(void *GfxBase, struct MonitorSpec *monitorSpec)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) monitorSpec;
	MyCaos.caos_Un.Offset	=	(-720);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CoerceMode(vp, monitorid, flags)	_CoerceMode(GRAPHICS_BASE_NAME, vp, monitorid, flags)

static __inline ULONG
_CoerceMode(void *GfxBase, struct ViewPort *vp, unsigned long monitorid, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.d0		=(ULONG) monitorid;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-936);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CopySBitMap(layer)	_CopySBitMap(GRAPHICS_BASE_NAME, layer)

static __inline void
_CopySBitMap(void *GfxBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-450);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	DisownBlitter()	_DisownBlitter(GRAPHICS_BASE_NAME)

static __inline void
_DisownBlitter(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-462);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	DisposeRegion(region)	_DisposeRegion(GRAPHICS_BASE_NAME, region)

static __inline void
_DisposeRegion(void *GfxBase, struct Region *region)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.caos_Un.Offset	=	(-534);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	DoCollision(rp)	_DoCollision(GRAPHICS_BASE_NAME, rp)

static __inline void
_DoCollision(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	Draw(rp, x, y)	_Draw(GRAPHICS_BASE_NAME, rp, x, y)

static __inline void
_Draw(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	DrawEllipse(rp, xCenter, yCenter, a, b)	_DrawEllipse(GRAPHICS_BASE_NAME, rp, xCenter, yCenter, a, b)

static __inline void
_DrawEllipse(void *GfxBase, struct RastPort *rp, long xCenter, long yCenter, long a, long b)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xCenter;
	MyCaos.d1		=(ULONG) yCenter;
	MyCaos.d2		=(ULONG) a;
	MyCaos.d3		=(ULONG) b;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	DrawGList(rp, vp)	_DrawGList(GRAPHICS_BASE_NAME, rp, vp)

static __inline void
_DrawGList(void *GfxBase, struct RastPort *rp, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	EraseRect(rp, xMin, yMin, xMax, yMax)	_EraseRect(GRAPHICS_BASE_NAME, rp, xMin, yMin, xMax, yMax)

static __inline void
_EraseRect(void *GfxBase, struct RastPort *rp, long xMin, long yMin, long xMax, long yMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xMin;
	MyCaos.d1		=(ULONG) yMin;
	MyCaos.d2		=(ULONG) xMax;
	MyCaos.d3		=(ULONG) yMax;
	MyCaos.caos_Un.Offset	=	(-810);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ExtendFont(font, fontTags)	_ExtendFont(GRAPHICS_BASE_NAME, font, fontTags)

static __inline ULONG
_ExtendFont(void *GfxBase, struct TextFont *font, struct TagItem *fontTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) font;
	MyCaos.a1		=(ULONG) fontTags;
	MyCaos.caos_Un.Offset	=	(-816);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ExtendFontTags(a0, tags...) \
	({ULONG _tags[] = { tags }; ExtendFont((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	FindColor(cm, r, g, b, maxcolor)	_FindColor(GRAPHICS_BASE_NAME, cm, r, g, b, maxcolor)

static __inline LONG
_FindColor(void *GfxBase, struct ColorMap *cm, unsigned long r, unsigned long g, unsigned long b, long maxcolor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a3		=(ULONG) cm;
	MyCaos.d1		=(ULONG) r;
	MyCaos.d2		=(ULONG) g;
	MyCaos.d3		=(ULONG) b;
	MyCaos.d4		=(ULONG) maxcolor;
	MyCaos.caos_Un.Offset	=	(-1008);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FindDisplayInfo(displayID)	_FindDisplayInfo(GRAPHICS_BASE_NAME, displayID)

static __inline DisplayInfoHandle
_FindDisplayInfo(void *GfxBase, unsigned long displayID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) displayID;
	MyCaos.caos_Un.Offset	=	(-726);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((DisplayInfoHandle)PPCCallOS(&MyCaos));
}

#define	Flood(rp, mode, x, y)	_Flood(GRAPHICS_BASE_NAME, rp, mode, x, y)

static __inline BOOL
_Flood(void *GfxBase, struct RastPort *rp, unsigned long mode, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d2		=(ULONG) mode;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-330);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FontExtent(font, fontExtent)	_FontExtent(GRAPHICS_BASE_NAME, font, fontExtent)

static __inline void
_FontExtent(void *GfxBase, struct TextFont *font, struct TextExtent *fontExtent)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) font;
	MyCaos.a1		=(ULONG) fontExtent;
	MyCaos.caos_Un.Offset	=	(-762);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeBitMap(bm)	_FreeBitMap(GRAPHICS_BASE_NAME, bm)

static __inline void
_FreeBitMap(void *GfxBase, struct BitMap *bm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bm;
	MyCaos.caos_Un.Offset	=	(-924);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeColorMap(colorMap)	_FreeColorMap(GRAPHICS_BASE_NAME, colorMap)

static __inline void
_FreeColorMap(void *GfxBase, struct ColorMap *colorMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) colorMap;
	MyCaos.caos_Un.Offset	=	(-576);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeCopList(copList)	_FreeCopList(GRAPHICS_BASE_NAME, copList)

static __inline void
_FreeCopList(void *GfxBase, struct CopList *copList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) copList;
	MyCaos.caos_Un.Offset	=	(-546);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeCprList(cprList)	_FreeCprList(GRAPHICS_BASE_NAME, cprList)

static __inline void
_FreeCprList(void *GfxBase, struct cprlist *cprList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cprList;
	MyCaos.caos_Un.Offset	=	(-564);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeDBufInfo(dbi)	_FreeDBufInfo(GRAPHICS_BASE_NAME, dbi)

static __inline void
_FreeDBufInfo(void *GfxBase, struct DBufInfo *dbi)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) dbi;
	MyCaos.caos_Un.Offset	=	(-972);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeGBuffers(anOb, rp, flag)	_FreeGBuffers(GRAPHICS_BASE_NAME, anOb, rp, flag)

static __inline void
_FreeGBuffers(void *GfxBase, struct AnimOb *anOb, struct RastPort *rp, long flag)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) anOb;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) flag;
	MyCaos.caos_Un.Offset	=	(-600);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeRaster(p, width, height)	_FreeRaster(GRAPHICS_BASE_NAME, p, width, height)

static __inline void
_FreeRaster(void *GfxBase, PLANEPTR p, unsigned long width, unsigned long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) p;
	MyCaos.d0		=(ULONG) width;
	MyCaos.d1		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-498);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeSprite(num)	_FreeSprite(GRAPHICS_BASE_NAME, num)

static __inline void
_FreeSprite(void *GfxBase, long num)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) num;
	MyCaos.caos_Un.Offset	=	(-414);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeSpriteData(sp)	_FreeSpriteData(GRAPHICS_BASE_NAME, sp)

static __inline void
_FreeSpriteData(void *GfxBase, struct ExtSprite *sp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a2		=(ULONG) sp;
	MyCaos.caos_Un.Offset	=	(-1032);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeVPortCopLists(vp)	_FreeVPortCopLists(GRAPHICS_BASE_NAME, vp)

static __inline void
_FreeVPortCopLists(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-540);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	GetAPen(rp)	_GetAPen(GRAPHICS_BASE_NAME, rp)

static __inline ULONG
_GetAPen(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-858);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetBPen(rp)	_GetBPen(GRAPHICS_BASE_NAME, rp)

static __inline ULONG
_GetBPen(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-864);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetBitMapAttr(bm, attrnum)	_GetBitMapAttr(GRAPHICS_BASE_NAME, bm, attrnum)

static __inline ULONG
_GetBitMapAttr(void *GfxBase, struct BitMap *bm, unsigned long attrnum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bm;
	MyCaos.d1		=(ULONG) attrnum;
	MyCaos.caos_Un.Offset	=	(-960);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetColorMap(entries)	_GetColorMap(GRAPHICS_BASE_NAME, entries)

static __inline struct ColorMap *
_GetColorMap(void *GfxBase, long entries)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) entries;
	MyCaos.caos_Un.Offset	=	(-570);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct ColorMap *)PPCCallOS(&MyCaos));
}

#define	GetDisplayInfoData(handle, buf, size, tagID, displayID)	_GetDisplayInfoData(GRAPHICS_BASE_NAME, handle, buf, size, tagID, displayID)

static __inline ULONG
_GetDisplayInfoData(void *GfxBase, DisplayInfoHandle handle, UBYTE *buf, unsigned long size, unsigned long tagID, unsigned long displayID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) handle;
	MyCaos.a1		=(ULONG) buf;
	MyCaos.d0		=(ULONG) size;
	MyCaos.d1		=(ULONG) tagID;
	MyCaos.d2		=(ULONG) displayID;
	MyCaos.caos_Un.Offset	=	(-756);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetDrMd(rp)	_GetDrMd(GRAPHICS_BASE_NAME, rp)

static __inline ULONG
_GetDrMd(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-870);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetExtSpriteA(ss, tags)	_GetExtSpriteA(GRAPHICS_BASE_NAME, ss, tags)

static __inline LONG
_GetExtSpriteA(void *GfxBase, struct ExtSprite *ss, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a2		=(ULONG) ss;
	MyCaos.a1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-930);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define GetExtSprite(a0, tags...) \
	({ULONG _tags[] = { tags }; GetExtSpriteA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GetGBuffers(anOb, rp, flag)	_GetGBuffers(GRAPHICS_BASE_NAME, anOb, rp, flag)

static __inline BOOL
_GetGBuffers(void *GfxBase, struct AnimOb *anOb, struct RastPort *rp, long flag)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) anOb;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) flag;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	GetOutlinePen(rp)	_GetOutlinePen(GRAPHICS_BASE_NAME, rp)

static __inline ULONG
_GetOutlinePen(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-876);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetRGB32(cm, firstcolor, ncolors, table)	_GetRGB32(GRAPHICS_BASE_NAME, cm, firstcolor, ncolors, table)

static __inline void
_GetRGB32(void *GfxBase, struct ColorMap *cm, unsigned long firstcolor, unsigned long ncolors, ULONG *table)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.d0		=(ULONG) firstcolor;
	MyCaos.d1		=(ULONG) ncolors;
	MyCaos.a1		=(ULONG) table;
	MyCaos.caos_Un.Offset	=	(-900);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	GetRGB4(colorMap, entry)	_GetRGB4(GRAPHICS_BASE_NAME, colorMap, entry)

static __inline ULONG
_GetRGB4(void *GfxBase, struct ColorMap *colorMap, long entry)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) colorMap;
	MyCaos.d0		=(ULONG) entry;
	MyCaos.caos_Un.Offset	=	(-582);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetRPAttrsA(rp, tags)	_GetRPAttrsA(GRAPHICS_BASE_NAME, rp, tags)

static __inline void
_GetRPAttrsA(void *GfxBase, struct RastPort *rp, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-1044);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define GetRPAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; GetRPAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GetSprite(sprite, num)	_GetSprite(GRAPHICS_BASE_NAME, sprite, num)

static __inline WORD
_GetSprite(void *GfxBase, struct SimpleSprite *sprite, long num)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sprite;
	MyCaos.d0		=(ULONG) num;
	MyCaos.caos_Un.Offset	=	(-408);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#define	GetVPModeID(vp)	_GetVPModeID(GRAPHICS_BASE_NAME, vp)

static __inline LONG
_GetVPModeID(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-792);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GfxAssociate(associateNode, gfxNodePtr)	_GfxAssociate(GRAPHICS_BASE_NAME, associateNode, gfxNodePtr)

static __inline void
_GfxAssociate(void *GfxBase, APTR associateNode, APTR gfxNodePtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) associateNode;
	MyCaos.a1		=(ULONG) gfxNodePtr;
	MyCaos.caos_Un.Offset	=	(-672);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	GfxFree(gfxNodePtr)	_GfxFree(GRAPHICS_BASE_NAME, gfxNodePtr)

static __inline void
_GfxFree(void *GfxBase, APTR gfxNodePtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gfxNodePtr;
	MyCaos.caos_Un.Offset	=	(-666);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	GfxLookUp(associateNode)	_GfxLookUp(GRAPHICS_BASE_NAME, associateNode)

static __inline APTR
_GfxLookUp(void *GfxBase, APTR associateNode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) associateNode;
	MyCaos.caos_Un.Offset	=	(-702);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	GfxNew(gfxNodeType)	_GfxNew(GRAPHICS_BASE_NAME, gfxNodeType)

static __inline APTR
_GfxNew(void *GfxBase, unsigned long gfxNodeType)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) gfxNodeType;
	MyCaos.caos_Un.Offset	=	(-660);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	InitArea(areaInfo, vectorBuffer, maxVectors)	_InitArea(GRAPHICS_BASE_NAME, areaInfo, vectorBuffer, maxVectors)

static __inline void
_InitArea(void *GfxBase, struct AreaInfo *areaInfo, APTR vectorBuffer, long maxVectors)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) areaInfo;
	MyCaos.a1		=(ULONG) vectorBuffer;
	MyCaos.d0		=(ULONG) maxVectors;
	MyCaos.caos_Un.Offset	=	(-282);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitBitMap(bitMap, depth, width, height)	_InitBitMap(GRAPHICS_BASE_NAME, bitMap, depth, width, height)

static __inline void
_InitBitMap(void *GfxBase, struct BitMap *bitMap, long depth, long width, long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bitMap;
	MyCaos.d0		=(ULONG) depth;
	MyCaos.d1		=(ULONG) width;
	MyCaos.d2		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-390);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitGMasks(anOb)	_InitGMasks(GRAPHICS_BASE_NAME, anOb)

static __inline void
_InitGMasks(void *GfxBase, struct AnimOb *anOb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) anOb;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitGels(head, tail, gelsInfo)	_InitGels(GRAPHICS_BASE_NAME, head, tail, gelsInfo)

static __inline void
_InitGels(void *GfxBase, struct VSprite *head, struct VSprite *tail, struct GelsInfo *gelsInfo)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) head;
	MyCaos.a1		=(ULONG) tail;
	MyCaos.a2		=(ULONG) gelsInfo;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitMasks(vSprite)	_InitMasks(GRAPHICS_BASE_NAME, vSprite)

static __inline void
_InitMasks(void *GfxBase, struct VSprite *vSprite)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vSprite;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitRastPort(rp)	_InitRastPort(GRAPHICS_BASE_NAME, rp)

static __inline void
_InitRastPort(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitTmpRas(tmpRas, buffer, size)	_InitTmpRas(GRAPHICS_BASE_NAME, tmpRas, buffer, size)

static __inline struct TmpRas *
_InitTmpRas(void *GfxBase, struct TmpRas *tmpRas, PLANEPTR buffer, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tmpRas;
	MyCaos.a1		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-468);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct TmpRas *)PPCCallOS(&MyCaos));
}

#define	InitVPort(vp)	_InitVPort(GRAPHICS_BASE_NAME, vp)

static __inline void
_InitVPort(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	InitView(view)	_InitView(GRAPHICS_BASE_NAME, view)

static __inline void
_InitView(void *GfxBase, struct View *view)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) view;
	MyCaos.caos_Un.Offset	=	(-360);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	LoadRGB32(vp, table)	_LoadRGB32(GRAPHICS_BASE_NAME, vp, table)

static __inline void
_LoadRGB32(void *GfxBase, struct ViewPort *vp, ULONG *table)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) table;
	MyCaos.caos_Un.Offset	=	(-882);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	LoadRGB4(vp, colors, count)	_LoadRGB4(GRAPHICS_BASE_NAME, vp, colors, count)

static __inline void
_LoadRGB4(void *GfxBase, struct ViewPort *vp, UWORD *colors, long count)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) colors;
	MyCaos.d0		=(ULONG) count;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	LoadView(view)	_LoadView(GRAPHICS_BASE_NAME, view)

static __inline void
_LoadView(void *GfxBase, struct View *view)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) view;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	LockLayerRom(layer)	_LockLayerRom(GRAPHICS_BASE_NAME, layer)

static __inline void
_LockLayerRom(void *GfxBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a5		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-432);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	MakeVPort(view, vp)	_MakeVPort(GRAPHICS_BASE_NAME, view, vp)

static __inline ULONG
_MakeVPort(void *GfxBase, struct View *view, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) view;
	MyCaos.a1		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ModeNotAvailable(modeID)	_ModeNotAvailable(GRAPHICS_BASE_NAME, modeID)

static __inline LONG
_ModeNotAvailable(void *GfxBase, unsigned long modeID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) modeID;
	MyCaos.caos_Un.Offset	=	(-798);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Move(rp, x, y)	_Move(GRAPHICS_BASE_NAME, rp, x, y)

static __inline void
_Move(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	MoveSprite(vp, sprite, x, y)	_MoveSprite(GRAPHICS_BASE_NAME, vp, sprite, x, y)

static __inline void
_MoveSprite(void *GfxBase, struct ViewPort *vp, struct SimpleSprite *sprite, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.a1		=(ULONG) sprite;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-426);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	MrgCop(view)	_MrgCop(GRAPHICS_BASE_NAME, view)

static __inline ULONG
_MrgCop(void *GfxBase, struct View *view)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) view;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	NewRegion()	_NewRegion(GRAPHICS_BASE_NAME)

static __inline struct Region *
_NewRegion(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-516);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct Region *)PPCCallOS(&MyCaos));
}

#define	NextDisplayInfo(displayID)	_NextDisplayInfo(GRAPHICS_BASE_NAME, displayID)

static __inline ULONG
_NextDisplayInfo(void *GfxBase, unsigned long displayID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) displayID;
	MyCaos.caos_Un.Offset	=	(-732);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ObtainBestPenA(cm, r, g, b, tags)	_ObtainBestPenA(GRAPHICS_BASE_NAME, cm, r, g, b, tags)

static __inline LONG
_ObtainBestPenA(void *GfxBase, struct ColorMap *cm, unsigned long r, unsigned long g, unsigned long b, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.d1		=(ULONG) r;
	MyCaos.d2		=(ULONG) g;
	MyCaos.d3		=(ULONG) b;
	MyCaos.a1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-840);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ObtainBestPen(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; ObtainBestPenA((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ObtainPen(cm, n, r, g, b, f)	_ObtainPen(GRAPHICS_BASE_NAME, cm, n, r, g, b, f)

static __inline ULONG
_ObtainPen(void *GfxBase, struct ColorMap *cm, unsigned long n, unsigned long r, unsigned long g, unsigned long b, long f)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.d0		=(ULONG) n;
	MyCaos.d1		=(ULONG) r;
	MyCaos.d2		=(ULONG) g;
	MyCaos.d3		=(ULONG) b;
	MyCaos.d4		=(ULONG) f;
	MyCaos.caos_Un.Offset	=	(-954);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	OpenFont(textAttr)	_OpenFont(GRAPHICS_BASE_NAME, textAttr)

static __inline struct TextFont *
_OpenFont(void *GfxBase, struct TextAttr *textAttr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) textAttr;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct TextFont *)PPCCallOS(&MyCaos));
}

#define	OpenMonitor(monitorName, displayID)	_OpenMonitor(GRAPHICS_BASE_NAME, monitorName, displayID)

static __inline struct MonitorSpec *
_OpenMonitor(void *GfxBase, STRPTR monitorName, unsigned long displayID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) monitorName;
	MyCaos.d0		=(ULONG) displayID;
	MyCaos.caos_Un.Offset	=	(-714);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct MonitorSpec *)PPCCallOS(&MyCaos));
}

#define	OrRectRegion(region, rectangle)	_OrRectRegion(GRAPHICS_BASE_NAME, region, rectangle)

static __inline BOOL
_OrRectRegion(void *GfxBase, struct Region *region, struct Rectangle *rectangle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.a1		=(ULONG) rectangle;
	MyCaos.caos_Un.Offset	=	(-510);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	OrRegionRegion(srcRegion, destRegion)	_OrRegionRegion(GRAPHICS_BASE_NAME, srcRegion, destRegion)

static __inline BOOL
_OrRegionRegion(void *GfxBase, struct Region *srcRegion, struct Region *destRegion)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRegion;
	MyCaos.a1		=(ULONG) destRegion;
	MyCaos.caos_Un.Offset	=	(-612);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	OwnBlitter()	_OwnBlitter(GRAPHICS_BASE_NAME)

static __inline void
_OwnBlitter(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-456);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	PolyDraw(rp, count, polyTable)	_PolyDraw(GRAPHICS_BASE_NAME, rp, count, polyTable)

static __inline void
_PolyDraw(void *GfxBase, struct RastPort *rp, long count, WORD *polyTable)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) count;
	MyCaos.a0		=(ULONG) polyTable;
	MyCaos.caos_Un.Offset	=	(-336);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	QBSBlit(blit)	_QBSBlit(GRAPHICS_BASE_NAME, blit)

static __inline void
_QBSBlit(void *GfxBase, struct bltnode *blit)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) blit;
	MyCaos.caos_Un.Offset	=	(-294);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	QBlit(blit)	_QBlit(GRAPHICS_BASE_NAME, blit)

static __inline void
_QBlit(void *GfxBase, struct bltnode *blit)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) blit;
	MyCaos.caos_Un.Offset	=	(-276);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadPixel(rp, x, y)	_ReadPixel(GRAPHICS_BASE_NAME, rp, x, y)

static __inline ULONG
_ReadPixel(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-318);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ReadPixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp)	_ReadPixelArray8(GRAPHICS_BASE_NAME, rp, xstart, ystart, xstop, ystop, array, temprp)

static __inline LONG
_ReadPixelArray8(void *GfxBase, struct RastPort *rp, unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE *array, struct RastPort *temprp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xstart;
	MyCaos.d1		=(ULONG) ystart;
	MyCaos.d2		=(ULONG) xstop;
	MyCaos.d3		=(ULONG) ystop;
	MyCaos.a2		=(ULONG) array;
	MyCaos.a1		=(ULONG) temprp;
	MyCaos.caos_Un.Offset	=	(-780);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadPixelLine8(rp, xstart, ystart, width, array, tempRP)	_ReadPixelLine8(GRAPHICS_BASE_NAME, rp, xstart, ystart, width, array, tempRP)

static __inline LONG
_ReadPixelLine8(void *GfxBase, struct RastPort *rp, unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE *array, struct RastPort *tempRP)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xstart;
	MyCaos.d1		=(ULONG) ystart;
	MyCaos.d2		=(ULONG) width;
	MyCaos.a2		=(ULONG) array;
	MyCaos.a1		=(ULONG) tempRP;
	MyCaos.caos_Un.Offset	=	(-768);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RectFill(rp, xMin, yMin, xMax, yMax)	_RectFill(GRAPHICS_BASE_NAME, rp, xMin, yMin, xMax, yMax)

static __inline void
_RectFill(void *GfxBase, struct RastPort *rp, long xMin, long yMin, long xMax, long yMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xMin;
	MyCaos.d1		=(ULONG) yMin;
	MyCaos.d2		=(ULONG) xMax;
	MyCaos.d3		=(ULONG) yMax;
	MyCaos.caos_Un.Offset	=	(-306);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ReleasePen(cm, n)	_ReleasePen(GRAPHICS_BASE_NAME, cm, n)

static __inline void
_ReleasePen(void *GfxBase, struct ColorMap *cm, unsigned long n)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.d0		=(ULONG) n;
	MyCaos.caos_Un.Offset	=	(-948);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	RemFont(textFont)	_RemFont(GRAPHICS_BASE_NAME, textFont)

static __inline void
_RemFont(void *GfxBase, struct TextFont *textFont)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) textFont;
	MyCaos.caos_Un.Offset	=	(-486);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	RemIBob(bob, rp, vp)	_RemIBob(GRAPHICS_BASE_NAME, bob, rp, vp)

static __inline void
_RemIBob(void *GfxBase, struct Bob *bob, struct RastPort *rp, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) bob;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a2		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	RemVSprite(vSprite)	_RemVSprite(GRAPHICS_BASE_NAME, vSprite)

static __inline void
_RemVSprite(void *GfxBase, struct VSprite *vSprite)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vSprite;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ScalerDiv(factor, numerator, denominator)	_ScalerDiv(GRAPHICS_BASE_NAME, factor, numerator, denominator)

static __inline UWORD
_ScalerDiv(void *GfxBase, unsigned long factor, unsigned long numerator, unsigned long denominator)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) factor;
	MyCaos.d1		=(ULONG) numerator;
	MyCaos.d2		=(ULONG) denominator;
	MyCaos.caos_Un.Offset	=	(-684);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	ScrollRaster(rp, dx, dy, xMin, yMin, xMax, yMax)	_ScrollRaster(GRAPHICS_BASE_NAME, rp, dx, dy, xMin, yMin, xMax, yMax)

static __inline void
_ScrollRaster(void *GfxBase, struct RastPort *rp, long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.d2		=(ULONG) xMin;
	MyCaos.d3		=(ULONG) yMin;
	MyCaos.d4		=(ULONG) xMax;
	MyCaos.d5		=(ULONG) yMax;
	MyCaos.caos_Un.Offset	=	(-396);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ScrollRasterBF(rp, dx, dy, xMin, yMin, xMax, yMax)	_ScrollRasterBF(GRAPHICS_BASE_NAME, rp, dx, dy, xMin, yMin, xMax, yMax)

static __inline void
_ScrollRasterBF(void *GfxBase, struct RastPort *rp, long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.d2		=(ULONG) xMin;
	MyCaos.d3		=(ULONG) yMin;
	MyCaos.d4		=(ULONG) xMax;
	MyCaos.d5		=(ULONG) yMax;
	MyCaos.caos_Un.Offset	=	(-1002);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	ScrollVPort(vp)	_ScrollVPort(GRAPHICS_BASE_NAME, vp)

static __inline void
_ScrollVPort(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-588);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetABPenDrMd(rp, apen, bpen, drawmode)	_SetABPenDrMd(GRAPHICS_BASE_NAME, rp, apen, bpen, drawmode)

static __inline void
_SetABPenDrMd(void *GfxBase, struct RastPort *rp, unsigned long apen, unsigned long bpen, unsigned long drawmode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) apen;
	MyCaos.d1		=(ULONG) bpen;
	MyCaos.d2		=(ULONG) drawmode;
	MyCaos.caos_Un.Offset	=	(-894);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetAPen(rp, pen)	_SetAPen(GRAPHICS_BASE_NAME, rp, pen)

static __inline void
_SetAPen(void *GfxBase, struct RastPort *rp, unsigned long pen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) pen;
	MyCaos.caos_Un.Offset	=	(-342);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetBPen(rp, pen)	_SetBPen(GRAPHICS_BASE_NAME, rp, pen)

static __inline void
_SetBPen(void *GfxBase, struct RastPort *rp, unsigned long pen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) pen;
	MyCaos.caos_Un.Offset	=	(-348);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetChipRev(want)	_SetChipRev(GRAPHICS_BASE_NAME, want)

static __inline ULONG
_SetChipRev(void *GfxBase, unsigned long want)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) want;
	MyCaos.caos_Un.Offset	=	(-888);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetCollision(num, routine, gelsInfo)	_SetCollision(GRAPHICS_BASE_NAME, num, routine, gelsInfo)

static __inline void
_SetCollision(void *GfxBase, unsigned long num, void (*routine)(struct VSprite *vSprite, APTR), struct GelsInfo *gelsInfo)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) num;
	MyCaos.a0		=(ULONG) routine;
	MyCaos.a1		=(ULONG) gelsInfo;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetDrMd(rp, drawMode)	_SetDrMd(GRAPHICS_BASE_NAME, rp, drawMode)

static __inline void
_SetDrMd(void *GfxBase, struct RastPort *rp, unsigned long drawMode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) drawMode;
	MyCaos.caos_Un.Offset	=	(-354);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetFont(rp, textFont)	_SetFont(GRAPHICS_BASE_NAME, rp, textFont)

static __inline LONG
_SetFont(void *GfxBase, struct RastPort *rp, struct TextFont *textFont)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) textFont;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetMaxPen(rp, maxpen)	_SetMaxPen(GRAPHICS_BASE_NAME, rp, maxpen)

static __inline void
_SetMaxPen(void *GfxBase, struct RastPort *rp, unsigned long maxpen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) maxpen;
	MyCaos.caos_Un.Offset	=	(-990);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetOutlinePen(rp, pen)	_SetOutlinePen(GRAPHICS_BASE_NAME, rp, pen)

static __inline ULONG
_SetOutlinePen(void *GfxBase, struct RastPort *rp, unsigned long pen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) pen;
	MyCaos.caos_Un.Offset	=	(-978);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetRGB32(vp, n, r, g, b)	_SetRGB32(GRAPHICS_BASE_NAME, vp, n, r, g, b)

static __inline void
_SetRGB32(void *GfxBase, struct ViewPort *vp, unsigned long n, unsigned long r, unsigned long g, unsigned long b)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.d0		=(ULONG) n;
	MyCaos.d1		=(ULONG) r;
	MyCaos.d2		=(ULONG) g;
	MyCaos.d3		=(ULONG) b;
	MyCaos.caos_Un.Offset	=	(-852);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetRGB32CM(cm, n, r, g, b)	_SetRGB32CM(GRAPHICS_BASE_NAME, cm, n, r, g, b)

static __inline void
_SetRGB32CM(void *GfxBase, struct ColorMap *cm, unsigned long n, unsigned long r, unsigned long g, unsigned long b)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cm;
	MyCaos.d0		=(ULONG) n;
	MyCaos.d1		=(ULONG) r;
	MyCaos.d2		=(ULONG) g;
	MyCaos.d3		=(ULONG) b;
	MyCaos.caos_Un.Offset	=	(-996);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetRGB4(vp, index, red, green, blue)	_SetRGB4(GRAPHICS_BASE_NAME, vp, index, red, green, blue)

static __inline void
_SetRGB4(void *GfxBase, struct ViewPort *vp, long index, unsigned long red, unsigned long green, unsigned long blue)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.d0		=(ULONG) index;
	MyCaos.d1		=(ULONG) red;
	MyCaos.d2		=(ULONG) green;
	MyCaos.d3		=(ULONG) blue;
	MyCaos.caos_Un.Offset	=	(-288);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetRGB4CM(colorMap, index, red, green, blue)	_SetRGB4CM(GRAPHICS_BASE_NAME, colorMap, index, red, green, blue)

static __inline void
_SetRGB4CM(void *GfxBase, struct ColorMap *colorMap, long index, unsigned long red, unsigned long green, unsigned long blue)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) colorMap;
	MyCaos.d0		=(ULONG) index;
	MyCaos.d1		=(ULONG) red;
	MyCaos.d2		=(ULONG) green;
	MyCaos.d3		=(ULONG) blue;
	MyCaos.caos_Un.Offset	=	(-630);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetRPAttrsA(rp, tags)	_SetRPAttrsA(GRAPHICS_BASE_NAME, rp, tags)

static __inline void
_SetRPAttrsA(void *GfxBase, struct RastPort *rp, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-1038);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define SetRPAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; SetRPAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetRast(rp, pen)	_SetRast(GRAPHICS_BASE_NAME, rp, pen)

static __inline void
_SetRast(void *GfxBase, struct RastPort *rp, unsigned long pen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) pen;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetSoftStyle(rp, style, enable)	_SetSoftStyle(GRAPHICS_BASE_NAME, rp, style, enable)

static __inline ULONG
_SetSoftStyle(void *GfxBase, struct RastPort *rp, unsigned long style, unsigned long enable)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) style;
	MyCaos.d1		=(ULONG) enable;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SetWriteMask(rp, msk)	_SetWriteMask(GRAPHICS_BASE_NAME, rp, msk)

static __inline ULONG
_SetWriteMask(void *GfxBase, struct RastPort *rp, unsigned long msk)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) msk;
	MyCaos.caos_Un.Offset	=	(-984);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SortGList(rp)	_SortGList(GRAPHICS_BASE_NAME, rp)

static __inline void
_SortGList(void *GfxBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	StripFont(font)	_StripFont(GRAPHICS_BASE_NAME, font)

static __inline void
_StripFont(void *GfxBase, struct TextFont *font)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) font;
	MyCaos.caos_Un.Offset	=	(-822);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	SyncSBitMap(layer)	_SyncSBitMap(GRAPHICS_BASE_NAME, layer)

static __inline void
_SyncSBitMap(void *GfxBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-444);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	Text(rp, string, count)	_Text(GRAPHICS_BASE_NAME, rp, string, count)

static __inline LONG
_Text(void *GfxBase, struct RastPort *rp, STRPTR string, unsigned long count)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) count;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	TextExtent(rp, string, count, textExtent)	_TextExtent(GRAPHICS_BASE_NAME, rp, string, count, textExtent)

static __inline WORD
_TextExtent(void *GfxBase, struct RastPort *rp, STRPTR string, long count, struct TextExtent *textExtent)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) count;
	MyCaos.a2		=(ULONG) textExtent;
	MyCaos.caos_Un.Offset	=	(-690);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#define	TextFit(rp, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight)	_TextFit(GRAPHICS_BASE_NAME, rp, string, strLen, textExtent, constrainingExtent, strDirection, constrainingBitWidth, constrainingBitHeight)

static __inline ULONG
_TextFit(void *GfxBase, struct RastPort *rp, STRPTR string, unsigned long strLen, struct TextExtent *textExtent, struct TextExtent *constrainingExtent, long strDirection, unsigned long constrainingBitWidth, unsigned long constrainingBitHeight)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) strLen;
	MyCaos.a2		=(ULONG) textExtent;
	MyCaos.a3		=(ULONG) constrainingExtent;
	MyCaos.d1		=(ULONG) strDirection;
	MyCaos.d2		=(ULONG) constrainingBitWidth;
	MyCaos.d3		=(ULONG) constrainingBitHeight;
	MyCaos.caos_Un.Offset	=	(-696);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	TextLength(rp, string, count)	_TextLength(GRAPHICS_BASE_NAME, rp, string, count)

static __inline WORD
_TextLength(void *GfxBase, struct RastPort *rp, STRPTR string, unsigned long count)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d0		=(ULONG) count;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#define	UCopperListInit(uCopList, n)	_UCopperListInit(GRAPHICS_BASE_NAME, uCopList, n)

static __inline struct CopList *
_UCopperListInit(void *GfxBase, struct UCopList *uCopList, long n)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) uCopList;
	MyCaos.d0		=(ULONG) n;
	MyCaos.caos_Un.Offset	=	(-594);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((struct CopList *)PPCCallOS(&MyCaos));
}

#define	UnlockLayerRom(layer)	_UnlockLayerRom(GRAPHICS_BASE_NAME, layer)

static __inline void
_UnlockLayerRom(void *GfxBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a5		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-438);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	VBeamPos()	_VBeamPos(GRAPHICS_BASE_NAME)

static __inline LONG
_VBeamPos(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-384);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	VideoControl(colorMap, tagarray)	_VideoControl(GRAPHICS_BASE_NAME, colorMap, tagarray)

static __inline BOOL
_VideoControl(void *GfxBase, struct ColorMap *colorMap, struct TagItem *tagarray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) colorMap;
	MyCaos.a1		=(ULONG) tagarray;
	MyCaos.caos_Un.Offset	=	(-708);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define VideoControlTags(a0, tags...) \
	({ULONG _tags[] = { tags }; VideoControl((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	WaitBOVP(vp)	_WaitBOVP(GRAPHICS_BASE_NAME, vp)

static __inline void
_WaitBOVP(void *GfxBase, struct ViewPort *vp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vp;
	MyCaos.caos_Un.Offset	=	(-402);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	WaitBlit()	_WaitBlit(GRAPHICS_BASE_NAME)

static __inline void
_WaitBlit(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	WaitTOF()	_WaitTOF(GRAPHICS_BASE_NAME)

static __inline void
_WaitTOF(void *GfxBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	WeighTAMatch(reqTextAttr, targetTextAttr, targetTags)	_WeighTAMatch(GRAPHICS_BASE_NAME, reqTextAttr, targetTextAttr, targetTags)

static __inline WORD
_WeighTAMatch(void *GfxBase, struct TextAttr *reqTextAttr, struct TextAttr *targetTextAttr, struct TagItem *targetTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) reqTextAttr;
	MyCaos.a1		=(ULONG) targetTextAttr;
	MyCaos.a2		=(ULONG) targetTags;
	MyCaos.caos_Un.Offset	=	(-804);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((WORD)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define WeighTAMatchTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; WeighTAMatch((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	WriteChunkyPixels(rp, xstart, ystart, xstop, ystop, array, bytesperrow)	_WriteChunkyPixels(GRAPHICS_BASE_NAME, rp, xstart, ystart, xstop, ystop, array, bytesperrow)

static __inline void
_WriteChunkyPixels(void *GfxBase, struct RastPort *rp, unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE *array, long bytesperrow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xstart;
	MyCaos.d1		=(ULONG) ystart;
	MyCaos.d2		=(ULONG) xstop;
	MyCaos.d3		=(ULONG) ystop;
	MyCaos.a2		=(ULONG) array;
	MyCaos.d4		=(ULONG) bytesperrow;
	MyCaos.caos_Un.Offset	=	(-1056);
	MyCaos.a6		=(ULONG) GfxBase;	
	PPCCallOS(&MyCaos);
}

#define	WritePixel(rp, x, y)	_WritePixel(GRAPHICS_BASE_NAME, rp, x, y)

static __inline LONG
_WritePixel(void *GfxBase, struct RastPort *rp, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) rp;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-324);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WritePixelArray8(rp, xstart, ystart, xstop, ystop, array, temprp)	_WritePixelArray8(GRAPHICS_BASE_NAME, rp, xstart, ystart, xstop, ystop, array, temprp)

static __inline LONG
_WritePixelArray8(void *GfxBase, struct RastPort *rp, unsigned long xstart, unsigned long ystart, unsigned long xstop, unsigned long ystop, UBYTE *array, struct RastPort *temprp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xstart;
	MyCaos.d1		=(ULONG) ystart;
	MyCaos.d2		=(ULONG) xstop;
	MyCaos.d3		=(ULONG) ystop;
	MyCaos.a2		=(ULONG) array;
	MyCaos.a1		=(ULONG) temprp;
	MyCaos.caos_Un.Offset	=	(-786);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WritePixelLine8(rp, xstart, ystart, width, array, tempRP)	_WritePixelLine8(GRAPHICS_BASE_NAME, rp, xstart, ystart, width, array, tempRP)

static __inline LONG
_WritePixelLine8(void *GfxBase, struct RastPort *rp, unsigned long xstart, unsigned long ystart, unsigned long width, UBYTE *array, struct RastPort *tempRP)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.d0		=(ULONG) xstart;
	MyCaos.d1		=(ULONG) ystart;
	MyCaos.d2		=(ULONG) width;
	MyCaos.a2		=(ULONG) array;
	MyCaos.a1		=(ULONG) tempRP;
	MyCaos.caos_Un.Offset	=	(-774);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	XorRectRegion(region, rectangle)	_XorRectRegion(GRAPHICS_BASE_NAME, region, rectangle)

static __inline BOOL
_XorRectRegion(void *GfxBase, struct Region *region, struct Rectangle *rectangle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) region;
	MyCaos.a1		=(ULONG) rectangle;
	MyCaos.caos_Un.Offset	=	(-558);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	XorRegionRegion(srcRegion, destRegion)	_XorRegionRegion(GRAPHICS_BASE_NAME, srcRegion, destRegion)

static __inline BOOL
_XorRegionRegion(void *GfxBase, struct Region *srcRegion, struct Region *destRegion)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRegion;
	MyCaos.a1		=(ULONG) destRegion;
	MyCaos.caos_Un.Offset	=	(-618);
	MyCaos.a6		=(ULONG) GfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_GRAPHICS_H */
