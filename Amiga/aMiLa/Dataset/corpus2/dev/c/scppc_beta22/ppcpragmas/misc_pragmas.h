/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MISC_H
#define _PPCPRAGMA_MISC_H
#ifdef __GNUC__
#ifndef _PPCINLINE__MISC_H
#include <ppcinline/misc.h>
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

#ifndef MISC_BASE_NAME
#define MISC_BASE_NAME MiscBase
#endif /* !MISC_BASE_NAME */

#define	AllocMiscResource(unitNum, name)	_AllocMiscResource(MISC_BASE_NAME, unitNum, name)

static __inline UBYTE *
_AllocMiscResource(void *MiscBase, unsigned long unitNum, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNum;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) MiscBase;	
	return((UBYTE *)PPCCallOS(&MyCaos));
}

#define	FreeMiscResource(unitNum)	_FreeMiscResource(MISC_BASE_NAME, unitNum)

static __inline void
_FreeMiscResource(void *MiscBase, unsigned long unitNum)
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
	MyCaos.a6		=(ULONG) MiscBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MISC_H */
