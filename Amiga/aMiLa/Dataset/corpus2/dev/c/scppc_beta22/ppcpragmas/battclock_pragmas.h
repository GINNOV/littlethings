/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_BATTCLOCK_H
#define _PPCPRAGMA_BATTCLOCK_H
#ifdef __GNUC__
#ifndef _PPCINLINE__BATTCLOCK_H
#include <ppcinline/battclock.h>
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

#ifndef BATTCLOCK_BASE_NAME
#define BATTCLOCK_BASE_NAME BattClockBase
#endif /* !BATTCLOCK_BASE_NAME */

#define	ReadBattClock()	_ReadBattClock(BATTCLOCK_BASE_NAME)

static __inline ULONG
_ReadBattClock(void *BattClockBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-12);
	MyCaos.a6		=(ULONG) BattClockBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ResetBattClock()	_ResetBattClock(BATTCLOCK_BASE_NAME)

static __inline void
_ResetBattClock(void *BattClockBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) BattClockBase;	
	PPCCallOS(&MyCaos);
}

#define	WriteBattClock(time)	_WriteBattClock(BATTCLOCK_BASE_NAME, time)

static __inline void
_WriteBattClock(void *BattClockBase, unsigned long time)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) time;
	MyCaos.caos_Un.Offset	=	(-18);
	MyCaos.a6		=(ULONG) BattClockBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_BATTCLOCK_H */
