/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_BATTMEM_H
#define _PPCPRAGMA_BATTMEM_H
#ifdef __GNUC__
#ifndef _PPCINLINE__BATTMEM_H
#include <ppcinline/battmem.h>
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

#ifndef BATTMEM_BASE_NAME
#define BATTMEM_BASE_NAME BattMemBase
#endif /* !BATTMEM_BASE_NAME */

#define	ObtainBattSemaphore()	_ObtainBattSemaphore(BATTMEM_BASE_NAME)

static __inline void
_ObtainBattSemaphore(void *BattMemBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) BattMemBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadBattMem(buffer, offset, length)	_ReadBattMem(BATTMEM_BASE_NAME, buffer, offset, length)

static __inline ULONG
_ReadBattMem(void *BattMemBase, APTR buffer, unsigned long offset, unsigned long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) offset;
	MyCaos.d1		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-18);
	MyCaos.a6		=(ULONG) BattMemBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ReleaseBattSemaphore()	_ReleaseBattSemaphore(BATTMEM_BASE_NAME)

static __inline void
_ReleaseBattSemaphore(void *BattMemBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-12);
	MyCaos.a6		=(ULONG) BattMemBase;	
	PPCCallOS(&MyCaos);
}

#define	WriteBattMem(buffer, offset, length)	_WriteBattMem(BATTMEM_BASE_NAME, buffer, offset, length)

static __inline ULONG
_WriteBattMem(void *BattMemBase, APTR buffer, unsigned long offset, unsigned long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) offset;
	MyCaos.d1		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-24);
	MyCaos.a6		=(ULONG) BattMemBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_BATTMEM_H */
