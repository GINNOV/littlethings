#ifndef _INCLUDE_PRAGMA_CONSOLE_LIB_H
#define _INCLUDE_PRAGMA_CONSOLE_LIB_H

#ifndef CLIB_CONSOLE_PROTOS_H
#include <clib/console_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/console.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ConsoleDevice,0x02A,CDInputHandler(a0,a1))
#pragma amicall(ConsoleDevice,0x030,RawKeyConvert(a0,a1,d1,a2))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ConsoleDevice CDInputHandler       02A 9802
#pragma  libcall ConsoleDevice RawKeyConvert        030 A19804
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CONSOLE_LIB_H  */
