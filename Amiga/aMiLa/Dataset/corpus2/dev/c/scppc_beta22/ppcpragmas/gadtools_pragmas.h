/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_GADTOOLS_H
#define _PPCPRAGMA_GADTOOLS_H
#ifdef __GNUC__
#ifndef _PPCINLINE__GADTOOLS_H
#include <ppcinline/gadtools.h>
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

#ifndef GADTOOLS_BASE_NAME
#define GADTOOLS_BASE_NAME GadToolsBase
#endif /* !GADTOOLS_BASE_NAME */

#define	CreateContext(glistptr)	_CreateContext(GADTOOLS_BASE_NAME, glistptr)

static __inline struct Gadget *
_CreateContext(void *GadToolsBase, struct Gadget **glistptr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) glistptr;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct Gadget *)PPCCallOS(&MyCaos));
}

#define	CreateGadgetA(kind, gad, ng, taglist)	_CreateGadgetA(GADTOOLS_BASE_NAME, kind, gad, ng, taglist)

static __inline struct Gadget *
_CreateGadgetA(void *GadToolsBase, unsigned long kind, struct Gadget *gad, struct NewGadget *ng, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) kind;
	MyCaos.a0		=(ULONG) gad;
	MyCaos.a1		=(ULONG) ng;
	MyCaos.a2		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct Gadget *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define CreateGadget(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; CreateGadgetA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	CreateMenusA(newmenu, taglist)	_CreateMenusA(GADTOOLS_BASE_NAME, newmenu, taglist)

static __inline struct Menu *
_CreateMenusA(void *GadToolsBase, struct NewMenu *newmenu, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) newmenu;
	MyCaos.a1		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct Menu *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define CreateMenus(a0, tags...) \
	({ULONG _tags[] = { tags }; CreateMenusA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	DrawBevelBoxA(rport, left, top, width, height, taglist)	_DrawBevelBoxA(GADTOOLS_BASE_NAME, rport, left, top, width, height, taglist)

static __inline void
_DrawBevelBoxA(void *GadToolsBase, struct RastPort *rport, long left, long top, long width, long height, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) rport;
	MyCaos.d0		=(ULONG) left;
	MyCaos.d1		=(ULONG) top;
	MyCaos.d2		=(ULONG) width;
	MyCaos.d3		=(ULONG) height;
	MyCaos.a1		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define DrawBevelBox(a0, a1, a2, a3, a4, tags...) \
	({ULONG _tags[] = { tags }; DrawBevelBoxA((a0), (a1), (a2), (a3), (a4), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	FreeGadgets(gad)	_FreeGadgets(GADTOOLS_BASE_NAME, gad)

static __inline void
_FreeGadgets(void *GadToolsBase, struct Gadget *gad)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) gad;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeMenus(menu)	_FreeMenus(GADTOOLS_BASE_NAME, menu)

static __inline void
_FreeMenus(void *GadToolsBase, struct Menu *menu)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) menu;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	FreeVisualInfo(vi)	_FreeVisualInfo(GADTOOLS_BASE_NAME, vi)

static __inline void
_FreeVisualInfo(void *GadToolsBase, APTR vi)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) vi;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	GT_BeginRefresh(win)	_GT_BeginRefresh(GADTOOLS_BASE_NAME, win)

static __inline void
_GT_BeginRefresh(void *GadToolsBase, struct Window *win)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	GT_EndRefresh(win, complete)	_GT_EndRefresh(GADTOOLS_BASE_NAME, win, complete)

static __inline void
_GT_EndRefresh(void *GadToolsBase, struct Window *win, long complete)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) win;
	MyCaos.d0		=(ULONG) complete;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	GT_FilterIMsg(imsg)	_GT_FilterIMsg(GADTOOLS_BASE_NAME, imsg)

static __inline struct IntuiMessage *
_GT_FilterIMsg(void *GadToolsBase, struct IntuiMessage *imsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) imsg;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct IntuiMessage *)PPCCallOS(&MyCaos));
}

#define	GT_GetGadgetAttrsA(gad, win, req, taglist)	_GT_GetGadgetAttrsA(GADTOOLS_BASE_NAME, gad, win, req, taglist)

static __inline LONG
_GT_GetGadgetAttrsA(void *GadToolsBase, struct Gadget *gad, struct Window *win, struct Requester *req, struct TagItem *taglist)
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
	MyCaos.a3		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define GT_GetGadgetAttrs(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; GT_GetGadgetAttrsA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GT_GetIMsg(iport)	_GT_GetIMsg(GADTOOLS_BASE_NAME, iport)

static __inline struct IntuiMessage *
_GT_GetIMsg(void *GadToolsBase, struct MsgPort *iport)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) iport;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct IntuiMessage *)PPCCallOS(&MyCaos));
}

#define	GT_PostFilterIMsg(imsg)	_GT_PostFilterIMsg(GADTOOLS_BASE_NAME, imsg)

static __inline struct IntuiMessage *
_GT_PostFilterIMsg(void *GadToolsBase, struct IntuiMessage *imsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) imsg;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((struct IntuiMessage *)PPCCallOS(&MyCaos));
}

#define	GT_RefreshWindow(win, req)	_GT_RefreshWindow(GADTOOLS_BASE_NAME, win, req)

static __inline void
_GT_RefreshWindow(void *GadToolsBase, struct Window *win, struct Requester *req)
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
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	GT_ReplyIMsg(imsg)	_GT_ReplyIMsg(GADTOOLS_BASE_NAME, imsg)

static __inline void
_GT_ReplyIMsg(void *GadToolsBase, struct IntuiMessage *imsg)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) imsg;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#define	GT_SetGadgetAttrsA(gad, win, req, taglist)	_GT_SetGadgetAttrsA(GADTOOLS_BASE_NAME, gad, win, req, taglist)

static __inline void
_GT_SetGadgetAttrsA(void *GadToolsBase, struct Gadget *gad, struct Window *win, struct Requester *req, struct TagItem *taglist)
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
	MyCaos.a3		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	PPCCallOS(&MyCaos);
}

#ifndef NO_PPCINLINE_STDARG
#define GT_SetGadgetAttrs(a0, a1, a2, tags...) \
	({ULONG _tags[] = { tags }; GT_SetGadgetAttrsA((a0), (a1), (a2), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	GetVisualInfoA(screen, taglist)	_GetVisualInfoA(GADTOOLS_BASE_NAME, screen, taglist)

static __inline APTR
_GetVisualInfoA(void *GadToolsBase, struct Screen *screen, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) screen;
	MyCaos.a1		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define GetVisualInfo(a0, tags...) \
	({ULONG _tags[] = { tags }; GetVisualInfoA((a0), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	LayoutMenuItemsA(firstitem, vi, taglist)	_LayoutMenuItemsA(GADTOOLS_BASE_NAME, firstitem, vi, taglist)

static __inline BOOL
_LayoutMenuItemsA(void *GadToolsBase, struct MenuItem *firstitem, APTR vi, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) firstitem;
	MyCaos.a1		=(ULONG) vi;
	MyCaos.a2		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define LayoutMenuItems(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; LayoutMenuItemsA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	LayoutMenusA(firstmenu, vi, taglist)	_LayoutMenusA(GADTOOLS_BASE_NAME, firstmenu, vi, taglist)

static __inline BOOL
_LayoutMenusA(void *GadToolsBase, struct Menu *firstmenu, APTR vi, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) firstmenu;
	MyCaos.a1		=(ULONG) vi;
	MyCaos.a2		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) GadToolsBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define LayoutMenus(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; LayoutMenusA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_GADTOOLS_H */
