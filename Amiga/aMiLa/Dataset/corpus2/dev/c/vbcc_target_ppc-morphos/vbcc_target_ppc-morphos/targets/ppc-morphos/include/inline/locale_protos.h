#ifndef _VBCCINLINE_LOCALE_H
#define _VBCCINLINE_LOCALE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __CloseCatalog(void *, CONST struct Catalog * catalog) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define CloseCatalog(catalog) __CloseCatalog(LocaleBase, (catalog))

VOID __CloseLocale(void *, CONST struct Locale * locale) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CloseLocale(locale) __CloseLocale(LocaleBase, (locale))

ULONG __ConvToLower(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define ConvToLower(locale, character) __ConvToLower(LocaleBase, (locale), (character))

ULONG __ConvToUpper(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define ConvToUpper(locale, character) __ConvToUpper(LocaleBase, (locale), (character))

VOID __FormatDate(void *, CONST struct Locale * locale, CONST_STRPTR fmtTemplate, CONST struct DateStamp * date, CONST struct Hook * putCharFunc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define FormatDate(locale, fmtTemplate, date, putCharFunc) __FormatDate(LocaleBase, (locale), (fmtTemplate), (date), (putCharFunc))

APTR __FormatString(void *, CONST struct Locale * locale, CONST_STRPTR fmtTemplate, CONST_APTR dataStream, CONST struct Hook * putCharFunc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define FormatString(locale, fmtTemplate, dataStream, putCharFunc) __FormatString(LocaleBase, (locale), (fmtTemplate), (dataStream), (putCharFunc))

STRPTR __GetCatalogStr(void *, CONST struct Catalog * catalog, LONG stringNum, CONST_STRPTR defaultString) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define GetCatalogStr(catalog, stringNum, defaultString) __GetCatalogStr(LocaleBase, (catalog), (stringNum), (defaultString))

STRPTR __GetLocaleStr(void *, CONST struct Locale * locale, ULONG stringNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GetLocaleStr(locale, stringNum) __GetLocaleStr(LocaleBase, (locale), (stringNum))

BOOL __IsAlNum(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define IsAlNum(locale, character) __IsAlNum(LocaleBase, (locale), (character))

BOOL __IsAlpha(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define IsAlpha(locale, character) __IsAlpha(LocaleBase, (locale), (character))

BOOL __IsCntrl(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define IsCntrl(locale, character) __IsCntrl(LocaleBase, (locale), (character))

BOOL __IsDigit(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define IsDigit(locale, character) __IsDigit(LocaleBase, (locale), (character))

BOOL __IsGraph(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define IsGraph(locale, character) __IsGraph(LocaleBase, (locale), (character))

BOOL __IsLower(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define IsLower(locale, character) __IsLower(LocaleBase, (locale), (character))

BOOL __IsPrint(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define IsPrint(locale, character) __IsPrint(LocaleBase, (locale), (character))

BOOL __IsPunct(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define IsPunct(locale, character) __IsPunct(LocaleBase, (locale), (character))

BOOL __IsSpace(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define IsSpace(locale, character) __IsSpace(LocaleBase, (locale), (character))

BOOL __IsUpper(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define IsUpper(locale, character) __IsUpper(LocaleBase, (locale), (character))

BOOL __IsXDigit(void *, CONST struct Locale * locale, ULONG character) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define IsXDigit(locale, character) __IsXDigit(LocaleBase, (locale), (character))

struct Catalog * __OpenCatalogA(void *, CONST struct Locale * locale, CONST_STRPTR name, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define OpenCatalogA(locale, name, tags) __OpenCatalogA(LocaleBase, (locale), (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Catalog * __linearvarargs __OpenCatalog(void *, CONST struct Locale * locale, CONST_STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define OpenCatalog(locale, name, ...) __OpenCatalog(LocaleBase, (locale), (name), __VA_ARGS__)
#endif

struct Locale * __OpenLocale(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define OpenLocale(name) __OpenLocale(LocaleBase, (name))

BOOL __ParseDate(void *, CONST struct Locale * locale, CONST struct DateStamp * date, CONST_STRPTR fmtTemplate, CONST struct Hook * getCharFunc) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define ParseDate(locale, date, fmtTemplate, getCharFunc) __ParseDate(LocaleBase, (locale), (date), (fmtTemplate), (getCharFunc))

ULONG __StrConvert(void *, CONST struct Locale * locale, CONST_STRPTR string, APTR buffer, ULONG bufferSize, ULONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define StrConvert(locale, string, buffer, bufferSize, type) __StrConvert(LocaleBase, (locale), (string), (buffer), (bufferSize), (type))

LONG __StrnCmp(void *, CONST struct Locale * locale, CONST_STRPTR string1, CONST_STRPTR string2, LONG length, ULONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define StrnCmp(locale, string1, string2, length, type) __StrnCmp(LocaleBase, (locale), (string1), (string2), (length), (type))

WCHAR __UCS4_ConvToLower(WCHAR utf32) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-232(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_ConvToLower(utf32) __UCS4_ConvToLower((utf32))

WCHAR __UCS4_ConvToUpper(WCHAR utf32) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-238(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_ConvToUpper(utf32) __UCS4_ConvToUpper((utf32))

ULONG __UTF8_Decode(CONST_STRPTR utf8, WCHAR * utf32) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-244(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UTF8_Decode(utf8, utf32) __UTF8_Decode((utf8), (utf32))

ULONG __UTF8_Encode(WCHAR utf32, STRPTR utf8) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-250(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UTF8_Encode(utf32, utf8) __UTF8_Encode((utf32), (utf8))

CONST_WSTRPTR __UCS4_GetCatalogStr(CONST struct Catalog * catalog, ULONG stringNum, CONST_WSTRPTR defaultString, void *) =
	"\tlwz\t0,-256(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_GetCatalogStr(catalog, stringNum, defaultString) __UCS4_GetCatalogStr((catalog), (stringNum), (defaultString), LocaleBase)

BOOL __UCS4_IsAlNum(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-262(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsAlNum(ucharacter) __UCS4_IsAlNum((ucharacter))

BOOL __UCS4_IsAlpha(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-268(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsAlpha(ucharacter) __UCS4_IsAlpha((ucharacter))

BOOL __UCS4_IsCntrl(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-274(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsCntrl(ucharacter) __UCS4_IsCntrl((ucharacter))

BOOL __UCS4_IsDigit(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-280(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsDigit(ucharacter) __UCS4_IsDigit((ucharacter))

BOOL __UCS4_IsGraph(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-286(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsGraph(ucharacter) __UCS4_IsGraph((ucharacter))

BOOL __UCS4_IsLower(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-292(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsLower(ucharacter) __UCS4_IsLower((ucharacter))

BOOL __UCS4_IsPrint(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-298(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsPrint(ucharacter) __UCS4_IsPrint((ucharacter))

BOOL __UCS4_IsPunct(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-304(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsPunct(ucharacter) __UCS4_IsPunct((ucharacter))

BOOL __UCS4_IsSpace(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-310(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsSpace(ucharacter) __UCS4_IsSpace((ucharacter))

BOOL __UCS4_IsUpper(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-316(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsUpper(ucharacter) __UCS4_IsUpper((ucharacter))

BOOL __UCS4_IsXDigit(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-322(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsXDigit(ucharacter) __UCS4_IsXDigit((ucharacter))

VOID __UCS4_FormatDate(CONST struct Locale * locale, CONST_WSTRPTR fmtTemplate, CONST struct DateStamp * date, CONST struct Hook * putCharFunc, void *) =
	"\tlwz\t0,-328(7)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_FormatDate(locale, fmtTemplate, date, putCharFunc) __UCS4_FormatDate((locale), (fmtTemplate), (date), (putCharFunc), LocaleBase)

APTR __UCS4_FormatString(CONST struct Locale * locale, CONST_WSTRPTR fmtTemplate, CONST_APTR dataStream, CONST struct Hook * putCharFunc, void *) =
	"\tlwz\t0,-334(7)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_FormatString(locale, fmtTemplate, dataStream, putCharFunc) __UCS4_FormatString((locale), (fmtTemplate), (dataStream), (putCharFunc), LocaleBase)

CONST_WSTRPTR __UCS4_GetLocaleStr(CONST struct Locale * locale, ULONG stringNum, void *) =
	"\tlwz\t0,-340(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_GetLocaleStr(locale, stringNum) __UCS4_GetLocaleStr((locale), (stringNum), LocaleBase)

LONG __UCS4_StrnCmp(CONST struct Locale * locale, CONST_WSTRPTR string1, CONST_WSTRPTR string2, LONG length, ULONG type, void *) =
	"\tlwz\t0,-346(8)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_StrnCmp(locale, string1, string2, length, type) __UCS4_StrnCmp((locale), (string1), (string2), (length), (type), LocaleBase)

LONG __UCS4_StrToLower(CONST struct Locale * locale, CONST_WSTRPTR string, WSTRPTR buffer, ULONG bufferSize, ULONG type, void *) =
	"\tlwz\t0,-352(8)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_StrToLower(locale, string, buffer, bufferSize, type) __UCS4_StrToLower((locale), (string), (buffer), (bufferSize), (type), LocaleBase)

LONG __UCS4_StrToUpper(CONST struct Locale * locale, CONST_WSTRPTR string, WSTRPTR buffer, ULONG bufferSize, ULONG type, void *) =
	"\tlwz\t0,-358(8)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_StrToUpper(locale, string, buffer, bufferSize, type) __UCS4_StrToUpper((locale), (string), (buffer), (bufferSize), (type), LocaleBase)

CONST_WSTRPTR __UCS4_Decompose(WCHAR ucharacter, void *) =
	"\tlwz\t0,-364(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_Decompose(ucharacter) __UCS4_Decompose((ucharacter), LocaleBase)

BOOL __UCS4_IsNSM(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-370(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsNSM(ucharacter) __UCS4_IsNSM((ucharacter))

CONST_WSTRPTR __UCS4_CanonicalDecompose(WCHAR ucharacter, void *) =
	"\tlwz\t0,-376(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_CanonicalDecompose(ucharacter) __UCS4_CanonicalDecompose((ucharacter), LocaleBase)

VOID __UCS4_Normalize(CONST_WSTRPTR src, WSTRPTR dst, LONG length, ULONG type, void *) =
	"\tlwz\t0,-382(7)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_Normalize(src, dst, length, type) __UCS4_Normalize((src), (dst), (length), (type), LocaleBase)

ULONG __ConvertUTF8ToUCS4(CONST_STRPTR src, WSTRPTR dst, LONG length) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-388(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ConvertUTF8ToUCS4(src, dst, length) __ConvertUTF8ToUCS4((src), (dst), (length))

ULONG __ConvertUCS4ToUTF8(CONST_WSTRPTR src, STRPTR dst, LONG length) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-394(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ConvertUCS4ToUTF8(src, dst, length) __ConvertUCS4ToUTF8((src), (dst), (length))

ULONG __UCS4_IsCombining(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-400(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_IsCombining(ucharacter) __UCS4_IsCombining((ucharacter))

LONG __UCS4_Compare(CONST struct Locale * locale, CONST_WSTRPTR string1, CONST_WSTRPTR string2, LONG length, ULONG flags, void *) =
	"\tlwz\t0,-406(8)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_Compare(locale, string1, string2, length, flags) __UCS4_Compare((locale), (string1), (string2), (length), (flags), LocaleBase)

ULONG __UCS4_GetCombiningClass(WCHAR ucharacter) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-412(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_GetCombiningClass(ucharacter) __UCS4_GetCombiningClass((ucharacter))

ULONG __UCS4_NormalizedLength(CONST_WSTRPTR string, LONG length, ULONG type, void *) =
	"\tlwz\t0,-418(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_NormalizedLength(string, length, type) __UCS4_NormalizedLength((string), (length), (type), LocaleBase)

LONG __UTF8_CheckEncoding(CONST_STRPTR string, LONG length, void *) =
	"\tlwz\t0,-424(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UTF8_CheckEncoding(string, length) __UTF8_CheckEncoding((string), (length), LocaleBase)

ULONG __IsUnicode(APTR buffer, ULONG length, void *) =
	"\tlwz\t0,-430(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IsUnicode(buffer, length) __IsUnicode((buffer), (length), LocaleBase)

VOID __UCS4_FormatClockData(CONST struct Locale * locale, CONST_WSTRPTR fmtTemplate, CONST struct ClockData * clockdata, CONST struct Hook * putCharFunc, void *) =
	"\tlwz\t0,-460(7)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define UCS4_FormatClockData(locale, fmtTemplate, clockdata, putCharFunc) __UCS4_FormatClockData((locale), (fmtTemplate), (clockdata), (putCharFunc), LocaleBase)

ssize_t __VSNPrintf(CONST struct Locale * locale, STRPTR buffer, ssize_t bufferSize, CONST_STRPTR fmtTemplate, va_list args, void *) =
	"\tlwz\t0,-466(8)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define VSNPrintf(locale, buffer, bufferSize, fmtTemplate, args) __VSNPrintf((locale), (buffer), (bufferSize), (fmtTemplate), (args), LocaleBase)

ssize_t __SNPrintf(CONST struct Locale * locale, STRPTR buffer, ssize_t bufferSize, CONST_STRPTR fmtTemplate, ...) =
	"\tlis\t11,LocaleBase@ha\n"
	"\tlwz\t12,LocaleBase@l(11)\n"
	"\tlwz\t0,-472(12)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SNPrintf(locale, buffer, bufferSize, ...) __SNPrintf((locale), (buffer), (bufferSize), __VA_ARGS__)

#endif /*  _VBCCINLINE_LOCALE_H  */
