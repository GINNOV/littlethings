/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_DISKFONT_H
#define _PPCPRAGMA_DISKFONT_H
#ifdef __GNUC__
#ifndef _PPCINLINE__DISKFONT_H
#include <ppcinline/diskfont.h>
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

#ifndef DISKFONT_BASE_NAME
#define DISKFONT_BASE_NAME DiskfontBase
#endif /* !DISKFONT_BASE_NAME */

#define	AvailFonts(buffer, bufBytes, flags)	_AvailFonts(DISKFONT_BASE_NAME, buffer, bufBytes, flags)

static __inline LONG
_AvailFonts(void *DiskfontBase, STRPTR buffer, long bufBytes, long flags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) bufBytes;
	MyCaos.d1		=(ULONG) flags;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) DiskfontBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#define	DisposeFontContents(fontContentsHeader)	_DisposeFontContents(DISKFONT_BASE_NAME, fontContentsHeader)

static __inline void
_DisposeFontContents(void *DiskfontBase, struct FontContentsHeader *fontContentsHeader)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a1		=(ULONG) fontContentsHeader;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) DiskfontBase;	
	PPCCallOS(&MyCaos);
}

#define	NewFontContents(fontsLock, fontName)	_NewFontContents(DISKFONT_BASE_NAME, fontsLock, fontName)

static __inline struct FontContentsHeader *
_NewFontContents(void *DiskfontBase, BPTR fontsLock, STRPTR fontName)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) fontsLock;
	MyCaos.a1		=(ULONG) fontName;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) DiskfontBase;	
	return((struct FontContentsHeader *)PPCCallOS(&MyCaos));
}

#define	NewScaledDiskFont(sourceFont, destTextAttr)	_NewScaledDiskFont(DISKFONT_BASE_NAME, sourceFont, destTextAttr)

static __inline struct DiskFont *
_NewScaledDiskFont(void *DiskfontBase, struct TextFont *sourceFont, struct TextAttr *destTextAttr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) sourceFont;
	MyCaos.a1		=(ULONG) destTextAttr;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) DiskfontBase;	
	return((struct DiskFont *)PPCCallOS(&MyCaos));
}

#define	OpenDiskFont(textAttr)	_OpenDiskFont(DISKFONT_BASE_NAME, textAttr)

static __inline struct TextFont *
_OpenDiskFont(void *DiskfontBase, struct TextAttr *textAttr)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) textAttr;
	MyCaos.caos_Un.Offset	=	(-30);
	MyCaos.a6		=(ULONG) DiskfontBase;	
	return((struct TextFont *)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_DISKFONT_H */
