/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MATHIEEEDOUBBAS_H
#define _PPCPRAGMA_MATHIEEEDOUBBAS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__MATHIEEEDOUBBAS_H
#include <ppcinline/mathieeedoubbas.h>
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

#ifndef MATHIEEEDOUBBAS_BASE_NAME
#define MATHIEEEDOUBBAS_BASE_NAME MathIeeeDoubBasBase
#endif /* !MATHIEEEDOUBBAS_BASE_NAME */

#define	IEEEDPAbs(parm)	_IEEEDPAbs(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPAbs(void *MathIeeeDoubBasBase, DOUBLE parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPAdd(leftParm, rightParm)	_IEEEDPAdd(MATHIEEEDOUBBAS_BASE_NAME, leftParm, rightParm)

static __inline DOUBLE
_IEEEDPAdd(void *MathIeeeDoubBasBase, DOUBLE leftParm, DOUBLE rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d2		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPCeil(parm)	_IEEEDPCeil(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPCeil(void *MathIeeeDoubBasBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPCmp(leftParm, rightParm)	_IEEEDPCmp(MATHIEEEDOUBBAS_BASE_NAME, leftParm, rightParm)

static __inline LONG
_IEEEDPCmp(void *MathIeeeDoubBasBase, DOUBLE leftParm, DOUBLE rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d2		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IEEEDPDiv(dividend, divisor)	_IEEEDPDiv(MATHIEEEDOUBBAS_BASE_NAME, dividend, divisor)

static __inline DOUBLE
_IEEEDPDiv(void *MathIeeeDoubBasBase, DOUBLE dividend, DOUBLE divisor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) dividend;
	MyCaos.d2		=(ULONG) divisor;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPFix(parm)	_IEEEDPFix(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline LONG
_IEEEDPFix(void *MathIeeeDoubBasBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IEEEDPFloor(parm)	_IEEEDPFloor(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPFloor(void *MathIeeeDoubBasBase, DOUBLE parm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) parm;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPFlt(integer)	_IEEEDPFlt(MATHIEEEDOUBBAS_BASE_NAME, integer)

static __inline DOUBLE
_IEEEDPFlt(void *MathIeeeDoubBasBase, long integer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) integer;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPMul(factor1, factor2)	_IEEEDPMul(MATHIEEEDOUBBAS_BASE_NAME, factor1, factor2)

static __inline DOUBLE
_IEEEDPMul(void *MathIeeeDoubBasBase, DOUBLE factor1, DOUBLE factor2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) factor1;
	MyCaos.d2		=(ULONG) factor2;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPNeg(parm)	_IEEEDPNeg(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline DOUBLE
_IEEEDPNeg(void *MathIeeeDoubBasBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPSub(leftParm, rightParm)	_IEEEDPSub(MATHIEEEDOUBBAS_BASE_NAME, leftParm, rightParm)

static __inline DOUBLE
_IEEEDPSub(void *MathIeeeDoubBasBase, DOUBLE leftParm, DOUBLE rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d2		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((DOUBLE)PPCCallOS(&MyCaos));
}

#define	IEEEDPTst(parm)	_IEEEDPTst(MATHIEEEDOUBBAS_BASE_NAME, parm)

static __inline LONG
_IEEEDPTst(void *MathIeeeDoubBasBase, DOUBLE parm)
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
	MyCaos.a6		=(ULONG) MathIeeeDoubBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MATHIEEEDOUBBAS_H */
