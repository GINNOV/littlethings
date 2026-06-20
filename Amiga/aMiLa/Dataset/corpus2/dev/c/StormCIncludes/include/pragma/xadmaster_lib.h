#ifndef _INCLUDE_PRAGMA_XADMASTER_LIB_H
#define _INCLUDE_PRAGMA_XADMASTER_LIB_H

#ifndef CLIB_XADMASTER_PROTOS_H
#include <clib/xadmaster_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/xadmaster.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(xadMasterBase,0x01E,xadAllocObjectA(d0,a0))
#pragma amicall(xadMasterBase,0x024,xadFreeObjectA(a0,a1))
#pragma amicall(xadMasterBase,0x02A,xadRecogFileA(d0,a0,a1))
#pragma amicall(xadMasterBase,0x030,xadGetInfoA(a0,a1))
#pragma amicall(xadMasterBase,0x036,xadFreeInfo(a0))
#pragma amicall(xadMasterBase,0x03C,xadFileUnArcA(a0,a1))
#pragma amicall(xadMasterBase,0x042,xadDiskUnArcA(a0,a1))
#pragma amicall(xadMasterBase,0x048,xadGetErrorText(d0))
#pragma amicall(xadMasterBase,0x04E,xadGetClientInfo())
#pragma amicall(xadMasterBase,0x054,xadHookAccess(d0,d1,a0,a1))
#pragma amicall(xadMasterBase,0x05A,xadConvertDatesA(a0))
#pragma amicall(xadMasterBase,0x060,xadCalcCRC16(d0,d1,d2,a0))
#pragma amicall(xadMasterBase,0x066,xadCalcCRC32(d0,d1,d2,a0))
#pragma amicall(xadMasterBase,0x06C,xadAllocVec(d0,d1))
#pragma amicall(xadMasterBase,0x072,xadCopyMem(a0,a1,d0))
#pragma amicall(xadMasterBase,0x078,xadHookTagAccessA(d0,d1,a0,a1,a2))
#pragma amicall(xadMasterBase,0x07E,xadConvertProtectionA(a0))
#pragma amicall(xadMasterBase,0x084,xadGetDiskInfoA(a0,a1))
#pragma amicall(xadMasterBase,0x08A,xadDiskFileUnArcA(a0,a1))
#pragma amicall(xadMasterBase,0x090,xadGetHookAccessA(a0,a1))
#pragma amicall(xadMasterBase,0x096,xadFreeHookAccessA(a0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall xadMasterBase xadAllocObjectA      01E 8002
#pragma  libcall xadMasterBase xadFreeObjectA       024 9802
#pragma  libcall xadMasterBase xadRecogFileA        02A 98003
#pragma  libcall xadMasterBase xadGetInfoA          030 9802
#pragma  libcall xadMasterBase xadFreeInfo          036 801
#pragma  libcall xadMasterBase xadFileUnArcA        03C 9802
#pragma  libcall xadMasterBase xadDiskUnArcA        042 9802
#pragma  libcall xadMasterBase xadGetErrorText      048 001
#pragma  libcall xadMasterBase xadGetClientInfo     04E 00
#pragma  libcall xadMasterBase xadHookAccess        054 981004
#pragma  libcall xadMasterBase xadConvertDatesA     05A 801
#pragma  libcall xadMasterBase xadCalcCRC16         060 821004
#pragma  libcall xadMasterBase xadCalcCRC32         066 821004
#pragma  libcall xadMasterBase xadAllocVec          06C 1002
#pragma  libcall xadMasterBase xadCopyMem           072 09803
#pragma  libcall xadMasterBase xadHookTagAccessA    078 A981005
#pragma  libcall xadMasterBase xadConvertProtectionA 07E 801
#pragma  libcall xadMasterBase xadGetDiskInfoA      084 9802
#pragma  libcall xadMasterBase xadDiskFileUnArcA    08A 9802
#pragma  libcall xadMasterBase xadGetHookAccessA    090 9802
#pragma  libcall xadMasterBase xadFreeHookAccessA   096 9802
#endif
#ifdef __STORM__
#pragma tagcall(xadMasterBase,0x01E,xadAllocObject(d0,a0))
#pragma tagcall(xadMasterBase,0x024,xadFreeObject(a0,a1))
#pragma tagcall(xadMasterBase,0x02A,xadRecogFile(d0,a0,a1))
#pragma tagcall(xadMasterBase,0x030,xadGetInfo(a0,a1))
#pragma tagcall(xadMasterBase,0x03C,xadFileUnArc(a0,a1))
#pragma tagcall(xadMasterBase,0x042,xadDiskUnArc(a0,a1))
#pragma tagcall(xadMasterBase,0x05A,xadConvertDates(a0))
#pragma tagcall(xadMasterBase,0x078,xadHookTagAccess(d0,d1,a0,a1,a2))
#pragma tagcall(xadMasterBase,0x07E,xadConvertProtection(a0))
#pragma tagcall(xadMasterBase,0x084,xadGetDiskInfo(a0,a1))
#pragma tagcall(xadMasterBase,0x08A,xadDiskFileUnArc(a0,a1))
#pragma tagcall(xadMasterBase,0x090,xadGetHookAccess(a0,a1))
#pragma tagcall(xadMasterBase,0x096,xadFreeHookAccess(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall xadMasterBase xadAllocObject       01E 8002
#pragma  tagcall xadMasterBase xadFreeObject        024 9802
#pragma  tagcall xadMasterBase xadRecogFile         02A 98003
#pragma  tagcall xadMasterBase xadGetInfo           030 9802
#pragma  tagcall xadMasterBase xadFileUnArc         03C 9802
#pragma  tagcall xadMasterBase xadDiskUnArc         042 9802
#pragma  tagcall xadMasterBase xadConvertDates      05A 801
#pragma  tagcall xadMasterBase xadHookTagAccess     078 A981005
#pragma  tagcall xadMasterBase xadConvertProtection 07E 801
#pragma  tagcall xadMasterBase xadGetDiskInfo       084 9802
#pragma  tagcall xadMasterBase xadDiskFileUnArc     08A 9802
#pragma  tagcall xadMasterBase xadGetHookAccess     090 9802
#pragma  tagcall xadMasterBase xadFreeHookAccess    096 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_XADMASTER_LIB_H  */
