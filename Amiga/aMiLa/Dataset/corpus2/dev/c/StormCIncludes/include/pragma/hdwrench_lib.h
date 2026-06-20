#ifndef _INCLUDE_PRAGMA_HDWRENCH_LIB_H
#define _INCLUDE_PRAGMA_HDWRENCH_LIB_H

#ifndef CLIB_HDWRENCH_PROTOS_H
#include <clib/hdwrench_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/hdwrench.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(HDWBase,0x01E,HDWOpenDevice(a0,d0))
#pragma amicall(HDWBase,0x024,HDWCloseDevice())
#pragma amicall(HDWBase,0x02A,RawRead(a0,d0))
#pragma amicall(HDWBase,0x030,RawWrite(a0))
#pragma amicall(HDWBase,0x036,WriteBlock(a0))
#pragma amicall(HDWBase,0x03C,ReadRDBs())
#pragma amicall(HDWBase,0x042,WriteRDBs())
#pragma amicall(HDWBase,0x048,QueryReady(a0))
#pragma amicall(HDWBase,0x04E,QueryInquiry(a0,a1))
#pragma amicall(HDWBase,0x054,QueryModeSense(d0,d1,a0,a1))
#pragma amicall(HDWBase,0x05A,QueryFindValid(a0,a1,d0,d1,d2,a2))
#pragma amicall(HDWBase,0x060,QueryCapacity(a0,a1))
#pragma amicall(HDWBase,0x066,ReadMountfile(d0,a0,a1))
#pragma amicall(HDWBase,0x06C,ReadRDBStructs(a0,d0))
#pragma amicall(HDWBase,0x072,WriteMountfile(a0,a1,d0))
#pragma amicall(HDWBase,0x078,WriteRDBStructs(a0))
#pragma amicall(HDWBase,0x07E,InMemMountfile(d0,a0,a1))
#pragma amicall(HDWBase,0x084,InMemRDBStructs(a0,d0,d1))
#pragma amicall(HDWBase,0x08A,OutMemMountfile(a0,a1,d0,d1))
#pragma amicall(HDWBase,0x090,OutMemRDBStructs(a0,a1,d0))
#pragma amicall(HDWBase,0x096,FindDiskName(a0))
#pragma amicall(HDWBase,0x09C,FindControllerID(a0,a1))
#pragma amicall(HDWBase,0x0A2,FindLastSector())
#pragma amicall(HDWBase,0x0A8,FindDefaults(d0,a0))
#pragma amicall(HDWBase,0x0AE,LowlevelFormat(a0))
#pragma amicall(HDWBase,0x0B4,VerifyDrive(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall HDWBase HDWOpenDevice        01E 0802
#pragma  libcall HDWBase HDWCloseDevice       024 00
#pragma  libcall HDWBase RawRead              02A 0802
#pragma  libcall HDWBase RawWrite             030 801
#pragma  libcall HDWBase WriteBlock           036 801
#pragma  libcall HDWBase ReadRDBs             03C 00
#pragma  libcall HDWBase WriteRDBs            042 00
#pragma  libcall HDWBase QueryReady           048 801
#pragma  libcall HDWBase QueryInquiry         04E 9802
#pragma  libcall HDWBase QueryModeSense       054 981004
#pragma  libcall HDWBase QueryFindValid       05A A2109806
#pragma  libcall HDWBase QueryCapacity        060 9802
#pragma  libcall HDWBase ReadMountfile        066 98003
#pragma  libcall HDWBase ReadRDBStructs       06C 0802
#pragma  libcall HDWBase WriteMountfile       072 09803
#pragma  libcall HDWBase WriteRDBStructs      078 801
#pragma  libcall HDWBase InMemMountfile       07E 98003
#pragma  libcall HDWBase InMemRDBStructs      084 10803
#pragma  libcall HDWBase OutMemMountfile      08A 109804
#pragma  libcall HDWBase OutMemRDBStructs     090 09803
#pragma  libcall HDWBase FindDiskName         096 801
#pragma  libcall HDWBase FindControllerID     09C 9802
#pragma  libcall HDWBase FindLastSector       0A2 00
#pragma  libcall HDWBase FindDefaults         0A8 8002
#pragma  libcall HDWBase LowlevelFormat       0AE 801
#pragma  libcall HDWBase VerifyDrive          0B4 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_HDWRENCH_LIB_H  */
