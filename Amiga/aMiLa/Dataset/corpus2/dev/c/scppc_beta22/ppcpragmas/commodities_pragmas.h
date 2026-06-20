/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_COMMODITIES_H
#define _PPCPRAGMA_COMMODITIES_H
#ifdef __GNUC__
#ifndef _PPCINLINE__COMMODITIES_H
#include <ppcinline/commodities.h>
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

#ifndef COMMODITIES_BASE_NAME
#define COMMODITIES_BASE_NAME CxBase
#endif /* !COMMODITIES_BASE_NAME */

#define	ActivateCxObj(co, tf)	_ActivateCxObj(COMMODITIES_BASE_NAME, co, tf)

static __inline LONG
_ActivateCxObj(void *CxBase, CxObj *co, long tf)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.d0		=(ULONG) tf;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) CxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	AddIEvents(events)	_AddIEvents(COMMODITIES_BASE_NAME, events)

static __inline void
_AddIEvents(void *CxBase, struct InputEvent *events)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) events;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	AttachCxObj(headObj, co)	_AttachCxObj(COMMODITIES_BASE_NAME, headObj, co)

static __inline void
_AttachCxObj(void *CxBase, CxObj *headObj, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) headObj;
	MyCaos.a1		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearCxObjError(co)	_ClearCxObjError(COMMODITIES_BASE_NAME, co)

static __inline void
_ClearCxObjError(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	CreateCxObj(type, arg1, arg2)	_CreateCxObj(COMMODITIES_BASE_NAME, type, arg1, arg2)

static __inline CxObj *
_CreateCxObj(void *CxBase, unsigned long type, long arg1, long arg2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) type;
	MyCaos.a0		=(ULONG) arg1;
	MyCaos.a1		=(ULONG) arg2;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) CxBase;	
	return((CxObj *)PPCCallOS(&MyCaos));
}

#define	CxBroker(nb, error)	_CxBroker(COMMODITIES_BASE_NAME, nb, error)

static __inline CxObj *
_CxBroker(void *CxBase, struct NewBroker *nb, LONG *error)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nb;
	MyCaos.d0		=(ULONG) error;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) CxBase;	
	return((CxObj *)PPCCallOS(&MyCaos));
}

#define	CxMsgData(cxm)	_CxMsgData(COMMODITIES_BASE_NAME, cxm)

static __inline APTR
_CxMsgData(void *CxBase, CxMsg *cxm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) CxBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	CxMsgID(cxm)	_CxMsgID(COMMODITIES_BASE_NAME, cxm)

static __inline LONG
_CxMsgID(void *CxBase, CxMsg *cxm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) CxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CxMsgType(cxm)	_CxMsgType(COMMODITIES_BASE_NAME, cxm)

static __inline ULONG
_CxMsgType(void *CxBase, CxMsg *cxm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) CxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CxObjError(co)	_CxObjError(COMMODITIES_BASE_NAME, co)

static __inline LONG
_CxObjError(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) CxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CxObjType(co)	_CxObjType(COMMODITIES_BASE_NAME, co)

static __inline ULONG
_CxObjType(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) CxBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	DeleteCxObj(co)	_DeleteCxObj(COMMODITIES_BASE_NAME, co)

static __inline void
_DeleteCxObj(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	DeleteCxObjAll(co)	_DeleteCxObjAll(COMMODITIES_BASE_NAME, co)

static __inline void
_DeleteCxObjAll(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	DisposeCxMsg(cxm)	_DisposeCxMsg(COMMODITIES_BASE_NAME, cxm)

static __inline void
_DisposeCxMsg(void *CxBase, CxMsg *cxm)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	DivertCxMsg(cxm, headObj, returnObj)	_DivertCxMsg(COMMODITIES_BASE_NAME, cxm, headObj, returnObj)

static __inline void
_DivertCxMsg(void *CxBase, CxMsg *cxm, CxObj *headObj, CxObj *returnObj)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.a1		=(ULONG) headObj;
	MyCaos.a2		=(ULONG) returnObj;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	EnqueueCxObj(headObj, co)	_EnqueueCxObj(COMMODITIES_BASE_NAME, headObj, co)

static __inline void
_EnqueueCxObj(void *CxBase, CxObj *headObj, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) headObj;
	MyCaos.a1		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	InsertCxObj(headObj, co, pred)	_InsertCxObj(COMMODITIES_BASE_NAME, headObj, co, pred)

static __inline void
_InsertCxObj(void *CxBase, CxObj *headObj, CxObj *co, CxObj *pred)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) headObj;
	MyCaos.a1		=(ULONG) co;
	MyCaos.a2		=(ULONG) pred;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	InvertKeyMap(ansiCode, event, km)	_InvertKeyMap(COMMODITIES_BASE_NAME, ansiCode, event, km)

static __inline BOOL
_InvertKeyMap(void *CxBase, unsigned long ansiCode, struct InputEvent *event, struct KeyMap *km)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) ansiCode;
	MyCaos.a0		=(ULONG) event;
	MyCaos.a1		=(ULONG) km;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) CxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	MatchIX(event, ix)	_MatchIX(COMMODITIES_BASE_NAME, event, ix)

static __inline BOOL
_MatchIX(void *CxBase, struct InputEvent *event, IX *ix)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) event;
	MyCaos.a1		=(ULONG) ix;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) CxBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ParseIX(description, ix)	_ParseIX(COMMODITIES_BASE_NAME, description, ix)

static __inline LONG
_ParseIX(void *CxBase, STRPTR description, IX *ix)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) description;
	MyCaos.a1		=(ULONG) ix;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) CxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RemoveCxObj(co)	_RemoveCxObj(COMMODITIES_BASE_NAME, co)

static __inline void
_RemoveCxObj(void *CxBase, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	RouteCxMsg(cxm, co)	_RouteCxMsg(COMMODITIES_BASE_NAME, cxm, co)

static __inline void
_RouteCxMsg(void *CxBase, CxMsg *cxm, CxObj *co)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cxm;
	MyCaos.a1		=(ULONG) co;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetCxObjPri(co, pri)	_SetCxObjPri(COMMODITIES_BASE_NAME, co, pri)

static __inline LONG
_SetCxObjPri(void *CxBase, CxObj *co, long pri)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) co;
	MyCaos.d0		=(ULONG) pri;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) CxBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetFilter(filter, text)	_SetFilter(COMMODITIES_BASE_NAME, filter, text)

static __inline void
_SetFilter(void *CxBase, CxObj *filter, STRPTR text)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) filter;
	MyCaos.a1		=(ULONG) text;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetFilterIX(filter, ix)	_SetFilterIX(COMMODITIES_BASE_NAME, filter, ix)

static __inline void
_SetFilterIX(void *CxBase, CxObj *filter, IX *ix)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) filter;
	MyCaos.a1		=(ULONG) ix;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#define	SetTranslate(translator, events)	_SetTranslate(COMMODITIES_BASE_NAME, translator, events)

static __inline void
_SetTranslate(void *CxBase, CxObj *translator, struct InputEvent *events)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) translator;
	MyCaos.a1		=(ULONG) events;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) CxBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_COMMODITIES_H */
