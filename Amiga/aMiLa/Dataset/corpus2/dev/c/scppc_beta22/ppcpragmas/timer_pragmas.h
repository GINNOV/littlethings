/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_TIMER_H
#define _PPCPRAGMA_TIMER_H
#ifdef __GNUC__
#ifndef _PPCINLINE__TIMER_H
#include <ppcinline/timer.h>
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

#ifndef TIMER_BASE_NAME
#define TIMER_BASE_NAME TimerBase
#endif /* !TIMER_BASE_NAME */

#define	AddTime(dest, src)	_AddTime(TIMER_BASE_NAME, dest, src)

static __inline void
_AddTime(void *TimerBase, struct timeval *dest, struct timeval *src)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dest;
	MyCaos.a1		=(ULONG) src;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) TimerBase;	
	PPCCallOS(&MyCaos);
}

#define	CmpTime(dest, src)	_CmpTime(TIMER_BASE_NAME, dest, src)

static __inline LONG
_CmpTime(void *TimerBase, struct timeval *dest, struct timeval *src)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dest;
	MyCaos.a1		=(ULONG) src;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) TimerBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GetSysTime(dest)	_GetSysTime(TIMER_BASE_NAME, dest)

static __inline void
_GetSysTime(void *TimerBase, struct timeval *dest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dest;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) TimerBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadEClock(dest)	_ReadEClock(TIMER_BASE_NAME, dest)

static __inline ULONG
_ReadEClock(void *TimerBase, struct EClockVal *dest)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dest;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) TimerBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	SubTime(dest, src)	_SubTime(TIMER_BASE_NAME, dest, src)

static __inline void
_SubTime(void *TimerBase, struct timeval *dest, struct timeval *src)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dest;
	MyCaos.a1		=(ULONG) src;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) TimerBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_TIMER_H */
