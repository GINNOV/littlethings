/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_AMIGAGUIDE_H
#define _PPCPRAGMA_AMIGAGUIDE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__AMIGAGUIDE_H
#include <ppcinline/amigaguide.h>
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

#ifndef AMIGAGUIDE_BASE_NAME
#define AMIGAGUIDE_BASE_NAME AmigaGuideBase
#endif /* !AMIGAGUIDE_BASE_NAME */

#define	AddAmigaGuideHostA(h, name, attrs)	_AddAmigaGuideHostA(AMIGAGUIDE_BASE_NAME, h, name, attrs)

static __inline APTR
_AddAmigaGuideHostA(void *AmigaGuideBase, struct Hook *h, STRPTR name, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) h;
	MyCaos.d0		=(ULONG) name;
	MyCaos.a1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AddAmigaGuideHost(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; AddAmigaGuideHostA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AmigaGuideSignal(cl)	_AmigaGuideSignal(AMIGAGUIDE_BASE_NAME, cl)

static __inline ULONG
_AmigaGuideSignal(void *AmigaGuideBase, APTR cl)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	CloseAmigaGuide(cl)	_CloseAmigaGuide(AMIGAGUIDE_BASE_NAME, cl)

static __inline void
_CloseAmigaGuide(void *AmigaGuideBase, APTR cl)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	PPCCallOS(&MyCaos);
}

#define	ExpungeXRef()	_ExpungeXRef(AMIGAGUIDE_BASE_NAME)

static __inline void
_ExpungeXRef(void *AmigaGuideBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	PPCCallOS(&MyCaos);
}

#define	GetAmigaGuideAttr(tag, cl, storage)	_GetAmigaGuideAttr(AMIGAGUIDE_BASE_NAME, tag, cl, storage)

static __inline LONG
_GetAmigaGuideAttr(void *AmigaGuideBase, Tag tag, APTR cl, ULONG *storage)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) tag;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.a1		=(ULONG) storage;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GetAmigaGuideMsg(cl)	_GetAmigaGuideMsg(AMIGAGUIDE_BASE_NAME, cl)

static __inline struct AmigaGuideMsg *
_GetAmigaGuideMsg(void *AmigaGuideBase, APTR cl)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((struct AmigaGuideMsg *)PPCCallOS(&MyCaos));
}

#define	GetAmigaGuideString(id)	_GetAmigaGuideString(AMIGAGUIDE_BASE_NAME, id)

static __inline STRPTR
_GetAmigaGuideString(void *AmigaGuideBase, long id)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	LoadXRef(lock, name)	_LoadXRef(AMIGAGUIDE_BASE_NAME, lock, name)

static __inline LONG
_LoadXRef(void *AmigaGuideBase, BPTR lock, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) lock;
	MyCaos.a1		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	LockAmigaGuideBase(handle)	_LockAmigaGuideBase(AMIGAGUIDE_BASE_NAME, handle)

static __inline LONG
_LockAmigaGuideBase(void *AmigaGuideBase, APTR handle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) handle;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	OpenAmigaGuideA(nag, attrs)	_OpenAmigaGuideA(AMIGAGUIDE_BASE_NAME, nag, attrs)

static __inline APTR
_OpenAmigaGuideA(void *AmigaGuideBase, struct NewAmigaGuide *nag, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nag;
	MyCaos.a1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define OpenAmigaGuide(a0, tags...) \
	({ULONG _tags[] = { tags }; OpenAmigaGuideA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	OpenAmigaGuideAsyncA(nag, attrs)	_OpenAmigaGuideAsyncA(AMIGAGUIDE_BASE_NAME, nag, attrs)

static __inline APTR
_OpenAmigaGuideAsyncA(void *AmigaGuideBase, struct NewAmigaGuide *nag, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nag;
	MyCaos.d0		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define OpenAmigaGuideAsync(a0, tags...) \
	({ULONG _tags[] = { tags }; OpenAmigaGuideAsyncA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	RemoveAmigaGuideHostA(hh, attrs)	_RemoveAmigaGuideHostA(AMIGAGUIDE_BASE_NAME, hh, attrs)

static __inline LONG
_RemoveAmigaGuideHostA(void *AmigaGuideBase, APTR hh, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) hh;
	MyCaos.a1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define RemoveAmigaGuideHost(a0, tags...) \
	({ULONG _tags[] = { tags }; RemoveAmigaGuideHostA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	ReplyAmigaGuideMsg(amsg)	_ReplyAmigaGuideMsg(AMIGAGUIDE_BASE_NAME, amsg)

static __inline void
_ReplyAmigaGuideMsg(void *AmigaGuideBase, struct AmigaGuideMsg *amsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) amsg;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	PPCCallOS(&MyCaos);
}

#define	SendAmigaGuideCmdA(cl, cmd, attrs)	_SendAmigaGuideCmdA(AMIGAGUIDE_BASE_NAME, cl, cmd, attrs)

static __inline LONG
_SendAmigaGuideCmdA(void *AmigaGuideBase, APTR cl, STRPTR cmd, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.d0		=(ULONG) cmd;
	MyCaos.d1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SendAmigaGuideCmd(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; SendAmigaGuideCmdA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SendAmigaGuideContextA(cl, attrs)	_SendAmigaGuideContextA(AMIGAGUIDE_BASE_NAME, cl, attrs)

static __inline LONG
_SendAmigaGuideContextA(void *AmigaGuideBase, APTR cl, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.d0		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SendAmigaGuideContext(a0, tags...) \
	({ULONG _tags[] = { tags }; SendAmigaGuideContextA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetAmigaGuideAttrsA(cl, attrs)	_SetAmigaGuideAttrsA(AMIGAGUIDE_BASE_NAME, cl, attrs)

static __inline LONG
_SetAmigaGuideAttrsA(void *AmigaGuideBase, APTR cl, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.a1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetAmigaGuideAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; SetAmigaGuideAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetAmigaGuideContextA(cl, id, attrs)	_SetAmigaGuideContextA(AMIGAGUIDE_BASE_NAME, cl, id, attrs)

static __inline LONG
_SetAmigaGuideContextA(void *AmigaGuideBase, APTR cl, unsigned long id, struct TagItem *attrs)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) cl;
	MyCaos.d0		=(ULONG) id;
	MyCaos.d1		=(ULONG) attrs;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetAmigaGuideContext(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; SetAmigaGuideContextA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	UnlockAmigaGuideBase(key)	_UnlockAmigaGuideBase(AMIGAGUIDE_BASE_NAME, key)

static __inline void
_UnlockAmigaGuideBase(void *AmigaGuideBase, long key)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) key;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) AmigaGuideBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_AMIGAGUIDE_H */
