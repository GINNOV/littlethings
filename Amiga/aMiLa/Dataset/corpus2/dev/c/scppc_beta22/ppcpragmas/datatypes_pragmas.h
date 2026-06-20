/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_DATATYPES_H
#define _PPCPRAGMA_DATATYPES_H
#ifdef __GNUC__
#ifndef _PPCINLINE__DATATYPES_H
#include <ppcinline/datatypes.h>
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

#ifndef DATATYPES_BASE_NAME
#define DATATYPES_BASE_NAME DataTypesBase
#endif /* !DATATYPES_BASE_NAME */

#define	AddDTObject(win, req, o, pos)	_AddDTObject(DATATYPES_BASE_NAME, win, req, o, pos)

static __inline LONG
_AddDTObject(void *DataTypesBase, struct Window *win, struct Requester *req, Object *o, long pos)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.a1		=(ULONG) req;
	MyCaos.a2		=(ULONG) o;
	MyCaos.d0		=(ULONG) pos;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DisposeDTObject(o)	_DisposeDTObject(DATATYPES_BASE_NAME, o)

static __inline void
_DisposeDTObject(void *DataTypesBase, Object *o)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	PPCCallOS(&MyCaos);
}

#define	DoAsyncLayout(o, gpl)	_DoAsyncLayout(DATATYPES_BASE_NAME, o, gpl)

static __inline ULONG
_DoAsyncLayout(void *DataTypesBase, Object *o, struct gpLayout *gpl)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a1		=(ULONG) gpl;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	DoDTMethodA(o, win, req, msg)	_DoDTMethodA(DATATYPES_BASE_NAME, o, win, req, msg)

static __inline ULONG
_DoDTMethodA(void *DataTypesBase, Object *o, struct Window *win, struct Requester *req, Msg msg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a1		=(ULONG) win;
	MyCaos.a2		=(ULONG) req;
	MyCaos.a3		=(ULONG) msg;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define DoDTMethod(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; DoDTMethodA((a0), (a1), (a2), (Msg)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GetDTAttrsA(o, attrs)	_GetDTAttrsA(DATATYPES_BASE_NAME, o, attrs)

static __inline ULONG
_GetDTAttrsA(void *DataTypesBase, Object *o, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a2		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define GetDTAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; GetDTAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GetDTMethods(object)	_GetDTMethods(DATATYPES_BASE_NAME, object)

static __inline ULONG *
_GetDTMethods(void *DataTypesBase, Object *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG *)PPCCallOS(&MyCaos));
}

#define	GetDTString(id)	_GetDTString(DATATYPES_BASE_NAME, id)

static __inline STRPTR
_GetDTString(void *DataTypesBase, unsigned long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	GetDTTriggerMethods(object)	_GetDTTriggerMethods(DATATYPES_BASE_NAME, object)

static __inline struct DTMethods *
_GetDTTriggerMethods(void *DataTypesBase, Object *object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((struct DTMethods *)PPCCallOS(&MyCaos));
}

#define	NewDTObjectA(name, attrs)	_NewDTObjectA(DATATYPES_BASE_NAME, name, attrs)

static __inline Object *
_NewDTObjectA(void *DataTypesBase, APTR name, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) name;
	MyCaos.a0		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((Object *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define NewDTObject(a0, tags...) \
	({ULONG _tags[] = { tags }; NewDTObjectA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ObtainDataTypeA(type, handle, attrs)	_ObtainDataTypeA(DATATYPES_BASE_NAME, type, handle, attrs)

static __inline struct DataType *
_ObtainDataTypeA(void *DataTypesBase, unsigned long type, APTR handle, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) type;
	MyCaos.a0		=(ULONG) handle;
	MyCaos.a1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((struct DataType *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define ObtainDataType(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; ObtainDataTypeA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	PrintDTObjectA(o, w, r, msg)	_PrintDTObjectA(DATATYPES_BASE_NAME, o, w, r, msg)

static __inline ULONG
_PrintDTObjectA(void *DataTypesBase, Object *o, struct Window *w, struct Requester *r, struct dtPrint *msg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a1		=(ULONG) w;
	MyCaos.a2		=(ULONG) r;
	MyCaos.a3		=(ULONG) msg;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define PrintDTObject(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; PrintDTObjectA((a0), (a1), (a2), (struct dtPrint *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	RefreshDTObjectA(o, win, req, attrs)	_RefreshDTObjectA(DATATYPES_BASE_NAME, o, win, req, attrs)

static __inline void
_RefreshDTObjectA(void *DataTypesBase, Object *o, struct Window *win, struct Requester *req, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a1		=(ULONG) win;
	MyCaos.a2		=(ULONG) req;
	MyCaos.a3		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define RefreshDTObject(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; RefreshDTObjectA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ReleaseDataType(dt)	_ReleaseDataType(DATATYPES_BASE_NAME, dt)

static __inline void
_ReleaseDataType(void *DataTypesBase, struct DataType *dt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) dt;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	PPCCallOS(&MyCaos);
}

#define	RemoveDTObject(win, o)	_RemoveDTObject(DATATYPES_BASE_NAME, win, o)

static __inline LONG
_RemoveDTObject(void *DataTypesBase, struct Window *win, Object *o)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.a1		=(ULONG) o;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetDTAttrsA(o, win, req, attrs)	_SetDTAttrsA(DATATYPES_BASE_NAME, o, win, req, attrs)

static __inline ULONG
_SetDTAttrsA(void *DataTypesBase, Object *o, struct Window *win, struct Requester *req, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) o;
	MyCaos.a1		=(ULONG) win;
	MyCaos.a2		=(ULONG) req;
	MyCaos.a3		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) DataTypesBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetDTAttrs(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; SetDTAttrsA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_DATATYPES_H */
