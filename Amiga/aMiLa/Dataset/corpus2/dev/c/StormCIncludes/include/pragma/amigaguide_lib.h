#ifndef _INCLUDE_PRAGMA_AMIGAGUIDE_LIB_H
#define _INCLUDE_PRAGMA_AMIGAGUIDE_LIB_H

#ifndef CLIB_AMIGAGUIDE_PROTOS_H
#include <clib/amigaguide_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/amigaguide.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(AmigaGuideBase,0x024,LockAmigaGuideBase(a0))
#pragma amicall(AmigaGuideBase,0x02A,UnlockAmigaGuideBase(d0))
#pragma amicall(AmigaGuideBase,0x036,OpenAmigaGuideA(a0,a1))
#pragma amicall(AmigaGuideBase,0x03C,OpenAmigaGuideAsyncA(a0,d0))
#pragma amicall(AmigaGuideBase,0x042,CloseAmigaGuide(a0))
#pragma amicall(AmigaGuideBase,0x048,AmigaGuideSignal(a0))
#pragma amicall(AmigaGuideBase,0x04E,GetAmigaGuideMsg(a0))
#pragma amicall(AmigaGuideBase,0x054,ReplyAmigaGuideMsg(a0))
#pragma amicall(AmigaGuideBase,0x05A,SetAmigaGuideContextA(a0,d0,d1))
#pragma amicall(AmigaGuideBase,0x060,SendAmigaGuideContextA(a0,d0))
#pragma amicall(AmigaGuideBase,0x066,SendAmigaGuideCmdA(a0,d0,d1))
#pragma amicall(AmigaGuideBase,0x06C,SetAmigaGuideAttrsA(a0,a1))
#pragma amicall(AmigaGuideBase,0x072,GetAmigaGuideAttr(d0,a0,a1))
#pragma amicall(AmigaGuideBase,0x07E,LoadXRef(a0,a1))
#pragma amicall(AmigaGuideBase,0x084,ExpungeXRef())
#pragma amicall(AmigaGuideBase,0x08A,AddAmigaGuideHostA(a0,d0,a1))
#pragma amicall(AmigaGuideBase,0x090,RemoveAmigaGuideHostA(a0,a1))
#pragma amicall(AmigaGuideBase,0x0D2,GetAmigaGuideString(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall AmigaGuideBase LockAmigaGuideBase   024 801
#pragma  libcall AmigaGuideBase UnlockAmigaGuideBase 02A 001
#pragma  libcall AmigaGuideBase OpenAmigaGuideA      036 9802
#pragma  libcall AmigaGuideBase OpenAmigaGuideAsyncA 03C 0802
#pragma  libcall AmigaGuideBase CloseAmigaGuide      042 801
#pragma  libcall AmigaGuideBase AmigaGuideSignal     048 801
#pragma  libcall AmigaGuideBase GetAmigaGuideMsg     04E 801
#pragma  libcall AmigaGuideBase ReplyAmigaGuideMsg   054 801
#pragma  libcall AmigaGuideBase SetAmigaGuideContextA 05A 10803
#pragma  libcall AmigaGuideBase SendAmigaGuideContextA 060 0802
#pragma  libcall AmigaGuideBase SendAmigaGuideCmdA   066 10803
#pragma  libcall AmigaGuideBase SetAmigaGuideAttrsA  06C 9802
#pragma  libcall AmigaGuideBase GetAmigaGuideAttr    072 98003
#pragma  libcall AmigaGuideBase LoadXRef             07E 9802
#pragma  libcall AmigaGuideBase ExpungeXRef          084 00
#pragma  libcall AmigaGuideBase AddAmigaGuideHostA   08A 90803
#pragma  libcall AmigaGuideBase RemoveAmigaGuideHostA 090 9802
#pragma  libcall AmigaGuideBase GetAmigaGuideString  0D2 001
#endif
#ifdef __STORM__
#pragma tagcall(AmigaGuideBase,0x036,OpenAmigaGuide(a0,a1))
#pragma tagcall(AmigaGuideBase,0x03C,OpenAmigaGuideAsync(a0,d0))
#pragma tagcall(AmigaGuideBase,0x05A,SetAmigaGuideContext(a0,d0,d1))
#pragma tagcall(AmigaGuideBase,0x060,SendAmigaGuideContext(a0,d0))
#pragma tagcall(AmigaGuideBase,0x066,SendAmigaGuideCmd(a0,d0,d1))
#pragma tagcall(AmigaGuideBase,0x06C,SetAmigaGuideAttrs(a0,a1))
#pragma tagcall(AmigaGuideBase,0x08A,AddAmigaGuideHost(a0,d0,a1))
#pragma tagcall(AmigaGuideBase,0x090,RemoveAmigaGuideHost(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall AmigaGuideBase OpenAmigaGuide       036 9802
#pragma  tagcall AmigaGuideBase OpenAmigaGuideAsync  03C 0802
#pragma  tagcall AmigaGuideBase SetAmigaGuideContext 05A 10803
#pragma  tagcall AmigaGuideBase SendAmigaGuideContext 060 0802
#pragma  tagcall AmigaGuideBase SendAmigaGuideCmd    066 10803
#pragma  tagcall AmigaGuideBase SetAmigaGuideAttrs   06C 9802
#pragma  tagcall AmigaGuideBase AddAmigaGuideHost    08A 90803
#pragma  tagcall AmigaGuideBase RemoveAmigaGuideHost 090 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_AMIGAGUIDE_LIB_H  */
