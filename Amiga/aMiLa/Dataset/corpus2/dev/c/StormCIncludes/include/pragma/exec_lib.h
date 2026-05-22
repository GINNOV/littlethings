#ifndef _INCLUDE_PRAGMA_EXEC_LIB_H
#define _INCLUDE_PRAGMA_EXEC_LIB_H

#ifndef CLIB_EXEC_PROTOS_H
#include <clib/exec_protos.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifdef __GNUC__
#ifdef NO_OBSOLETE
#error "Please include the proto file and not the compiler specific file!"
#endif
#include <inline/exec.h>
#endif

#if defined(AZTEC_C) || defined(__MAXON__) || defined(__STORM__)
#pragma amicall(SysBase,0x01E,Supervisor(a5))
#pragma amicall(SysBase,0x048,InitCode(d0,d1))
#pragma amicall(SysBase,0x04E,InitStruct(a1,a2,d0))
#pragma amicall(SysBase,0x054,MakeLibrary(a0,a1,a2,d0,d1))
#pragma amicall(SysBase,0x05A,MakeFunctions(a0,a1,a2))
#pragma amicall(SysBase,0x060,FindResident(a1))
#pragma amicall(SysBase,0x066,InitResident(a1,d1))
#pragma amicall(SysBase,0x06C,Alert(d7))
#pragma amicall(SysBase,0x072,Debug(d0))
#pragma amicall(SysBase,0x078,Disable())
#pragma amicall(SysBase,0x07E,Enable())
#pragma amicall(SysBase,0x084,Forbid())
#pragma amicall(SysBase,0x08A,Permit())
#pragma amicall(SysBase,0x090,SetSR(d0,d1))
#pragma amicall(SysBase,0x096,SuperState())
#pragma amicall(SysBase,0x09C,UserState(d0))
#pragma amicall(SysBase,0x0A2,SetIntVector(d0,a1))
#pragma amicall(SysBase,0x0A8,AddIntServer(d0,a1))
#pragma amicall(SysBase,0x0AE,RemIntServer(d0,a1))
#pragma amicall(SysBase,0x0B4,Cause(a1))
#pragma amicall(SysBase,0x0BA,Allocate(a0,d0))
#pragma amicall(SysBase,0x0C0,Deallocate(a0,a1,d0))
#pragma amicall(SysBase,0x0C6,AllocMem(d0,d1))
#pragma amicall(SysBase,0x0CC,AllocAbs(d0,a1))
#pragma amicall(SysBase,0x0D2,FreeMem(a1,d0))
#pragma amicall(SysBase,0x0D8,AvailMem(d1))
#pragma amicall(SysBase,0x0DE,AllocEntry(a0))
#pragma amicall(SysBase,0x0E4,FreeEntry(a0))
#pragma amicall(SysBase,0x0EA,Insert(a0,a1,a2))
#pragma amicall(SysBase,0x0F0,AddHead(a0,a1))
#pragma amicall(SysBase,0x0F6,AddTail(a0,a1))
#pragma amicall(SysBase,0x0FC,Remove(a1))
#pragma amicall(SysBase,0x102,RemHead(a0))
#pragma amicall(SysBase,0x108,RemTail(a0))
#pragma amicall(SysBase,0x10E,Enqueue(a0,a1))
#pragma amicall(SysBase,0x114,FindName(a0,a1))
#pragma amicall(SysBase,0x11A,AddTask(a1,a2,a3))
#pragma amicall(SysBase,0x120,RemTask(a1))
#pragma amicall(SysBase,0x126,FindTask(a1))
#pragma amicall(SysBase,0x12C,SetTaskPri(a1,d0))
#pragma amicall(SysBase,0x132,SetSignal(d0,d1))
#pragma amicall(SysBase,0x138,SetExcept(d0,d1))
#pragma amicall(SysBase,0x13E,Wait(d0))
#pragma amicall(SysBase,0x144,Signal(a1,d0))
#pragma amicall(SysBase,0x14A,AllocSignal(d0))
#pragma amicall(SysBase,0x150,FreeSignal(d0))
#pragma amicall(SysBase,0x156,AllocTrap(d0))
#pragma amicall(SysBase,0x15C,FreeTrap(d0))
#pragma amicall(SysBase,0x162,AddPort(a1))
#pragma amicall(SysBase,0x168,RemPort(a1))
#pragma amicall(SysBase,0x16E,PutMsg(a0,a1))
#pragma amicall(SysBase,0x174,GetMsg(a0))
#pragma amicall(SysBase,0x17A,ReplyMsg(a1))
#pragma amicall(SysBase,0x180,WaitPort(a0))
#pragma amicall(SysBase,0x186,FindPort(a1))
#pragma amicall(SysBase,0x18C,AddLibrary(a1))
#pragma amicall(SysBase,0x192,RemLibrary(a1))
#pragma amicall(SysBase,0x198,OldOpenLibrary(a1))
#pragma amicall(SysBase,0x19E,CloseLibrary(a1))
#pragma amicall(SysBase,0x1A4,SetFunction(a1,a0,d0))
#pragma amicall(SysBase,0x1AA,SumLibrary(a1))
#pragma amicall(SysBase,0x1B0,AddDevice(a1))
#pragma amicall(SysBase,0x1B6,RemDevice(a1))
#pragma amicall(SysBase,0x1BC,OpenDevice(a0,d0,a1,d1))
#pragma amicall(SysBase,0x1C2,CloseDevice(a1))
#pragma amicall(SysBase,0x1C8,DoIO(a1))
#pragma amicall(SysBase,0x1CE,SendIO(a1))
#pragma amicall(SysBase,0x1D4,CheckIO(a1))
#pragma amicall(SysBase,0x1DA,WaitIO(a1))
#pragma amicall(SysBase,0x1E0,AbortIO(a1))
#pragma amicall(SysBase,0x1E6,AddResource(a1))
#pragma amicall(SysBase,0x1EC,RemResource(a1))
#pragma amicall(SysBase,0x1F2,OpenResource(a1))
#pragma amicall(SysBase,0x20A,RawDoFmt(a0,a1,a2,a3))
#pragma amicall(SysBase,0x210,GetCC())
#pragma amicall(SysBase,0x216,TypeOfMem(a1))
#pragma amicall(SysBase,0x21C,Procure(a0,a1))
#pragma amicall(SysBase,0x222,Vacate(a0,a1))
#pragma amicall(SysBase,0x228,OpenLibrary(a1,d0))
#pragma amicall(SysBase,0x22E,InitSemaphore(a0))
#pragma amicall(SysBase,0x234,ObtainSemaphore(a0))
#pragma amicall(SysBase,0x23A,ReleaseSemaphore(a0))
#pragma amicall(SysBase,0x240,AttemptSemaphore(a0))
#pragma amicall(SysBase,0x246,ObtainSemaphoreList(a0))
#pragma amicall(SysBase,0x24C,ReleaseSemaphoreList(a0))
#pragma amicall(SysBase,0x252,FindSemaphore(a1))
#pragma amicall(SysBase,0x258,AddSemaphore(a1))
#pragma amicall(SysBase,0x25E,RemSemaphore(a1))
#pragma amicall(SysBase,0x264,SumKickData())
#pragma amicall(SysBase,0x26A,AddMemList(d0,d1,d2,a0,a1))
#pragma amicall(SysBase,0x270,CopyMem(a0,a1,d0))
#pragma amicall(SysBase,0x276,CopyMemQuick(a0,a1,d0))
#pragma amicall(SysBase,0x27C,CacheClearU())
#pragma amicall(SysBase,0x282,CacheClearE(a0,d0,d1))
#pragma amicall(SysBase,0x288,CacheControl(d0,d1))
#pragma amicall(SysBase,0x28E,CreateIORequest(a0,d0))
#pragma amicall(SysBase,0x294,DeleteIORequest(a0))
#pragma amicall(SysBase,0x29A,CreateMsgPort())
#pragma amicall(SysBase,0x2A0,DeleteMsgPort(a0))
#pragma amicall(SysBase,0x2A6,ObtainSemaphoreShared(a0))
#pragma amicall(SysBase,0x2AC,AllocVec(d0,d1))
#pragma amicall(SysBase,0x2B2,FreeVec(a1))
#pragma amicall(SysBase,0x2B8,CreatePool(d0,d1,d2))
#pragma amicall(SysBase,0x2BE,DeletePool(a0))
#pragma amicall(SysBase,0x2C4,AllocPooled(a0,d0))
#pragma amicall(SysBase,0x2CA,FreePooled(a0,a1,d0))
#pragma amicall(SysBase,0x2D0,AttemptSemaphoreShared(a0))
#pragma amicall(SysBase,0x2D6,ColdReboot())
#pragma amicall(SysBase,0x2DC,StackSwap(a0))
#pragma amicall(SysBase,0x2FA,CachePreDMA(a0,a1,d0))
#pragma amicall(SysBase,0x300,CachePostDMA(a0,a1,d0))
#pragma amicall(SysBase,0x306,AddMemHandler(a1))
#pragma amicall(SysBase,0x30C,RemMemHandler(a1))
#pragma amicall(SysBase,0x312,ObtainQuickVector(a0))
#pragma amicall(SysBase,0x33C,NewMinList(a0))
#pragma amicall(SysBase,0x354,AVL_AddNode(a0,a1,a2))
#pragma amicall(SysBase,0x35A,AVL_RemNodeByAddress(a0,a1))
#pragma amicall(SysBase,0x360,AVL_RemNodeByKey(a0,a1,a2))
#pragma amicall(SysBase,0x366,AVL_FindNode(a0,a1,a2))
#pragma amicall(SysBase,0x36C,AVL_FindPrevNodeByAddress(a0))
#pragma amicall(SysBase,0x372,AVL_FindPrevNodeByKey(a0,a1,a2))
#pragma amicall(SysBase,0x378,AVL_FindNextNodeByAddress(a0))
#pragma amicall(SysBase,0x37E,AVL_FindNextNodeByKey(a0,a1,a2))
#pragma amicall(SysBase,0x384,AVL_FindFirstNode(a0))
#pragma amicall(SysBase,0x38A,AVL_FindLastNode(a0))
#endif
#if defined(_DCC) || defined(__SASC)
#pragma  libcall SysBase Supervisor           01E D01
#pragma  libcall SysBase InitCode             048 1002
#pragma  libcall SysBase InitStruct           04E 0A903
#pragma  libcall SysBase MakeLibrary          054 10A9805
#pragma  libcall SysBase MakeFunctions        05A A9803
#pragma  libcall SysBase FindResident         060 901
#pragma  libcall SysBase InitResident         066 1902
#pragma  libcall SysBase Alert                06C 701
#pragma  libcall SysBase Debug                072 001
#pragma  libcall SysBase Disable              078 00
#pragma  libcall SysBase Enable               07E 00
#pragma  libcall SysBase Forbid               084 00
#pragma  libcall SysBase Permit               08A 00
#pragma  libcall SysBase SetSR                090 1002
#pragma  libcall SysBase SuperState           096 00
#pragma  libcall SysBase UserState            09C 001
#pragma  libcall SysBase SetIntVector         0A2 9002
#pragma  libcall SysBase AddIntServer         0A8 9002
#pragma  libcall SysBase RemIntServer         0AE 9002
#pragma  libcall SysBase Cause                0B4 901
#pragma  libcall SysBase Allocate             0BA 0802
#pragma  libcall SysBase Deallocate           0C0 09803
#pragma  libcall SysBase AllocMem             0C6 1002
#pragma  libcall SysBase AllocAbs             0CC 9002
#pragma  libcall SysBase FreeMem              0D2 0902
#pragma  libcall SysBase AvailMem             0D8 101
#pragma  libcall SysBase AllocEntry           0DE 801
#pragma  libcall SysBase FreeEntry            0E4 801
#pragma  libcall SysBase Insert               0EA A9803
#pragma  libcall SysBase AddHead              0F0 9802
#pragma  libcall SysBase AddTail              0F6 9802
#pragma  libcall SysBase Remove               0FC 901
#pragma  libcall SysBase RemHead              102 801
#pragma  libcall SysBase RemTail              108 801
#pragma  libcall SysBase Enqueue              10E 9802
#pragma  libcall SysBase FindName             114 9802
#pragma  libcall SysBase AddTask              11A BA903
#pragma  libcall SysBase RemTask              120 901
#pragma  libcall SysBase FindTask             126 901
#pragma  libcall SysBase SetTaskPri           12C 0902
#pragma  libcall SysBase SetSignal            132 1002
#pragma  libcall SysBase SetExcept            138 1002
#pragma  libcall SysBase Wait                 13E 001
#pragma  libcall SysBase Signal               144 0902
#pragma  libcall SysBase AllocSignal          14A 001
#pragma  libcall SysBase FreeSignal           150 001
#pragma  libcall SysBase AllocTrap            156 001
#pragma  libcall SysBase FreeTrap             15C 001
#pragma  libcall SysBase AddPort              162 901
#pragma  libcall SysBase RemPort              168 901
#pragma  libcall SysBase PutMsg               16E 9802
#pragma  libcall SysBase GetMsg               174 801
#pragma  libcall SysBase ReplyMsg             17A 901
#pragma  libcall SysBase WaitPort             180 801
#pragma  libcall SysBase FindPort             186 901
#pragma  libcall SysBase AddLibrary           18C 901
#pragma  libcall SysBase RemLibrary           192 901
#pragma  libcall SysBase OldOpenLibrary       198 901
#pragma  libcall SysBase CloseLibrary         19E 901
#pragma  libcall SysBase SetFunction          1A4 08903
#pragma  libcall SysBase SumLibrary           1AA 901
#pragma  libcall SysBase AddDevice            1B0 901
#pragma  libcall SysBase RemDevice            1B6 901
#pragma  libcall SysBase OpenDevice           1BC 190804
#pragma  libcall SysBase CloseDevice          1C2 901
#pragma  libcall SysBase DoIO                 1C8 901
#pragma  libcall SysBase SendIO               1CE 901
#pragma  libcall SysBase CheckIO              1D4 901
#pragma  libcall SysBase WaitIO               1DA 901
#pragma  libcall SysBase AbortIO              1E0 901
#pragma  libcall SysBase AddResource          1E6 901
#pragma  libcall SysBase RemResource          1EC 901
#pragma  libcall SysBase OpenResource         1F2 901
#pragma  libcall SysBase RawDoFmt             20A BA9804
#pragma  libcall SysBase GetCC                210 00
#pragma  libcall SysBase TypeOfMem            216 901
#pragma  libcall SysBase Procure              21C 9802
#pragma  libcall SysBase Vacate               222 9802
#pragma  libcall SysBase OpenLibrary          228 0902
#pragma  libcall SysBase InitSemaphore        22E 801
#pragma  libcall SysBase ObtainSemaphore      234 801
#pragma  libcall SysBase ReleaseSemaphore     23A 801
#pragma  libcall SysBase AttemptSemaphore     240 801
#pragma  libcall SysBase ObtainSemaphoreList  246 801
#pragma  libcall SysBase ReleaseSemaphoreList 24C 801
#pragma  libcall SysBase FindSemaphore        252 901
#pragma  libcall SysBase AddSemaphore         258 901
#pragma  libcall SysBase RemSemaphore         25E 901
#pragma  libcall SysBase SumKickData          264 00
#pragma  libcall SysBase AddMemList           26A 9821005
#pragma  libcall SysBase CopyMem              270 09803
#pragma  libcall SysBase CopyMemQuick         276 09803
#pragma  libcall SysBase CacheClearU          27C 00
#pragma  libcall SysBase CacheClearE          282 10803
#pragma  libcall SysBase CacheControl         288 1002
#pragma  libcall SysBase CreateIORequest      28E 0802
#pragma  libcall SysBase DeleteIORequest      294 801
#pragma  libcall SysBase CreateMsgPort        29A 00
#pragma  libcall SysBase DeleteMsgPort        2A0 801
#pragma  libcall SysBase ObtainSemaphoreShared 2A6 801
#pragma  libcall SysBase AllocVec             2AC 1002
#pragma  libcall SysBase FreeVec              2B2 901
#pragma  libcall SysBase CreatePool           2B8 21003
#pragma  libcall SysBase DeletePool           2BE 801
#pragma  libcall SysBase AllocPooled          2C4 0802
#pragma  libcall SysBase FreePooled           2CA 09803
#pragma  libcall SysBase AttemptSemaphoreShared 2D0 801
#pragma  libcall SysBase ColdReboot           2D6 00
#pragma  libcall SysBase StackSwap            2DC 801
#pragma  libcall SysBase CachePreDMA          2FA 09803
#pragma  libcall SysBase CachePostDMA         300 09803
#pragma  libcall SysBase AddMemHandler        306 901
#pragma  libcall SysBase RemMemHandler        30C 901
#pragma  libcall SysBase ObtainQuickVector    312 801
#pragma  libcall SysBase NewMinList           33C 801
#pragma  libcall SysBase AVL_AddNode          354 A9803
#pragma  libcall SysBase AVL_RemNodeByAddress 35A 9802
#pragma  libcall SysBase AVL_RemNodeByKey     360 A9803
#pragma  libcall SysBase AVL_FindNode         366 A9803
#pragma  libcall SysBase AVL_FindPrevNodeByAddress 36C 801
#pragma  libcall SysBase AVL_FindPrevNodeByKey 372 A9803
#pragma  libcall SysBase AVL_FindNextNodeByAddress 378 801
#pragma  libcall SysBase AVL_FindNextNodeByKey 37E A9803
#pragma  libcall SysBase AVL_FindFirstNode    384 801
#pragma  libcall SysBase AVL_FindLastNode     38A 801
#endif

#ifdef __cplusplus
}
#endif

#endif	/*  _INCLUDE_PRAGMA_EXEC_LIB_H  */
