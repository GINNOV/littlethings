#ifndef _INCLUDE_PRAGMA_MATHIEEESINGTRANS_LIB_H
#define _INCLUDE_PRAGMA_MATHIEEESINGTRANS_LIB_H

#ifndef CLIB_MATHIEEESINGTRANS_PROTOS_H
#include <clib/mathieeesingtrans_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathieeesingtrans.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathIeeeSingTransBase,0x01E,IEEESPAtan(d0))
#pragma amicall(MathIeeeSingTransBase,0x024,IEEESPSin(d0))
#pragma amicall(MathIeeeSingTransBase,0x02A,IEEESPCos(d0))
#pragma amicall(MathIeeeSingTransBase,0x030,IEEESPTan(d0))
#pragma amicall(MathIeeeSingTransBase,0x036,IEEESPSincos(a0,d0))
#pragma amicall(MathIeeeSingTransBase,0x03C,IEEESPSinh(d0))
#pragma amicall(MathIeeeSingTransBase,0x042,IEEESPCosh(d0))
#pragma amicall(MathIeeeSingTransBase,0x048,IEEESPTanh(d0))
#pragma amicall(MathIeeeSingTransBase,0x04E,IEEESPExp(d0))
#pragma amicall(MathIeeeSingTransBase,0x054,IEEESPLog(d0))
#pragma amicall(MathIeeeSingTransBase,0x05A,IEEESPPow(d1,d0))
#pragma amicall(MathIeeeSingTransBase,0x060,IEEESPSqrt(d0))
#pragma amicall(MathIeeeSingTransBase,0x066,IEEESPTieee(d0))
#pragma amicall(MathIeeeSingTransBase,0x06C,IEEESPFieee(d0))
#pragma amicall(MathIeeeSingTransBase,0x072,IEEESPAsin(d0))
#pragma amicall(MathIeeeSingTransBase,0x078,IEEESPAcos(d0))
#pragma amicall(MathIeeeSingTransBase,0x07E,IEEESPLog10(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathIeeeSingTransBase IEEESPAtan           01E 001
#pragma  libcall MathIeeeSingTransBase IEEESPSin            024 001
#pragma  libcall MathIeeeSingTransBase IEEESPCos            02A 001
#pragma  libcall MathIeeeSingTransBase IEEESPTan            030 001
#pragma  libcall MathIeeeSingTransBase IEEESPSincos         036 0802
#pragma  libcall MathIeeeSingTransBase IEEESPSinh           03C 001
#pragma  libcall MathIeeeSingTransBase IEEESPCosh           042 001
#pragma  libcall MathIeeeSingTransBase IEEESPTanh           048 001
#pragma  libcall MathIeeeSingTransBase IEEESPExp            04E 001
#pragma  libcall MathIeeeSingTransBase IEEESPLog            054 001
#pragma  libcall MathIeeeSingTransBase IEEESPPow            05A 0102
#pragma  libcall MathIeeeSingTransBase IEEESPSqrt           060 001
#pragma  libcall MathIeeeSingTransBase IEEESPTieee          066 001
#pragma  libcall MathIeeeSingTransBase IEEESPFieee          06C 001
#pragma  libcall MathIeeeSingTransBase IEEESPAsin           072 001
#pragma  libcall MathIeeeSingTransBase IEEESPAcos           078 001
#pragma  libcall MathIeeeSingTransBase IEEESPLog10          07E 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHIEEESINGTRANS_LIB_H  */
