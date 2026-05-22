/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_IFFPARSE_H
#define _PPCPRAGMA_IFFPARSE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__IFFPARSE_H
#include <ppcinline/iffparse.h>
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

#ifndef IFFPARSE_BASE_NAME
#define IFFPARSE_BASE_NAME IFFParseBase
#endif /* !IFFPARSE_BASE_NAME */

#define	AllocIFF()	_AllocIFF(IFFPARSE_BASE_NAME)

static __inline struct IFFHandle *
_AllocIFF(void *IFFParseBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct IFFHandle *)PPCCallOS(&MyCaos));
}

#define	AllocLocalItem(type, id, ident, dataSize)	_AllocLocalItem(IFFPARSE_BASE_NAME, type, id, ident, dataSize)

static __inline struct LocalContextItem *
_AllocLocalItem(void *IFFParseBase, long type, long id, long ident, long dataSize)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.d2		=(ULONG) ident;
	MyCaos.d3		=(ULONG) dataSize;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct LocalContextItem *)PPCCallOS(&MyCaos));
}

#define	CloseClipboard(clipHandle)	_CloseClipboard(IFFPARSE_BASE_NAME, clipHandle)

static __inline void
_CloseClipboard(void *IFFParseBase, struct ClipboardHandle *clipHandle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) clipHandle;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseIFF(iff)	_CloseIFF(IFFPARSE_BASE_NAME, iff)

static __inline void
_CloseIFF(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	CollectionChunk(iff, type, id)	_CollectionChunk(IFFPARSE_BASE_NAME, iff, type, id)

static __inline LONG
_CollectionChunk(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CollectionChunks(iff, propArray, numPairs)	_CollectionChunks(IFFPARSE_BASE_NAME, iff, propArray, numPairs)

static __inline LONG
_CollectionChunks(void *IFFParseBase, struct IFFHandle *iff, LONG *propArray, long numPairs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) propArray;
	MyCaos.d0		=(ULONG) numPairs;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CurrentChunk(iff)	_CurrentChunk(IFFPARSE_BASE_NAME, iff)

static __inline struct ContextNode *
_CurrentChunk(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct ContextNode *)PPCCallOS(&MyCaos));
}

#define	EntryHandler(iff, type, id, position, handler, object)	_EntryHandler(IFFPARSE_BASE_NAME, iff, type, id, position, handler, object)

static __inline LONG
_EntryHandler(void *IFFParseBase, struct IFFHandle *iff, long type, long id, long position, struct Hook *handler, APTR object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.d2		=(ULONG) position;
	MyCaos.a1		=(ULONG) handler;
	MyCaos.a2		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ExitHandler(iff, type, id, position, handler, object)	_ExitHandler(IFFPARSE_BASE_NAME, iff, type, id, position, handler, object)

static __inline LONG
_ExitHandler(void *IFFParseBase, struct IFFHandle *iff, long type, long id, long position, struct Hook *handler, APTR object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.d2		=(ULONG) position;
	MyCaos.a1		=(ULONG) handler;
	MyCaos.a2		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	FindCollection(iff, type, id)	_FindCollection(IFFPARSE_BASE_NAME, iff, type, id)

static __inline struct CollectionItem *
_FindCollection(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct CollectionItem *)PPCCallOS(&MyCaos));
}

#define	FindLocalItem(iff, type, id, ident)	_FindLocalItem(IFFPARSE_BASE_NAME, iff, type, id, ident)

static __inline struct LocalContextItem *
_FindLocalItem(void *IFFParseBase, struct IFFHandle *iff, long type, long id, long ident)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.d2		=(ULONG) ident;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct LocalContextItem *)PPCCallOS(&MyCaos));
}

#define	FindProp(iff, type, id)	_FindProp(IFFPARSE_BASE_NAME, iff, type, id)

static __inline struct StoredProperty *
_FindProp(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct StoredProperty *)PPCCallOS(&MyCaos));
}

