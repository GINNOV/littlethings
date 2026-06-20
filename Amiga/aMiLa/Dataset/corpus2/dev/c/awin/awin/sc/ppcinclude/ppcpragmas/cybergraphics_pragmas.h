/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_CYBERGRAPHICS_H
#define _PPCPRAGMA_CYBERGRAPHICS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__CYBERGRAPHICS_H
#include <powerup/ppcinline/cybergraphics.h>
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

#ifndef CYBERGRAPHICS_BASE_NAME
#define CYBERGRAPHICS_BASE_NAME CyberGfxBase
#endif /* !CYBERGRAPHICS_BASE_NAME */

#define	AllocCModeListTagList(ModeListTags)	_AllocCModeListTagList(CYBERGRAPHICS_BASE_NAME, ModeListTags)

static __inline struct List *
_AllocCModeListTagList(void *CyberGfxBase, struct TagItem *ModeListTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) ModeListTags;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((struct List *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AllocCModeListTags(tags...) \
	({ULONG _tags[] = { tags }; AllocCModeListTagList((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	BestCModeIDTagList(BestModeIDTags)	_BestCModeIDTagList(CYBERGRAPHICS_BASE_NAME, BestModeIDTags)

static __inline ULONG
_BestCModeIDTagList(void *CyberGfxBase, struct TagItem *BestModeIDTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) BestModeIDTags;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define BestCModeIDTags(tags...) \
	({ULONG _tags[] = { tags }; BestCModeIDTagList((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	CModeRequestTagList(ModeRequest, ModeRequestTags)	_CModeRequestTagList(CYBERGRAPHICS_BASE_NAME, ModeRequest, ModeRequestTags)

static __inline ULONG
_CModeRequestTagList(void *CyberGfxBase, APTR ModeRequest, struct TagItem *ModeRequestTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) ModeRequest;
	MyCaos.a1		=(ULONG) ModeRequestTags;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define CModeRequestTags(a0, tags...) \
	({ULONG _tags[] = { tags }; CModeRequestTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	CVideoCtrlTagList(ViewPort, TagList)	_CVideoCtrlTagList(CYBERGRAPHICS_BASE_NAME, ViewPort, TagList)

static __inline void
_CVideoCtrlTagList(void *CyberGfxBase, struct ViewPort *ViewPort, struct TagItem *TagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) ViewPort;
	MyCaos.a1		=(ULONG) TagList;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define CVideoCtrlTags(a0, tags...) \
	({ULONG _tags[] = { tags }; CVideoCtrlTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	DoCDrawMethodTagList(Hook, RastPort, TagList)	_DoCDrawMethodTagList(CYBERGRAPHICS_BASE_NAME, Hook, RastPort, TagList)

static __inline void
_DoCDrawMethodTagList(void *CyberGfxBase, struct Hook *Hook, struct RastPort *RastPort, struct TagItem *TagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) Hook;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.a2		=(ULONG) TagList;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define DoCDrawMethodTags(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; DoCDrawMethodTagList((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ExtractColor(RastPort, BitMap, Colour, SrcX, SrcY, Width, Height)	_ExtractColor(CYBERGRAPHICS_BASE_NAME, RastPort, BitMap, Colour, SrcX, SrcY, Width, Height)

static __inline ULONG
_ExtractColor(void *CyberGfxBase, struct RastPort *RastPort, struct BitMap *BitMap, ULONG Colour, ULONG SrcX, ULONG SrcY, ULONG Width, ULONG Height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) RastPort;
	MyCaos.a1		=(ULONG) BitMap;
	MyCaos.d0		=(ULONG) Colour;
	MyCaos.d1		=(ULONG) SrcX;
	MyCaos.d2		=(ULONG) SrcY;
	MyCaos.d3		=(ULONG) Width;
	MyCaos.d4		=(ULONG) Height;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	FillPixelArray(RastPort, DestX, DestY, SizeX, SizeY, ARGB)	_FillPixelArray(CYBERGRAPHICS_BASE_NAME, RastPort, DestX, DestY, SizeX, SizeY, ARGB)

static __inline ULONG
_FillPixelArray(void *CyberGfxBase, struct RastPort *RastPort, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, ULONG ARGB)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d0		=(ULONG) DestX;
	MyCaos.d1		=(ULONG) DestY;
	MyCaos.d2		=(ULONG) SizeX;
	MyCaos.d3		=(ULONG) SizeY;
	MyCaos.d4		=(ULONG) ARGB;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	FreeCModeList(ModeList)	_FreeCModeList(CYBERGRAPHICS_BASE_NAME, ModeList)

static __inline void
_FreeCModeList(void *CyberGfxBase, struct List *ModeList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) ModeList;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	PPCCallOS(&MyCaos);
}

#define	GetCyberIDAttr(CyberIDAttr, CyberDisplayModeID)	_GetCyberIDAttr(CYBERGRAPHICS_BASE_NAME, CyberIDAttr, CyberDisplayModeID)

static __inline ULONG
_GetCyberIDAttr(void *CyberGfxBase, ULONG CyberIDAttr, ULONG CyberDisplayModeID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) CyberIDAttr;
	MyCaos.d1		=(ULONG) CyberDisplayModeID;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetCyberMapAttr(CyberGfxBitmap, CyberAttrTag)	_GetCyberMapAttr(CYBERGRAPHICS_BASE_NAME, CyberGfxBitmap, CyberAttrTag)

static __inline ULONG
_GetCyberMapAttr(void *CyberGfxBase, struct BitMap *CyberGfxBitmap, ULONG CyberAttrTag)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) CyberGfxBitmap;
	MyCaos.d0		=(ULONG) CyberAttrTag;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	InvertPixelArray(RastPort, DestX, DestY, SizeX, SizeY)	_InvertPixelArray(CYBERGRAPHICS_BASE_NAME, RastPort, DestX, DestY, SizeX, SizeY)

static __inline ULONG
_InvertPixelArray(void *CyberGfxBase, struct RastPort *RastPort, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d0		=(ULONG) DestX;
	MyCaos.d1		=(ULONG) DestY;
	MyCaos.d2		=(ULONG) SizeX;
	MyCaos.d3		=(ULONG) SizeY;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	IsCyberModeID(displayID)	_IsCyberModeID(CYBERGRAPHICS_BASE_NAME, displayID)

static __inline BOOL
_IsCyberModeID(void *CyberGfxBase, ULONG displayID)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) displayID;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	LockBitMapTagList(BitMap, TagList)	_LockBitMapTagList(CYBERGRAPHICS_BASE_NAME, BitMap, TagList)

static __inline APTR
_LockBitMapTagList(void *CyberGfxBase, APTR BitMap, struct TagItem *TagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) BitMap;
	MyCaos.a1		=(ULONG) TagList;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define LockBitMapTags(a0, tags...) \
	({ULONG _tags[] = { tags }; LockBitMapTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	MovePixelArray(SrcX, SrcY, RastPort, DestX, DestY, SizeX, SizeY)	_MovePixelArray(CYBERGRAPHICS_BASE_NAME, SrcX, SrcY, RastPort, DestX, DestY, SizeX, SizeY)

static __inline ULONG
_MovePixelArray(void *CyberGfxBase, UWORD SrcX, UWORD SrcY, struct RastPort *RastPort, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) SrcX;
	MyCaos.d1		=(ULONG) SrcY;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d2		=(ULONG) DestX;
	MyCaos.d3		=(ULONG) DestY;
	MyCaos.d4		=(ULONG) SizeX;
	MyCaos.d5		=(ULONG) SizeY;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ReadPixelArray(destRect, destX, destY, destMod, RastPort, SrcX, SrcY, SizeX, SizeY, DestFormat)	_ReadPixelArray(CYBERGRAPHICS_BASE_NAME, destRect, destX, destY, destMod, RastPort, SrcX, SrcY, SizeX, SizeY, DestFormat)

static __inline ULONG
_ReadPixelArray(void *CyberGfxBase, APTR destRect, UWORD destX, UWORD destY, UWORD destMod, struct RastPort *RastPort, UWORD SrcX, UWORD SrcY, UWORD SizeX, UWORD SizeY, UBYTE DestFormat)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) destRect;
	MyCaos.d0		=(ULONG) destX;
	MyCaos.d1		=(ULONG) destY;
	MyCaos.d2		=(ULONG) destMod;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d3		=(ULONG) SrcX;
	MyCaos.d4		=(ULONG) SrcY;
	MyCaos.d5		=(ULONG) SizeX;
	MyCaos.d6		=(ULONG) SizeY;
	MyCaos.d7		=(ULONG) DestFormat;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ReadRGBPixel(RastPort, x, y)	_ReadRGBPixel(CYBERGRAPHICS_BASE_NAME, RastPort, x, y)

static __inline ULONG
_ReadRGBPixel(void *CyberGfxBase, struct RastPort *RastPort, UWORD x, UWORD y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ScalePixelArray(srcRect, SrcW, SrcH, SrcMod, RastPort, DestX, DestY, DestW, DestH, SrcFormat)	_ScalePixelArray(CYBERGRAPHICS_BASE_NAME, srcRect, SrcW, SrcH, SrcMod, RastPort, DestX, DestY, DestW, DestH, SrcFormat)

static __inline LONG
_ScalePixelArray(void *CyberGfxBase, APTR srcRect, UWORD SrcW, UWORD SrcH, UWORD SrcMod, struct RastPort *RastPort, UWORD DestX, UWORD DestY, UWORD DestW, UWORD DestH, UBYTE SrcFormat)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRect;
	MyCaos.d0		=(ULONG) SrcW;
	MyCaos.d1		=(ULONG) SrcH;
	MyCaos.d2		=(ULONG) SrcMod;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d3		=(ULONG) DestX;
	MyCaos.d4		=(ULONG) DestY;
	MyCaos.d5		=(ULONG) DestW;
	MyCaos.d6		=(ULONG) DestH;
	MyCaos.d7		=(ULONG) SrcFormat;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	UnLockBitMap(Handle)	_UnLockBitMap(CYBERGRAPHICS_BASE_NAME, Handle)

static __inline void
_UnLockBitMap(void *CyberGfxBase, APTR Handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) Handle;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	PPCCallOS(&MyCaos);
}

#define	UnLockBitMapTagList(Handle, TagList)	_UnLockBitMapTagList(CYBERGRAPHICS_BASE_NAME, Handle, TagList)

static __inline void
_UnLockBitMapTagList(void *CyberGfxBase, APTR Handle, struct TagItem *TagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) Handle;
	MyCaos.a1		=(ULONG) TagList;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define UnLockBitMapTags(a0, tags...) \
	({ULONG _tags[] = { tags }; UnLockBitMapTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	WriteLUTPixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat)	_WriteLUTPixelArray(CYBERGRAPHICS_BASE_NAME, srcRect, SrcX, SrcY, SrcMod, RastPort, ColorTab, DestX, DestY, SizeX, SizeY, CTFormat)

static __inline ULONG
_WriteLUTPixelArray(void *CyberGfxBase, APTR srcRect, UWORD SrcX, UWORD SrcY, UWORD SrcMod, struct RastPort *RastPort, APTR ColorTab, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, UBYTE CTFormat)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRect;
	MyCaos.d0		=(ULONG) SrcX;
	MyCaos.d1		=(ULONG) SrcY;
	MyCaos.d2		=(ULONG) SrcMod;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.a2		=(ULONG) ColorTab;
	MyCaos.d3		=(ULONG) DestX;
	MyCaos.d4		=(ULONG) DestY;
	MyCaos.d5		=(ULONG) SizeX;
	MyCaos.d6		=(ULONG) SizeY;
	MyCaos.d7		=(ULONG) CTFormat;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	WritePixelArray(srcRect, SrcX, SrcY, SrcMod, RastPort, DestX, DestY, SizeX, SizeY, SrcFormat)	_WritePixelArray(CYBERGRAPHICS_BASE_NAME, srcRect, SrcX, SrcY, SrcMod, RastPort, DestX, DestY, SizeX, SizeY, SrcFormat)

static __inline ULONG
_WritePixelArray(void *CyberGfxBase, APTR srcRect, UWORD SrcX, UWORD SrcY, UWORD SrcMod, struct RastPort *RastPort, UWORD DestX, UWORD DestY, UWORD SizeX, UWORD SizeY, UBYTE SrcFormat)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) srcRect;
	MyCaos.d0		=(ULONG) SrcX;
	MyCaos.d1		=(ULONG) SrcY;
	MyCaos.d2		=(ULONG) SrcMod;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d3		=(ULONG) DestX;
	MyCaos.d4		=(ULONG) DestY;
	MyCaos.d5		=(ULONG) SizeX;
	MyCaos.d6		=(ULONG) SizeY;
	MyCaos.d7		=(ULONG) SrcFormat;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	WriteRGBPixel(RastPort, x, y, argb)	_WriteRGBPixel(CYBERGRAPHICS_BASE_NAME, RastPort, x, y, argb)

static __inline LONG
_WriteRGBPixel(void *CyberGfxBase, struct RastPort *RastPort, UWORD x, UWORD y, ULONG argb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) RastPort;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.d2		=(ULONG) argb;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) CyberGfxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_CYBERGRAPHICS_H */
