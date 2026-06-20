#ifndef _INCLUDE_PRAGMA_UTILITY_LIB_H
#define _INCLUDE_PRAGMA_UTILITY_LIB_H

#ifndef CLIB_UTILITY_PROTOS_H
#include <clib/utility_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/utility.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(UtilityBase,0x01E,FindTagItem(d0,a0))
#pragma amicall(UtilityBase,0x024,GetTagData(d0,d1,a0))
#pragma amicall(UtilityBase,0x02A,PackBoolTags(d0,a0,a1))
#pragma amicall(UtilityBase,0x030,NextTagItem(a0))
#pragma amicall(UtilityBase,0x036,FilterTagChanges(a0,a1,d0))
#pragma amicall(UtilityBase,0x03C,MapTags(a0,a1,d0))
#pragma amicall(UtilityBase,0x042,AllocateTagItems(d0))
#pragma amicall(UtilityBase,0x048,CloneTagItems(a0))
#pragma amicall(UtilityBase,0x04E,FreeTagItems(a0))
#pragma amicall(UtilityBase,0x054,RefreshTagItemClones(a0,a1))
#pragma amicall(UtilityBase,0x05A,TagInArray(d0,a0))
#pragma amicall(UtilityBase,0x060,FilterTagItems(a0,a1,d0))
#pragma amicall(UtilityBase,0x066,CallHookPkt(a0,a2,a1))
#pragma amicall(UtilityBase,0x078,Amiga2Date(d0,a0))
#pragma amicall(UtilityBase,0x07E,Date2Amiga(a0))
#pragma amicall(UtilityBase,0x084,CheckDate(a0))
#pragma amicall(UtilityBase,0x08A,SMult32(d0,d1))
#pragma amicall(UtilityBase,0x090,UMult32(d0,d1))
#pragma amicall(UtilityBase,0x096,SDivMod32(d0,d1))
#pragma amicall(UtilityBase,0x09C,UDivMod32(d0,d1))
#pragma amicall(UtilityBase,0x0A2,Stricmp(a0,a1))
#pragma amicall(UtilityBase,0x0A8,Strnicmp(a0,a1,d0))
#pragma amicall(UtilityBase,0x0AE,ToUpper(d0))
#pragma amicall(UtilityBase,0x0B4,ToLower(d0))
#pragma amicall(UtilityBase,0x0BA,ApplyTagChanges(a0,a1))
#pragma amicall(UtilityBase,0x0C6,SMult64(d0,d1))
#pragma amicall(UtilityBase,0x0CC,UMult64(d0,d1))
#pragma amicall(UtilityBase,0x0D2,PackStructureTags(a0,a1,a2))
#pragma amicall(UtilityBase,0x0D8,UnpackStructureTags(a0,a1,a2))
#pragma amicall(UtilityBase,0x0DE,AddNamedObject(a0,a1))
#pragma amicall(UtilityBase,0x0E4,AllocNamedObjectA(a0,a1))
#pragma amicall(UtilityBase,0x0EA,AttemptRemNamedObject(a0))
#pragma amicall(UtilityBase,0x0F0,FindNamedObject(a0,a1,a2))
#pragma amicall(UtilityBase,0x0F6,FreeNamedObject(a0))
#pragma amicall(UtilityBase,0x0FC,NamedObjectName(a0))
#pragma amicall(UtilityBase,0x102,ReleaseNamedObject(a0))
#pragma amicall(UtilityBase,0x108,RemNamedObject(a0,a1))
#pragma amicall(UtilityBase,0x10E,GetUniqueID())
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall UtilityBase FindTagItem          01E 8002
#pragma  libcall UtilityBase GetTagData           024 81003
#pragma  libcall UtilityBase PackBoolTags         02A 98003
#pragma  libcall UtilityBase NextTagItem          030 801
#pragma  libcall UtilityBase FilterTagChanges     036 09803
#pragma  libcall UtilityBase MapTags              03C 09803
#pragma  libcall UtilityBase AllocateTagItems     042 001
#pragma  libcall UtilityBase CloneTagItems        048 801
#pragma  libcall UtilityBase FreeTagItems         04E 801
#pragma  libcall UtilityBase RefreshTagItemClones 054 9802
#pragma  libcall UtilityBase TagInArray           05A 8002
#pragma  libcall UtilityBase FilterTagItems       060 09803
#pragma  libcall UtilityBase CallHookPkt          066 9A803
#pragma  libcall UtilityBase Amiga2Date           078 8002
#pragma  libcall UtilityBase Date2Amiga           07E 801
#pragma  libcall UtilityBase CheckDate            084 801
#pragma  libcall UtilityBase SMult32              08A 1002
#pragma  libcall UtilityBase UMult32              090 1002
#pragma  libcall UtilityBase SDivMod32            096 1002
#pragma  libcall UtilityBase UDivMod32            09C 1002
#pragma  libcall UtilityBase Stricmp              0A2 9802
#pragma  libcall UtilityBase Strnicmp             0A8 09803
#pragma  libcall UtilityBase ToUpper              0AE 001
#pragma  libcall UtilityBase ToLower              0B4 001
#pragma  libcall UtilityBase ApplyTagChanges      0BA 9802
#pragma  libcall UtilityBase SMult64              0C6 1002
#pragma  libcall UtilityBase UMult64              0CC 1002
#pragma  libcall UtilityBase PackStructureTags    0D2 A9803
#pragma  libcall UtilityBase UnpackStructureTags  0D8 A9803
#pragma  libcall UtilityBase AddNamedObject       0DE 9802
#pragma  libcall UtilityBase AllocNamedObjectA    0E4 9802
#pragma  libcall UtilityBase AttemptRemNamedObject 0EA 801
#pragma  libcall UtilityBase FindNamedObject      0F0 A9803
#pragma  libcall UtilityBase FreeNamedObject      0F6 801
#pragma  libcall UtilityBase NamedObjectName      0FC 801
#pragma  libcall UtilityBase ReleaseNamedObject   102 801
#pragma  libcall UtilityBase RemNamedObject       108 9802
#pragma  libcall UtilityBase GetUniqueID          10E 00
#endif
#ifdef __STORM__
#pragma tagcall(UtilityBase,0x0E4,AllocNamedObject(a0,a1))
#endif
#ifdef __SASC_60
#pragma  tagcall UtilityBase AllocNamedObject     0E4 9802
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_UTILITY_LIB_H  */
