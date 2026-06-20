#ifndef _INCLUDE_PRAGMA_POWERPC_LIB_H
#define _INCLUDE_PRAGMA_POWERPC_LIB_H

#ifndef CLIB_POWERPC_PROTOS_H
#include <clib/powerpc_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/powerpc.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(PowerPCBase,0x01E,RunPPC(a0))
#pragma amicall(PowerPCBase,0x024,WaitForPPC(a0))
#pragma amicall(PowerPCBase,0x02A,GetCPU())
#pragma amicall(PowerPCBase,0x030,PowerDebugMode(d0))
#pragma amicall(PowerPCBase,0x036,AllocVec32(d0,d1))
#pragma amicall(PowerPCBase,0x03C,FreeVec32(a1))
#pragma amicall(PowerPCBase,0x042,SPrintF68K(a0,a1))
#pragma amicall(PowerPCBase,0x048,AllocXMsg(d0,a0))
#pragma amicall(PowerPCBase,0x04E,FreeXMsg(a0))
#pragma amicall(PowerPCBase,0x054,PutXMsg(a0,a1))
#pragma amicall(PowerPCBase,0x05A,GetPPCState())
#pragma amicall(PowerPCBase,0x060,SetCache68K(d0,a0,d1))
#pragma amicall(PowerPCBase,0x066,CreatePPCTask(a0))
#pragma amicall(PowerPCBase,0x06C,CausePPCInterrupt())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall PowerPCBase RunPPC               01E 801
#pragma  libcall PowerPCBase WaitForPPC           024 801
#pragma  libcall PowerPCBase GetCPU               02A 00
#pragma  libcall PowerPCBase PowerDebugMode       030 001
#pragma  libcall PowerPCBase AllocVec32           036 1002
#pragma  libcall PowerPCBase FreeVec32            03C 901
#pragma  libcall PowerPCBase SPrintF68K           042 9802
#pragma  libcall PowerPCBase AllocXMsg            048 8002
#pragma  libcall PowerPCBase FreeXMsg             04E 801
#pragma  libcall PowerPCBase PutXMsg              054 9802
#pragma  libcall PowerPCBase GetPPCState          05A 00
#pragma  libcall PowerPCBase SetCache68K          060 18003
#pragma  libcall PowerPCBase CreatePPCTask        066 801
#pragma  libcall PowerPCBase CausePPCInterrupt    06C 00
#endif
#ifdef __STORM__
#pragma tagcall(PowerPCBase,0x066,CreatePPCTaskTags(a0))
#endif
#ifdef __SASC_60
#pragma  tagcall PowerPCBase CreatePPCTaskTags    066 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_POWERPC_LIB_H  */
