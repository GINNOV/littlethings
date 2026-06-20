/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_NONVOLATILE_H
#define _PPCPRAGMA_NONVOLATILE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__NONVOLATILE_H
#include <ppcinline/nonvolatile.h>
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

#ifndef NONVOLATILE_BASE_NAME
#define NONVOLATILE_BASE_NAME NVBase
#endif /* !NONVOLATILE_BASE_NAME */

#define	DeleteNV(appName, itemName, killRequesters)	_DeleteNV(NONVOLATILE_BASE_NAME, appName, itemName, killRequesters)

static __inline BOOL
_DeleteNV(void *NVBase, STRPTR appName, STRPTR itemName, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appName;
	MyCaos.a1		=(ULONG) itemName;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) NVBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FreeNVData(data)	_FreeNVData(NONVOLATILE_BASE_NAME, data)

static __inline void
_FreeNVData(void *NVBase, APTR data)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) data;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) NVBase;	
	PPCCallOS(&MyCaos);
}

#define	GetCopyNV(appName, itemName, killRequesters)	_GetCopyNV(NONVOLATILE_BASE_NAME, appName, itemName, killRequesters)

static __inline APTR
_GetCopyNV(void *NVBase, STRPTR appName, STRPTR itemName, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appName;
	MyCaos.a1		=(ULONG) itemName;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) NVBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	GetNVInfo(killRequesters)	_GetNVInfo(NONVOLATILE_BASE_NAME, killRequesters)

static __inline struct NVInfo *
_GetNVInfo(void *NVBase, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) NVBase;	
	return((struct NVInfo *)PPCCallOS(&MyCaos));
}

#define	GetNVList(appName, killRequesters)	_GetNVList(NONVOLATILE_BASE_NAME, appName, killRequesters)

static __inline struct MinList *
_GetNVList(void *NVBase, STRPTR appName, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appName;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) NVBase;	
	return((struct MinList *)PPCCallOS(&MyCaos));
}

#define	SetNVProtection(appName, itemName, mask, killRequesters)	_SetNVProtection(NONVOLATILE_BASE_NAME, appName, itemName, mask, killRequesters)

static __inline BOOL
_SetNVProtection(void *NVBase, STRPTR appName, STRPTR itemName, long mask, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appName;
	MyCaos.a1		=(ULONG) itemName;
	MyCaos.d2		=(ULONG) mask;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) NVBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	StoreNV(appName, itemName, data, length, killRequesters)	_StoreNV(NONVOLATILE_BASE_NAME, appName, itemName, data, length, killRequesters)

static __inline UWORD
_StoreNV(void *NVBase, STRPTR appName, STRPTR itemName, APTR data, unsigned long length, long killRequesters)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appName;
	MyCaos.a1		=(ULONG) itemName;
	MyCaos.a2		=(ULONG) data;
	MyCaos.d0		=(ULONG) length;
	MyCaos.d1		=(ULONG) killRequesters;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) NVBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_NONVOLATILE_H */
