#ifndef _INCLUDE_PRAGMA_MATHIEEESINGBAS_LIB_H
#define _INCLUDE_PRAGMA_MATHIEEESINGBAS_LIB_H

#ifndef CLIB_MATHIEEESINGBAS_PROTOS_H
#include <clib/mathieeesingbas_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathieeesingbas.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathIeeeSingBasBase,0x01E,IEEESPFix(d0))
#pragma amicall(MathIeeeSingBasBase,0x024,IEEESPFlt(d0))
#pragma amicall(MathIeeeSingBasBase,0x02A,IEEESPCmp(d0,d1))
#pragma amicall(MathIeeeSingBasBase,0x030,IEEESPTst(d0))
#pragma amicall(MathIeeeSingBasBase,0x036,IEEESPAbs(d0))
#pragma amicall(MathIeeeSingBasBase,0x03C,IEEESPNeg(d0))
#pragma amicall(MathIeeeSingBasBase,0x042,IEEESPAdd(d0,d1))
#pragma amicall(MathIeeeSingBasBase,0x048,IEEESPSub(d0,d1))
#pragma amicall(MathIeeeSingBasBase,0x04E,IEEESPMul(d0,d1))
#pragma amicall(MathIeeeSingBasBase,0x054,IEEESPDiv(d0,d1))
#pragma amicall(MathIeeeSingBasBase,0x05A,IEEESPFloor(d0))
#pragma amicall(MathIeeeSingBasBase,0x060,IEEESPCeil(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathIeeeSingBasBase IEEESPFix            01E 001
#pragma  libcall MathIeeeSingBasBase IEEESPFlt            024 001
#pragma  libcall MathIeeeSingBasBase IEEESPCmp            02A 1002
#pragma  libcall MathIeeeSingBasBase IEEESPTst            030 001
#pragma  libcall MathIeeeSingBasBase IEEESPAbs            036 001
#pragma  libcall MathIeeeSingBasBase IEEESPNeg            03C 001
#pragma  libcall MathIeeeSingBasBase IEEESPAdd            042 1002
#pragma  libcall MathIeeeSingBasBase IEEESPSub            048 1002
#pragma  libcall MathIeeeSingBasBase IEEESPMul            04E 1002
#pragma  libcall MathIeeeSingBasBase IEEESPDiv            054 1002
#pragma  libcall MathIeeeSingBasBase IEEESPFloor          05A 001
#pragma  libcall MathIeeeSingBasBase IEEESPCeil           060 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHIEEESINGBAS_LIB_H  */
