/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_DISK_H
#define _PPCPRAGMA_DISK_H
#ifdef __GNUC__
#ifndef _PPCINLINE__DISK_H
#include <ppcinline/disk.h>
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

#ifndef DISK_BASE_NAME
#define DISK_BASE_NAME DiskBase
#endif /* !DISK_BASE_NAME */

#define	AllocUnit(unitNum)	_AllocUnit(DISK_BASE_NAME, unitNum)

static __inline BOOL
_AllocUnit(void *DiskBase, long unitNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNum;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) DiskBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FreeUnit(unitNum)	_FreeUnit(DISK_BASE_NAME, unitNum)

static __inline void
_FreeUnit(void *DiskBase, long unitNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNum;
	MyCaos.caos_Un.Offset	=	(-12);
	MyCaos.a6		=(ULONG) DiskBase;	
	PPCCallOS(&MyCaos);
}

#define	GetUnit(unitPointer)	_GetUnit(DISK_BASE_NAME, unitPointer)

static __inline struct DiskResourceUnit *
_GetUnit(void *DiskBase, struct DiskResourceUnit *unitPointer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) unitPointer;
	MyCaos.caos_Un.Offset	=	(-18);
	MyCaos.a6		=(ULONG) DiskBase;	
	return((struct DiskResourceUnit *)PPCCallOS(&MyCaos));
}

#define	GetUnitID(unitNum)	_GetUnitID(DISK_BASE_NAME, unitNum)

static __inline LONG
_GetUnitID(void *DiskBase, long unitNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNum;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) DiskBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GiveUnit()	_GiveUnit(DISK_BASE_NAME)

static __inline void
_GiveUnit(void *DiskBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-24);
	MyCaos.a6		=(ULONG) DiskBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadUnitID(unitNum)	_ReadUnitID(DISK_BASE_NAME, unitNum)

static __inline LONG
_ReadUnitID(void *DiskBase, long unitNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNum;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) DiskBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_DISK_H */
