#ifndef _INCLUDE_PRAGMA_EXPANSION_LIB_H
#define _INCLUDE_PRAGMA_EXPANSION_LIB_H

#ifndef CLIB_EXPANSION_PROTOS_H
#include <clib/expansion_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/expansion.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(ExpansionBase,0x01E,AddConfigDev(a0))
#pragma amicall(ExpansionBase,0x024,AddBootNode(d0,d1,a0,a1))
#pragma amicall(ExpansionBase,0x02A,AllocBoardMem(d0))
#pragma amicall(ExpansionBase,0x030,AllocConfigDev())
#pragma amicall(ExpansionBase,0x036,AllocExpansionMem(d0,d1))
#pragma amicall(ExpansionBase,0x03C,ConfigBoard(a0,a1))
#pragma amicall(ExpansionBase,0x042,ConfigChain(a0))
#pragma amicall(ExpansionBase,0x048,FindConfigDev(a0,d0,d1))
#pragma amicall(ExpansionBase,0x04E,FreeBoardMem(d0,d1))
#pragma amicall(ExpansionBase,0x054,FreeConfigDev(a0))
#pragma amicall(ExpansionBase,0x05A,FreeExpansionMem(d0,d1))
#pragma amicall(ExpansionBase,0x060,ReadExpansionByte(a0,d0))
#pragma amicall(ExpansionBase,0x066,ReadExpansionRom(a0,a1))
#pragma amicall(ExpansionBase,0x06C,RemConfigDev(a0))
#pragma amicall(ExpansionBase,0x072,WriteExpansionByte(a0,d0,d1))
#pragma amicall(ExpansionBase,0x078,ObtainConfigBinding())
#pragma amicall(ExpansionBase,0x07E,ReleaseConfigBinding())
#pragma amicall(ExpansionBase,0x084,SetCurrentBinding(a0,d0))
#pragma amicall(ExpansionBase,0x08A,GetCurrentBinding(a0,d0))
#pragma amicall(ExpansionBase,0x090,MakeDosNode(a0))
#pragma amicall(ExpansionBase,0x096,AddDosNode(d0,d1,a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall ExpansionBase AddConfigDev         01E 801
#pragma  libcall ExpansionBase AddBootNode          024 981004
#pragma  libcall ExpansionBase AllocBoardMem        02A 001
#pragma  libcall ExpansionBase AllocConfigDev       030 00
#pragma  libcall ExpansionBase AllocExpansionMem    036 1002
#pragma  libcall ExpansionBase ConfigBoard          03C 9802
#pragma  libcall ExpansionBase ConfigChain          042 801
#pragma  libcall ExpansionBase FindConfigDev        048 10803
#pragma  libcall ExpansionBase FreeBoardMem         04E 1002
#pragma  libcall ExpansionBase FreeConfigDev        054 801
#pragma  libcall ExpansionBase FreeExpansionMem     05A 1002
#pragma  libcall ExpansionBase ReadExpansionByte    060 0802
#pragma  libcall ExpansionBase ReadExpansionRom     066 9802
#pragma  libcall ExpansionBase RemConfigDev         06C 801
#pragma  libcall ExpansionBase WriteExpansionByte   072 10803
#pragma  libcall ExpansionBase ObtainConfigBinding  078 00
#pragma  libcall ExpansionBase ReleaseConfigBinding 07E 00
#pragma  libcall ExpansionBase SetCurrentBinding    084 0802
#pragma  libcall ExpansionBase GetCurrentBinding    08A 0802
#pragma  libcall ExpansionBase MakeDosNode          090 801
#pragma  libcall ExpansionBase AddDosNode           096 81003
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_EXPANSION_LIB_H  */
