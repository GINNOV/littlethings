#ifndef _INCLUDE_PRAGMA_MATHTRANS_LIB_H
#define _INCLUDE_PRAGMA_MATHTRANS_LIB_H

#ifndef CLIB_MATHTRANS_PROTOS_H
#include <clib/mathtrans_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathtrans.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathTransBase,0x01E,SPAtan(d0))
#pragma amicall(MathTransBase,0x024,SPSin(d0))
#pragma amicall(MathTransBase,0x02A,SPCos(d0))
#pragma amicall(MathTransBase,0x030,SPTan(d0))
#pragma amicall(MathTransBase,0x036,SPSincos(d1,d0))
#pragma amicall(MathTransBase,0x03C,SPSinh(d0))
#pragma amicall(MathTransBase,0x042,SPCosh(d0))
#pragma amicall(MathTransBase,0x048,SPTanh(d0))
#pragma amicall(MathTransBase,0x04E,SPExp(d0))
#pragma amicall(MathTransBase,0x054,SPLog(d0))
#pragma amicall(MathTransBase,0x05A,SPPow(d1,d0))
#pragma amicall(MathTransBase,0x060,SPSqrt(d0))
#pragma amicall(MathTransBase,0x066,SPTieee(d0))
#pragma amicall(MathTransBase,0x06C,SPFieee(d0))
#pragma amicall(MathTransBase,0x072,SPAsin(d0))
#pragma amicall(MathTransBase,0x078,SPAcos(d0))
#pragma amicall(MathTransBase,0x07E,SPLog10(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathTransBase SPAtan               01E 001
#pragma  libcall MathTransBase SPSin                024 001
#pragma  libcall MathTransBase SPCos                02A 001
#pragma  libcall MathTransBase SPTan                030 001
#pragma  libcall MathTransBase SPSincos             036 0102
#pragma  libcall MathTransBase SPSinh               03C 001
#pragma  libcall MathTransBase SPCosh               042 001
#pragma  libcall MathTransBase SPTanh               048 001
#pragma  libcall MathTransBase SPExp                04E 001
#pragma  libcall MathTransBase SPLog                054 001
#pragma  libcall MathTransBase SPPow                05A 0102
#pragma  libcall MathTransBase SPSqrt               060 001
#pragma  libcall MathTransBase SPTieee              066 001
#pragma  libcall MathTransBase SPFieee              06C 001
#pragma  libcall MathTransBase SPAsin               072 001
#pragma  libcall MathTransBase SPAcos               078 001
#pragma  libcall MathTransBase SPLog10              07E 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHTRANS_LIB_H  */
