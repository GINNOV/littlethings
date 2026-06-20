/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_INTUITION_H
#define _PPCPRAGMA_INTUITION_H
#ifdef __GNUC__
#ifndef _PPCINLINE__INTUITION_H
#include <ppcinline/intuition.h>
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

#ifndef INTUITION_BASE_NAME
#define INTUITION_BASE_NAME IntuitionBase
#endif /* !INTUITION_BASE_NAME */

#define	ActivateGadget(gadgets, window, requester)	_ActivateGadget(INTUITION_BASE_NAME, gadgets, window, requester)

static __inline BOOL
_ActivateGadget(void *IntuitionBase, struct Gadget *gadgets, struct Window *window, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadgets;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-462);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ActivateWindow(window)	_ActivateWindow(INTUITION_BASE_NAME, window)

static __inline void
_ActivateWindow(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-450);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	AddClass(classPtr)	_AddClass(INTUITION_BASE_NAME, classPtr)

static __inline void
_AddClass(void *IntuitionBase, struct IClass *classPtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) classPtr;
	MyCaos.caos_Un.Offset	=	(-684);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	AddGList(window, gadget, position, numGad, requester)	_AddGList(INTUITION_BASE_NAME, window, gadget, position, numGad, requester)

static __inline UWORD
_AddGList(void *IntuitionBase, struct Window *window, struct Gadget *gadget, unsigned long position, long numGad, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) gadget;
	MyCaos.d0		=(ULONG) position;
	MyCaos.d1		=(ULONG) numGad;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-438);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	AddGadget(window, gadget, position)	_AddGadget(INTUITION_BASE_NAME, window, gadget, position)

static __inline UWORD
_AddGadget(void *IntuitionBase, struct Window *window, struct Gadget *gadget, unsigned long position)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) gadget;
	MyCaos.d0		=(ULONG) position;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	AllocRemember(rememberKey, size, flags)	_AllocRemember(INTUITION_BASE_NAME, rememberKey, size, flags)

static __inline APTR
_AllocRemember(void *IntuitionBase, struct Remember **rememberKey, unsigned long size, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rememberKey;
	MyCaos.d0		=(ULONG) size;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-396);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	AllocScreenBuffer(sc, bm, flags)	_AllocScreenBuffer(INTUITION_BASE_NAME, sc, bm, flags)

static __inline struct ScreenBuffer *
_AllocScreenBuffer(void *IntuitionBase, struct Screen *sc, struct BitMap *bm, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sc;
	MyCaos.a1		=(ULONG) bm;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-768);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct ScreenBuffer *)PPCCallOS(&MyCaos));
}

#define	AlohaWorkbench(wbport)	_AlohaWorkbench(INTUITION_BASE_NAME, wbport)

static __inline void
_AlohaWorkbench(void *IntuitionBase, long wbport)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) wbport;
	MyCaos.caos_Un.Offset	=	(-402);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	AutoRequest(window, body, posText, negText, pFlag, nFlag, width, height)	_AutoRequest(INTUITION_BASE_NAME, window, body, posText, negText, pFlag, nFlag, width, height)

static __inline BOOL
_AutoRequest(void *IntuitionBase, struct Window *window, struct IntuiText *body, struct IntuiText *posText, struct IntuiText *negText, unsigned long pFlag, unsigned long nFlag, unsigned long width, unsigned long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) body;
	MyCaos.a2		=(ULONG) posText;
	MyCaos.a3		=(ULONG) negText;
	MyCaos.d0		=(ULONG) pFlag;
	MyCaos.d1		=(ULONG) nFlag;
	MyCaos.d2		=(ULONG) width;
	MyCaos.d3		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-348);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	BeginRefresh(window)	_BeginRefresh(INTUITION_BASE_NAME, window)

static __inline void
_BeginRefresh(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-354);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	BuildEasyRequestArgs(window, easyStruct, idcmp, args)	_BuildEasyRequestArgs(INTUITION_BASE_NAME, window, easyStruct, idcmp, args)

static __inline struct Window *
_BuildEasyRequestArgs(void *IntuitionBase, struct Window *window, struct EasyStruct *easyStruct, unsigned long idcmp, APTR args)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) easyStruct;
	MyCaos.d0		=(ULONG) idcmp;
	MyCaos.a3		=(ULONG) args;
	MyCaos.caos_Un.Offset	=	(-594);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Window *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define BuildEasyRequest(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; BuildEasyRequestArgs((a0), (a1), (a2), (APTR)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	BuildSysRequest(window, body, posText, negText, flags, width, height)	_BuildSysRequest(INTUITION_BASE_NAME, window, body, posText, negText, flags, width, height)

static __inline struct Window *
_BuildSysRequest(void *IntuitionBase, struct Window *window, struct IntuiText *body, struct IntuiText *posText, struct IntuiText *negText, unsigned long flags, unsigned long width, unsigned long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) body;
	MyCaos.a2		=(ULONG) posText;
	MyCaos.a3		=(ULONG) negText;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.d1		=(ULONG) width;
	MyCaos.d2		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-360);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Window *)PPCCallOS(&MyCaos));
}

#define	ChangeScreenBuffer(sc, sb)	_ChangeScreenBuffer(INTUITION_BASE_NAME, sc, sb)

