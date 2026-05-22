/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_WB_H
#define _PPCPRAGMA_WB_H
#ifdef __GNUC__
#ifndef _PPCINLINE__WB_H
#include <ppcinline/wb.h>
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

#ifndef WB_BASE_NAME
#define WB_BASE_NAME WorkbenchBase
#endif /* !WB_BASE_NAME */

#define	AddAppIconA(id, userdata, text, msgport, lock, diskobj, taglist)	_AddAppIconA(WB_BASE_NAME, id, userdata, text, msgport, lock, diskobj, taglist)

static __inline struct AppIcon *
_AddAppIconA(void *WorkbenchBase, unsigned long id, unsigned long userdata, UBYTE *text, struct MsgPort *msgport, struct FileLock *lock, struct DiskObject *diskobj, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.d1		=(ULONG) userdata;
	MyCaos.a0		=(ULONG) text;
	MyCaos.a1		=(ULONG) msgport;
	MyCaos.a2		=(ULONG) lock;
	MyCaos.a3		=(ULONG) diskobj;
	MyCaos.a4		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((struct AppIcon *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AddAppIcon(a0, a1, a2, a3, a4, a5, tags...) \
	({ULONG _tags[] = { tags }; AddAppIconA((a0), (a1), (a2), (a3), (a4), (a5), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AddAppMenuItemA(id, userdata, text, msgport, taglist)	_AddAppMenuItemA(WB_BASE_NAME, id, userdata, text, msgport, taglist)

static __inline struct AppMenuItem *
_AddAppMenuItemA(void *WorkbenchBase, unsigned long id, unsigned long userdata, UBYTE *text, struct MsgPort *msgport, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.d1		=(ULONG) userdata;
	MyCaos.a0		=(ULONG) text;
	MyCaos.a1		=(ULONG) msgport;
	MyCaos.a2		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((struct AppMenuItem *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AddAppMenuItem(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; AddAppMenuItemA((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	AddAppWindowA(id, userdata, window, msgport, taglist)	_AddAppWindowA(WB_BASE_NAME, id, userdata, window, msgport, taglist)

static __inline struct AppWindow *
_AddAppWindowA(void *WorkbenchBase, unsigned long id, unsigned long userdata, struct Window *window, struct MsgPort *msgport, struct TagItem *taglist)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.d0		=(ULONG) id;
	MyCaos.d1		=(ULONG) userdata;
	MyCaos.a0		=(ULONG) window;
	MyCaos.a1		=(ULONG) msgport;
	MyCaos.a2		=(ULONG) taglist;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((struct AppWindow *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define AddAppWindow(a0, a1, a2, a3, tags...) \
	({ULONG _tags[] = { tags }; AddAppWindowA((a0), (a1), (a2), (a3), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	RemoveAppIcon(appIcon)	_RemoveAppIcon(WB_BASE_NAME, appIcon)

static __inline BOOL
_RemoveAppIcon(void *WorkbenchBase, struct AppIcon *appIcon)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appIcon;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	RemoveAppMenuItem(appMenuItem)	_RemoveAppMenuItem(WB_BASE_NAME, appMenuItem)

static __inline BOOL
_RemoveAppMenuItem(void *WorkbenchBase, struct AppMenuItem *appMenuItem)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appMenuItem;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	RemoveAppWindow(appWindow)	_RemoveAppWindow(WB_BASE_NAME, appWindow)

static __inline BOOL
_RemoveAppWindow(void *WorkbenchBase, struct AppWindow *appWindow)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) appWindow;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	WBInfo(lock, name, screen)	_WBInfo(WB_BASE_NAME, lock, name, screen)

static __inline void
_WBInfo(void *WorkbenchBase, BPTR lock, STRPTR name, struct Screen *screen)
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
	MyCaos.a2		=(ULONG) screen;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) WorkbenchBase;	
	PPCCallOS(&MyCaos);
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_WB_H */
