/* Automatically generated header! Do not edit! */

#ifndef _PPCPRAGMA_LOCALE_H
#define _PPCPRAGMA_LOCALE_H
#ifdef __GNUC__
#ifndef _PPCINLINE__LOCALE_H
#include <ppcinline/locale.h>
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

#ifndef LOCALE_BASE_NAME
#define LOCALE_BASE_NAME LocaleBase
#endif /* !LOCALE_BASE_NAME */

#define	CloseCatalog(catalog)	_CloseCatalog(LOCALE_BASE_NAME, catalog)

static __inline void
_CloseCatalog(void *LocaleBase, struct Catalog *catalog)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) catalog;
	MyCaos.caos_Un.Offset	=	(-36);
	MyCaos.a6		=(ULONG) LocaleBase;	
	PPCCallOS(&MyCaos);
}

#define	CloseLocale(locale)	_CloseLocale(LOCALE_BASE_NAME, locale)

static __inline void
_CloseLocale(void *LocaleBase, struct Locale *locale)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.caos_Un.Offset	=	(-42);
	MyCaos.a6		=(ULONG) LocaleBase;	
	PPCCallOS(&MyCaos);
}

#define	ConvToLower(locale, character)	_ConvToLower(LOCALE_BASE_NAME, locale, character)

static __inline ULONG
_ConvToLower(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-48);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	ConvToUpper(locale, character)	_ConvToUpper(LOCALE_BASE_NAME, locale, character)

static __inline ULONG
_ConvToUpper(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-54);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	FormatDate(locale, fmtTemplate, date, putCharFunc)	_FormatDate(LOCALE_BASE_NAME, locale, fmtTemplate, date, putCharFunc)

static __inline void
_FormatDate(void *LocaleBase, struct Locale *locale, STRPTR fmtTemplate, struct DateStamp *date, struct Hook *putCharFunc)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) fmtTemplate;
	MyCaos.a2		=(ULONG) date;
	MyCaos.a3		=(ULONG) putCharFunc;
	MyCaos.caos_Un.Offset	=	(-60);
	MyCaos.a6		=(ULONG) LocaleBase;	
	PPCCallOS(&MyCaos);
}

#define	FormatString(locale, fmtTemplate, dataStream, putCharFunc)	_FormatString(LOCALE_BASE_NAME, locale, fmtTemplate, dataStream, putCharFunc)

static __inline APTR
_FormatString(void *LocaleBase, struct Locale *locale, STRPTR fmtTemplate, APTR dataStream, struct Hook *putCharFunc)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) fmtTemplate;
	MyCaos.a2		=(ULONG) dataStream;
	MyCaos.a3		=(ULONG) putCharFunc;
	MyCaos.caos_Un.Offset	=	(-66);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((APTR)PPCCallOS(&MyCaos));
}

#define	GetCatalogStr(catalog, stringNum, defaultString)	_GetCatalogStr(LOCALE_BASE_NAME, catalog, stringNum, defaultString)

static __inline STRPTR
_GetCatalogStr(void *LocaleBase, struct Catalog *catalog, long stringNum, STRPTR defaultString)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) catalog;
	MyCaos.d0		=(ULONG) stringNum;
	MyCaos.a1		=(ULONG) defaultString;
	MyCaos.caos_Un.Offset	=	(-72);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	GetLocaleStr(locale, stringNum)	_GetLocaleStr(LOCALE_BASE_NAME, locale, stringNum)

static __inline STRPTR
_GetLocaleStr(void *LocaleBase, struct Locale *locale, unsigned long stringNum)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) stringNum;
	MyCaos.caos_Un.Offset	=	(-78);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((STRPTR)PPCCallOS(&MyCaos));
}