static __inline ULONG
_ChangeScreenBuffer(void *IntuitionBase, struct Screen *sc, struct ScreenBuffer *sb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sc;
	MyCaos.a1		=(ULONG) sb;
	MyCaos.caos_Un.Offset	=	(-780);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ChangeWindowBox(window, left, top, width, height)	_ChangeWindowBox(INTUITION_BASE_NAME, window, left, top, width, height)

static __inline void
_ChangeWindowBox(void *IntuitionBase, struct Window *window, long left, long top, long width, long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) left;
	MyCaos.d1		=(ULONG) top;
	MyCaos.d2		=(ULONG) width;
	MyCaos.d3		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-486);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearDMRequest(window)	_ClearDMRequest(INTUITION_BASE_NAME, window)

static __inline BOOL
_ClearDMRequest(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ClearMenuStrip(window)	_ClearMenuStrip(INTUITION_BASE_NAME, window)

static __inline void
_ClearMenuStrip(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ClearPointer(window)	_ClearPointer(INTUITION_BASE_NAME, window)

static __inline void
_ClearPointer(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseScreen(screen)	_CloseScreen(INTUITION_BASE_NAME, screen)

static __inline BOOL
_CloseScreen(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	CloseWindow(window)	_CloseWindow(INTUITION_BASE_NAME, window)

static __inline void
_CloseWindow(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseWorkBench()	_CloseWorkBench(INTUITION_BASE_NAME)

static __inline LONG
_CloseWorkBench(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	CurrentTime(seconds, micros)	_CurrentTime(INTUITION_BASE_NAME, seconds, micros)

static __inline void
_CurrentTime(void *IntuitionBase, ULONG *seconds, ULONG *micros)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) seconds;
	MyCaos.a1		=(ULONG) micros;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	DisplayAlert(alertNumber, string, height)	_DisplayAlert(INTUITION_BASE_NAME, alertNumber, string, height)

static __inline BOOL
_DisplayAlert(void *IntuitionBase, unsigned long alertNumber, UBYTE *string, unsigned long height)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) alertNumber;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d1		=(ULONG) height;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	DisplayBeep(screen)	_DisplayBeep(INTUITION_BASE_NAME, screen)

static __inline void
_DisplayBeep(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	DisposeObject(object)	_DisposeObject(INTUITION_BASE_NAME, object)

static __inline void
_DisposeObject(void *IntuitionBase, APTR object)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.caos_Un.Offset	=	(-642);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	DoGadgetMethodA(gad, win, req, message)	_DoGadgetMethodA(INTUITION_BASE_NAME, gad, win, req, message)

static __inline ULONG
_DoGadgetMethodA(void *IntuitionBase, struct Gadget *gad, struct Window *win, struct Requester *req, Msg message)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gad;
	MyCaos.a1		=(ULONG) win;
	MyCaos.a2		=(ULONG) req;
	MyCaos.a3		=(ULONG) message;
	MyCaos.caos_Un.Offset	=	(-810);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define DoGadgetMethod(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; DoGadgetMethodA((a0), (a1), (a2), (Msg)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	DoubleClick(sSeconds, sMicros, cSeconds, cMicros)	_DoubleClick(INTUITION_BASE_NAME, sSeconds, sMicros, cSeconds, cMicros)

static __inline BOOL
_DoubleClick(void *IntuitionBase, unsigned long sSeconds, unsigned long sMicros, unsigned long cSeconds, unsigned long cMicros)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) sSeconds;
	MyCaos.d1		=(ULONG) sMicros;
	MyCaos.d2		=(ULONG) cSeconds;
	MyCaos.d3		=(ULONG) cMicros;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	DrawBorder(rp, border, leftOffset, topOffset)	_DrawBorder(INTUITION_BASE_NAME, rp, border, leftOffset, topOffset)

static __inline void
_DrawBorder(void *IntuitionBase, struct RastPort *rp, struct Border *border, long leftOffset, long topOffset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) border;
	MyCaos.d0		=(ULONG) leftOffset;
	MyCaos.d1		=(ULONG) topOffset;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	DrawImage(rp, image, leftOffset, topOffset)	_DrawImage(INTUITION_BASE_NAME, rp, image, leftOffset, topOffset)

static __inline void
_DrawImage(void *IntuitionBase, struct RastPort *rp, struct Image *image, long leftOffset, long topOffset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) image;
	MyCaos.d0		=(ULONG) leftOffset;
	MyCaos.d1		=(ULONG) topOffset;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	DrawImageState(rp, image, leftOffset, topOffset, state, drawInfo)	_DrawImageState(INTUITION_BASE_NAME, rp, image, leftOffset, topOffset, state, drawInfo)

static __inline void
_DrawImageState(void *IntuitionBase, struct RastPort *rp, struct Image *image, long leftOffset, long topOffset, unsigned long state, struct DrawInfo *drawInfo)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) image;
	MyCaos.d0		=(ULONG) leftOffset;
	MyCaos.d1		=(ULONG) topOffset;
	MyCaos.d2		=(ULONG) state;
	MyCaos.a2		=(ULONG) drawInfo;
	MyCaos.caos_Un.Offset	=	(-618);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	EasyRequestArgs(window, easyStruct, idcmpPtr, args)	_EasyRequestArgs(INTUITION_BASE_NAME, window, easyStruct, idcmpPtr, args)

static __inline LONG
_EasyRequestArgs(void *IntuitionBase, struct Window *window, struct EasyStruct *easyStruct, ULONG *idcmpPtr, APTR args)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) easyStruct;
	MyCaos.a2		=(ULONG) idcmpPtr;
	MyCaos.a3		=(ULONG) args;
	MyCaos.caos_Un.Offset	=	(-588);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define EasyRequest(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; EasyRequestArgs((a0), (a1), (a2), (APTR)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	EndRefresh(window, complete)	_EndRefresh(INTUITION_BASE_NAME, window, complete)

static __inline void
_EndRefresh(void *IntuitionBase, struct Window *window, long complete)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) complete;
	MyCaos.caos_Un.Offset	=	(-366);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	EndRequest(requester, window)	_EndRequest(INTUITION_BASE_NAME, requester, window)

static __inline void
_EndRequest(void *IntuitionBase, struct Requester *requester, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) requester;
	MyCaos.a1		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	EraseImage(rp, image, leftOffset, topOffset)	_EraseImage(INTUITION_BASE_NAME, rp, image, leftOffset, topOffset)

static __inline void
_EraseImage(void *IntuitionBase, struct RastPort *rp, struct Image *image, long leftOffset, long topOffset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) image;
	MyCaos.d0		=(ULONG) leftOffset;
	MyCaos.d1		=(ULONG) topOffset;
	MyCaos.caos_Un.Offset	=	(-630);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeClass(classPtr)	_FreeClass(INTUITION_BASE_NAME, classPtr)

static __inline BOOL
_FreeClass(void *IntuitionBase, struct IClass *classPtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) classPtr;
	MyCaos.caos_Un.Offset	=	(-714);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	FreeRemember(rememberKey, reallyForget)	_FreeRemember(INTUITION_BASE_NAME, rememberKey, reallyForget)

static __inline void
_FreeRemember(void *IntuitionBase, struct Remember **rememberKey, long reallyForget)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rememberKey;
	MyCaos.d0		=(ULONG) reallyForget;
	MyCaos.caos_Un.Offset	=	(-408);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeScreenBuffer(sc, sb)	_FreeScreenBuffer(INTUITION_BASE_NAME, sc, sb)

static __inline void
_FreeScreenBuffer(void *IntuitionBase, struct Screen *sc, struct ScreenBuffer *sb)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sc;
	MyCaos.a1		=(ULONG) sb;
	MyCaos.caos_Un.Offset	=	(-774);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeScreenDrawInfo(screen, drawInfo)	_FreeScreenDrawInfo(INTUITION_BASE_NAME, screen, drawInfo)

static __inline void
_FreeScreenDrawInfo(void *IntuitionBase, struct Screen *screen, struct DrawInfo *drawInfo)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.a1		=(ULONG) drawInfo;
	MyCaos.caos_Un.Offset	=	(-696);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeSysRequest(window)	_FreeSysRequest(INTUITION_BASE_NAME, window)

static __inline void
_FreeSysRequest(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-372);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	GadgetMouse(gadget, gInfo, mousePoint)	_GadgetMouse(INTUITION_BASE_NAME, gadget, gInfo, mousePoint)

static __inline void
_GadgetMouse(void *IntuitionBase, struct Gadget *gadget, struct GadgetInfo *gInfo, WORD *mousePoint)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) gInfo;
	MyCaos.a2		=(ULONG) mousePoint;
	MyCaos.caos_Un.Offset	=	(-570);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	GetAttr(attrID, object, storagePtr)	_GetAttr(INTUITION_BASE_NAME, attrID, object, storagePtr)

static __inline ULONG
_GetAttr(void *IntuitionBase, unsigned long attrID, APTR object, ULONG *storagePtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) attrID;
	MyCaos.a0		=(ULONG) object;
	MyCaos.a1		=(ULONG) storagePtr;
	MyCaos.caos_Un.Offset	=	(-654);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	GetDefPrefs(preferences, size)	_GetDefPrefs(INTUITION_BASE_NAME, preferences, size)

static __inline struct Preferences *
_GetDefPrefs(void *IntuitionBase, struct Preferences *preferences, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) preferences;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Preferences *)PPCCallOS(&MyCaos));
}

#define	GetDefaultPubScreen(nameBuffer)	_GetDefaultPubScreen(INTUITION_BASE_NAME, nameBuffer)

static __inline void
_GetDefaultPubScreen(void *IntuitionBase, UBYTE *nameBuffer)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) nameBuffer;
	MyCaos.caos_Un.Offset	=	(-582);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	GetPrefs(preferences, size)	_GetPrefs(INTUITION_BASE_NAME, preferences, size)