#define	FindPropContext(iff)	_FindPropContext(IFFPARSE_BASE_NAME, iff)

static __inline struct ContextNode *
_FindPropContext(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct ContextNode *)PPCCallOS(&MyCaos));
}

#define	FreeIFF(iff)	_FreeIFF(IFFPARSE_BASE_NAME, iff)

static __inline void
_FreeIFF(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeLocalItem(localItem)	_FreeLocalItem(IFFPARSE_BASE_NAME, localItem)

static __inline void
_FreeLocalItem(void *IFFParseBase, struct LocalContextItem *localItem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) localItem;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	GoodID(id)	_GoodID(IFFPARSE_BASE_NAME, id)

static __inline LONG
_GoodID(void *IFFParseBase, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GoodType(type)	_GoodType(IFFPARSE_BASE_NAME, type)

static __inline LONG
_GoodType(void *IFFParseBase, long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	IDtoStr(id, buf)	_IDtoStr(IFFPARSE_BASE_NAME, id, buf)

static __inline STRPTR
_IDtoStr(void *IFFParseBase, long id, STRPTR buf)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.a0		=(ULONG) buf;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	InitIFF(iff, flags, streamHook)	_InitIFF(IFFPARSE_BASE_NAME, iff, flags, streamHook)

static __inline void
_InitIFF(void *IFFParseBase, struct IFFHandle *iff, long flags, struct Hook *streamHook)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.a1		=(ULONG) streamHook;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	InitIFFasClip(iff)	_InitIFFasClip(IFFPARSE_BASE_NAME, iff)

static __inline void
_InitIFFasClip(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	InitIFFasDOS(iff)	_InitIFFasDOS(IFFPARSE_BASE_NAME, iff)

static __inline void
_InitIFFasDOS(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	LocalItemData(localItem)	_LocalItemData(IFFPARSE_BASE_NAME, localItem)

static __inline APTR
_LocalItemData(void *IFFParseBase, struct LocalContextItem *localItem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) localItem;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	OpenClipboard(unitNumber)	_OpenClipboard(IFFPARSE_BASE_NAME, unitNumber)

static __inline struct ClipboardHandle *
_OpenClipboard(void *IFFParseBase, long unitNumber)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) unitNumber;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct ClipboardHandle *)PPCCallOS(&MyCaos));
}

#define	OpenIFF(iff, rwMode)	_OpenIFF(IFFPARSE_BASE_NAME, iff, rwMode)

static __inline LONG
_OpenIFF(void *IFFParseBase, struct IFFHandle *iff, long rwMode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) rwMode;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ParentChunk(contextNode)	_ParentChunk(IFFPARSE_BASE_NAME, contextNode)

static __inline struct ContextNode *
_ParentChunk(void *IFFParseBase, struct ContextNode *contextNode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) contextNode;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((struct ContextNode *)PPCCallOS(&MyCaos));
}

#define	ParseIFF(iff, control)	_ParseIFF(IFFPARSE_BASE_NAME, iff, control)

static __inline LONG
_ParseIFF(void *IFFParseBase, struct IFFHandle *iff, long control)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) control;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PopChunk(iff)	_PopChunk(IFFPARSE_BASE_NAME, iff)

static __inline LONG
_PopChunk(void *IFFParseBase, struct IFFHandle *iff)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PropChunk(iff, type, id)	_PropChunk(IFFPARSE_BASE_NAME, iff, type, id)

