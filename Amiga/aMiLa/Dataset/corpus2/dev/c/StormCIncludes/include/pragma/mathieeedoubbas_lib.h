#ifndef _INCLUDE_PRAGMA_MATHIEEEDOUBBAS_LIB_H
#define _INCLUDE_PRAGMA_MATHIEEEDOUBBAS_LIB_H

#ifndef CLIB_MATHIEEEDOUBBAS_PROTOS_H
#include <clib/mathieeedoubbas_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathieeedoubbas.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathIeeeDoubBasBase,0x01E,IEEEDPFix(d0,d1))
#pragma amicall(MathIeeeDoubBasBase,0x024,IEEEDPFlt(d0))
#pragma amicall(MathIeeeDoubBasBase,0x02A,IEEEDPCmp(d0,d1,d2,d3))
#pragma amicall(MathIeeeDoubBasBase,0x030,IEEEDPTst(d0,d1))
#pragma amicall(MathIeeeDoubBasBase,0x036,IEEEDPAbs(d0,d1))
#pragma amicall(MathIeeeDoubBasBase,0x03C,IEEEDPNeg(d0,d1))
#pragma amicall(MathIeeeDoubBasBase,0x042,IEEEDPAdd(d0,d1,d2,d3))
#pragma amicall(MathIeeeDoubBasBase,0x048,IEEEDPSub(d0,d1,d2,d3))
#pragma amicall(MathIeeeDoubBasBase,0x04E,IEEEDPMul(d0,d1,d2,d3))
#pragma amicall(MathIeeeDoubBasBase,0x054,IEEEDPDiv(d0,d1,d2,d3))
#pragma amicall(MathIeeeDoubBasBase,0x05A,IEEEDPFloor(d0,d1))
#pragma amicall(MathIeeeDoubBasBase,0x060,IEEEDPCeil(d0,d1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathIeeeDoubBasBase IEEEDPFix            01E 1002
#pragma  libcall MathIeeeDoubBasBase IEEEDPFlt            024 001
#pragma  libcall MathIeeeDoubBasBase IEEEDPCmp            02A 321004
#pragma  libcall MathIeeeDoubBasBase IEEEDPTst            030 1002
#pragma  libcall MathIeeeDoubBasBase IEEEDPAbs            036 1002
#pragma  libcall MathIeeeDoubBasBase IEEEDPNeg            03C 1002
#pragma  libcall MathIeeeDoubBasBase IEEEDPAdd            042 321004
#pragma  libcall MathIeeeDoubBasBase IEEEDPSub            048 321004
#pragma  libcall MathIeeeDoubBasBase IEEEDPMul            04E 321004
#pragma  libcall MathIeeeDoubBasBase IEEEDPDiv            054 321004
#pragma  libcall MathIeeeDoubBasBase IEEEDPFloor          05A 1002
#pragma  libcall MathIeeeDoubBasBase IEEEDPCeil           060 1002
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHIEEEDOUBBAS_LIB_H  */