static __inline struct Preferences *
_GetPrefs(void *IntuitionBase, struct Preferences *preferences, long size)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) preferences;
	MyCaos.d0		=(ULONG) size;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Preferences *)PPCCallOS(&MyCaos));
}

#define	GetScreenData(buffer, size, type, screen)	_GetScreenData(INTUITION_BASE_NAME, buffer, size, type, screen)

static __inline LONG
_GetScreenData(void *IntuitionBase, APTR buffer, unsigned long size, unsigned long type, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) size;
	MyCaos.d1		=(ULONG) type;
	MyCaos.a1		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-426);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	GetScreenDrawInfo(screen)	_GetScreenDrawInfo(INTUITION_BASE_NAME, screen)

static __inline struct DrawInfo *
_GetScreenDrawInfo(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-690);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct DrawInfo *)PPCCallOS(&MyCaos));
}

#define	HelpControl(win, flags)	_HelpControl(INTUITION_BASE_NAME, win, flags)

static __inline void
_HelpControl(void *IntuitionBase, struct Window *win, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-828);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	InitRequester(requester)	_InitRequester(INTUITION_BASE_NAME, requester)

static __inline void
_InitRequester(void *IntuitionBase, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	IntuiTextLength(iText)	_IntuiTextLength(INTUITION_BASE_NAME, iText)

static __inline LONG
_IntuiTextLength(void *IntuitionBase, struct IntuiText *iText)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iText;
	MyCaos.caos_Un.Offset	=	(-330);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	Intuition(iEvent)	_Intuition(INTUITION_BASE_NAME, iEvent)

static __inline void
_Intuition(void *IntuitionBase, struct InputEvent *iEvent)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iEvent;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ItemAddress(menuStrip, menuNumber)	_ItemAddress(INTUITION_BASE_NAME, menuStrip, menuNumber)

static __inline struct MenuItem *
_ItemAddress(void *IntuitionBase, struct Menu *menuStrip, unsigned long menuNumber)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) menuStrip;
	MyCaos.d0		=(ULONG) menuNumber;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct MenuItem *)PPCCallOS(&MyCaos));
}

