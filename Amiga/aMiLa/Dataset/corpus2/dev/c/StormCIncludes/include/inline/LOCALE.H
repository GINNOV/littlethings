#ifndef _INLINE_LOCALE_H
#define _INLINE_LOCALE_H

#ifndef LOCALE_BASE_NAME
#define LOCALE_BASE_NAME LocaleBase
#endif

#define CloseCatalog(catalog) \
	((VOID (*)(struct Catalog * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 36))(catalog, (struct Library *) LOCALE_BASE_NAME)

#define CloseLocale(locale) \
	((VOID (*)(struct Locale * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 42))(locale, (struct Library *) LOCALE_BASE_NAME)

#define ConvToLower(locale, character) \
	((ULONG (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 48))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define ConvToUpper(locale, character) \
	((ULONG (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 54))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define FormatDate(locale, fmtTemplate, date, putCharFunc) \
	((VOID (*)(struct Locale * __asm("a0"), STRPTR __asm("a1"), struct DateStamp * __asm("a2"), struct Hook * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 60))(locale, fmtTemplate, date, putCharFunc, (struct Library *) LOCALE_BASE_NAME)

#define FormatString(locale, fmtTemplate, dataStream, putCharFunc) \
	((APTR (*)(struct Locale * __asm("a0"), STRPTR __asm("a1"), APTR __asm("a2"), struct Hook * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 66))(locale, fmtTemplate, dataStream, putCharFunc, (struct Library *) LOCALE_BASE_NAME)

#define GetCatalogStr(catalog, stringNum, defaultString) \
	((STRPTR (*)(struct Catalog * __asm("a0"), LONG __asm("d0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 72))(catalog, stringNum, defaultString, (struct Library *) LOCALE_BASE_NAME)

#define GetLocaleStr(locale, stringNum) \
	((STRPTR (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 78))(locale, stringNum, (struct Library *) LOCALE_BASE_NAME)

#define IsAlNum(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 84))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsAlpha(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 90))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsCntrl(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 96))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsDigit(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 102))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsGraph(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 108))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsLower(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 114))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsPrint(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 120))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsPunct(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 126))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsSpace(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 132))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsUpper(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 138))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define IsXDigit(locale, character) \
	((BOOL (*)(struct Locale * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 144))(locale, character, (struct Library *) LOCALE_BASE_NAME)

#define OpenCatalogA(locale, name, tags) \
	((struct Catalog * (*)(struct Locale * __asm("a0"), STRPTR __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 150))(locale, name, tags, (struct Library *) LOCALE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenCatalog(locale, name, tags...) \
	({ULONG _tags[] = {tags}; OpenCatalogA((locale), (name), (Tag) _tags);})
#endif

#define OpenLocale(name) \
	((struct Locale * (*)(STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 156))(name, (struct Library *) LOCALE_BASE_NAME)

#define ParseDate(locale, date, fmtTemplate, getCharFunc) \
	((BOOL (*)(struct Locale * __asm("a0"), struct DateStamp * __asm("a1"), STRPTR __asm("a2"), struct Hook * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 162))(locale, date, fmtTemplate, getCharFunc, (struct Library *) LOCALE_BASE_NAME)

#define StrConvert(locale, string, buffer, bufferSize, type) \
	((ULONG (*)(struct Locale * __asm("a0"), STRPTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 174))(locale, string, buffer, bufferSize, type, (struct Library *) LOCALE_BASE_NAME)

#define StrnCmp(locale, string1, string2, length, type) \
	((LONG (*)(struct Locale * __asm("a0"), STRPTR __asm("a1"), STRPTR __asm("a2"), LONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) LOCALE_BASE_NAME) - 180))(locale, string1, string2, length, type, (struct Library *) LOCALE_BASE_NAME)

#endif /*  _INLINE_LOCALE_H  */
