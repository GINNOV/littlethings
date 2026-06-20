/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_LOWLEVEL_H
#define _PPCPRAGMA_LOWLEVEL_H
#ifdef __GNUC__
#ifndef _PPCINLINE__LOWLEVEL_H
#include <ppcinline/lowlevel.h>
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

#ifndef LOWLEVEL_BASE_NAME
#define LOWLEVEL_BASE_NAME LowLevelBase
#endif /* !LOWLEVEL_BASE_NAME */

#define	AddKBInt(intRoutine, intData)	_AddKBInt(LOWLEVEL_BASE_NAME, intRoutine, intData)

static __inline APTR
_AddKBInt(void *LowLevelBase, APTR intRoutine, APTR intData)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) intRoutine;
	MyCaos.a1		=(ULONG) intData;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AddTimerInt(intRoutine, intData)	_AddTimerInt(LOWLEVEL_BASE_NAME, intRoutine, intData)

static __inline APTR
_AddTimerInt(void *LowLevelBase, APTR intRoutine, APTR intData)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) intRoutine;
	MyCaos.a1		=(ULONG) intData;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AddVBlankInt(intRoutine, intData)	_AddVBlankInt(LOWLEVEL_BASE_NAME, intRoutine, intData)

static __inline APTR
_AddVBlankInt(void *LowLevelBase, APTR intRoutine, APTR intData)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) intRoutine;
	MyCaos.a1		=(ULONG) intData;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	ElapsedTime(context)	_ElapsedTime(LOWLEVEL_BASE_NAME, context)

static __inline ULONG
_ElapsedTime(void *LowLevelBase, struct EClockVal *context)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) context;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetKey()	_GetKey(LOWLEVEL_BASE_NAME)

static __inline ULONG
_GetKey(void *LowLevelBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetLanguageSelection()	_GetLanguageSelection(LOWLEVEL_BASE_NAME)

static __inline UBYTE
_GetLanguageSelection(void *LowLevelBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	QueryKeys(queryArray, arraySize)	_QueryKeys(LOWLEVEL_BASE_NAME, queryArray, arraySize)

static __inline void
_QueryKeys(void *LowLevelBase, struct KeyQuery *queryArray, unsigned long arraySize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) queryArray;
	MyCaos.d1		=(ULONG) arraySize;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadJoyPort(port)	_ReadJoyPort(LOWLEVEL_BASE_NAME, port)

static __inline ULONG
_ReadJoyPort(void *LowLevelBase, unsigned long port)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) port;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	RemKBInt(intHandle)	_RemKBInt(LOWLEVEL_BASE_NAME, intHandle)

static __inline void
_RemKBInt(void *LowLevelBase, APTR intHandle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) intHandle;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	RemTimerInt(intHandle)	_RemTimerInt(LOWLEVEL_BASE_NAME, intHandle)

static __inline void
_RemTimerInt(void *LowLevelBase, APTR intHandle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) intHandle;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	RemVBlankInt(intHandle)	_RemVBlankInt(LOWLEVEL_BASE_NAME, intHandle)

static __inline void
_RemVBlankInt(void *LowLevelBase, APTR intHandle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) intHandle;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	SetJoyPortAttrsA(portNumber, tagList)	_SetJoyPortAttrsA(LOWLEVEL_BASE_NAME, portNumber, tagList)

static __inline BOOL
_SetJoyPortAttrsA(void *LowLevelBase, unsigned long portNumber, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) portNumber;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetJoyPortAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; SetJoyPortAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	StartTimerInt(intHandle, timeInterval, continuous)	_StartTimerInt(LOWLEVEL_BASE_NAME, intHandle, timeInterval, continuous)

static __inline void
_StartTimerInt(void *LowLevelBase, APTR intHandle, unsigned long timeInterval, long continuous)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) intHandle;
	MyCaos.d0		=(ULONG) timeInterval;
	MyCaos.d1		=(ULONG) continuous;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	StopTimerInt(intHandle)	_StopTimerInt(LOWLEVEL_BASE_NAME, intHandle)

static __inline void
_StopTimerInt(void *LowLevelBase, APTR intHandle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) intHandle;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	PPCCallOS(&MyCaos);
}

#define	SystemControlA(tagList)	_SystemControlA(LOWLEVEL_BASE_NAME, tagList)

static __inline ULONG
_SystemControlA(void *LowLevelBase, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) LowLevelBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SystemControl(tags...) \
	({ULONG _tags[] = { tags }; SystemControlA((struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_LOWLEVEL_H */