#define	LendMenus(fromwindow, towindow)	_LendMenus(INTUITION_BASE_NAME, fromwindow, towindow)

static __inline void
_LendMenus(void *IntuitionBase, struct Window *fromwindow, struct Window *towindow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fromwindow;
	MyCaos.a1		=(ULONG) towindow;
	MyCaos.caos_Un.Offset	=	(-804);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	LockIBase(dontknow)	_LockIBase(INTUITION_BASE_NAME, dontknow)

static __inline ULONG
_LockIBase(void *IntuitionBase, unsigned long dontknow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) dontknow;
	MyCaos.caos_Un.Offset	=	(-414);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	LockPubScreen(name)	_LockPubScreen(INTUITION_BASE_NAME, name)

static __inline struct Screen *
_LockPubScreen(void *IntuitionBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-510);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Screen *)PPCCallOS(&MyCaos));
}

#define	LockPubScreenList()	_LockPubScreenList(INTUITION_BASE_NAME)

static __inline struct List *
_LockPubScreenList(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-522);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct List *)PPCCallOS(&MyCaos));
}

#define	MakeClass(classID, superClassID, superClassPtr, instanceSize, flags)	_MakeClass(INTUITION_BASE_NAME, classID, superClassID, superClassPtr, instanceSize, flags)

static __inline struct IClass *
_MakeClass(void *IntuitionBase, UBYTE *classID, UBYTE *superClassID, struct IClass *superClassPtr, unsigned long instanceSize, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) classID;
	MyCaos.a1		=(ULONG) superClassID;
	MyCaos.a2		=(ULONG) superClassPtr;
	MyCaos.d0		=(ULONG) instanceSize;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-678);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct IClass *)PPCCallOS(&MyCaos));
}

#define	MakeScreen(screen)	_MakeScreen(INTUITION_BASE_NAME, screen)

static __inline LONG
_MakeScreen(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-378);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ModifyIDCMP(window, flags)	_ModifyIDCMP(INTUITION_BASE_NAME, window, flags)

static __inline BOOL
_ModifyIDCMP(void *IntuitionBase, struct Window *window, unsigned long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody)	_ModifyProp(INTUITION_BASE_NAME, gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody)

