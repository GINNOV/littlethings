/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_POTGO_H
#define _PPCPRAGMA_POTGO_H
#ifdef __GNUC__
#ifndef _PPCINLINE__POTGO_H
#include <ppcinline/potgo.h>
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

#ifndef POTGO_BASE_NAME
#define POTGO_BASE_NAME PotgoBase
#endif /* !POTGO_BASE_NAME */

#define	AllocPotBits(bits)	_AllocPotBits(POTGO_BASE_NAME, bits)

static __inline UWORD
_AllocPotBits(void *PotgoBase, unsigned long bits)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) bits;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) PotgoBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	FreePotBits(bits)	_FreePotBits(POTGO_BASE_NAME, bits)

static __inline void
_FreePotBits(void *PotgoBase, unsigned long bits)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) bits;
	MyCaos.caos_Un.Offset	=	(-12);
	MyCaos.a6		=(ULONG) PotgoBase;	
	PPCCallOS(&MyCaos);
}

#define	WritePotgo(word, mask)	_WritePotgo(POTGO_BASE_NAME, word, mask)

static __inline void
_WritePotgo(void *PotgoBase, unsigned long word, unsigned long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) word;
	MyCaos.d1		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-18);
	MyCaos.a6		=(ULONG) PotgoBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_POTGO_H */
