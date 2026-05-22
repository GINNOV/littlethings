/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_ICON_H
#define _PPCPRAGMA_ICON_H
#ifdef __GNUC__
#ifndef _PPCINLINE__ICON_H
#include <ppcinline/icon.h>
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

#ifndef ICON_BASE_NAME
#define ICON_BASE_NAME IconBase
#endif /* !ICON_BASE_NAME */

#define	AddFreeList(freelist, mem, size)	_AddFreeList(ICON_BASE_NAME, freelist, mem, size)

static __inline BOOL
_AddFreeList(void *IconBase, struct FreeList *freelist, APTR mem, unsigned long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) freelist;
	MyCaos.a1		=(ULONG) mem;
	MyCaos.a2		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) IconBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	BumpRevision(newname, oldname)	_BumpRevision(ICON_BASE_NAME, newname, oldname)

static __inline UBYTE *
_BumpRevision(void *IconBase, UBYTE *newname, UBYTE *oldname)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newname;
	MyCaos.a1		=(ULONG) oldname;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) IconBase;	
	return((UBYTE *)PPCCallOS(&MyCaos));
}

#define	DeleteDiskObject(name)	_DeleteDiskObject(ICON_BASE_NAME, name)

static __inline BOOL
_DeleteDiskObject(void *IconBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) IconBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FindToolType(toolTypeArray, typeName)	_FindToolType(ICON_BASE_NAME, toolTypeArray, typeName)

static __inline UBYTE *
_FindToolType(void *IconBase, UBYTE **toolTypeArray, UBYTE *typeName)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) toolTypeArray;
	MyCaos.a1		=(ULONG) typeName;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) IconBase;	
	return((UBYTE *)PPCCallOS(&MyCaos));
}

#define	FreeDiskObject(diskobj)	_FreeDiskObject(ICON_BASE_NAME, diskobj)

static __inline void
_FreeDiskObject(void *IconBase, struct DiskObject *diskobj)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) diskobj;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) IconBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeFreeList(freelist)	_FreeFreeList(ICON_BASE_NAME, freelist)

static __inline void
_FreeFreeList(void *IconBase, struct FreeList *freelist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) freelist;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) IconBase;	
	PPCCallOS(&MyCaos);
}

#define	GetDefDiskObject(type)	_GetDefDiskObject(ICON_BASE_NAME, type)

static __inline struct DiskObject *
_GetDefDiskObject(void *IconBase, long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) IconBase;	
	return((struct DiskObject *)PPCCallOS(&MyCaos));
}

#define	GetDiskObject(name)	_GetDiskObject(ICON_BASE_NAME, name)

static __inline struct DiskObject *
_GetDiskObject(void *IconBase, UBYTE *name)
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
	MyCaos.a6		=(ULONG) IconBase;	
	return((struct DiskObject *)PPCCallOS(&MyCaos));
}

#define	GetDiskObjectNew(name)	_GetDiskObjectNew(ICON_BASE_NAME, name)

static __inline struct DiskObject *
_GetDiskObjectNew(void *IconBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) IconBase;	
	return((struct DiskObject *)PPCCallOS(&MyCaos));
}

#define	MatchToolValue(typeString, value)	_MatchToolValue(ICON_BASE_NAME, typeString, value)

static __inline BOOL
_MatchToolValue(void *IconBase, UBYTE *typeString, UBYTE *value)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) typeString;
	MyCaos.a1		=(ULONG) value;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) IconBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	PutDefDiskObject(diskObject)	_PutDefDiskObject(ICON_BASE_NAME, diskObject)

static __inline BOOL
_PutDefDiskObject(void *IconBase, struct DiskObject *diskObject)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) diskObject;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) IconBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	PutDiskObject(name, diskobj)	_PutDiskObject(ICON_BASE_NAME, name, diskobj)

static __inline BOOL
_PutDiskObject(void *IconBase, UBYTE *name, struct DiskObject *diskobj)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.a1		=(ULONG) diskobj;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) IconBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_ICON_H */
