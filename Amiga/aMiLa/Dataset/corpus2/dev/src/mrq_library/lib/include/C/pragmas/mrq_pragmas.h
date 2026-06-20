#ifndef _INCLUDE_PRAGMA_MRQ_PRAGMAS_H
#define _INCLUDE_PRAGMA_MRQ_PRAGMAS_H

#ifndef CLIB_MRQ_PROTOS_H
#include <clib/mrq_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(MisterQLibBase,0x01E,ClearR())
#pragma amicall(MisterQLibBase,0x024,MisterQInit())
#pragma amicall(MisterQLibBase,0x02A,MisterQCleanUp(a0))
#pragma amicall(MisterQLibBase,0x030,MRequest(a1,a5))
#pragma amicall(MisterQLibBase,0x036,MLoadFile(a0,a5,d0))
#pragma amicall(MisterQLibBase,0x03C,MFreeFile(a0,a5))
#pragma amicall(MisterQLibBase,0x042,MSaveFile(a0,a5,a1,d0))
#pragma amicall(MisterQLibBase,0x048,CopyBytes(a0,a1,d1))
#pragma amicall(MisterQLibBase,0x04E,MCloseScreen(a5,a0))
#pragma amicall(MisterQLibBase,0x054,MOpenScreen(a5,d0,d1,d2,a0))
#pragma amicall(MisterQLibBase,0x05A,C2P(a5,a0,d0,d1,d2,d3))
#pragma amicall(MisterQLibBase,0x060,AslFILERequest(a0,a5))
#pragma amicall(MisterQLibBase,0x066,AslFreeFILERequest(a0))
#pragma amicall(MisterQLibBase,0x06C,DecConvert(d0,a5))
#pragma amicall(MisterQLibBase,0x072,HexConvert(d0,a5))
#pragma amicall(MisterQLibBase,0x078,RomanConvert(d0,a5))
#pragma amicall(MisterQLibBase,0x07E,Rnd(d0,a5))
#pragma amicall(MisterQLibBase,0x084,WyswTXT(d0,d1,a0,a5))
#pragma amicall(MisterQLibBase,0x08A,GetMessage(a0,a5))
#pragma amicall(MisterQLibBase,0x090,P2C(a0,a1,d0,d1,a5))
#pragma amicall(MisterQLibBase,0x096,SearchW(a0,d0,a1,d1))
#pragma amicall(MisterQLibBase,0x09C,GetDynamicMessage(a0,a5))
#pragma amicall(MisterQLibBase,0x0A2,DoubleBuffer(a0,d0,d1,d2,d3,a5))
#pragma amicall(MisterQLibBase,0x0A8,GetFPS())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall MisterQLibBase ClearR               01E 00
#pragma  libcall MisterQLibBase MisterQInit          024 00
#pragma  libcall MisterQLibBase MisterQCleanUp       02A 801
#pragma  libcall MisterQLibBase MRequest             030 D902
#pragma  libcall MisterQLibBase MLoadFile            036 0D803
#pragma  libcall MisterQLibBase MFreeFile            03C D802
#pragma  libcall MisterQLibBase MSaveFile            042 09D804
#pragma  libcall MisterQLibBase CopyBytes            048 19803
#pragma  libcall MisterQLibBase MCloseScreen         04E 8D02
#pragma  libcall MisterQLibBase MOpenScreen          054 8210D05
#pragma  libcall MisterQLibBase C2P                  05A 32108D06
#pragma  libcall MisterQLibBase AslFILERequest       060 D802
#pragma  libcall MisterQLibBase AslFreeFILERequest   066 801
#pragma  libcall MisterQLibBase DecConvert           06C D002
#pragma  libcall MisterQLibBase HexConvert           072 D002
#pragma  libcall MisterQLibBase RomanConvert         078 D002
#pragma  libcall MisterQLibBase Rnd                  07E D002
#pragma  libcall MisterQLibBase WyswTXT              084 D81004
#pragma  libcall MisterQLibBase GetMessage           08A D802
#pragma  libcall MisterQLibBase P2C                  090 D109805
#pragma  libcall MisterQLibBase SearchW              096 190804
#pragma  libcall MisterQLibBase GetDynamicMessage    09C D802
#pragma  libcall MisterQLibBase DoubleBuffer         0A2 D3210806
#pragma  libcall MisterQLibBase GetFPS               0A8 00
#endif

#endif	/*  _INCLUDE_PRAGMA_MRQ_PRAGMAS_H  */