static __inline void
_ModifyProp(void *IntuitionBase, struct Gadget *gadget, struct Window *window, struct Requester *requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.d1		=(ULONG) horizPot;
	MyCaos.d2		=(ULONG) vertPot;
	MyCaos.d3		=(ULONG) horizBody;
	MyCaos.d4		=(ULONG) vertBody;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	MoveScreen(screen, dx, dy)	_MoveScreen(INTUITION_BASE_NAME, screen, dx, dy)

static __inline void
_MoveScreen(void *IntuitionBase, struct Screen *screen, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	MoveWindow(window, dx, dy)	_MoveWindow(INTUITION_BASE_NAME, window, dx, dy)

static __inline void
_MoveWindow(void *IntuitionBase, struct Window *window, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-168);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	MoveWindowInFrontOf(window, behindWindow)	_MoveWindowInFrontOf(INTUITION_BASE_NAME, window, behindWindow)

static __inline void
_MoveWindowInFrontOf(void *IntuitionBase, struct Window *window, struct Window *behindWindow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) behindWindow;
	MyCaos.caos_Un.Offset	=	(-480);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	NewModifyProp(gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad)	_NewModifyProp(INTUITION_BASE_NAME, gadget, window, requester, flags, horizPot, vertPot, horizBody, vertBody, numGad)

static __inline void
_NewModifyProp(void *IntuitionBase, struct Gadget *gadget, struct Window *window, struct Requester *requester, unsigned long flags, unsigned long horizPot, unsigned long vertPot, unsigned long horizBody, unsigned long vertBody, long numGad)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.d1		=(ULONG) horizPot;
	MyCaos.d2		=(ULONG) vertPot;
	MyCaos.d3		=(ULONG) horizBody;
	MyCaos.d4		=(ULONG) vertBody;
	MyCaos.d5		=(ULONG) numGad;
	MyCaos.caos_Un.Offset	=	(-468);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	NewObjectA(classPtr, classID, tagList)	_NewObjectA(INTUITION_BASE_NAME, classPtr, classID, tagList)

static __inline APTR
_NewObjectA(void *IntuitionBase, struct IClass *classPtr, UBYTE *classID, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) classPtr;
	MyCaos.a1		=(ULONG) classID;
	MyCaos.a2		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-636);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define NewObject(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; NewObjectA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	NextObject(objectPtrPtr)	_NextObject(INTUITION_BASE_NAME, objectPtrPtr)

static __inline APTR
_NextObject(void *IntuitionBase, APTR objectPtrPtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) objectPtrPtr;
	MyCaos.caos_Un.Offset	=	(-666);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	NextPubScreen(screen, namebuf)	_NextPubScreen(INTUITION_BASE_NAME, screen, namebuf)

static __inline UBYTE *
_NextPubScreen(void *IntuitionBase, struct Screen *screen, UBYTE *namebuf)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.a1		=(ULONG) namebuf;
	MyCaos.caos_Un.Offset	=	(-534);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UBYTE *)PPCCallOS(&MyCaos));
}

#define	ObtainGIRPort(gInfo)	_ObtainGIRPort(INTUITION_BASE_NAME, gInfo)

static __inline struct RastPort *
_ObtainGIRPort(void *IntuitionBase, struct GadgetInfo *gInfo)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gInfo;
	MyCaos.caos_Un.Offset	=	(-558);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct RastPort *)PPCCallOS(&MyCaos));
}

#define	OffGadget(gadget, window, requester)	_OffGadget(INTUITION_BASE_NAME, gadget, window, requester)

static __inline void
_OffGadget(void *IntuitionBase, struct Gadget *gadget, struct Window *window, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	OffMenu(window, menuNumber)	_OffMenu(INTUITION_BASE_NAME, window, menuNumber)

static __inline void
_OffMenu(void *IntuitionBase, struct Window *window, unsigned long menuNumber)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) menuNumber;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	OnGadget(gadget, window, requester)	_OnGadget(INTUITION_BASE_NAME, gadget, window, requester)

static __inline void
_OnGadget(void *IntuitionBase, struct Gadget *gadget, struct Window *window, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-186);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	OnMenu(window, menuNumber)	_OnMenu(INTUITION_BASE_NAME, window, menuNumber)

static __inline void
_OnMenu(void *IntuitionBase, struct Window *window, unsigned long menuNumber)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) menuNumber;
	MyCaos.caos_Un.Offset	=	(-192);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	OpenIntuition()	_OpenIntuition(INTUITION_BASE_NAME)

static __inline void
_OpenIntuition(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	OpenScreen(newScreen)	_OpenScreen(INTUITION_BASE_NAME, newScreen)

static __inline struct Screen *
_OpenScreen(void *IntuitionBase, struct NewScreen *newScreen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newScreen;
	MyCaos.caos_Un.Offset	=	(-198);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Screen *)PPCCallOS(&MyCaos));
}

#define	OpenScreenTagList(newScreen, tagList)	_OpenScreenTagList(INTUITION_BASE_NAME, newScreen, tagList)

static __inline struct Screen *
_OpenScreenTagList(void *IntuitionBase, struct NewScreen *newScreen, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newScreen;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-612);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Screen *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define OpenScreenTags(a0, tags...) \
	({ULONG _tags[] = { tags }; OpenScreenTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	OpenWindow(newWindow)	_OpenWindow(INTUITION_BASE_NAME, newWindow)

static __inline struct Window *
_OpenWindow(void *IntuitionBase, struct NewWindow *newWindow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newWindow;
	MyCaos.caos_Un.Offset	=	(-204);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Window *)PPCCallOS(&MyCaos));
}

#define	OpenWindowTagList(newWindow, tagList)	_OpenWindowTagList(INTUITION_BASE_NAME, newWindow, tagList)

