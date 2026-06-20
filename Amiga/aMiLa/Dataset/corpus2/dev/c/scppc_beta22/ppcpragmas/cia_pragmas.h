/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_CIA_H
#define _PPCPRAGMA_CIA_H
#ifdef __GNUC__
#ifndef _PPCINLINE__CIA_H
#include <ppcinline/cia.h>
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

#define	AbleICR(resource, mask)	_AbleICR(resource, mask)

static __inline WORD
_AbleICR(struct Library *resource, long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a6		=(ULONG) resource;
	MyCaos.d0		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-18);
	return((WORD)PPCCallOS(&MyCaos));
}

#define	AddICRVector(resource, iCRBit, interrupt)	_AddICRVector(resource, iCRBit, interrupt)

static __inline struct Interrupt *
_AddICRVector(struct Library *resource, long iCRBit, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a6		=(ULONG) resource;
	MyCaos.d0		=(ULONG) iCRBit;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-6);
	return((struct Interrupt *)PPCCallOS(&MyCaos));
}

#define	RemICRVector(resource, iCRBit, interrupt)	_RemICRVector(resource, iCRBit, interrupt)

static __inline void
_RemICRVector(struct Library *resource, long iCRBit, struct Interrupt *interrupt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a6		=(ULONG) resource;
	MyCaos.d0		=(ULONG) iCRBit;
	MyCaos.a1		=(ULONG) interrupt;
	MyCaos.caos_Un.Offset	=	(-12);
	PPCCallOS(&MyCaos);
}

#define	SetICR(resource, mask)	_SetICR(resource, mask)

static __inline WORD
_SetICR(struct Library *resource, long mask)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a6		=(ULONG) resource;
	MyCaos.d0		=(ULONG) mask;
	MyCaos.caos_Un.Offset	=	(-24);
	return((WORD)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_CIA_H */
