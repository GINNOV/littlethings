/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_BULLET_H
#define _PPCPRAGMA_BULLET_H
#ifdef __GNUC__
#ifndef _PPCINLINE__BULLET_H
#include <ppcinline/bullet.h>
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

#ifndef BULLET_BASE_NAME
#define BULLET_BASE_NAME BulletBase
#endif /* !BULLET_BASE_NAME */

#define	CloseEngine(glyphEngine)	_CloseEngine(BULLET_BASE_NAME, glyphEngine)

static __inline void
_CloseEngine(void *BulletBase, struct GlyphEngine *glyphEngine)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) glyphEngine;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) BulletBase;	
	PPCCallOS(&MyCaos);
}

#define	ObtainInfoA(glyphEngine, tagList)	_ObtainInfoA(BULLET_BASE_NAME, glyphEngine, tagList)

static __inline ULONG
_ObtainInfoA(void *BulletBase, struct GlyphEngine *glyphEngine, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) glyphEngine;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) BulletBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ObtainInfo(a0, tags...) \
	({ULONG _tags[] = { tags }; ObtainInfoA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	OpenEngine()	_OpenEngine(BULLET_BASE_NAME)

static __inline struct GlyphEngine *
_OpenEngine(void *BulletBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) BulletBase;	
	return((struct GlyphEngine *)PPCCallOS(&MyCaos));
}

#define	ReleaseInfoA(glyphEngine, tagList)	_ReleaseInfoA(BULLET_BASE_NAME, glyphEngine, tagList)

static __inline ULONG
_ReleaseInfoA(void *BulletBase, struct GlyphEngine *glyphEngine, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) glyphEngine;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) BulletBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ReleaseInfo(a0, tags...) \
	({ULONG _tags[] = { tags }; ReleaseInfoA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetInfoA(glyphEngine, tagList)	_SetInfoA(BULLET_BASE_NAME, glyphEngine, tagList)

static __inline ULONG
_SetInfoA(void *BulletBase, struct GlyphEngine *glyphEngine, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) glyphEngine;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) BulletBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetInfo(a0, tags...) \
	({ULONG _tags[] = { tags }; SetInfoA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_BULLET_H */