static __inline struct Window *
_OpenWindowTagList(void *IntuitionBase, struct NewWindow *newWindow, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newWindow;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-606);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Window *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define OpenWindowTags(a0, tags...) \
	({ULONG _tags[] = { tags }; OpenWindowTagList((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	OpenWorkBench()	_OpenWorkBench(INTUITION_BASE_NAME)

static __inline ULONG
_OpenWorkBench(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-210);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	PointInImage(point, image)	_PointInImage(INTUITION_BASE_NAME, point, image)

static __inline BOOL
_PointInImage(void *IntuitionBase, unsigned long point, struct Image *image)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) point;
	MyCaos.a0		=(ULONG) image;
	MyCaos.caos_Un.Offset	=	(-624);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	PrintIText(rp, iText, left, top)	_PrintIText(INTUITION_BASE_NAME, rp, iText, left, top)

static __inline void
_PrintIText(void *IntuitionBase, struct RastPort *rp, struct IntuiText *iText, long left, long top)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.a1		=(ULONG) iText;
	MyCaos.d0		=(ULONG) left;
	MyCaos.d1		=(ULONG) top;
	MyCaos.caos_Un.Offset	=	(-216);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	PubScreenStatus(screen, statusFlags)	_PubScreenStatus(INTUITION_BASE_NAME, screen, statusFlags)

static __inline UWORD
_PubScreenStatus(void *IntuitionBase, struct Screen *screen, unsigned long statusFlags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.d0		=(ULONG) statusFlags;
	MyCaos.caos_Un.Offset	=	(-552);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	QueryOverscan(displayID, rect, oScanType)	_QueryOverscan(INTUITION_BASE_NAME, displayID, rect, oScanType)

static __inline LONG
_QueryOverscan(void *IntuitionBase, unsigned long displayID, struct Rectangle *rect, long oScanType)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) displayID;
	MyCaos.a1		=(ULONG) rect;
	MyCaos.d0		=(ULONG) oScanType;
	MyCaos.caos_Un.Offset	=	(-474);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RefreshGList(gadgets, window, requester, numGad)	_RefreshGList(INTUITION_BASE_NAME, gadgets, window, requester, numGad)

static __inline void
_RefreshGList(void *IntuitionBase, struct Gadget *gadgets, struct Window *window, struct Requester *requester, long numGad)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadgets;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.d0		=(ULONG) numGad;
	MyCaos.caos_Un.Offset	=	(-432);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	RefreshGadgets(gadgets, window, requester)	_RefreshGadgets(INTUITION_BASE_NAME, gadgets, window, requester)

static __inline void
_RefreshGadgets(void *IntuitionBase, struct Gadget *gadgets, struct Window *window, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadgets;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-222);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	RefreshWindowFrame(window)	_RefreshWindowFrame(INTUITION_BASE_NAME, window)

static __inline void
_RefreshWindowFrame(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-456);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ReleaseGIRPort(rp)	_ReleaseGIRPort(INTUITION_BASE_NAME, rp)

static __inline void
_ReleaseGIRPort(void *IntuitionBase, struct RastPort *rp)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rp;
	MyCaos.caos_Un.Offset	=	(-564);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	RemakeDisplay()	_RemakeDisplay(INTUITION_BASE_NAME)

static __inline LONG
_RemakeDisplay(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-384);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	RemoveClass(classPtr)	_RemoveClass(INTUITION_BASE_NAME, classPtr)

static __inline void
_RemoveClass(void *IntuitionBase, struct IClass *classPtr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) classPtr;
	MyCaos.caos_Un.Offset	=	(-708);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	RemoveGList(remPtr, gadget, numGad)	_RemoveGList(INTUITION_BASE_NAME, remPtr, gadget, numGad)

static __inline UWORD
_RemoveGList(void *IntuitionBase, struct Window *remPtr, struct Gadget *gadget, long numGad)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) remPtr;
	MyCaos.a1		=(ULONG) gadget;
	MyCaos.d0		=(ULONG) numGad;
	MyCaos.caos_Un.Offset	=	(-444);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	RemoveGadget(window, gadget)	_RemoveGadget(INTUITION_BASE_NAME, window, gadget)

static __inline UWORD
_RemoveGadget(void *IntuitionBase, struct Window *window, struct Gadget *gadget)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) gadget;
	MyCaos.caos_Un.Offset	=	(-228);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	ReportMouse(flag, window)	_ReportMouse(INTUITION_BASE_NAME, flag, window)

static __inline void
_ReportMouse(void *IntuitionBase, long flag, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) flag;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-234);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	Request(requester, window)	_Request(INTUITION_BASE_NAME, requester, window)

static __inline BOOL
_Request(void *IntuitionBase, struct Requester *requester, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) requester;
	MyCaos.a1		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-240);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	ResetMenuStrip(window, menu)	_ResetMenuStrip(INTUITION_BASE_NAME, window, menu)

static __inline BOOL
_ResetMenuStrip(void *IntuitionBase, struct Window *window, struct Menu *menu)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) menu;
	MyCaos.caos_Un.Offset	=	(-702);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	RethinkDisplay()	_RethinkDisplay(INTUITION_BASE_NAME)

static __inline LONG
_RethinkDisplay(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-390);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	ScreenDepth(screen, flags, reserved)	_ScreenDepth(INTUITION_BASE_NAME, screen, flags, reserved)

static __inline void
_ScreenDepth(void *IntuitionBase, struct Screen *screen, unsigned long flags, APTR reserved)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.a1		=(ULONG) reserved;
	MyCaos.caos_Un.Offset	=	(-786);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ScreenPosition(screen, flags, x1, y1, x2, y2)	_ScreenPosition(INTUITION_BASE_NAME, screen, flags, x1, y1, x2, y2)