static __inline LONG
_PropChunk(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PropChunks(iff, propArray, numPairs)	_PropChunks(IFFPARSE_BASE_NAME, iff, propArray, numPairs)

static __inline LONG
_PropChunks(void *IFFParseBase, struct IFFHandle *iff, LONG *propArray, long numPairs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) propArray;
	MyCaos.d0		=(ULONG) numPairs;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	PushChunk(iff, type, id, size)	_PushChunk(IFFPARSE_BASE_NAME, iff, type, id, size)

static __inline LONG
_PushChunk(void *IFFParseBase, struct IFFHandle *iff, long type, long id, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.d2		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadChunkBytes(iff, buf, numBytes)	_ReadChunkBytes(IFFPARSE_BASE_NAME, iff, buf, numBytes)

static __inline LONG
_ReadChunkBytes(void *IFFParseBase, struct IFFHandle *iff, APTR buf, long numBytes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) buf;
	MyCaos.d0		=(ULONG) numBytes;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ReadChunkRecords(iff, buf, bytesPerRecord, numRecords)	_ReadChunkRecords(IFFPARSE_BASE_NAME, iff, buf, bytesPerRecord, numRecords)

static __inline LONG
_ReadChunkRecords(void *IFFParseBase, struct IFFHandle *iff, APTR buf, long bytesPerRecord, long numRecords)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) buf;
	MyCaos.d0		=(ULONG) bytesPerRecord;
	MyCaos.d1		=(ULONG) numRecords;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetLocalItemPurge(localItem, purgeHook)	_SetLocalItemPurge(IFFPARSE_BASE_NAME, localItem, purgeHook)

static __inline void
_SetLocalItemPurge(void *IFFParseBase, struct LocalContextItem *localItem, struct Hook *purgeHook)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) localItem;
	MyCaos.a1		=(ULONG) purgeHook;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	StopChunk(iff, type, id)	_StopChunk(IFFPARSE_BASE_NAME, iff, type, id)

static __inline LONG
_StopChunk(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	StopChunks(iff, propArray, numPairs)	_StopChunks(IFFPARSE_BASE_NAME, iff, propArray, numPairs)

static __inline LONG
_StopChunks(void *IFFParseBase, struct IFFHandle *iff, LONG *propArray, long numPairs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) propArray;
	MyCaos.d0		=(ULONG) numPairs;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	StopOnExit(iff, type, id)	_StopOnExit(IFFPARSE_BASE_NAME, iff, type, id)

static __inline LONG
_StopOnExit(void *IFFParseBase, struct IFFHandle *iff, long type, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.d0		=(ULONG) type;
	MyCaos.d1		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	StoreItemInContext(iff, localItem, contextNode)	_StoreItemInContext(IFFPARSE_BASE_NAME, iff, localItem, contextNode)

static __inline void
_StoreItemInContext(void *IFFParseBase, struct IFFHandle *iff, struct LocalContextItem *localItem, struct ContextNode *contextNode)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) localItem;
	MyCaos.a2		=(ULONG) contextNode;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	PPCCallOS(&MyCaos);
}

#define	StoreLocalItem(iff, localItem, position)	_StoreLocalItem(IFFPARSE_BASE_NAME, iff, localItem, position)

static __inline LONG
_StoreLocalItem(void *IFFParseBase, struct IFFHandle *iff, struct LocalContextItem *localItem, long position)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) localItem;
	MyCaos.d0		=(ULONG) position;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WriteChunkBytes(iff, buf, numBytes)	_WriteChunkBytes(IFFPARSE_BASE_NAME, iff, buf, numBytes)

static __inline LONG
_WriteChunkBytes(void *IFFParseBase, struct IFFHandle *iff, APTR buf, long numBytes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) buf;
	MyCaos.d0		=(ULONG) numBytes;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	WriteChunkRecords(iff, buf, bytesPerRecord, numRecords)	_WriteChunkRecords(IFFPARSE_BASE_NAME, iff, buf, bytesPerRecord, numRecords)

static __inline LONG
_WriteChunkRecords(void *IFFParseBase, struct IFFHandle *iff, APTR buf, long bytesPerRecord, long numRecords)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iff;
	MyCaos.a1		=(ULONG) buf;
	MyCaos.d0		=(ULONG) bytesPerRecord;
	MyCaos.d1		=(ULONG) numRecords;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) IFFParseBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_IFFPARSE_H */
