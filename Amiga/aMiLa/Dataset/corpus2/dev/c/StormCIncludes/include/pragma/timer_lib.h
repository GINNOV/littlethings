#ifndef _INCLUDE_PRAGMA_TIMER_LIB_H
#define _INCLUDE_PRAGMA_TIMER_LIB_H

#ifndef CLIB_TIMER_PROTOS_H
#include <clib/timer_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/timer.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(TimerBase,0x02A,AddTime(a0,a1))
#pragma amicall(TimerBase,0x030,SubTime(a0,a1))
#pragma amicall(TimerBase,0x036,CmpTime(a0,a1))
#pragma amicall(TimerBase,0x03C,ReadEClock(a0))
#pragma amicall(TimerBase,0x042,GetSysTime(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall TimerBase AddTime              02A 9802
#pragma  libcall TimerBase SubTime              030 9802
#pragma  libcall TimerBase CmpTime              036 9802
#pragma  libcall TimerBase ReadEClock           03C 801
#pragma  libcall TimerBase GetSysTime           042 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_TIMER_LIB_H  */
