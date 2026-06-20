#ifndef _VBCCINLINE_EXEC_H
#define _VBCCINLINE_EXEC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

ULONG __Supervisor(void *, ULONG (*userFunction)(VOID)) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,52(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define Supervisor(userFunction) __Supervisor(SysBase, (userFunction))

VOID __InitCode(void *, ULONG startClass, ULONG version) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define InitCode(startClass, version) __InitCode(SysBase, (startClass), (version))

VOID __InitStruct(void *, CONST APTR initTable, APTR memory, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define InitStruct(initTable, memory, size) __InitStruct(SysBase, (initTable), (memory), (size))

struct Library * __MakeLibrary(void *, CONST APTR funcInit, CONST APTR structInit, ULONG (*libInit)(VOID), ULONG dataSize, ULONG segList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define MakeLibrary(funcInit, structInit, libInit, dataSize, segList) __MakeLibrary(SysBase, (funcInit), (structInit), (libInit), (dataSize), (segList))

VOID __MakeFunctions(void *, APTR target, CONST APTR functionArray, CONST APTR funcDispBase) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define MakeFunctions(target, functionArray, funcDispBase) __MakeFunctions(SysBase, (target), (functionArray), (funcDispBase))

struct Resident * __FindResident(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define FindResident(name) __FindResident(SysBase, (name))

APTR __InitResident(void *, CONST struct Resident * resident, ULONG segList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define InitResident(resident, segList) __InitResident(SysBase, (resident), (segList))

VOID __Alert(void *, ULONG alertNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,28(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define Alert(alertNum) __Alert(SysBase, (alertNum))

VOID __Debug(void *, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define Debug(flags) __Debug(SysBase, (flags))

VOID __Disable(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define Disable() __Disable(SysBase)

VOID __Enable(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define Enable() __Enable(SysBase)

VOID __Forbid(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define Forbid() __Forbid(SysBase)

VOID __Permit(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define Permit() __Permit(SysBase)

ULONG __SetSR(void *, ULONG newSR, ULONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define SetSR(newSR, mask) __SetSR(SysBase, (newSR), (mask))

APTR __SuperState(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define SuperState() __SuperState(SysBase)

VOID __UserState(void *, APTR sysStack) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define UserState(sysStack) __UserState(SysBase, (sysStack))

struct Interrupt * __SetIntVector(void *, LONG intNumber, CONST struct Interrupt * interrupt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define SetIntVector(intNumber, interrupt) __SetIntVector(SysBase, (intNumber), (interrupt))

VOID __AddIntServer(void *, LONG intNumber, struct Interrupt * interrupt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define AddIntServer(intNumber, interrupt) __AddIntServer(SysBase, (intNumber), (interrupt))

VOID __RemIntServer(void *, LONG intNumber, struct Interrupt * interrupt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define RemIntServer(intNumber, interrupt) __RemIntServer(SysBase, (intNumber), (interrupt))

VOID __Cause(void *, struct Interrupt * interrupt) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define Cause(interrupt) __Cause(SysBase, (interrupt))

APTR __Allocate(void *, struct MemHeader * freeList, ULONG byteSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define Allocate(freeList, byteSize) __Allocate(SysBase, (freeList), (byteSize))

VOID __Deallocate(void *, struct MemHeader * freeList, APTR memoryBlock, ULONG byteSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define Deallocate(freeList, memoryBlock, byteSize) __Deallocate(SysBase, (freeList), (memoryBlock), (byteSize))

APTR __AllocMem(void *, ULONG byteSize, ULONG requirements) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define AllocMem(byteSize, requirements) __AllocMem(SysBase, (byteSize), (requirements))

APTR __AllocAbs(void *, ULONG byteSize, APTR location) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-204\n"
	"\tbctrl";
#define AllocAbs(byteSize, location) __AllocAbs(SysBase, (byteSize), (location))

VOID __FreeMem(void *, APTR memoryBlock, ULONG byteSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-210\n"
	"\tbctrl";
#define FreeMem(memoryBlock, byteSize) __FreeMem(SysBase, (memoryBlock), (byteSize))

ULONG __AvailMem(void *, ULONG requirements) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-216\n"
	"\tbctrl";
#define AvailMem(requirements) __AvailMem(SysBase, (requirements))

struct MemList * __AllocEntry(void *, struct MemList * entry) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-222\n"
	"\tbctrl";
#define AllocEntry(entry) __AllocEntry(SysBase, (entry))

VOID __FreeEntry(void *, struct MemList * entry) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-228\n"
	"\tbctrl";
#define FreeEntry(entry) __FreeEntry(SysBase, (entry))

VOID __Insert(void *, struct List * list, struct Node * node, struct Node * pred) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-234\n"
	"\tbctrl";
#define Insert(list, node, pred) __Insert(SysBase, (list), (node), (pred))

VOID __AddHead(void *, struct List * list, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-240\n"
	"\tbctrl";
#define AddHead(list, node) __AddHead(SysBase, (list), (node))

VOID __AddTail(void *, struct List * list, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-246\n"
	"\tbctrl";
#define AddTail(list, node) __AddTail(SysBase, (list), (node))

VOID __Remove(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-252\n"
	"\tbctrl";
#define Remove(node) __Remove(SysBase, (node))

struct Node * __RemHead(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-258\n"
	"\tbctrl";
#define RemHead(list) __RemHead(SysBase, (list))

struct Node * __RemTail(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-264\n"
	"\tbctrl";
#define RemTail(list) __RemTail(SysBase, (list))

VOID __Enqueue(void *, struct List * list, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-270\n"
	"\tbctrl";
#define Enqueue(list, node) __Enqueue(SysBase, (list), (node))

struct Node * __FindName(void *, struct List * list, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-276\n"
	"\tbctrl";
#define FindName(list, name) __FindName(SysBase, (list), (name))

APTR __AddTask(void *, struct Task * task, CONST APTR initPC, CONST APTR finalPC) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,40(2)\n"
	"\tstw\t6,44(2)\n"
	"\tli\t3,-282\n"
	"\tbctrl";
#define AddTask(task, initPC, finalPC) __AddTask(SysBase, (task), (initPC), (finalPC))

VOID __RemTask(void *, struct Task * task) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-288\n"
	"\tbctrl";
#define RemTask(task) __RemTask(SysBase, (task))

struct Task * __FindTask(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-294\n"
	"\tbctrl";
#define FindTask(name) __FindTask(SysBase, (name))

BYTE __SetTaskPri(void *, struct Task * task, LONG priority) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-300\n"
	"\tbctrl";
#define SetTaskPri(task, priority) __SetTaskPri(SysBase, (task), (priority))

ULONG __SetSignal(void *, ULONG newSignals, ULONG signalSet) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-306\n"
	"\tbctrl";
#define SetSignal(newSignals, signalSet) __SetSignal(SysBase, (newSignals), (signalSet))

ULONG __SetExcept(void *, ULONG newSignals, ULONG signalSet) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-312\n"
	"\tbctrl";
#define SetExcept(newSignals, signalSet) __SetExcept(SysBase, (newSignals), (signalSet))

ULONG __Wait(void *, ULONG signalSet) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-318\n"
	"\tbctrl";
#define Wait(signalSet) __Wait(SysBase, (signalSet))

VOID __Signal(void *, struct Task * task, ULONG signalSet) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-324\n"
	"\tbctrl";
#define Signal(task, signalSet) __Signal(SysBase, (task), (signalSet))

BYTE __AllocSignal(void *, LONG signalNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-330\n"
	"\tbctrl";
#define AllocSignal(signalNum) __AllocSignal(SysBase, (signalNum))

VOID __FreeSignal(void *, LONG signalNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-336\n"
	"\tbctrl";
#define FreeSignal(signalNum) __FreeSignal(SysBase, (signalNum))

LONG __AllocTrap(void *, LONG trapNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-342\n"
	"\tbctrl";
#define AllocTrap(trapNum) __AllocTrap(SysBase, (trapNum))

VOID __FreeTrap(void *, LONG trapNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-348\n"
	"\tbctrl";
#define FreeTrap(trapNum) __FreeTrap(SysBase, (trapNum))

VOID __AddPort(void *, struct MsgPort * port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-354\n"
	"\tbctrl";
#define AddPort(port) __AddPort(SysBase, (port))

VOID __RemPort(void *, struct MsgPort * port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-360\n"
	"\tbctrl";
#define RemPort(port) __RemPort(SysBase, (port))

VOID __PutMsg(void *, struct MsgPort * port, struct Message * message) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-366\n"
	"\tbctrl";
#define PutMsg(port, message) __PutMsg(SysBase, (port), (message))

struct Message * __GetMsg(void *, struct MsgPort * port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-372\n"
	"\tbctrl";
#define GetMsg(port) __GetMsg(SysBase, (port))

VOID __ReplyMsg(void *, struct Message * message) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-378\n"
	"\tbctrl";
#define ReplyMsg(message) __ReplyMsg(SysBase, (message))

struct Message * __WaitPort(void *, struct MsgPort * port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-384\n"
	"\tbctrl";
#define WaitPort(port) __WaitPort(SysBase, (port))

struct MsgPort * __FindPort(void *, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-390\n"
	"\tbctrl";
#define FindPort(name) __FindPort(SysBase, (name))

VOID __AddLibrary(void *, struct Library * library) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-396\n"
	"\tbctrl";
#define AddLibrary(library) __AddLibrary(SysBase, (library))

VOID __RemLibrary(void *, struct Library * library) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-402\n"
	"\tbctrl";
#define RemLibrary(library) __RemLibrary(SysBase, (library))

struct Library * __OldOpenLibrary(void *, CONST_STRPTR libName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-408\n"
	"\tbctrl";
#define OldOpenLibrary(libName) __OldOpenLibrary(SysBase, (libName))

VOID __CloseLibrary(void *, struct Library * library) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-414\n"
	"\tbctrl";
#define CloseLibrary(library) __CloseLibrary(SysBase, (library))

APTR __SetFunction(void *, struct Library * library, LONG funcOffset, ULONG (*newFunction)(VOID)) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-420\n"
	"\tbctrl";
#define SetFunction(library, funcOffset, newFunction) __SetFunction(SysBase, (library), (funcOffset), (newFunction))

VOID __SumLibrary(void *, struct Library * library) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-426\n"
	"\tbctrl";
#define SumLibrary(library) __SumLibrary(SysBase, (library))

VOID __AddDevice(void *, struct Device * device) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-432\n"
	"\tbctrl";
#define AddDevice(device) __AddDevice(SysBase, (device))

VOID __RemDevice(void *, struct Device * device) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-438\n"
	"\tbctrl";
#define RemDevice(device) __RemDevice(SysBase, (device))

BYTE __OpenDevice(void *, CONST_STRPTR devName, ULONG unit, struct IORequest * ioRequest, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-444\n"
	"\tbctrl";
#define OpenDevice(devName, unit, ioRequest, flags) __OpenDevice(SysBase, (devName), (unit), (ioRequest), (flags))

VOID __CloseDevice(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define CloseDevice(ioRequest) __CloseDevice(SysBase, (ioRequest))

BYTE __DoIO(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define DoIO(ioRequest) __DoIO(SysBase, (ioRequest))

VOID __SendIO(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-462\n"
	"\tbctrl";
#define SendIO(ioRequest) __SendIO(SysBase, (ioRequest))

struct IORequest * __CheckIO(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-468\n"
	"\tbctrl";
#define CheckIO(ioRequest) __CheckIO(SysBase, (ioRequest))

BYTE __WaitIO(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-474\n"
	"\tbctrl";
#define WaitIO(ioRequest) __WaitIO(SysBase, (ioRequest))

VOID __AbortIO(void *, struct IORequest * ioRequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-480\n"
	"\tbctrl";
#define AbortIO(ioRequest) __AbortIO(SysBase, (ioRequest))

VOID __AddResource(void *, APTR resource) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-486\n"
	"\tbctrl";
#define AddResource(resource) __AddResource(SysBase, (resource))

VOID __RemResource(void *, APTR resource) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-492\n"
	"\tbctrl";
#define RemResource(resource) __RemResource(SysBase, (resource))

APTR __OpenResource(void *, CONST_STRPTR resName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-498\n"
	"\tbctrl";
#define OpenResource(resName) __OpenResource(SysBase, (resName))

VOID __RawIOInit(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-504\n"
	"\tbctrl";
#define RawIOInit() __RawIOInit(SysBase)

UBYTE __RawMayGetChar(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-510\n"
	"\tbctrl";
#define RawMayGetChar() __RawMayGetChar(SysBase)

VOID __RawPutChar(void *, UBYTE d0arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-516\n"
	"\tbctrl";
#define RawPutChar(d0arg) __RawPutChar(SysBase, (d0arg))

APTR __RawDoFmt(void *, CONST_STRPTR formatString, CONST APTR dataStream, VOID (*putChProc)(VOID), APTR putChData) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-522\n"
	"\tbctrl";
#define RawDoFmt(formatString, dataStream, putChProc, putChData) __RawDoFmt(SysBase, (formatString), (dataStream), (putChProc), (putChData))

ULONG __GetCC(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-528\n"
	"\tbctrl";
#define GetCC() __GetCC(SysBase)

ULONG __TypeOfMem(void *, CONST APTR address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-534\n"
	"\tbctrl";
#define TypeOfMem(address) __TypeOfMem(SysBase, (address))

ULONG __Procure(void *, struct SignalSemaphore * sigSem, struct SemaphoreMessage * bidMsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-540\n"
	"\tbctrl";
#define Procure(sigSem, bidMsg) __Procure(SysBase, (sigSem), (bidMsg))

VOID __Vacate(void *, struct SignalSemaphore * sigSem, struct SemaphoreMessage * bidMsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-546\n"
	"\tbctrl";
#define Vacate(sigSem, bidMsg) __Vacate(SysBase, (sigSem), (bidMsg))

struct Library * __OpenLibrary(void *, CONST_STRPTR libName, ULONG version) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-552\n"
	"\tbctrl";
#define OpenLibrary(libName, version) __OpenLibrary(SysBase, (libName), (version))

VOID __InitSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-558\n"
	"\tbctrl";
#define InitSemaphore(sigSem) __InitSemaphore(SysBase, (sigSem))

VOID __ObtainSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-564\n"
	"\tbctrl";
#define ObtainSemaphore(sigSem) __ObtainSemaphore(SysBase, (sigSem))

VOID __ReleaseSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-570\n"
	"\tbctrl";
#define ReleaseSemaphore(sigSem) __ReleaseSemaphore(SysBase, (sigSem))

ULONG __AttemptSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-576\n"
	"\tbctrl";
#define AttemptSemaphore(sigSem) __AttemptSemaphore(SysBase, (sigSem))

VOID __ObtainSemaphoreList(void *, struct List * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-582\n"
	"\tbctrl";
#define ObtainSemaphoreList(sigSem) __ObtainSemaphoreList(SysBase, (sigSem))

VOID __ReleaseSemaphoreList(void *, struct List * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-588\n"
	"\tbctrl";
#define ReleaseSemaphoreList(sigSem) __ReleaseSemaphoreList(SysBase, (sigSem))

struct SignalSemaphore * __FindSemaphore(void *, STRPTR sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-594\n"
	"\tbctrl";
#define FindSemaphore(sigSem) __FindSemaphore(SysBase, (sigSem))

VOID __AddSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-600\n"
	"\tbctrl";
#define AddSemaphore(sigSem) __AddSemaphore(SysBase, (sigSem))

VOID __RemSemaphore(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-606\n"
	"\tbctrl";
#define RemSemaphore(sigSem) __RemSemaphore(SysBase, (sigSem))

ULONG __SumKickData(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-612\n"
	"\tbctrl";
#define SumKickData() __SumKickData(SysBase)

VOID __AddMemList(void *, ULONG size, ULONG attributes, LONG pri, APTR base, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,32(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-618\n"
	"\tbctrl";
#define AddMemList(size, attributes, pri, base, name) __AddMemList(SysBase, (size), (attributes), (pri), (base), (name))

VOID __CopyMem(void *, CONST APTR source, APTR dest, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-624\n"
	"\tbctrl";
#define CopyMem(source, dest, size) __CopyMem(SysBase, (source), (dest), (size))

VOID __CopyMemQuick(void *, CONST APTR source, APTR dest, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-630\n"
	"\tbctrl";
#define CopyMemQuick(source, dest, size) __CopyMemQuick(SysBase, (source), (dest), (size))

VOID __CacheClearU(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-636\n"
	"\tbctrl";
#define CacheClearU() __CacheClearU(SysBase)

VOID __CacheClearE(void *, APTR address, ULONG length, ULONG caches) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-642\n"
	"\tbctrl";
#define CacheClearE(address, length, caches) __CacheClearE(SysBase, (address), (length), (caches))

ULONG __CacheControl(void *, ULONG cacheBits, ULONG cacheMask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-648\n"
	"\tbctrl";
#define CacheControl(cacheBits, cacheMask) __CacheControl(SysBase, (cacheBits), (cacheMask))

APTR __CreateIORequest(void *, CONST struct MsgPort * port, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-654\n"
	"\tbctrl";
#define CreateIORequest(port, size) __CreateIORequest(SysBase, (port), (size))

VOID __DeleteIORequest(void *, APTR iorequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-660\n"
	"\tbctrl";
#define DeleteIORequest(iorequest) __DeleteIORequest(SysBase, (iorequest))

struct MsgPort * __CreateMsgPort(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-666\n"
	"\tbctrl";
#define CreateMsgPort() __CreateMsgPort(SysBase)

VOID __DeleteMsgPort(void *, struct MsgPort * port) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-672\n"
	"\tbctrl";
#define DeleteMsgPort(port) __DeleteMsgPort(SysBase, (port))

VOID __ObtainSemaphoreShared(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-678\n"
	"\tbctrl";
#define ObtainSemaphoreShared(sigSem) __ObtainSemaphoreShared(SysBase, (sigSem))

APTR __AllocVec(void *, ULONG byteSize, ULONG requirements) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-684\n"
	"\tbctrl";
#define AllocVec(byteSize, requirements) __AllocVec(SysBase, (byteSize), (requirements))

VOID __FreeVec(void *, APTR memoryBlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-690\n"
	"\tbctrl";
#define FreeVec(memoryBlock) __FreeVec(SysBase, (memoryBlock))

APTR __CreatePool(void *, ULONG requirements, ULONG puddleSize, ULONG threshSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-696\n"
	"\tbctrl";
#define CreatePool(requirements, puddleSize, threshSize) __CreatePool(SysBase, (requirements), (puddleSize), (threshSize))

VOID __DeletePool(void *, APTR poolHeader) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-702\n"
	"\tbctrl";
#define DeletePool(poolHeader) __DeletePool(SysBase, (poolHeader))

APTR __AllocPooled(void *, APTR poolHeader, ULONG memSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-708\n"
	"\tbctrl";
#define AllocPooled(poolHeader, memSize) __AllocPooled(SysBase, (poolHeader), (memSize))

VOID __FreePooled(void *, APTR poolHeader, APTR memory, ULONG memSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-714\n"
	"\tbctrl";
#define FreePooled(poolHeader, memory, memSize) __FreePooled(SysBase, (poolHeader), (memory), (memSize))

ULONG __AttemptSemaphoreShared(void *, struct SignalSemaphore * sigSem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-720\n"
	"\tbctrl";
#define AttemptSemaphoreShared(sigSem) __AttemptSemaphoreShared(SysBase, (sigSem))

VOID __ColdReboot(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-726\n"
	"\tbctrl";
#define ColdReboot() __ColdReboot(SysBase)

VOID __StackSwap(void *, struct StackSwapStruct * newStack) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-732\n"
	"\tbctrl";
#define StackSwap(newStack) __StackSwap(SysBase, (newStack))

ULONG __NewGetTaskAttrsA(void *, struct Task * task, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-738\n"
	"\tbctrl";
#define NewGetTaskAttrsA(task, Data, DataSize, Type, Tags) __NewGetTaskAttrsA(SysBase, (task), (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewGetTaskAttrs(void *, struct Task * task, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-738\n"
	"\tbctrl";
#define NewGetTaskAttrs(task, Data, DataSize, ...) __NewGetTaskAttrs(SysBase, (task), (Data), (DataSize), __VA_ARGS__)
#endif

ULONG __NewSetTaskAttrsA(void *, struct Task * task, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-744\n"
	"\tbctrl";
#define NewSetTaskAttrsA(task, Data, DataSize, Type, Tags) __NewSetTaskAttrsA(SysBase, (task), (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewSetTaskAttrs(void *, struct Task * task, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-744\n"
	"\tbctrl";
#define NewSetTaskAttrs(task, Data, DataSize, ...) __NewSetTaskAttrs(SysBase, (task), (Data), (DataSize), __VA_ARGS__)
#endif

APTR __CachePreDMA(void *, CONST APTR address, ULONG * length, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-762\n"
	"\tbctrl";
#define CachePreDMA(address, length, flags) __CachePreDMA(SysBase, (address), (length), (flags))

VOID __CachePostDMA(void *, CONST APTR address, ULONG * length, ULONG flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-768\n"
	"\tbctrl";
#define CachePostDMA(address, length, flags) __CachePostDMA(SysBase, (address), (length), (flags))

VOID __AddMemHandler(void *, struct Interrupt * memhand) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-774\n"
	"\tbctrl";
#define AddMemHandler(memhand) __AddMemHandler(SysBase, (memhand))

VOID __RemMemHandler(void *, struct Interrupt * memhand) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-780\n"
	"\tbctrl";
#define RemMemHandler(memhand) __RemMemHandler(SysBase, (memhand))

ULONG __ObtainQuickVector(void *, APTR interruptCode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-786\n"
	"\tbctrl";
#define ObtainQuickVector(interruptCode) __ObtainQuickVector(SysBase, (interruptCode))

APTR __NewSetFunction(void *, struct Library * library, APTR function, LONG offset, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-792\n"
	"\tbctrl";
#define NewSetFunction(library, function, offset, tags) __NewSetFunction(SysBase, (library), (function), (offset), (tags))

struct Library * __NewCreateLibrary(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-798\n"
	"\tbctrl";
#define NewCreateLibrary(tags) __NewCreateLibrary(SysBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Library * __linearvarargs __NewCreateLibraryTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-798\n"
	"\tbctrl";
#define NewCreateLibraryTags(...) __NewCreateLibraryTags(SysBase, __VA_ARGS__)
#endif

ULONG __NewPPCStackSwap(void *, struct StackSwapStruct * newStack, APTR function, struct PPCStackSwapArgs * args) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-804\n"
	"\tbctrl";
#define NewPPCStackSwap(newStack, function, args) __NewPPCStackSwap(SysBase, (newStack), (function), (args))

APTR __TaggedOpenLibrary(void *, LONG LibTag) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-810\n"
	"\tbctrl";
#define TaggedOpenLibrary(LibTag) __TaggedOpenLibrary(SysBase, (LibTag))

ULONG __ReadGayle(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-816\n"
	"\tbctrl";
#define ReadGayle() __ReadGayle(SysBase)

STRPTR __VNewRawDoFmt(void *, CONST_STRPTR FmtString, APTR (*PutChProc)(APTR, UBYTE), STRPTR PutChData, va_list args) =
	"\tlwz\t0,-820(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define VNewRawDoFmt(FmtString, PutChProc, PutChData, args) __VNewRawDoFmt(SysBase, (FmtString), (PutChProc), (PutChData), (args))

VOID __CacheFlushDataArea(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-828\n"
	"\tbctrl";
#define CacheFlushDataArea(Address, Size) __CacheFlushDataArea(SysBase, (Address), (Size))

VOID __CacheInvalidInstArea(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-834\n"
	"\tbctrl";
#define CacheInvalidInstArea(Address, Size) __CacheInvalidInstArea(SysBase, (Address), (Size))

VOID __CacheInvalidDataArea(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-840\n"
	"\tbctrl";
#define CacheInvalidDataArea(Address, Size) __CacheInvalidDataArea(SysBase, (Address), (Size))

VOID __CacheFlushDataInstArea(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-846\n"
	"\tbctrl";
#define CacheFlushDataInstArea(Address, Size) __CacheFlushDataInstArea(SysBase, (Address), (Size))

VOID __CacheTrashCacheArea(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-852\n"
	"\tbctrl";
#define CacheTrashCacheArea(Address, Size) __CacheTrashCacheArea(SysBase, (Address), (Size))

APTR __AllocTaskPooled(void *, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-858\n"
	"\tbctrl";
#define AllocTaskPooled(Size) __AllocTaskPooled(SysBase, (Size))

VOID __FreeTaskPooled(void *, APTR Address, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-864\n"
	"\tbctrl";
#define FreeTaskPooled(Address, Size) __FreeTaskPooled(SysBase, (Address), (Size))

APTR __AllocVecTaskPooled(void *, ULONG Size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-870\n"
	"\tbctrl";
#define AllocVecTaskPooled(Size) __AllocVecTaskPooled(SysBase, (Size))

VOID __FreeVecTaskPooled(void *, APTR Address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-876\n"
	"\tbctrl";
#define FreeVecTaskPooled(Address) __FreeVecTaskPooled(SysBase, (Address))

VOID __FlushPool(void *, APTR poolHeader) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-882\n"
	"\tbctrl";
#define FlushPool(poolHeader) __FlushPool(SysBase, (poolHeader))

VOID __FlushTaskPool(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-888\n"
	"\tbctrl";
#define FlushTaskPool() __FlushTaskPool(SysBase)

APTR __AllocVecPooled(void *, APTR poolHeader, ULONG memSize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-894\n"
	"\tbctrl";
#define AllocVecPooled(poolHeader, memSize) __AllocVecPooled(SysBase, (poolHeader), (memSize))

VOID __FreeVecPooled(void *, APTR poolHeader, APTR memory) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-900\n"
	"\tbctrl";
#define FreeVecPooled(poolHeader, memory) __FreeVecPooled(SysBase, (poolHeader), (memory))

ULONG __NewGetSystemAttrsA(void *, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-906\n"
	"\tbctrl";
#define NewGetSystemAttrsA(Data, DataSize, Type, Tags) __NewGetSystemAttrsA(SysBase, (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewGetSystemAttrs(void *, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-906\n"
	"\tbctrl";
#define NewGetSystemAttrs(Data, DataSize, ...) __NewGetSystemAttrs(SysBase, (Data), (DataSize), __VA_ARGS__)
#endif

ULONG __NewSetSystemAttrsA(void *, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-912\n"
	"\tbctrl";
#define NewSetSystemAttrsA(Data, DataSize, Type, Tags) __NewSetSystemAttrsA(SysBase, (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewSetSystemAttrs(void *, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-912\n"
	"\tbctrl";
#define NewSetSystemAttrs(Data, DataSize, ...) __NewSetSystemAttrs(SysBase, (Data), (DataSize), __VA_ARGS__)
#endif

struct Task * __NewCreateTaskA(void *, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define NewCreateTaskA(Tags) __NewCreateTaskA(SysBase, (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Task * __linearvarargs __NewCreateTask(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-918\n"
	"\tbctrl";
#define NewCreateTask(...) __NewCreateTask(SysBase, __VA_ARGS__)
#endif

STRPTR __NewRawDoFmt(void *, CONST_STRPTR FmtString, APTR (*PutChProc)(APTR, UBYTE), STRPTR PutChData, ...) =
	"\tlwz\t0,-922(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define NewRawDoFmt(FmtString, PutChProc, ...) __NewRawDoFmt(SysBase, (FmtString), (PutChProc), __VA_ARGS__)

APTR __AllocateAligned(void *, struct MemHeader * memHeader, ULONG byteSize, ULONG alignSize, ULONG alignOffset) =
	"\tlwz\t0,-928(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AllocateAligned(memHeader, byteSize, alignSize, alignOffset) __AllocateAligned(SysBase, (memHeader), (byteSize), (alignSize), (alignOffset))

APTR __AllocMemAligned(void *, ULONG byteSize, ULONG attributes, ULONG alignSize, ULONG alignOffset) =
	"\tlwz\t0,-934(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AllocMemAligned(byteSize, attributes, alignSize, alignOffset) __AllocMemAligned(SysBase, (byteSize), (attributes), (alignSize), (alignOffset))

APTR __AllocVecAligned(void *, ULONG byteSize, ULONG attributes, ULONG alignSize, ULONG alignOffset) =
	"\tlwz\t0,-940(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AllocVecAligned(byteSize, attributes, alignSize, alignOffset) __AllocVecAligned(SysBase, (byteSize), (attributes), (alignSize), (alignOffset))

VOID __AddExecNotify(void *, struct Hook * hook) =
	"\tlwz\t0,-946(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AddExecNotify(hook) __AddExecNotify(SysBase, (hook))

VOID __RemExecNotify(void *, struct Hook * hook) =
	"\tlwz\t0,-952(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RemExecNotify(hook) __RemExecNotify(SysBase, (hook))

struct Node * __FindExecNode(void *, ULONG type, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-960\n"
	"\tbctrl";
#define FindExecNode(type, name) __FindExecNode(SysBase, (type), (name))

APTR __AddExecNodeA(void *, APTR innode, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-966\n"
	"\tbctrl";
#define AddExecNodeA(innode, Tags) __AddExecNodeA(SysBase, (innode), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __AddExecNode(void *, APTR innode, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-966\n"
	"\tbctrl";
#define AddExecNode(...) __AddExecNode(SysBase, __VA_ARGS__)
#endif

APTR __AllocVecDMA(void *, ULONG byteSize, ULONG requirements) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-972\n"
	"\tbctrl";
#define AllocVecDMA(byteSize, requirements) __AllocVecDMA(SysBase, (byteSize), (requirements))

VOID __FreeVecDMA(void *, APTR memoryBlock) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-978\n"
	"\tbctrl";
#define FreeVecDMA(memoryBlock) __FreeVecDMA(SysBase, (memoryBlock))

APTR __AllocPooledAligned(void *, APTR poolHeader, ULONG byteSize, ULONG alignSize, ULONG alignOffset) =
	"\tlwz\t0,-982(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AllocPooledAligned(poolHeader, byteSize, alignSize, alignOffset) __AllocPooledAligned(SysBase, (poolHeader), (byteSize), (alignSize), (alignOffset))

LONG __AddResident(void *, struct Resident * resident) =
	"\tlwz\t0,-988(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AddResident(resident) __AddResident(SysBase, (resident))

struct Task * __FindTaskByPID(void *, ULONG processID) =
	"\tlwz\t0,-994(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define FindTaskByPID(processID) __FindTaskByPID(SysBase, (processID))

void __DumpTaskState(void *, struct Task * task) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-1026\n"
	"\tbctrl";
#define DumpTaskState(task) __DumpTaskState(SysBase, (task))

void __AddExecNotifyType(void *, struct Hook * hook, LONG type) =
	"\tlwz\t0,-1030(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AddExecNotifyType(hook, type) __AddExecNotifyType(SysBase, (hook), (type))

ULONG __ShutdownA(void *, struct TagItem * TagItems) =
	"\tlwz\t0,-1036(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ShutdownA(TagItems) __ShutdownA(SysBase, (TagItems))

ULONG __AvailPool(void *, APTR poolHeader, ULONG flags) =
	"\tlwz\t0,-1048(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AvailPool(poolHeader, flags) __AvailPool(SysBase, (poolHeader), (flags))

void __PutMsgHead(void *, struct MsgPort * port, struct Message * message) =
	"\tlwz\t0,-1060(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define PutMsgHead(port, message) __PutMsgHead(SysBase, (port), (message))

ULONG __NewGetTaskPIDAttrsA(void *, ULONG TaskPID, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-1068\n"
	"\tbctrl";
#define NewGetTaskPIDAttrsA(TaskPID, Data, DataSize, Type, Tags) __NewGetTaskPIDAttrsA(SysBase, (TaskPID), (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewGetTaskPIDAttrs(void *, ULONG TaskPID, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1068\n"
	"\tbctrl";
#define NewGetTaskPIDAttrs(TaskPID, Data, DataSize, ...) __NewGetTaskPIDAttrs(SysBase, (TaskPID), (Data), (DataSize), __VA_ARGS__)
#endif

ULONG __NewSetTaskPIDAttrsA(void *, ULONG TaskPID, APTR Data, ULONG DataSize, ULONG Type, struct TagItem * Tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,36(2)\n"
	"\tli\t3,-1074\n"
	"\tbctrl";
#define NewSetTaskPIDAttrsA(TaskPID, Data, DataSize, Type, Tags) __NewSetTaskPIDAttrsA(SysBase, (TaskPID), (Data), (DataSize), (Type), (Tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __NewSetTaskPIDAttrs(void *, ULONG TaskPID, APTR Data, ULONG DataSize, ULONG Type, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-1074\n"
	"\tbctrl";
#define NewSetTaskPIDAttrs(TaskPID, Data, DataSize, ...) __NewSetTaskPIDAttrs(SysBase, (TaskPID), (Data), (DataSize), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_EXEC_H  */
