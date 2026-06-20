/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_EXPANSION_H
#define _PPCPRAGMA_EXPANSION_H
#ifdef __GNUC__
#ifndef _PPCINLINE__EXPANSION_H
#include <ppcinline/expansion.h>
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

#ifndef EXPANSION_BASE_NAME
#define EXPANSION_BASE_NAME ExpansionBase
#endif /* !EXPANSION_BASE_NAME */

#define	AddBootNode(bootPri, flags, deviceNode, configDev)	_AddBootNode(EXPANSION_BASE_NAME, bootPri, flags, deviceNode, configDev)

static __inline BOOL
_AddBootNode(void *ExpansionBase, long bootPri, unsigned long flags, struct DeviceNode *deviceNode, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) bootPri;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.a0		=(ULONG) deviceNode;
	MyCaos.a1		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AddConfigDev(configDev)	_AddConfigDev(EXPANSION_BASE_NAME, configDev)

static __inline void
_AddConfigDev(void *ExpansionBase, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	AddDosNode(bootPri, flags, deviceNode)	_AddDosNode(EXPANSION_BASE_NAME, bootPri, flags, deviceNode)

static __inline BOOL
_AddDosNode(void *ExpansionBase, long bootPri, unsigned long flags, struct DeviceNode *deviceNode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) bootPri;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.a0		=(ULONG) deviceNode;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AllocBoardMem(slotSpec)	_AllocBoardMem(EXPANSION_BASE_NAME, slotSpec)

static __inline void
_AllocBoardMem(void *ExpansionBase, unsigned long slotSpec)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) slotSpec;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	AllocConfigDev()	_AllocConfigDev(EXPANSION_BASE_NAME)

static __inline struct ConfigDev *
_AllocConfigDev(void *ExpansionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((struct ConfigDev *)PPCCallOS(&MyCaos));
}

#define	AllocExpansionMem(numSlots, slotAlign)	_AllocExpansionMem(EXPANSION_BASE_NAME, numSlots, slotAlign)

static __inline APTR
_AllocExpansionMem(void *ExpansionBase, unsigned long numSlots, unsigned long slotAlign)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) numSlots;
	MyCaos.d1		=(ULONG) slotAlign;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	ConfigBoard(board, configDev)	_ConfigBoard(EXPANSION_BASE_NAME, board, configDev)

static __inline void
_ConfigBoard(void *ExpansionBase, APTR board, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) board;
	MyCaos.a1		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	ConfigChain(baseAddr)	_ConfigChain(EXPANSION_BASE_NAME, baseAddr)

static __inline void
_ConfigChain(void *ExpansionBase, APTR baseAddr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) baseAddr;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	FindConfigDev(oldConfigDev, manufacturer, product)	_FindConfigDev(EXPANSION_BASE_NAME, oldConfigDev, manufacturer, product)

static __inline struct ConfigDev *
_FindConfigDev(void *ExpansionBase, struct ConfigDev *oldConfigDev, long manufacturer, long product)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) oldConfigDev;
	MyCaos.d0		=(ULONG) manufacturer;
	MyCaos.d1		=(ULONG) product;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((struct ConfigDev *)PPCCallOS(&MyCaos));
}

#define	FreeBoardMem(startSlot, slotSpec)	_FreeBoardMem(EXPANSION_BASE_NAME, startSlot, slotSpec)

static __inline void
_FreeBoardMem(void *ExpansionBase, unsigned long startSlot, unsigned long slotSpec)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) startSlot;
	MyCaos.d1		=(ULONG) slotSpec;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeConfigDev(configDev)	_FreeConfigDev(EXPANSION_BASE_NAME, configDev)

static __inline void
_FreeConfigDev(void *ExpansionBase, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeExpansionMem(startSlot, numSlots)	_FreeExpansionMem(EXPANSION_BASE_NAME, startSlot, numSlots)

static __inline void
_FreeExpansionMem(void *ExpansionBase, unsigned long startSlot, unsigned long numSlots)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) startSlot;
	MyCaos.d1		=(ULONG) numSlots;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	GetCurrentBinding(currentBinding, bindingSize)	_GetCurrentBinding(EXPANSION_BASE_NAME, currentBinding, bindingSize)

static __inline ULONG
_GetCurrentBinding(void *ExpansionBase, struct CurrentBinding *currentBinding, unsigned long bindingSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) currentBinding;
	MyCaos.d0		=(ULONG) bindingSize;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	MakeDosNode(parmPacket)	_MakeDosNode(EXPANSION_BASE_NAME, parmPacket)

static __inline struct DeviceNode *
_MakeDosNode(void *ExpansionBase, APTR parmPacket)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) parmPacket;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((struct DeviceNode *)PPCCallOS(&MyCaos));
}

#define	ObtainConfigBinding()	_ObtainConfigBinding(EXPANSION_BASE_NAME)

static __inline void
_ObtainConfigBinding(void *ExpansionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	ReadExpansionByte(board, offset)	_ReadExpansionByte(EXPANSION_BASE_NAME, board, offset)

static __inline UBYTE
_ReadExpansionByte(void *ExpansionBase, APTR board, unsigned long offset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) board;
	MyCaos.d0		=(ULONG) offset;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	ReadExpansionRom(board, configDev)	_ReadExpansionRom(EXPANSION_BASE_NAME, board, configDev)

static __inline void
_ReadExpansionRom(void *ExpansionBase, APTR board, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) board;
	MyCaos.a1		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	ReleaseConfigBinding()	_ReleaseConfigBinding(EXPANSION_BASE_NAME)

static __inline void
_ReleaseConfigBinding(void *ExpansionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	RemConfigDev(configDev)	_RemConfigDev(EXPANSION_BASE_NAME, configDev)

static __inline void
_RemConfigDev(void *ExpansionBase, struct ConfigDev *configDev)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) configDev;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	SetCurrentBinding(currentBinding, bindingSize)	_SetCurrentBinding(EXPANSION_BASE_NAME, currentBinding, bindingSize)

static __inline void
_SetCurrentBinding(void *ExpansionBase, struct CurrentBinding *currentBinding, unsigned long bindingSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) currentBinding;
	MyCaos.d0		=(ULONG) bindingSize;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#define	WriteExpansionByte(board, offset, byte)	_WriteExpansionByte(EXPANSION_BASE_NAME, board, offset, byte)

static __inline void
_WriteExpansionByte(void *ExpansionBase, APTR board, unsigned long offset, unsigned long byte)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) board;
	MyCaos.d0		=(ULONG) offset;
	MyCaos.d1		=(ULONG) byte;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) ExpansionBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_EXPANSION_H */
