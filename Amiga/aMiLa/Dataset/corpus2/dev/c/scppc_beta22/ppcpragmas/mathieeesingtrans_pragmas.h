/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MATHIEEESINGTRANS_H
#define _PPCPRAGMA_MATHIEEESINGTRANS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__MATHIEEESINGTRANS_H
#include <ppcinline/mathieeesingtrans.h>
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

#ifndef MATHIEEESINGTRANS_BASE_NAME
#define MATHIEEESINGTRANS_BASE_NAME MathIeeeSingTransBase
#endif /* !MATHIEEESINGTRANS_BASE_NAME */

#define	IEEESPAcos(parm)	_IEEESPAcos(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPAcos(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPAsin(parm)	_IEEESPAsin(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPAsin(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPAtan(parm)	_IEEESPAtan(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPAtan(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPCos(parm)	_IEEESPCos(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPCos(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPCosh(parm)	_IEEESPCosh(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPCosh(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPExp(parm)	_IEEESPExp(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPExp(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPFieee(parm)	_IEEESPFieee(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPFieee(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPLog(parm)	_IEEESPLog(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPLog(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPLog10(parm)	_IEEESPLog10(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPLog10(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPPow(exp, arg)	_IEEESPPow(MATHIEEESINGTRANS_BASE_NAME, exp, arg)

static __inline FLOAT
_IEEESPPow(void *MathIeeeSingTransBase, FLOAT exp, FLOAT arg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d1		=(ULONG) exp;
	MyCaos.d0		=(ULONG) arg;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPSin(parm)	_IEEESPSin(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPSin(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPSincos(cosptr, parm)	_IEEESPSincos(MATHIEEESINGTRANS_BASE_NAME, cosptr, parm)

static __inline FLOAT
_IEEESPSincos(void *MathIeeeSingTransBase, FLOAT *cosptr, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cosptr;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPSinh(parm)	_IEEESPSinh(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPSinh(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPSqrt(parm)	_IEEESPSqrt(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPSqrt(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPTan(parm)	_IEEESPTan(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPTan(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPTanh(parm)	_IEEESPTanh(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPTanh(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPTieee(parm)	_IEEESPTieee(MATHIEEESINGTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPTieee(void *MathIeeeSingTransBase, FLOAT parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) MathIeeeSingTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MATHIEEESINGTRANS_H */
