#ifndef _INCLUDE_PRAGMA_LOCALE_LIB_H
#define _INCLUDE_PRAGMA_LOCALE_LIB_H

#ifndef CLIB_LOCALE_PROTOS_H
#include <clib/locale_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/locale.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(LocaleBase,0x024,CloseCatalog(a0))
#pragma amicall(LocaleBase,0x02A,CloseLocale(a0))
#pragma amicall(LocaleBase,0x030,ConvToLower(a0,d0))
#pragma amicall(LocaleBase,0x036,ConvToUpper(a0,d0))
#pragma amicall(LocaleBase,0x03C,FormatDate(a0,a1,a2,a3))
#pragma amicall(LocaleBase,0x042,FormatString(a0,a1,a2,a3))
#pragma amicall(LocaleBase,0x048,GetCatalogStr(a0,d0,a1))
#pragma amicall(LocaleBase,0x04E,GetLocaleStr(a0,d0))
#pragma amicall(LocaleBase,0x054,IsAlNum(a0,d0))
#pragma amicall(LocaleBase,0x05A,IsAlpha(a0,d0))
#pragma amicall(LocaleBase,0x060,IsCntrl(a0,d0))
#pragma amicall(LocaleBase,0x066,IsDigit(a0,d0))
#pragma amicall(LocaleBase,0x06C,IsGraph(a0,d0))
#pragma amicall(LocaleBase,0x072,IsLower(a0,d0))
#pragma amicall(LocaleBase,0x078,IsPrint(a0,d0))
#pragma amicall(LocaleBase,0x07E,IsPunct(a0,d0))
#pragma amicall(LocaleBase,0x084,IsSpace(a0,d0))
#pragma amicall(LocaleBase,0x08A,IsUpper(a0,d0))
#pragma amicall(LocaleBase,0x090,IsXDigit(a0,d0))
#pragma amicall(LocaleBase,0x096,OpenCatalogA(a0,a1,a2))
#pragma amicall(LocaleBase,0x09C,OpenLocale(a0))
#pragma amicall(LocaleBase,0x0A2,ParseDate(a0,a1,a2,a3))
#pragma amicall(LocaleBase,0x0AE,StrConvert(a0,a1,a2,d0,d1))
#pragma amicall(LocaleBase,0x0B4,StrnCmp(a0,a1,a2,d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall LocaleBase CloseCatalog         024 801
#pragma  libcall LocaleBase CloseLocale          02A 801
#pragma  libcall LocaleBase ConvToLower          030 0802
#pragma  libcall LocaleBase ConvToUpper          036 0802
#pragma  libcall LocaleBase FormatDate           03C BA9804
#pragma  libcall LocaleBase FormatString         042 BA9804
#pragma  libcall LocaleBase GetCatalogStr        048 90803
#pragma  libcall LocaleBase GetLocaleStr         04E 0802
#pragma  libcall LocaleBase IsAlNum              054 0802
#pragma  libcall LocaleBase IsAlpha              05A 0802
#pragma  libcall LocaleBase IsCntrl              060 0802
#pragma  libcall LocaleBase IsDigit              066 0802
#pragma  libcall LocaleBase IsGraph              06C 0802
#pragma  libcall LocaleBase IsLower              072 0802
#pragma  libcall LocaleBase IsPrint              078 0802
#pragma  libcall LocaleBase IsPunct              07E 0802
#pragma  libcall LocaleBase IsSpace              084 0802
#pragma  libcall LocaleBase IsUpper              08A 0802
#pragma  libcall LocaleBase IsXDigit             090 0802
#pragma  libcall LocaleBase OpenCatalogA         096 A9803
#pragma  libcall LocaleBase OpenLocale           09C 801
#pragma  libcall LocaleBase ParseDate            0A2 BA9804
#pragma  libcall LocaleBase StrConvert           0AE 10A9805
#pragma  libcall LocaleBase StrnCmp              0B4 10A9805
#endif
#ifdef __STORM__
#pragma tagcall(LocaleBase,0x096,OpenCatalog(a0,a1,a2))
#endif
#ifdef __SASC_60
#pragma  tagcall LocaleBase OpenCatalog          096 A9803
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_LOCALE_LIB_H  */