static __inline void
_ScreenPosition(void *IntuitionBase, struct Screen *screen, unsigned long flags, long x1, long y1, long x2, long y2)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.d0		=(ULONG) flags;
	MyCaos.d1		=(ULONG) x1;
	MyCaos.d2		=(ULONG) y1;
	MyCaos.d3		=(ULONG) x2;
	MyCaos.d4		=(ULONG) y2;
	MyCaos.caos_Un.Offset	=	(-792);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ScreenToBack(screen)	_ScreenToBack(INTUITION_BASE_NAME, screen)

static __inline void
_ScreenToBack(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-246);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ScreenToFront(screen)	_ScreenToFront(INTUITION_BASE_NAME, screen)

static __inline void
_ScreenToFront(void *IntuitionBase, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-252);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ScrollWindowRaster(win, dx, dy, xMin, yMin, xMax, yMax)	_ScrollWindowRaster(INTUITION_BASE_NAME, win, dx, dy, xMin, yMin, xMax, yMax)

static __inline void
_ScrollWindowRaster(void *IntuitionBase, struct Window *win, long dx, long dy, long xMin, long yMin, long xMax, long yMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) win;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.d2		=(ULONG) xMin;
	MyCaos.d3		=(ULONG) yMin;
	MyCaos.d4		=(ULONG) xMax;
	MyCaos.d5		=(ULONG) yMax;
	MyCaos.caos_Un.Offset	=	(-798);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	SetAttrsA(object, tagList)	_SetAttrsA(INTUITION_BASE_NAME, object, tagList)

static __inline ULONG
_SetAttrsA(void *IntuitionBase, APTR object, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) object;
	MyCaos.a1		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-648);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetAttrs(a0, tags...) \
	({ULONG _tags[] = { tags }; SetAttrsA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetDMRequest(window, requester)	_SetDMRequest(INTUITION_BASE_NAME, window, requester)

static __inline BOOL
_SetDMRequest(void *IntuitionBase, struct Window *window, struct Requester *requester)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) requester;
	MyCaos.caos_Un.Offset	=	(-258);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetDefaultPubScreen(name)	_SetDefaultPubScreen(INTUITION_BASE_NAME, name)

static __inline void
_SetDefaultPubScreen(void *IntuitionBase, UBYTE *name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-540);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	SetEditHook(hook)	_SetEditHook(INTUITION_BASE_NAME, hook)

static __inline struct Hook *
_SetEditHook(void *IntuitionBase, struct Hook *hook)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) hook;
	MyCaos.caos_Un.Offset	=	(-492);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Hook *)PPCCallOS(&MyCaos));
}

#define	SetGadgetAttrsA(gadget, window, requester, tagList)	_SetGadgetAttrsA(INTUITION_BASE_NAME, gadget, window, requester, tagList)

static __inline ULONG
_SetGadgetAttrsA(void *IntuitionBase, struct Gadget *gadget, struct Window *window, struct Requester *requester, struct TagItem *tagList)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gadget;
	MyCaos.a1		=(ULONG) window;
	MyCaos.a2		=(ULONG) requester;
	MyCaos.a3		=(ULONG) tagList;
	MyCaos.caos_Un.Offset	=	(-660);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define SetGadgetAttrs(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; SetGadgetAttrsA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetMenuStrip(window, menu)	_SetMenuStrip(INTUITION_BASE_NAME, window, menu)

static __inline BOOL
_SetMenuStrip(void *IntuitionBase, struct Window *window, struct Menu *menu)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) menu;
	MyCaos.caos_Un.Offset	=	(-264);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	SetMouseQueue(window, queueLength)	_SetMouseQueue(INTUITION_BASE_NAME, window, queueLength)

static __inline LONG
_SetMouseQueue(void *IntuitionBase, struct Window *window, unsigned long queueLength)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) queueLength;
	MyCaos.caos_Un.Offset	=	(-498);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	SetPointer(window, pointer, height, width, xOffset, yOffset)	_SetPointer(INTUITION_BASE_NAME, window, pointer, height, width, xOffset, yOffset)

static __inline void
_SetPointer(void *IntuitionBase, struct Window *window, UWORD *pointer, long height, long width, long xOffset, long yOffset)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) pointer;
	MyCaos.d0		=(ULONG) height;
	MyCaos.d1		=(ULONG) width;
	MyCaos.d2		=(ULONG) xOffset;
	MyCaos.d3		=(ULONG) yOffset;
	MyCaos.caos_Un.Offset	=	(-270);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	SetPrefs(preferences, size, inform)	_SetPrefs(INTUITION_BASE_NAME, preferences, size, inform)

static __inline struct Preferences *
_SetPrefs(void *IntuitionBase, struct Preferences *preferences, long size, long inform)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) preferences;
	MyCaos.d0		=(ULONG) size;
	MyCaos.d1		=(ULONG) inform;
	MyCaos.caos_Un.Offset	=	(-324);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct Preferences *)PPCCallOS(&MyCaos));
}

#define	SetPubScreenModes(modes)	_SetPubScreenModes(INTUITION_BASE_NAME, modes)

static __inline UWORD
_SetPubScreenModes(void *IntuitionBase, unsigned long modes)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) modes;
	MyCaos.caos_Un.Offset	=	(-546);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((UWORD)PPCCallOS(&MyCaos));
}

