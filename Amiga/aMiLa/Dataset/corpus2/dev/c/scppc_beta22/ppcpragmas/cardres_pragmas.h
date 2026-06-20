/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_CARDRES_H
#define _PPCPRAGMA_CARDRES_H
#ifdef __GNUC__
#ifndef _PPCINLINE__CARDRES_H
#include <ppcinline/cardres.h>
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

#ifndef CARDRES_BASE_NAME
#define CARDRES_BASE_NAME CardResource
#endif /* !CARDRES_BASE_NAME */

#define	BeginCardAccess(handle)	_BeginCardAccess(CARDRES_BASE_NAME, handle)

static __inline BOOL
_BeginCardAccess(void *CardResource, struct CardHandle *handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-24);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CardAccessSpeed(handle, nanoseconds)	_CardAccessSpeed(CARDRES_BASE_NAME, handle, nanoseconds)

static __inline ULONG
_CardAccessSpeed(void *CardResource, struct CardHandle *handle, unsigned long nanoseconds)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.d0		=(ULONG) nanoseconds;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) CardResource;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CardChangeCount()	_CardChangeCount(CARDRES_BASE_NAME)

static __inline ULONG
_CardChangeCount(void *CardResource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) CardResource;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CardForceChange()	_CardForceChange(CARDRES_BASE_NAME)

static __inline BOOL
_CardForceChange(void *CardResource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CardInterface()	_CardInterface(CARDRES_BASE_NAME)

static __inline ULONG
_CardInterface(void *CardResource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) CardResource;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CardMiscControl(handle, control_bits)	_CardMiscControl(CARDRES_BASE_NAME, handle, control_bits)

static __inline UBYTE
_CardMiscControl(void *CardResource, struct CardHandle *handle, unsigned long control_bits)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.d1		=(ULONG) control_bits;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) CardResource;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	CardProgramVoltage(handle, voltage)	_CardProgramVoltage(CARDRES_BASE_NAME, handle, voltage)

static __inline LONG
_CardProgramVoltage(void *CardResource, struct CardHandle *handle, unsigned long voltage)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.d0		=(ULONG) voltage;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) CardResource;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CardResetCard(handle)	_CardResetCard(CARDRES_BASE_NAME, handle)

static __inline BOOL
_CardResetCard(void *CardResource, struct CardHandle *handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CardResetRemove(handle, flag)	_CardResetRemove(CARDRES_BASE_NAME, handle, flag)

static __inline BOOL
_CardResetRemove(void *CardResource, struct CardHandle *handle, unsigned long flag)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.d0		=(ULONG) flag;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CopyTuple(handle, buffer, tuplecode, size)	_CopyTuple(CARDRES_BASE_NAME, handle, buffer, tuplecode, size)

static __inline BOOL
_CopyTuple(void *CardResource, struct CardHandle *handle, UBYTE *buffer, unsigned long tuplecode, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d1		=(ULONG) tuplecode;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	DeviceTuple(tuple_data, storage)	_DeviceTuple(CARDRES_BASE_NAME, tuple_data, storage)

static __inline ULONG
_DeviceTuple(void *CardResource, UBYTE *tuple_data, struct DeviceTData *storage)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tuple_data;
	MyCaos.a1		=(ULONG) storage;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) CardResource;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	EndCardAccess(handle)	_EndCardAccess(CARDRES_BASE_NAME, handle)

static __inline BOOL
_EndCardAccess(void *CardResource, struct CardHandle *handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) CardResource;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	GetCardMap()	_GetCardMap(CARDRES_BASE_NAME)

static __inline struct CardMemoryMap *
_GetCardMap(void *CardResource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-18);
	MyCaos.a6		=(ULONG) CardResource;	
	return((struct CardMemoryMap *)PPCCallOS(&MyCaos));
}

#define	IfAmigaXIP(handle)	_IfAmigaXIP(CARDRES_BASE_NAME, handle)

static __inline struct Resident *
_IfAmigaXIP(void *CardResource, struct CardHandle *handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a2		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) CardResource;	
	return((struct Resident *)PPCCallOS(&MyCaos));
}

#define	OwnCard(handle)	_OwnCard(CARDRES_BASE_NAME, handle)

static __inline struct CardHandle *
_OwnCard(void *CardResource, struct CardHandle *handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-6);
	MyCaos.a6		=(ULONG) CardResource;	
	return((struct CardHandle *)PPCCallOS(&MyCaos));
}

#define	ReadCardStatus()	_ReadCardStatus(CARDRES_BASE_NAME)

static __inline UBYTE
_ReadCardStatus(void *CardResource)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) CardResource;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	ReleaseCard(handle, flags)	_ReleaseCard(CARDRES_BASE_NAME, handle, flags)

static __inline void
_ReleaseCard(void *CardResource, struct CardHandle *handle, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) handle;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-12);
	MyCaos.a6		=(ULONG) CardResource;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_CARDRES_H */
