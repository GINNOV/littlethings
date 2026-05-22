#ifndef _INCLUDE_PRAGMA_CARDRES_LIB_H
#define _INCLUDE_PRAGMA_CARDRES_LIB_H

#ifndef CLIB_CARDRES_PROTOS_H
#include <clib/cardres_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/cardres.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(CardResource,0x006,OwnCard(a1))
#pragma amicall(CardResource,0x00C,ReleaseCard(a1,d0))
#pragma amicall(CardResource,0x012,GetCardMap())
#pragma amicall(CardResource,0x018,BeginCardAccess(a1))
#pragma amicall(CardResource,0x01E,EndCardAccess(a1))
#pragma amicall(CardResource,0x024,ReadCardStatus())
#pragma amicall(CardResource,0x02A,CardResetRemove(a1,d0))
#pragma amicall(CardResource,0x030,CardMiscControl(a1,d1))
#pragma amicall(CardResource,0x036,CardAccessSpeed(a1,d0))
#pragma amicall(CardResource,0x03C,CardProgramVoltage(a1,d0))
#pragma amicall(CardResource,0x042,CardResetCard(a1))
#pragma amicall(CardResource,0x048,CopyTuple(a1,a0,d1,d0))
#pragma amicall(CardResource,0x04E,DeviceTuple(a0,a1))
#pragma amicall(CardResource,0x054,IfAmigaXIP(a2))
#pragma amicall(CardResource,0x05A,CardForceChange())
#pragma amicall(CardResource,0x060,CardChangeCount())
#pragma amicall(CardResource,0x066,CardInterface())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall CardResource OwnCard              006 901
#pragma  libcall CardResource ReleaseCard          00C 0902
#pragma  libcall CardResource GetCardMap           012 00
#pragma  libcall CardResource BeginCardAccess      018 901
#pragma  libcall CardResource EndCardAccess        01E 901
#pragma  libcall CardResource ReadCardStatus       024 00
#pragma  libcall CardResource CardResetRemove      02A 0902
#pragma  libcall CardResource CardMiscControl      030 1902
#pragma  libcall CardResource CardAccessSpeed      036 0902
#pragma  libcall CardResource CardProgramVoltage   03C 0902
#pragma  libcall CardResource CardResetCard        042 901
#pragma  libcall CardResource CopyTuple            048 018904
#pragma  libcall CardResource DeviceTuple          04E 9802
#pragma  libcall CardResource IfAmigaXIP           054 A01
#pragma  libcall CardResource CardForceChange      05A 00
#pragma  libcall CardResource CardChangeCount      060 00
#pragma  libcall CardResource CardInterface        066 00
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_CARDRES_LIB_H  */
