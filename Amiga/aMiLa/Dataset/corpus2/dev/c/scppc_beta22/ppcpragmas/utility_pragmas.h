/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_UTILITY_H
#define _PPCPRAGMA_UTILITY_H
#ifdef __GNUC__
#ifndef _PPCINLINE__UTILITY_H
#include <ppcinline/utility.h>
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

#ifndef UTILITY_BASE_NAME
#define UTILITY_BASE_NAME UtilityBase
#endif /* !UTILITY_BASE_NAME */

#define	AddNamedObject(nameSpace, object)	_AddNamedObject(UTILITY_BASE_NAME, nameSpace, object)

static __inline BOOL
_AddNamedObject(void *UtilityBase, struct NamedObject *nameSpace, struct NamedObject *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nameSpace;
	MyCaos.a1		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	AllocNamedObjectA(name, tagList)	_AllocNamedObjectA(UTILITY_BASE_NAME, name, tagList)

static __inline struct NamedObject *
_AllocNamedObjectA(void *UtilityBase, STRPTR name, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct NamedObject *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AllocNamedObject(a0, tags...) \
	({ULONG _tags[] = { tags }; AllocNamedObjectA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AllocateTagItems(numTags)	_AllocateTagItems(UTILITY_BASE_NAME, numTags)

static __inline struct TagItem *
_AllocateTagItems(void *UtilityBase, unsigned long numTags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) numTags;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct TagItem *)PPCCallOS(&MyCaos));
}

#define	Amiga2Date(seconds, result)	_Amiga2Date(UTILITY_BASE_NAME, seconds, result)

static __inline void
_Amiga2Date(void *UtilityBase, unsigned long seconds, struct ClockData *result)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) seconds;
	MyCaos.a0		=(ULONG) result;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	ApplyTagChanges(list, changeList)	_ApplyTagChanges(UTILITY_BASE_NAME, list, changeList)

static __inline void
_ApplyTagChanges(void *UtilityBase, struct TagItem *list, struct TagItem *changeList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) list;
	MyCaos.a1		=(ULONG) changeList;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	AttemptRemNamedObject(object)	_AttemptRemNamedObject(UTILITY_BASE_NAME, object)

static __inline LONG
_AttemptRemNamedObject(void *UtilityBase, struct NamedObject *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CallHookPkt(hook, object, paramPacket)	_CallHookPkt(UTILITY_BASE_NAME, hook, object, paramPacket)

static __inline ULONG
_CallHookPkt(void *UtilityBase, struct Hook *hook, APTR object, APTR paramPacket)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) hook;
	MyCaos.a2		=(ULONG) object;
	MyCaos.a1		=(ULONG) paramPacket;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CheckDate(date)	_CheckDate(UTILITY_BASE_NAME, date)

static __inline ULONG
_CheckDate(void *UtilityBase, struct ClockData *date)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) date;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CloneTagItems(tagList)	_CloneTagItems(UTILITY_BASE_NAME, tagList)

static __inline struct TagItem *
_CloneTagItems(void *UtilityBase, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct TagItem *)PPCCallOS(&MyCaos));
}

#define	Date2Amiga(date)	_Date2Amiga(UTILITY_BASE_NAME, date)

static __inline ULONG
_Date2Amiga(void *UtilityBase, struct ClockData *date)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) date;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	FilterTagChanges(changeList, originalList, apply)	_FilterTagChanges(UTILITY_BASE_NAME, changeList, originalList, apply)

static __inline void
_FilterTagChanges(void *UtilityBase, struct TagItem *changeList, struct TagItem *originalList, unsigned long apply)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) changeList;
	MyCaos.a1		=(ULONG) originalList;
	MyCaos.d0		=(ULONG) apply;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	FilterTagItems(tagList, filterArray, logic)	_FilterTagItems(UTILITY_BASE_NAME, tagList, filterArray, logic)

static __inline ULONG
_FilterTagItems(void *UtilityBase, struct TagItem *tagList, Tag *filterArray, unsigned long logic)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.a1		=(ULONG) filterArray;
	MyCaos.d0		=(ULONG) logic;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	FindNamedObject(nameSpace, name, lastObject)	_FindNamedObject(UTILITY_BASE_NAME, nameSpace, name, lastObject)

static __inline struct NamedObject *
_FindNamedObject(void *UtilityBase, struct NamedObject *nameSpace, STRPTR name, struct NamedObject *lastObject)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nameSpace;
	MyCaos.a1		=(ULONG) name;
	MyCaos.a2		=(ULONG) lastObject;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct NamedObject *)PPCCallOS(&MyCaos));
}

#define	FindTagItem(tagVal, tagList)	_FindTagItem(UTILITY_BASE_NAME, tagVal, tagList)

static __inline struct TagItem *
_FindTagItem(void *UtilityBase, Tag tagVal, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tagVal;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct TagItem *)PPCCallOS(&MyCaos));
}

#define	FreeNamedObject(object)	_FreeNamedObject(UTILITY_BASE_NAME, object)

