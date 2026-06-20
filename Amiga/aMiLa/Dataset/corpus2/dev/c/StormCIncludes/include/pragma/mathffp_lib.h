#ifndef _INCLUDE_PRAGMA_MATHFFP_LIB_H
#define _INCLUDE_PRAGMA_MATHFFP_LIB_H

#ifndef CLIB_MATHFFP_PROTOS_H
#include <clib/mathffp_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/mathffp.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MathBase,0x01E,SPFix(d0))
#pragma amicall(MathBase,0x024,SPFlt(d0))
#pragma amicall(MathBase,0x02A,SPCmp(d1,d0))
#pragma amicall(MathBase,0x030,SPTst(d1))
#pragma amicall(MathBase,0x036,SPAbs(d0))
#pragma amicall(MathBase,0x03C,SPNeg(d0))
#pragma amicall(MathBase,0x042,SPAdd(d1,d0))
#pragma amicall(MathBase,0x048,SPSub(d1,d0))
#pragma amicall(MathBase,0x04E,SPMul(d1,d0))
#pragma amicall(MathBase,0x054,SPDiv(d1,d0))
#pragma amicall(MathBase,0x05A,SPFloor(d0))
#pragma amicall(MathBase,0x060,SPCeil(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MathBase SPFix                01E 001
#pragma  libcall MathBase SPFlt                024 001
#pragma  libcall MathBase SPCmp                02A 0102
#pragma  libcall MathBase SPTst                030 101
#pragma  libcall MathBase SPAbs                036 001
#pragma  libcall MathBase SPNeg                03C 001
#pragma  libcall MathBase SPAdd                042 0102
#pragma  libcall MathBase SPSub                048 0102
#pragma  libcall MathBase SPMul                04E 0102
#pragma  libcall MathBase SPDiv                054 0102
#pragma  libcall MathBase SPFloor              05A 001
#pragma  libcall MathBase SPCeil               060 001
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_MATHFFP_LIB_H  */
