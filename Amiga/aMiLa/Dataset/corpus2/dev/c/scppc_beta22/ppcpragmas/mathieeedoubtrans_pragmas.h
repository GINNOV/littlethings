/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MATHIEEEDOUBTRANS_H
#define _PPCPRAGMA_MATHIEEEDOUBTRANS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__MATHIEEEDOUBTRANS_H
#include <ppcinline/mathieeedoubtrans.h>
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

#ifndef MATHIEEEDOUBTRANS_BASE_NAME
#define MATHIEEEDOUBTRANS_BASE_NAME MathIeeeDoubTransBase
#endif /* !MATHIEEEDOUBTRANS_BASE_NAME */

#define	IEEEDPAcos(parm)	_IEEEDPAcos(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPAcos(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPAsin(parm)	_IEEEDPAsin(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPAsin(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPAtan(parm)	_IEEEDPAtan(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPAtan(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPCos(parm)	_IEEEDPCos(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPCos(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPCosh(parm)	_IEEEDPCosh(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPCosh(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPExp(parm)	_IEEEDPExp(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPExp(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPFieee(single)	_IEEEDPFieee(MATHIEEEDOUBTRANS_BASE_NAME, single)

static __inline DOUBLE
_IEEEDPFieee(void *MathIeeeDoubTransBase, FLOAT single)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) single;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPLog(parm)	_IEEEDPLog(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPLog(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPLog10(parm)	_IEEEDPLog10(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPLog10(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPPow(exp, arg)	_IEEEDPPow(MATHIEEEDOUBTRANS_BASE_NAME, exp, arg)

static __inline DOUBLE
_IEEEDPPow(void *MathIeeeDoubTransBase, DOUBLE exp, DOUBLE arg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d2		=(ULONG) exp;
	MyCaos.d0		=(ULONG) arg;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPSin(parm)	_IEEEDPSin(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPSin(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPSincos(pf2, parm)	_IEEEDPSincos(MATHIEEEDOUBTRANS_BASE_NAME, pf2, parm)

static __inline DOUBLE
_IEEEDPSincos(void *MathIeeeDoubTransBase, DOUBLE *pf2, DOUBLE parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) pf2;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPSinh(parm)	_IEEEDPSinh(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPSinh(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPSqrt(parm)	_IEEEDPSqrt(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPSqrt(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPTan(parm)	_IEEEDPTan(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPTan(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPTanh(parm)	_IEEEDPTanh(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPTanh(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPTieee(parm)	_IEEEDPTieee(MATHIEEEDOUBTRANS_BASE_NAME, parm)

static __inline FLOAT
_IEEEDPTieee(void *MathIeeeDoubTransBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubTransBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MATHIEEEDOUBTRANS_H */