static __inline void
_FreeNamedObject(void *UtilityBase, struct NamedObject *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeTagItems(tagList)	_FreeTagItems(UTILITY_BASE_NAME, tagList)

static __inline void
_FreeTagItems(void *UtilityBase, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	GetTagData(tagValue, defaultVal, tagList)	_GetTagData(UTILITY_BASE_NAME, tagValue, defaultVal, tagList)

static __inline ULONG
_GetTagData(void *UtilityBase, Tag tagValue, unsigned long defaultVal, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tagValue;
	MyCaos.d1		=(ULONG) defaultVal;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetUniqueID()	_GetUniqueID(UTILITY_BASE_NAME)

static __inline ULONG
_GetUniqueID(void *UtilityBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	MapTags(tagList, mapList, mapType)	_MapTags(UTILITY_BASE_NAME, tagList, mapList, mapType)

static __inline void
_MapTags(void *UtilityBase, struct TagItem *tagList, struct TagItem *mapList, unsigned long mapType)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.a1		=(ULONG) mapList;
	MyCaos.d0		=(ULONG) mapType;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	NamedObjectName(object)	_NamedObjectName(UTILITY_BASE_NAME, object)

static __inline STRPTR
_NamedObjectName(void *UtilityBase, struct NamedObject *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	NextTagItem(tagListPtr)	_NextTagItem(UTILITY_BASE_NAME, tagListPtr)

static __inline struct TagItem *
_NextTagItem(void *UtilityBase, struct TagItem **tagListPtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) tagListPtr;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((struct TagItem *)PPCCallOS(&MyCaos));
}

#define	PackBoolTags(initialFlags, tagList, boolMap)	_PackBoolTags(UTILITY_BASE_NAME, initialFlags, tagList, boolMap)

static __inline ULONG
_PackBoolTags(void *UtilityBase, unsigned long initialFlags, struct TagItem *tagList, struct TagItem *boolMap)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) initialFlags;
	MyCaos.a0		=(ULONG) tagList;
	MyCaos.a1		=(ULONG) boolMap;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	PackStructureTags(pack, packTable, tagList)	_PackStructureTags(UTILITY_BASE_NAME, pack, packTable, tagList)

static __inline ULONG
_PackStructureTags(void *UtilityBase, APTR pack, ULONG *packTable, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) pack;
	MyCaos.a1		=(ULONG) packTable;
	MyCaos.a2		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	RefreshTagItemClones(clone, original)	_RefreshTagItemClones(UTILITY_BASE_NAME, clone, original)

static __inline void
_RefreshTagItemClones(void *UtilityBase, struct TagItem *clone, struct TagItem *original)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) clone;
	MyCaos.a1		=(ULONG) original;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	ReleaseNamedObject(object)	_ReleaseNamedObject(UTILITY_BASE_NAME, object)

static __inline void
_ReleaseNamedObject(void *UtilityBase, struct NamedObject *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	RemNamedObject(object, message)	_RemNamedObject(UTILITY_BASE_NAME, object, message)

static __inline void
_RemNamedObject(void *UtilityBase, struct NamedObject *object, struct Message *message)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.a1		=(ULONG) message;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) UtilityBase;	
	PPCCallOS(&MyCaos);
}

#define	SDivMod32(dividend, divisor)	_SDivMod32(UTILITY_BASE_NAME, dividend, divisor)

static __inline LONG
_SDivMod32(void *UtilityBase, long dividend, long divisor)
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
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SMult32(arg1, arg2)	_SMult32(UTILITY_BASE_NAME, arg1, arg2)

static __inline LONG
_SMult32(void *UtilityBase, long arg1, long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) arg1;
	MyCaos.d1		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SMult64(arg1, arg2)	_SMult64(UTILITY_BASE_NAME, arg1, arg2)

static __inline LONG
_SMult64(void *UtilityBase, long arg1, long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) arg1;
	MyCaos.d1		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Stricmp(string1, string2)	_Stricmp(UTILITY_BASE_NAME, string1, string2)

static __inline LONG
_Stricmp(void *UtilityBase, STRPTR string1, STRPTR string2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) string1;
	MyCaos.a1		=(ULONG) string2;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Strnicmp(string1, string2, length)	_Strnicmp(UTILITY_BASE_NAME, string1, string2, length)

static __inline LONG
_Strnicmp(void *UtilityBase, STRPTR string1, STRPTR string2, long length)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) string1;
	MyCaos.a1		=(ULONG) string2;
	MyCaos.d0		=(ULONG) length;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	TagInArray(tagValue, tagArray)	_TagInArray(UTILITY_BASE_NAME, tagValue, tagArray)

static __inline BOOL
_TagInArray(void *UtilityBase, Tag tagValue, Tag *tagArray)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tagValue;
	MyCaos.a0		=(ULONG) tagArray;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ToLower(character)	_ToLower(UTILITY_BASE_NAME, character)

static __inline UBYTE
_ToLower(void *UtilityBase, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	ToUpper(character)	_ToUpper(UTILITY_BASE_NAME, character)

static __inline UBYTE
_ToUpper(void *UtilityBase, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((UBYTE)PPCCallOS(&MyCaos));
}

#define	UDivMod32(dividend, divisor)	_UDivMod32(UTILITY_BASE_NAME, dividend, divisor)

static __inline ULONG
_UDivMod32(void *UtilityBase, unsigned long dividend, unsigned long divisor)
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
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	UMult32(arg1, arg2)	_UMult32(UTILITY_BASE_NAME, arg1, arg2)

static __inline ULONG
_UMult32(void *UtilityBase, unsigned long arg1, unsigned long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) arg1;
	MyCaos.d1		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	UMult64(arg1, arg2)	_UMult64(UTILITY_BASE_NAME, arg1, arg2)

static __inline ULONG
_UMult64(void *UtilityBase, unsigned long arg1, unsigned long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) arg1;
	MyCaos.d1		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	UnpackStructureTags(pack, packTable, tagList)	_UnpackStructureTags(UTILITY_BASE_NAME, pack, packTable, tagList)

static __inline ULONG
_UnpackStructureTags(void *UtilityBase, APTR pack, ULONG *packTable, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) pack;
	MyCaos.a1		=(ULONG) packTable;
	MyCaos.a2		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) UtilityBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_UTILITY_H */
