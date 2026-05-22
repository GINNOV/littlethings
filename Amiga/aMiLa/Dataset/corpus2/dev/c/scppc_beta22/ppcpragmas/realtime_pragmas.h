/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_REALTIME_H
#define _PPCPRAGMA_REALTIME_H
#ifdef __GNUC__
#ifndef _PPCINLINE__REALTIME_H
#include <ppcinline/realtime.h>
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

#ifndef REALTIME_BASE_NAME
#define REALTIME_BASE_NAME RealTimeBase
#endif /* !REALTIME_BASE_NAME */

#define	CreatePlayerA(tagList)	_CreatePlayerA(REALTIME_BASE_NAME, tagList)

static __inline struct Player *
_CreatePlayerA(void *RealTimeBase, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((struct Player *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define CreatePlayer(tags...) \
	({ULONG _tags[] = { tags }; CreatePlayerA((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	DeletePlayer(player)	_DeletePlayer(REALTIME_BASE_NAME, player)

static __inline void
_DeletePlayer(void *RealTimeBase, struct Player *player)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) player;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	PPCCallOS(&MyCaos);
}

#define	ExternalSync(player, minTime, maxTime)	_ExternalSync(REALTIME_BASE_NAME, player, minTime, maxTime)

static __inline BOOL
_ExternalSync(void *RealTimeBase, struct Player *player, long minTime, long maxTime)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) player;
	MyCaos.d0		=(ULONG) minTime;
	MyCaos.d1		=(ULONG) maxTime;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FindConductor(name)	_FindConductor(REALTIME_BASE_NAME, name)

static __inline struct Conductor *
_FindConductor(void *RealTimeBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((struct Conductor *)PPCCallOS(&MyCaos));
}

#define	GetPlayerAttrsA(player, tagList)	_GetPlayerAttrsA(REALTIME_BASE_NAME, player, tagList)

static __inline ULONG
_GetPlayerAttrsA(void *RealTimeBase, struct Player *player, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) player;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define GetPlayerAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; GetPlayerAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	LockRealTime(lockType)	_LockRealTime(REALTIME_BASE_NAME, lockType)

static __inline APTR
_LockRealTime(void *RealTimeBase, unsigned long lockType)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) lockType;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	NextConductor(previousConductor)	_NextConductor(REALTIME_BASE_NAME, previousConductor)

static __inline struct Conductor *
_NextConductor(void *RealTimeBase, struct Conductor *previousConductor)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) previousConductor;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((struct Conductor *)PPCCallOS(&MyCaos));
}

#define	SetConductorState(player, state, time)	_SetConductorState(REALTIME_BASE_NAME, player, state, time)

static __inline LONG
_SetConductorState(void *RealTimeBase, struct Player *player, unsigned long state, long time)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) player;
	MyCaos.d0		=(ULONG) state;
	MyCaos.d1		=(ULONG) time;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetPlayerAttrsA(player, tagList)	_SetPlayerAttrsA(REALTIME_BASE_NAME, player, tagList)

static __inline BOOL
_SetPlayerAttrsA(void *RealTimeBase, struct Player *player, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) player;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetPlayerAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; SetPlayerAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	UnlockRealTime(lock)	_UnlockRealTime(REALTIME_BASE_NAME, lock)

static __inline void
_UnlockRealTime(void *RealTimeBase, APTR lock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) lock;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) RealTimeBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_REALTIME_H */