#define	SetWindowPointerA(win, taglist)	_SetWindowPointerA(INTUITION_BASE_NAME, win, taglist)

static __inline void
_SetWindowPointerA(void *IntuitionBase, struct Window *win, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.a1		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-816);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define SetWindowPointer(a0, tags...) \
	({ULONG _tags[] = { tags }; SetWindowPointerA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	SetWindowTitles(window, windowTitle, screenTitle)	_SetWindowTitles(INTUITION_BASE_NAME, window, windowTitle, screenTitle)

static __inline void
_SetWindowTitles(void *IntuitionBase, struct Window *window, UBYTE *windowTitle, UBYTE *screenTitle)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) windowTitle;
	MyCaos.a2		=(ULONG) screenTitle;
	MyCaos.caos_Un.Offset	=	(-276);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ShowTitle(screen, showIt)	_ShowTitle(INTUITION_BASE_NAME, screen, showIt)

static __inline void
_ShowTitle(void *IntuitionBase, struct Screen *screen, long showIt)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.d0		=(ULONG) showIt;
	MyCaos.caos_Un.Offset	=	(-282);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	SizeWindow(window, dx, dy)	_SizeWindow(INTUITION_BASE_NAME, window, dx, dy)

static __inline void
_SizeWindow(void *IntuitionBase, struct Window *window, long dx, long dy)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) dx;
	MyCaos.d1		=(ULONG) dy;
	MyCaos.caos_Un.Offset	=	(-288);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	SysReqHandler(window, idcmpPtr, waitInput)	_SysReqHandler(INTUITION_BASE_NAME, window, idcmpPtr, waitInput)

static __inline LONG
_SysReqHandler(void *IntuitionBase, struct Window *window, ULONG *idcmpPtr, long waitInput)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) idcmpPtr;
	MyCaos.d0		=(ULONG) waitInput;
	MyCaos.caos_Un.Offset	=	(-600);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	TimedDisplayAlert(alertNumber, string, height, time)	_TimedDisplayAlert(INTUITION_BASE_NAME, alertNumber, string, height, time)

static __inline BOOL
_TimedDisplayAlert(void *IntuitionBase, unsigned long alertNumber, UBYTE *string, unsigned long height, unsigned long time)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) alertNumber;
	MyCaos.a0		=(ULONG) string;
	MyCaos.d1		=(ULONG) height;
	MyCaos.a1		=(ULONG) time;
	MyCaos.caos_Un.Offset	=	(-822);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	UnlockIBase(ibLock)	_UnlockIBase(INTUITION_BASE_NAME, ibLock)

static __inline void
_UnlockIBase(void *IntuitionBase, unsigned long ibLock)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) ibLock;
	MyCaos.caos_Un.Offset	=	(-420);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockPubScreen(name, screen)	_UnlockPubScreen(INTUITION_BASE_NAME, name, screen)

static __inline void
_UnlockPubScreen(void *IntuitionBase, UBYTE *name, struct Screen *screen)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.a1		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-516);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	UnlockPubScreenList()	_UnlockPubScreenList(INTUITION_BASE_NAME)

static __inline void
_UnlockPubScreenList(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-528);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ViewAddress()	_ViewAddress(INTUITION_BASE_NAME)

static __inline struct View *
_ViewAddress(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-294);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct View *)PPCCallOS(&MyCaos));
}

#define	ViewPortAddress(window)	_ViewPortAddress(INTUITION_BASE_NAME, window)

static __inline struct ViewPort *
_ViewPortAddress(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-300);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((struct ViewPort *)PPCCallOS(&MyCaos));
}

#define	WBenchToBack()	_WBenchToBack(INTUITION_BASE_NAME)

static __inline BOOL
_WBenchToBack(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-336);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	WBenchToFront()	_WBenchToFront(INTUITION_BASE_NAME)

static __inline BOOL
_WBenchToFront(void *IntuitionBase)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.caos_Un.Offset	=	(-342);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	WindowLimits(window, widthMin, heightMin, widthMax, heightMax)	_WindowLimits(INTUITION_BASE_NAME, window, widthMin, heightMin, widthMax, heightMax)

static __inline BOOL
_WindowLimits(void *IntuitionBase, struct Window *window, long widthMin, long heightMin, unsigned long widthMax, unsigned long heightMax)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.d0		=(ULONG) widthMin;
	MyCaos.d1		=(ULONG) heightMin;
	MyCaos.d2		=(ULONG) widthMax;
	MyCaos.d3		=(ULONG) heightMax;
	MyCaos.caos_Un.Offset	=	(-318);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	WindowToBack(window)	_WindowToBack(INTUITION_BASE_NAME, window)

static __inline void
_WindowToBack(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-306);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	WindowToFront(window)	_WindowToFront(INTUITION_BASE_NAME, window)

static __inline void
_WindowToFront(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-312);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#define	ZipWindow(window)	_ZipWindow(INTUITION_BASE_NAME, window)

static __inline void
_ZipWindow(void *IntuitionBase, struct Window *window)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) window;
	MyCaos.caos_Un.Offset	=	(-504);
	MyCaos.a6		=(ULONG) IntuitionBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_INTUITION_H */
