#ifndef _INCLUDE_PRAGMA_IFFPARSE_LIB_H
#define _INCLUDE_PRAGMA_IFFPARSE_LIB_H

#ifndef CLIB_IFFPARSE_PROTOS_H
#include <clib/iffparse_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/iffparse.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(IFFParseBase,0x01E,AllocIFF())
#pragma amicall(IFFParseBase,0x024,OpenIFF(a0,d0))
#pragma amicall(IFFParseBase,0x02A,ParseIFF(a0,d0))
#pragma amicall(IFFParseBase,0x030,CloseIFF(a0))
#pragma amicall(IFFParseBase,0x036,FreeIFF(a0))
#pragma amicall(IFFParseBase,0x03C,ReadChunkBytes(a0,a1,d0))
#pragma amicall(IFFParseBase,0x042,WriteChunkBytes(a0,a1,d0))
#pragma amicall(IFFParseBase,0x048,ReadChunkRecords(a0,a1,d0,d1))
#pragma amicall(IFFParseBase,0x04E,WriteChunkRecords(a0,a1,d0,d1))
#pragma amicall(IFFParseBase,0x054,PushChunk(a0,d0,d1,d2))
#pragma amicall(IFFParseBase,0x05A,PopChunk(a0))
#pragma amicall(IFFParseBase,0x066,EntryHandler(a0,d0,d1,d2,a1,a2))
#pragma amicall(IFFParseBase,0x06C,ExitHandler(a0,d0,d1,d2,a1,a2))
#pragma amicall(IFFParseBase,0x072,PropChunk(a0,d0,d1))
#pragma amicall(IFFParseBase,0x078,PropChunks(a0,a1,d0))
#pragma amicall(IFFParseBase,0x07E,StopChunk(a0,d0,d1))
#pragma amicall(IFFParseBase,0x084,StopChunks(a0,a1,d0))
#pragma amicall(IFFParseBase,0x08A,CollectionChunk(a0,d0,d1))
#pragma amicall(IFFParseBase,0x090,CollectionChunks(a0,a1,d0))
#pragma amicall(IFFParseBase,0x096,StopOnExit(a0,d0,d1))
#pragma amicall(IFFParseBase,0x09C,FindProp(a0,d0,d1))
#pragma amicall(IFFParseBase,0x0A2,FindCollection(a0,d0,d1))
#pragma amicall(IFFParseBase,0x0A8,FindPropContext(a0))
#pragma amicall(IFFParseBase,0x0AE,CurrentChunk(a0))
#pragma amicall(IFFParseBase,0x0B4,ParentChunk(a0))
#pragma amicall(IFFParseBase,0x0BA,AllocLocalItem(d0,d1,d2,d3))
#pragma amicall(IFFParseBase,0x0C0,LocalItemData(a0))
#pragma amicall(IFFParseBase,0x0C6,SetLocalItemPurge(a0,a1))
#pragma amicall(IFFParseBase,0x0CC,FreeLocalItem(a0))
#pragma amicall(IFFParseBase,0x0D2,FindLocalItem(a0,d0,d1,d2))
#pragma amicall(IFFParseBase,0x0D8,StoreLocalItem(a0,a1,d0))
#pragma amicall(IFFParseBase,0x0DE,StoreItemInContext(a0,a1,a2))
#pragma amicall(IFFParseBase,0x0E4,InitIFF(a0,d0,a1))
#pragma amicall(IFFParseBase,0x0EA,InitIFFasDOS(a0))
#pragma amicall(IFFParseBase,0x0F0,InitIFFasClip(a0))
#pragma amicall(IFFParseBase,0x0F6,OpenClipboard(d0))
#pragma amicall(IFFParseBase,0x0FC,CloseClipboard(a0))
#pragma amicall(IFFParseBase,0x102,GoodID(d0))
#pragma amicall(IFFParseBase,0x108,GoodType(d0))
#pragma amicall(IFFParseBase,0x10E,IDtoStr(d0,a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall IFFParseBase AllocIFF             01E 00
#pragma  libcall IFFParseBase OpenIFF              024 0802
#pragma  libcall IFFParseBase ParseIFF             02A 0802
#pragma  libcall IFFParseBase CloseIFF             030 801
#pragma  libcall IFFParseBase FreeIFF              036 801
#pragma  libcall IFFParseBase ReadChunkBytes       03C 09803
#pragma  libcall IFFParseBase WriteChunkBytes      042 09803
#pragma  libcall IFFParseBase ReadChunkRecords     048 109804
#pragma  libcall IFFParseBase WriteChunkRecords    04E 109804
#pragma  libcall IFFParseBase PushChunk            054 210804
#pragma  libcall IFFParseBase PopChunk             05A 801
#pragma  libcall IFFParseBase EntryHandler         066 A9210806
#pragma  libcall IFFParseBase ExitHandler          06C A9210806
#pragma  libcall IFFParseBase PropChunk            072 10803
#pragma  libcall IFFParseBase PropChunks           078 09803
#pragma  libcall IFFParseBase StopChunk            07E 10803
#pragma  libcall IFFParseBase StopChunks           084 09803
#pragma  libcall IFFParseBase CollectionChunk      08A 10803
#pragma  libcall IFFParseBase CollectionChunks     090 09803
#pragma  libcall IFFParseBase StopOnExit           096 10803
#pragma  libcall IFFParseBase FindProp             09C 10803
#pragma  libcall IFFParseBase FindCollection       0A2 10803
#pragma  libcall IFFParseBase FindPropContext      0A8 801
#pragma  libcall IFFParseBase CurrentChunk         0AE 801
#pragma  libcall IFFParseBase ParentChunk          0B4 801
#pragma  libcall IFFParseBase AllocLocalItem       0BA 321004
#pragma  libcall IFFParseBase LocalItemData        0C0 801
#pragma  libcall IFFParseBase SetLocalItemPurge    0C6 9802
#pragma  libcall IFFParseBase FreeLocalItem        0CC 801
#pragma  libcall IFFParseBase FindLocalItem        0D2 210804
#pragma  libcall IFFParseBase StoreLocalItem       0D8 09803
#pragma  libcall IFFParseBase StoreItemInContext   0DE A9803
#pragma  libcall IFFParseBase InitIFF              0E4 90803
#pragma  libcall IFFParseBase InitIFFasDOS         0EA 801
#pragma  libcall IFFParseBase InitIFFasClip        0F0 801
#pragma  libcall IFFParseBase OpenClipboard        0F6 001
#pragma  libcall IFFParseBase CloseClipboard       0FC 801
#pragma  libcall IFFParseBase GoodID               102 001
#pragma  libcall IFFParseBase GoodType             108 001
#pragma  libcall IFFParseBase IDtoStr              10E 8002
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_IFFPARSE_LIB_H  */
