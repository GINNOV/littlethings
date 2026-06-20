#ifndef _INCLUDE_PRAGMA_GATEXPR_LIB_H
#define _INCLUDE_PRAGMA_GATEXPR_LIB_H

#ifndef CLIB_GATEXPR_PROTOS_H
#include <clib/GateXpr_protos.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(GateXprBase,0x01E,TransferSetup(a0,d0,a1,d1,d2,d3,d4,d5))
#pragma amicall(GateXprBase,0x024,ReceiveFile(a0,d0,a1))
#pragma amicall(GateXprBase,0x02A,SendFile(a0,d0,a1))
#pragma amicall(GateXprBase,0x030,GetOptions(a0))
#pragma amicall(GateXprBase,0x036,SetOptions(a0))
#pragma amicall(GateXprBase,0x03C,TransferSetupShared(a0,a1,a2))
#pragma amicall(GateXprBase,0x042,InstallTransferNote(a0))
#pragma amicall(GateXprBase,0x048,SendMultipleFiles(a0,d0,a1))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall GateXprBase TransferSetup        01E 5432190808
#pragma  libcall GateXprBase ReceiveFile          024 90803
#pragma  libcall GateXprBase SendFile             02A 90803
#pragma  libcall GateXprBase GetOptions           030 801
#pragma  libcall GateXprBase SetOptions           036 801
#pragma  libcall GateXprBase TransferSetupShared  03C A9803
#pragma  libcall GateXprBase InstallTransferNote  042 801
#pragma  libcall GateXprBase SendMultipleFiles    048 90803
#endif

#endif	/*  _INCLUDE_PRAGMA_GATEXPR_LIB_H  */
