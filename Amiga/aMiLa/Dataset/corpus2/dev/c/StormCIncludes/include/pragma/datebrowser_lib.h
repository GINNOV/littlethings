#ifndef _INCLUDE_PRAGMA_DATEBROWSER_LIB_H
#define _INCLUDE_PRAGMA_DATEBROWSER_LIB_H

#ifndef CLIB_DATEBROWSER_PROTOS_H
#include <clib/datebrowser_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/datebrowser.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DateBrowserBase,0x01E,DATEBROWSER_GetClass())
#pragma amicall(DateBrowserBase,0x024,JulianWeekDay(d0,d1,d2))
#pragma amicall(DateBrowserBase,0x02A,JulianMonthDays(d0,d1))
#pragma amicall(DateBrowserBase,0x030,JulianLeapYear(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DateBrowserBase DATEBROWSER_GetClass 01E 00
#pragma  libcall DateBrowserBase JulianWeekDay        024 21003
#pragma  libcall DateBrowserBase JulianMonthDays      02A 1002
#pragma  libcall DateBrowserBase JulianLeapYear       030 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DATEBROWSER_LIB_H  */
