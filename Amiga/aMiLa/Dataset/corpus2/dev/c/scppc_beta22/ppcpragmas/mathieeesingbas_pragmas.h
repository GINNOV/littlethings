/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_MATHIEEESINGBAS_H
#define _PPCPRAGMA_MATHIEEESINGBAS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__MATHIEEESINGBAS_H
#include <ppcinline/mathieeesingbas.h>
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

#ifndef MATHIEEESINGBAS_BASE_NAME
#define MATHIEEESINGBAS_BASE_NAME MathIeeeSingBasBase
#endif /* !MATHIEEESINGBAS_BASE_NAME */

#define	IEEESPAbs(parm)	_IEEESPAbs(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPAbs(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPAdd(leftParm, rightParm)	_IEEESPAdd(MATHIEEESINGBAS_BASE_NAME, leftParm, rightParm)

static __inline FLOAT
_IEEESPAdd(void *MathIeeeSingBasBase, FLOAT leftParm, FLOAT rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d1		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPCeil(parm)	_IEEESPCeil(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPCeil(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPCmp(leftParm, rightParm)	_IEEESPCmp(MATHIEEESINGBAS_BASE_NAME, leftParm, rightParm)

static __inline LONG
_IEEESPCmp(void *MathIeeeSingBasBase, FLOAT leftParm, FLOAT rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d1		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IEEESPDiv(dividend, divisor)	_IEEESPDiv(MATHIEEESINGBAS_BASE_NAME, dividend, divisor)

static __inline FLOAT
_IEEESPDiv(void *MathIeeeSingBasBase, FLOAT dividend, FLOAT divisor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) dividend;
	MyCaos.d1		=(ULONG) divisor;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPFix(parm)	_IEEESPFix(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline LONG
_IEEESPFix(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IEEESPFloor(parm)	_IEEESPFloor(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPFloor(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPFlt(integer)	_IEEESPFlt(MATHIEEESINGBAS_BASE_NAME, integer)

static __inline FLOAT
_IEEESPFlt(void *MathIeeeSingBasBase, long integer)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPMul(leftParm, rightParm)	_IEEESPMul(MATHIEEESINGBAS_BASE_NAME, leftParm, rightParm)

static __inline FLOAT
_IEEESPMul(void *MathIeeeSingBasBase, FLOAT leftParm, FLOAT rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d1		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPNeg(parm)	_IEEESPNeg(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline FLOAT
_IEEESPNeg(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPSub(leftParm, rightParm)	_IEEESPSub(MATHIEEESINGBAS_BASE_NAME, leftParm, rightParm)

static __inline FLOAT
_IEEESPSub(void *MathIeeeSingBasBase, FLOAT leftParm, FLOAT rightParm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) leftParm;
	MyCaos.d1		=(ULONG) rightParm;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((FLOAT)PPCCallOS(&MyCaos));
}

#define	IEEESPTst(parm)	_IEEESPTst(MATHIEEESINGBAS_BASE_NAME, parm)

static __inline LONG
_IEEESPTst(void *MathIeeeSingBasBase, FLOAT parm)
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
	MyCaos.a6		=(ULONG) MathIeeeSingBasBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_MATHIEEESINGBAS_H */
