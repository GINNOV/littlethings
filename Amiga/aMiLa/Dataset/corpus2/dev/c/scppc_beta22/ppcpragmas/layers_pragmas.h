/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_LAYERS_H
#define _PPCPRAGMA_LAYERS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__LAYERS_H
#include <ppcinline/layers.h>
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

#ifndef LAYERS_BASE_NAME
#define LAYERS_BASE_NAME LayersBase
#endif /* !LAYERS_BASE_NAME */

#define	BeginUpdate(l)	_BeginUpdate(LAYERS_BASE_NAME, l)

static __inline LONG
_BeginUpdate(void *LayersBase, struct Layer *l)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) l;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	BehindLayer(dummy, layer)	_BehindLayer(LAYERS_BASE_NAME, dummy, layer)

static __inline LONG
_BehindLayer(void *LayersBase, long dummy, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CreateBehindHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2)	_CreateBehindHookLayer(LAYERS_BASE_NAME, li, bm, x0, y0, x1, y1, flags, hook, bm2)

static __inline struct Layer *
_CreateBehindHookLayer(void *LayersBase, struct Layer_Info *li, struct BitMap *bm, long x0, long y0, long x1, long y1, long flags, struct Hook *hook, struct BitMap *bm2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.d0		=(ULONG) x0;
	MyCaos.d1		=(ULONG) y0;
	MyCaos.d2		=(ULONG) x1;
	MyCaos.d3		=(ULONG) y1;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.a3		=(ULONG) hook;
	MyCaos.a2		=(ULONG) bm2;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer *)PPCCallOS(&MyCaos));
}

#define	CreateBehindLayer(li, bm, x0, y0, x1, y1, flags, bm2)	_CreateBehindLayer(LAYERS_BASE_NAME, li, bm, x0, y0, x1, y1, flags, bm2)

static __inline struct Layer *
_CreateBehindLayer(void *LayersBase, struct Layer_Info *li, struct BitMap *bm, long x0, long y0, long x1, long y1, long flags, struct BitMap *bm2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.d0		=(ULONG) x0;
	MyCaos.d1		=(ULONG) y0;
	MyCaos.d2		=(ULONG) x1;
	MyCaos.d3		=(ULONG) y1;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.a2		=(ULONG) bm2;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer *)PPCCallOS(&MyCaos));
}

#define	CreateUpfrontHookLayer(li, bm, x0, y0, x1, y1, flags, hook, bm2)	_CreateUpfrontHookLayer(LAYERS_BASE_NAME, li, bm, x0, y0, x1, y1, flags, hook, bm2)

static __inline struct Layer *
_CreateUpfrontHookLayer(void *LayersBase, struct Layer_Info *li, struct BitMap *bm, long x0, long y0, long x1, long y1, long flags, struct Hook *hook, struct BitMap *bm2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.d0		=(ULONG) x0;
	MyCaos.d1		=(ULONG) y0;
	MyCaos.d2		=(ULONG) x1;
	MyCaos.d3		=(ULONG) y1;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.a3		=(ULONG) hook;
	MyCaos.a2		=(ULONG) bm2;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer *)PPCCallOS(&MyCaos));
}

#define	CreateUpfrontLayer(li, bm, x0, y0, x1, y1, flags, bm2)	_CreateUpfrontLayer(LAYERS_BASE_NAME, li, bm, x0, y0, x1, y1, flags, bm2)

static __inline struct Layer *
_CreateUpfrontLayer(void *LayersBase, struct Layer_Info *li, struct BitMap *bm, long x0, long y0, long x1, long y1, long flags, struct BitMap *bm2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.d0		=(ULONG) x0;
	MyCaos.d1		=(ULONG) y0;
	MyCaos.d2		=(ULONG) x1;
	MyCaos.d3		=(ULONG) y1;
	MyCaos.d4		=(ULONG) flags;
	MyCaos.a2		=(ULONG) bm2;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer *)PPCCallOS(&MyCaos));
}

#define	DeleteLayer(dummy, layer)	_DeleteLayer(LAYERS_BASE_NAME, dummy, layer)

static __inline LONG
_DeleteLayer(void *LayersBase, long dummy, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DisposeLayerInfo(li)	_DisposeLayerInfo(LAYERS_BASE_NAME, li)

static __inline void
_DisposeLayerInfo(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	DoHookClipRects(hook, rport, rect)	_DoHookClipRects(LAYERS_BASE_NAME, hook, rport, rect)

static __inline void
_DoHookClipRects(void *LayersBase, struct Hook *hook, struct RastPort *rport, struct Rectangle *rect)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) hook;
	MyCaos.a1		=(ULONG) rport;
	MyCaos.a2		=(ULONG) rect;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	EndUpdate(layer, flag)	_EndUpdate(LAYERS_BASE_NAME, layer, flag)

static __inline void
_EndUpdate(void *LayersBase, struct Layer *layer, unsigned long flag)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.d0		=(ULONG) flag;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	FattenLayerInfo(li)	_FattenLayerInfo(LAYERS_BASE_NAME, li)

static __inline LONG
_FattenLayerInfo(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	InitLayers(li)	_InitLayers(LAYERS_BASE_NAME, li)

static __inline void
_InitLayers(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	InstallClipRegion(layer, region)	_InstallClipRegion(LAYERS_BASE_NAME, layer, region)

static __inline struct Region *
_InstallClipRegion(void *LayersBase, struct Layer *layer, struct Region *region)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.a1		=(ULONG) region;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Region *)PPCCallOS(&MyCaos));
}