#define	IsAlNum(locale, character)	_IsAlNum(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsAlNum(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-84);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsAlpha(locale, character)	_IsAlpha(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsAlpha(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-90);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsCntrl(locale, character)	_IsCntrl(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsCntrl(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-96);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsDigit(locale, character)	_IsDigit(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsDigit(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-102);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsGraph(locale, character)	_IsGraph(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsGraph(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-108);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsLower(locale, character)	_IsLower(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsLower(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-114);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsPrint(locale, character)	_IsPrint(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsPrint(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-120);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsPunct(locale, character)	_IsPunct(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsPunct(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-126);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsSpace(locale, character)	_IsSpace(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsSpace(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-132);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsUpper(locale, character)	_IsUpper(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsUpper(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-138);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	IsXDigit(locale, character)	_IsXDigit(LOCALE_BASE_NAME, locale, character)

static __inline BOOL
_IsXDigit(void *LocaleBase, struct Locale *locale, unsigned long character)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.d0		=(ULONG) character;
	MyCaos.caos_Un.Offset	=	(-144);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	OpenCatalogA(locale, name, tags)	_OpenCatalogA(LOCALE_BASE_NAME, locale, name, tags)

static __inline struct Catalog *
_OpenCatalogA(void *LocaleBase, struct Locale *locale, STRPTR name, struct TagItem *tags)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) name;
	MyCaos.a2		=(ULONG) tags;
	MyCaos.caos_Un.Offset	=	(-150);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((struct Catalog *)PPCCallOS(&MyCaos));
}

#ifndef NO_PPCINLINE_STDARG
#define OpenCatalog(a0, a1, tags...) \
	({ULONG _tags[] = { tags }; OpenCatalogA((a0), (a1), (struct TagItem *)_tags);})
#endif /* !NO_PPCINLINE_STDARG */

#define	OpenLocale(name)	_OpenLocale(LOCALE_BASE_NAME, name)

static __inline struct Locale *
_OpenLocale(void *LocaleBase, STRPTR name)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) name;
	MyCaos.caos_Un.Offset	=	(-156);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((struct Locale *)PPCCallOS(&MyCaos));
}

#define	ParseDate(locale, date, fmtTemplate, getCharFunc)	_ParseDate(LOCALE_BASE_NAME, locale, date, fmtTemplate, getCharFunc)

static __inline BOOL
_ParseDate(void *LocaleBase, struct Locale *locale, struct DateStamp *date, STRPTR fmtTemplate, struct Hook *getCharFunc)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) date;
	MyCaos.a2		=(ULONG) fmtTemplate;
	MyCaos.a3		=(ULONG) getCharFunc;
	MyCaos.caos_Un.Offset	=	(-162);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((BOOL)PPCCallOS(&MyCaos));
}

#define	StrConvert(locale, string, buffer, bufferSize, type)	_StrConvert(LOCALE_BASE_NAME, locale, string, buffer, bufferSize, type)

static __inline ULONG
_StrConvert(void *LocaleBase, struct Locale *locale, STRPTR string, APTR buffer, unsigned long bufferSize, unsigned long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) string;
	MyCaos.a2		=(ULONG) buffer;
	MyCaos.d0		=(ULONG) bufferSize;
	MyCaos.d1		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-174);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((ULONG)PPCCallOS(&MyCaos));
}

#define	StrnCmp(locale, string1, string2, length, type)	_StrnCmp(LOCALE_BASE_NAME, locale, string1, string2, length, type)

static __inline LONG
_StrnCmp(void *LocaleBase, struct Locale *locale, STRPTR string1, STRPTR string2, long length, unsigned long type)
{
struct Caos	MyCaos;
	MyCaos.M68kCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.M68kStart	=	NULL;
//	MyCaos.M68kSize		=	0;
	MyCaos.PPCCacheMode	=	IF_CACHEFLUSHALL;
//	MyCaos.PPCStart		=	NULL;
//	MyCaos.PPCSize		=	0;
	MyCaos.a0		=(ULONG) locale;
	MyCaos.a1		=(ULONG) string1;
	MyCaos.a2		=(ULONG) string2;
	MyCaos.d0		=(ULONG) length;
	MyCaos.d1		=(ULONG) type;
	MyCaos.caos_Un.Offset	=	(-180);
	MyCaos.a6		=(ULONG) LocaleBase;	
	return((LONG)PPCCallOS(&MyCaos));
}

#endif /* SASC Pragmas */
#endif /* !_PPCPRAGMA_LOCALE_H */
