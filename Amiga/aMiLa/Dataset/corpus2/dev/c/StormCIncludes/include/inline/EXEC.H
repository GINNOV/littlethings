#ifndef _INLINE_EXEC_H
#define _INLINE_EXEC_H

#ifndef EXEC_BASE_NAME
#define EXEC_BASE_NAME SysBase
#endif

#define Supervisor(userFunction) \
	((ULONG (*)(ULONG (*)(VOID) __asm("a5"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 30))(userFunction, (struct Library *) EXEC_BASE_NAME)

#define InitCode(startClass, version) \
	((VOID (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 72))(startClass, version, (struct Library *) EXEC_BASE_NAME)

#define InitStruct(initTable, memory, size) \
	((VOID (*)(CONST APTR __asm("a1"), APTR __asm("a2"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 78))(initTable, memory, size, (struct Library *) EXEC_BASE_NAME)

#define MakeLibrary(funcInit, structInit, libInit, dataSize, segList) \
	((struct Library * (*)(CONST APTR __asm("a0"), CONST APTR __asm("a1"), ULONG (*)(VOID) __asm("a2"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 84))(funcInit, structInit, libInit, dataSize, segList, (struct Library *) EXEC_BASE_NAME)

#define MakeFunctions(target, functionArray, funcDispBase) \
	((VOID (*)(APTR __asm("a0"), CONST APTR __asm("a1"), ULONG __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 90))(target, functionArray, funcDispBase, (struct Library *) EXEC_BASE_NAME)

#define FindResident(name) \
	((struct Resident * (*)(CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 96))(name, (struct Library *) EXEC_BASE_NAME)

#define InitResident(resident, segList) \
	((APTR (*)(CONST struct Resident * __asm("a1"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 102))(resident, segList, (struct Library *) EXEC_BASE_NAME)

#define Alert(alertNum) \
	((VOID (*)(ULONG __asm("d7"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 108))(alertNum, (struct Library *) EXEC_BASE_NAME)

#define Debug(flags) \
	((VOID (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 114))(flags, (struct Library *) EXEC_BASE_NAME)

#define Disable() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 120))((struct Library *) EXEC_BASE_NAME)

#define Enable() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 126))((struct Library *) EXEC_BASE_NAME)

#define Forbid() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 132))((struct Library *) EXEC_BASE_NAME)

#define Permit() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 138))((struct Library *) EXEC_BASE_NAME)

#define SetSR(newSR, mask) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 144))(newSR, mask, (struct Library *) EXEC_BASE_NAME)

#define SuperState() \
	((APTR (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 150))((struct Library *) EXEC_BASE_NAME)

#define UserState(sysStack) \
	((VOID (*)(APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 156))(sysStack, (struct Library *) EXEC_BASE_NAME)

#define SetIntVector(intNumber, interrupt) \
	((struct Interrupt * (*)(LONG __asm("d0"), CONST struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 162))(intNumber, interrupt, (struct Library *) EXEC_BASE_NAME)

#define AddIntServer(intNumber, interrupt) \
	((VOID (*)(LONG __asm("d0"), struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 168))(intNumber, interrupt, (struct Library *) EXEC_BASE_NAME)

#define RemIntServer(intNumber, interrupt) \
	((VOID (*)(LONG __asm("d0"), struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 174))(intNumber, interrupt, (struct Library *) EXEC_BASE_NAME)

#define Cause(interrupt) \
	((VOID (*)(struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 180))(interrupt, (struct Library *) EXEC_BASE_NAME)

#define Allocate(freeList, byteSize) \
	((APTR (*)(struct MemHeader * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 186))(freeList, byteSize, (struct Library *) EXEC_BASE_NAME)

#define Deallocate(freeList, memoryBlock, byteSize) \
	((VOID (*)(struct MemHeader * __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 192))(freeList, memoryBlock, byteSize, (struct Library *) EXEC_BASE_NAME)

#define AllocMem(byteSize, requirements) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 198))(byteSize, requirements, (struct Library *) EXEC_BASE_NAME)

#define AllocAbs(byteSize, location) \
	((APTR (*)(ULONG __asm("d0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 204))(byteSize, location, (struct Library *) EXEC_BASE_NAME)

#define FreeMem(memoryBlock, byteSize) \
	((VOID (*)(APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 210))(memoryBlock, byteSize, (struct Library *) EXEC_BASE_NAME)

#define AvailMem(requirements) \
	((ULONG (*)(ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 216))(requirements, (struct Library *) EXEC_BASE_NAME)

#define AllocEntry(entry) \
	((struct MemList * (*)(struct MemList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 222))(entry, (struct Library *) EXEC_BASE_NAME)

#define FreeEntry(entry) \
	((VOID (*)(struct MemList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 228))(entry, (struct Library *) EXEC_BASE_NAME)

#define Insert(list, node, pred) \
	((VOID (*)(struct List * __asm("a0"), struct Node * __asm("a1"), struct Node * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 234))(list, node, pred, (struct Library *) EXEC_BASE_NAME)

#define AddHead(list, node) \
	((VOID (*)(struct List * __asm("a0"), struct Node * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 240))(list, node, (struct Library *) EXEC_BASE_NAME)

#define AddTail(list, node) \
	((VOID (*)(struct List * __asm("a0"), struct Node * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 246))(list, node, (struct Library *) EXEC_BASE_NAME)

#define Remove(node) \
	((VOID (*)(struct Node * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 252))(node, (struct Library *) EXEC_BASE_NAME)

#define RemHead(list) \
	((struct Node * (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 258))(list, (struct Library *) EXEC_BASE_NAME)

#define RemTail(list) \
	((struct Node * (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 264))(list, (struct Library *) EXEC_BASE_NAME)

#define Enqueue(list, node) \
	((VOID (*)(struct List * __asm("a0"), struct Node * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 270))(list, node, (struct Library *) EXEC_BASE_NAME)

#define FindName(list, name) \
	((struct Node * (*)(struct List * __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 276))(list, name, (struct Library *) EXEC_BASE_NAME)

#define AddTask(task, initPC, finalPC) \
	((APTR (*)(struct Task * __asm("a1"), CONST APTR __asm("a2"), CONST APTR __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 282))(task, initPC, finalPC, (struct Library *) EXEC_BASE_NAME)

#define RemTask(task) \
	((VOID (*)(struct Task * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 288))(task, (struct Library *) EXEC_BASE_NAME)

#define FindTask(name) \
	((struct Task * (*)(CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 294))(name, (struct Library *) EXEC_BASE_NAME)

#define SetTaskPri(task, priority) \
	((BYTE (*)(struct Task * __asm("a1"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 300))(task, priority, (struct Library *) EXEC_BASE_NAME)

#define SetSignal(newSignals, signalSet) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 306))(newSignals, signalSet, (struct Library *) EXEC_BASE_NAME)

#define SetExcept(newSignals, signalSet) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 312))(newSignals, signalSet, (struct Library *) EXEC_BASE_NAME)

#define Wait(signalSet) \
	((ULONG (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 318))(signalSet, (struct Library *) EXEC_BASE_NAME)

#define Signal(task, signalSet) \
	((VOID (*)(struct Task * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 324))(task, signalSet, (struct Library *) EXEC_BASE_NAME)

#define AllocSignal(signalNum) \
	((BYTE (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 330))(signalNum, (struct Library *) EXEC_BASE_NAME)

#define FreeSignal(signalNum) \
	((VOID (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 336))(signalNum, (struct Library *) EXEC_BASE_NAME)

#define AllocTrap(trapNum) \
	((LONG (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 342))(trapNum, (struct Library *) EXEC_BASE_NAME)

#define FreeTrap(trapNum) \
	((VOID (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 348))(trapNum, (struct Library *) EXEC_BASE_NAME)

#define AddPort(port) \
	((VOID (*)(struct MsgPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 354))(port, (struct Library *) EXEC_BASE_NAME)

#define RemPort(port) \
	((VOID (*)(struct MsgPort * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 360))(port, (struct Library *) EXEC_BASE_NAME)

#define PutMsg(port, message) \
	((VOID (*)(struct MsgPort * __asm("a0"), struct Message * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 366))(port, message, (struct Library *) EXEC_BASE_NAME)

#define GetMsg(port) \
	((struct Message * (*)(struct MsgPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 372))(port, (struct Library *) EXEC_BASE_NAME)

#define ReplyMsg(message) \
	((VOID (*)(struct Message * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 378))(message, (struct Library *) EXEC_BASE_NAME)

#define WaitPort(port) \
	((struct Message * (*)(struct MsgPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 384))(port, (struct Library *) EXEC_BASE_NAME)

#define FindPort(name) \
	((struct MsgPort * (*)(CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 390))(name, (struct Library *) EXEC_BASE_NAME)

#define AddLibrary(library) \
	((VOID (*)(struct Library * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 396))(library, (struct Library *) EXEC_BASE_NAME)

#define RemLibrary(library) \
	((VOID (*)(struct Library * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 402))(library, (struct Library *) EXEC_BASE_NAME)

#define OldOpenLibrary(libName) \
	((struct Library * (*)(CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 408))(libName, (struct Library *) EXEC_BASE_NAME)

#define CloseLibrary(library) \
	((VOID (*)(struct Library * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 414))(library, (struct Library *) EXEC_BASE_NAME)

#define SetFunction(library, funcOffset, newFunction) \
	((APTR (*)(struct Library * __asm("a1"), LONG __asm("a0"), ULONG (*)(VOID) __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 420))(library, funcOffset, newFunction, (struct Library *) EXEC_BASE_NAME)

#define SumLibrary(library) \
	((VOID (*)(struct Library * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 426))(library, (struct Library *) EXEC_BASE_NAME)

#define AddDevice(device) \
	((VOID (*)(struct Device * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 432))(device, (struct Library *) EXEC_BASE_NAME)

#define RemDevice(device) \
	((VOID (*)(struct Device * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 438))(device, (struct Library *) EXEC_BASE_NAME)

#define OpenDevice(devName, unit, ioRequest, flags) \
	((BYTE (*)(CONST_STRPTR __asm("a0"), ULONG __asm("d0"), struct IORequest * __asm("a1"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 444))(devName, unit, ioRequest, flags, (struct Library *) EXEC_BASE_NAME)

#define CloseDevice(ioRequest) \
	((VOID (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 450))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define DoIO(ioRequest) \
	((BYTE (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 456))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define SendIO(ioRequest) \
	((VOID (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 462))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define CheckIO(ioRequest) \
	((struct IORequest * (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 468))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define WaitIO(ioRequest) \
	((BYTE (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 474))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define AbortIO(ioRequest) \
	((VOID (*)(struct IORequest * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 480))(ioRequest, (struct Library *) EXEC_BASE_NAME)

#define AddResource(resource) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 486))(resource, (struct Library *) EXEC_BASE_NAME)

#define RemResource(resource) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 492))(resource, (struct Library *) EXEC_BASE_NAME)

#define OpenResource(resName) \
	((APTR (*)(CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 498))(resName, (struct Library *) EXEC_BASE_NAME)

#define RawDoFmt(formatString, dataStream, putChProc, putChData) \
	((APTR (*)(CONST_STRPTR __asm("a0"), CONST APTR __asm("a1"), VOID (*)(VOID) __asm("a2"), APTR __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 522))(formatString, dataStream, putChProc, putChData, (struct Library *) EXEC_BASE_NAME)

#define GetCC() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 528))((struct Library *) EXEC_BASE_NAME)

#define TypeOfMem(address) \
	((ULONG (*)(CONST APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 534))(address, (struct Library *) EXEC_BASE_NAME)

#define Procure(sigSem, bidMsg) \
	((ULONG (*)(struct SignalSemaphore * __asm("a0"), struct SemaphoreMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 540))(sigSem, bidMsg, (struct Library *) EXEC_BASE_NAME)

#define Vacate(sigSem, bidMsg) \
	((VOID (*)(struct SignalSemaphore * __asm("a0"), struct SemaphoreMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 546))(sigSem, bidMsg, (struct Library *) EXEC_BASE_NAME)

#define OpenLibrary(libName, version) \
	((struct Library * (*)(CONST_STRPTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 552))(libName, version, (struct Library *) EXEC_BASE_NAME)

#define InitSemaphore(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 558))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define ObtainSemaphore(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 564))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define ReleaseSemaphore(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 570))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define AttemptSemaphore(sigSem) \
	((ULONG (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 576))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define ObtainSemaphoreList(sigSem) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 582))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define ReleaseSemaphoreList(sigSem) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 588))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define FindSemaphore(name) \
	((struct SignalSemaphore * (*)(STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 594))(name, (struct Library *) EXEC_BASE_NAME)

#define AddSemaphore(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 600))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define RemSemaphore(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 606))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define SumKickData() \
	((ULONG (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 612))((struct Library *) EXEC_BASE_NAME)

#define AddMemList(size, attributes, pri, base, name) \
	((VOID (*)(ULONG __asm("d0"), ULONG __asm("d1"), LONG __asm("d2"), APTR __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 618))(size, attributes, pri, base, name, (struct Library *) EXEC_BASE_NAME)

#define CopyMem(source, dest, size) \
	((VOID (*)(CONST APTR __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 624))(source, dest, size, (struct Library *) EXEC_BASE_NAME)

#define CopyMemQuick(source, dest, size) \
	((VOID (*)(CONST APTR __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 630))(source, dest, size, (struct Library *) EXEC_BASE_NAME)

#define CacheClearU() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 636))((struct Library *) EXEC_BASE_NAME)

#define CacheClearE(address, length, caches) \
	((VOID (*)(APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 642))(address, length, caches, (struct Library *) EXEC_BASE_NAME)

#define CacheControl(cacheBits, cacheMask) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 648))(cacheBits, cacheMask, (struct Library *) EXEC_BASE_NAME)

#define CreateIORequest(port, size) \
	((APTR (*)(CONST struct MsgPort * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 654))(port, size, (struct Library *) EXEC_BASE_NAME)

#define DeleteIORequest(iorequest) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 660))(iorequest, (struct Library *) EXEC_BASE_NAME)

#define CreateMsgPort() \
	((struct MsgPort * (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 666))((struct Library *) EXEC_BASE_NAME)

#define DeleteMsgPort(port) \
	((VOID (*)(struct MsgPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 672))(port, (struct Library *) EXEC_BASE_NAME)

#define ObtainSemaphoreShared(sigSem) \
	((VOID (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 678))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define AllocVec(byteSize, requirements) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 684))(byteSize, requirements, (struct Library *) EXEC_BASE_NAME)

#define FreeVec(memoryBlock) \
	((VOID (*)(APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 690))(memoryBlock, (struct Library *) EXEC_BASE_NAME)

#define CreatePool(requirements, puddleSize, threshSize) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 696))(requirements, puddleSize, threshSize, (struct Library *) EXEC_BASE_NAME)

#define DeletePool(poolHeader) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 702))(poolHeader, (struct Library *) EXEC_BASE_NAME)

#define AllocPooled(poolHeader, memSize) \
	((APTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 708))(poolHeader, memSize, (struct Library *) EXEC_BASE_NAME)

#define FreePooled(poolHeader, memory, memSize) \
	((VOID (*)(APTR __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 714))(poolHeader, memory, memSize, (struct Library *) EXEC_BASE_NAME)

#define AttemptSemaphoreShared(sigSem) \
	((ULONG (*)(struct SignalSemaphore * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 720))(sigSem, (struct Library *) EXEC_BASE_NAME)

#define ColdReboot() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 726))((struct Library *) EXEC_BASE_NAME)

#define StackSwap(newStack) \
	((VOID (*)(struct StackSwapStruct * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 732))(newStack, (struct Library *) EXEC_BASE_NAME)

#define ChildFree(tid) \
	((VOID (*)(APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 738))(tid, (struct Library *) EXEC_BASE_NAME)

#define ChildOrphan(tid) \
	((VOID (*)(APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 744))(tid, (struct Library *) EXEC_BASE_NAME)

#define ChildStatus(tid) \
	((VOID (*)(APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 750))(tid, (struct Library *) EXEC_BASE_NAME)

#define ChildWait(tid) \
	((VOID (*)(APTR __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 756))(tid, (struct Library *) EXEC_BASE_NAME)

#define CachePreDMA(address, length, flags) \
	((APTR (*)(CONST APTR __asm("a0"), ULONG * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 762))(address, length, flags, (struct Library *) EXEC_BASE_NAME)

#define CachePostDMA(address, length, flags) \
	((VOID (*)(CONST APTR __asm("a0"), ULONG * __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 768))(address, length, flags, (struct Library *) EXEC_BASE_NAME)

#define AddMemHandler(memhand) \
	((VOID (*)(struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 774))(memhand, (struct Library *) EXEC_BASE_NAME)

#define RemMemHandler(memhand) \
	((VOID (*)(struct Interrupt * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 780))(memhand, (struct Library *) EXEC_BASE_NAME)

#define ObtainQuickVector(interruptCode) \
	((ULONG (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 786))(interruptCode, (struct Library *) EXEC_BASE_NAME)

#define AVL_AddNode(root, node, func) \
        ((struct AVLNode * (*)(struct AVLNode ** __asm("a0"), struct AVLNode * __asm("a1"), AVLNODECOMP __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 852))(root, node, func, (struct Library *) EXEC_BASE_NAME)

#define AVL_RemNodeByAddress(root, node) \
        ((struct AVLNode * (*)(struct AVLNode ** __asm("a0"), struct AVLNode * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 858))(root, node, (struct Library *) EXEC_BASE_NAME)

#define AVL_RemNodeByKey(root, key, func) \
        ((struct AVLNode * (*)(struct AVLNode ** __asm("a0"), struct AVLNode * __asm("a1"), AVLKEYCOMP __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 864))(root, key, func, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindNode(root, key, func) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), AVLKey __asm("a1"), AVLKEYCOMP __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 870))(root, key, func, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindPrevNodeByAddress(node) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 876))(node, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindPrevNodeByKey(root, key, func) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), AVLKey __asm("a1"), AVLKEYCOMP __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 882))(root, key, func, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindNextNodeByAddress(node) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 888))(node, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindNextNodeByKey(root, key, func) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), AVLKey __asm("a1"), AVLKEYCOMP __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 894))(root, key, func, (struct Library *) EXEC_BASE_NAME)

#define AVL_FindFirstNode(root) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 900))(root (struct Library *) EXEC_BASE_NAME)

#define AVL_FindLastNode(root) \
        ((struct AVLNode * (*)(const struct AVLNode * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) EXEC_BASE_NAME) - 906))(root (struct Library *) EXEC_BASE_NAME)

#endif /*  _INLINE_EXEC_H  */