#define	InstallLayerHook(layer, hook)	_InstallLayerHook(LAYERS_BASE_NAME, layer, hook)

static __inline struct Hook *
_InstallLayerHook(void *LayersBase, struct Layer *layer, struct Hook *hook)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.a1		=(ULONG) hook;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Hook *)PPCCallOS(&MyCaos));
}

#define	InstallLayerInfoHook(li, hook)	_InstallLayerInfoHook(LAYERS_BASE_NAME, li, hook)

static __inline struct Hook *
_InstallLayerInfoHook(void *LayersBase, struct Layer_Info *li, struct Hook *hook)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.a1		=(ULONG) hook;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Hook *)PPCCallOS(&MyCaos));
}

#define	LockLayer(dummy, layer)	_LockLayer(LAYERS_BASE_NAME, dummy, layer)

static __inline void
_LockLayer(void *LayersBase, long dummy, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	LockLayerInfo(li)	_LockLayerInfo(LAYERS_BASE_NAME, li)

static __inline void
_LockLayerInfo(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	LockLayers(li)	_LockLayers(LAYERS_BASE_NAME, li)

static __inline void
_LockLayers(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	MoveLayer(dummy, layer, dx, dy)	_MoveLayer(LAYERS_BASE_NAME, dummy, layer, dx, dy)

static __inline LONG
_MoveLayer(void *LayersBase, long dummy, struct Layer *layer, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MoveLayerInFrontOf(layer_to_move, other_layer)	_MoveLayerInFrontOf(LAYERS_BASE_NAME, layer_to_move, other_layer)

static __inline LONG
_MoveLayerInFrontOf(void *LayersBase, struct Layer *layer_to_move, struct Layer *other_layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer_to_move;
	MyCaos.a1		=(ULONG) other_layer;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	MoveSizeLayer(layer, dx, dy, dw, dh)	_MoveSizeLayer(LAYERS_BASE_NAME, layer, dx, dy, dw, dh)

static __inline LONG
_MoveSizeLayer(void *LayersBase, struct Layer *layer, long dx, long dy, long dw, long dh)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.d2		=(ULONG) dw;
	MyCaos.d3		=(ULONG) dh;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	NewLayerInfo()	_NewLayerInfo(LAYERS_BASE_NAME)

static __inline struct Layer_Info *
_NewLayerInfo(void *LayersBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer_Info *)PPCCallOS(&MyCaos));
}

#define	ScrollLayer(dummy, layer, dx, dy)	_ScrollLayer(LAYERS_BASE_NAME, dummy, layer, dx, dy)

static __inline void
_ScrollLayer(void *LayersBase, long dummy, struct Layer *layer, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	SizeLayer(dummy, layer, dx, dy)	_SizeLayer(LAYERS_BASE_NAME, dummy, layer, dx, dy)

static __inline LONG
_SizeLayer(void *LayersBase, long dummy, struct Layer *layer, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SortLayerCR(layer, dx, dy)	_SortLayerCR(LAYERS_BASE_NAME, layer, dx, dy)

static __inline void
_SortLayerCR(void *LayersBase, struct Layer *layer, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	SwapBitsRastPortClipRect(rp, cr)	_SwapBitsRastPortClipRect(LAYERS_BASE_NAME, rp, cr)

static __inline void
_SwapBitsRastPortClipRect(void *LayersBase, struct RastPort *rp, struct ClipRect *cr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) cr;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	ThinLayerInfo(li)	_ThinLayerInfo(LAYERS_BASE_NAME, li)

static __inline void
_ThinLayerInfo(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockLayer(layer)	_UnlockLayer(LAYERS_BASE_NAME, layer)

static __inline void
_UnlockLayer(void *LayersBase, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockLayerInfo(li)	_UnlockLayerInfo(LAYERS_BASE_NAME, li)

static __inline void
_UnlockLayerInfo(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockLayers(li)	_UnlockLayers(LAYERS_BASE_NAME, li)

static __inline void
_UnlockLayers(void *LayersBase, struct Layer_Info *li)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) LayersBase;	
	PPCCallOS(&MyCaos);
}

#define	UpfrontLayer(dummy, layer)	_UpfrontLayer(LAYERS_BASE_NAME, dummy, layer)

static __inline LONG
_UpfrontLayer(void *LayersBase, long dummy, struct Layer *layer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dummy;
	MyCaos.a1		=(ULONG) layer;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WhichLayer(li, x, y)	_WhichLayer(LAYERS_BASE_NAME, li, x, y)

static __inline struct Layer *
_WhichLayer(void *LayersBase, struct Layer_Info *li, long x, long y)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) li;
	MyCaos.d0		=(ULONG) x;
	MyCaos.d1		=(ULONG) y;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) LayersBase;	
	return((struct Layer *)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_LAYERS_H */
