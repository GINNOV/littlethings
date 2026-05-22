#ifndef _INCLUDE_PRAGMA_DATATYPES_LIB_H
#define _INCLUDE_PRAGMA_DATATYPES_LIB_H

#ifndef CLIB_DATATYPES_PROTOS_H
#include <clib/datatypes_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/datatypes.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(DataTypesBase,0x024,ObtainDataTypeA(d0,a0,a1))
#pragma amicall(DataTypesBase,0x02A,ReleaseDataType(a0))
#pragma amicall(DataTypesBase,0x030,NewDTObjectA(d0,a0))
#pragma amicall(DataTypesBase,0x036,DisposeDTObject(a0))
#pragma amicall(DataTypesBase,0x03C,SetDTAttrsA(a0,a1,a2,a3))
#pragma amicall(DataTypesBase,0x042,GetDTAttrsA(a0,a2))
#pragma amicall(DataTypesBase,0x048,AddDTObject(a0,a1,a2,d0))
#pragma amicall(DataTypesBase,0x04E,RefreshDTObjectA(a0,a1,a2,a3))
#pragma amicall(DataTypesBase,0x054,DoAsyncLayout(a0,a1))
#pragma amicall(DataTypesBase,0x05A,DoDTMethodA(a0,a1,a2,a3))
#pragma amicall(DataTypesBase,0x060,RemoveDTObject(a0,a1))
#pragma amicall(DataTypesBase,0x066,GetDTMethods(a0))
#pragma amicall(DataTypesBase,0x06C,GetDTTriggerMethods(a0))
#pragma amicall(DataTypesBase,0x072,PrintDTObjectA(a0,a1,a2,a3))
#pragma amicall(DataTypesBase,0x078,ObtainDTDrawInfoA(a0,a1))
#pragma amicall(DataTypesBase,0x07E,DrawDTObjectA(a0,a1,d0,d1,d2,d3,d4,d5,a2))
#pragma amicall(DataTypesBase,0x084,ReleaseDTDrawInfo(a0,a1))
#pragma amicall(DataTypesBase,0x08A,GetDTString(d0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall DataTypesBase ObtainDataTypeA      024 98003
#pragma  libcall DataTypesBase ReleaseDataType      02A 801
#pragma  libcall DataTypesBase NewDTObjectA         030 8002
#pragma  libcall DataTypesBase DisposeDTObject      036 801
#pragma  libcall DataTypesBase SetDTAttrsA          03C BA9804
#pragma  libcall DataTypesBase GetDTAttrsA          042 A802
#pragma  libcall DataTypesBase AddDTObject          048 0A9804
#pragma  libcall DataTypesBase RefreshDTObjectA     04E BA9804
#pragma  libcall DataTypesBase DoAsyncLayout        054 9802
#pragma  libcall DataTypesBase DoDTMethodA          05A BA9804
#pragma  libcall DataTypesBase RemoveDTObject       060 9802
#pragma  libcall DataTypesBase GetDTMethods         066 801
#pragma  libcall DataTypesBase GetDTTriggerMethods  06C 801
#pragma  libcall DataTypesBase PrintDTObjectA       072 BA9804
#pragma  libcall DataTypesBase ObtainDTDrawInfoA    078 9802
#pragma  libcall DataTypesBase DrawDTObjectA        07E A5432109809
#pragma  libcall DataTypesBase ReleaseDTDrawInfo    084 9802
#pragma  libcall DataTypesBase GetDTString          08A 001
#endif
#ifdef __STORM__
#pragma tagcall(DataTypesBase,0x024,ObtainDataType(d0,a0,a1))
#pragma tagcall(DataTypesBase,0x030,NewDTObject(d0,a0))
#pragma tagcall(DataTypesBase,0x03C,SetDTAttrs(a0,a1,a2,a3))
#pragma tagcall(DataTypesBase,0x042,GetDTAttrs(a0,a2))
#pragma tagcall(DataTypesBase,0x04E,RefreshDTObject(a0,a1,a2,a3))
#pragma tagcall(DataTypesBase,0x04E,RefreshDTObjects(a0,a1,a2,a3))
#pragma tagcall(DataTypesBase,0x05A,DoDTMethod(a0,a1,a2,a3))
#pragma tagcall(DataTypesBase,0x072,PrintDTObject(a0,a1,a2,a3))
#pragma tagcall(DataTypesBase,0x078,ObtainDTDrawInfo(a0,a1))
#pragma tagcall(DataTypesBase,0x07E,DrawDTObject(a0,a1,d0,d1,d2,d3,d4,d5,a2))
#endif
#ifdef __SASC_60
#pragma  tagcall DataTypesBase ObtainDataType       024 98003
#pragma  tagcall DataTypesBase NewDTObject          030 8002
#pragma  tagcall DataTypesBase SetDTAttrs           03C BA9804
#pragma  tagcall DataTypesBase GetDTAttrs           042 A802
#pragma  tagcall DataTypesBase RefreshDTObject      04E BA9804
#pragma  tagcall DataTypesBase RefreshDTObjects     04E BA9804
#pragma  tagcall DataTypesBase DoDTMethod           05A BA9804
#pragma  tagcall DataTypesBase PrintDTObject        072 BA9804
#pragma  tagcall DataTypesBase ObtainDTDrawInfo     078 9802
#pragma  tagcall DataTypesBase DrawDTObject         07E A5432109809
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_DATATYPES_LIB_H  */
