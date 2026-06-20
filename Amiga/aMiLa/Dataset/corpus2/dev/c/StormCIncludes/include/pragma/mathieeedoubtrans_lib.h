#ifndef _INCLUDE_PRAGMA_MATHIEEEDOUBTRANS_LIB_H
#define _INCLUDE_PRAGMA_MATHIEEEDOUBTRANS_LIB_H

#ifndef CLIB_MATHIEEEDOUBTRANS_PROTOS_H
#include <clib/mathieeedoubtrans_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathieeedoubtrans.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathIeeeDoubTransBase,0x01E,IEEEDPAtan(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x024,IEEEDPSin(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x02A,IEEEDPCos(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x030,IEEEDPTan(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x036,IEEEDPSincos(a0,d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x03C,IEEEDPSinh(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x042,IEEEDPCosh(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x048,IEEEDPTanh(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x04E,IEEEDPExp(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x054,IEEEDPLog(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x05A,IEEEDPPow(d2,d3,d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x060,IEEEDPSqrt(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x066,IEEEDPTieee(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x06C,IEEEDPFieee(d0))
#pragma amicall(MathIeeeDoubTransBase,0x072,IEEEDPAsin(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x078,IEEEDPAcos(d0,d1))
#pragma amicall(MathIeeeDoubTransBase,0x07E,IEEEDPLog10(d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathIeeeDoubTransBase IEEEDPAtan           01E 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPSin            024 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPCos            02A 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPTan            030 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPSincos         036 10803
#pragma  libcall MathIeeeDoubTransBase IEEEDPSinh           03C 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPCosh           042 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPTanh           048 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPExp            04E 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPLog            054 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPPow            05A 103204
#pragma  libcall MathIeeeDoubTransBase IEEEDPSqrt           060 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPTieee          066 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPFieee          06C 001
#pragma  libcall MathIeeeDoubTransBase IEEEDPAsin           072 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPAcos           078 1002
#pragma  libcall MathIeeeDoubTransBase IEEEDPLog10          07E 1002
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHIEEEDOUBTRANS_LIB_H  */
