#ifndef _VBCCINLINE_POWERPC_H
#define _VBCCINLINE_POWERPC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

ULONG __Run68K(void *, struct PPCArgs * PPStruct)="\tlwz\tr0,-298(r3)\n\tmtlr\tr0\n\tblrl";
#define Run68K(PPStruct) __Run68K(PowerPCBase, (PPStruct))

ULONG __WaitFor68K(void *, struct PPCArgs * PPStruct)="\tlwz\tr0,-304(r3)\n\tmtlr\tr0\n\tblrl";
#define WaitFor68K(PPStruct) __WaitFor68K(PowerPCBase, (PPStruct))

VOID __SPrintF(void *, STRPTR Formatstring, APTR Values)="\tlwz\tr0,-310(r3)\n\tmtlr\tr0\n\tblrl";
#define SPrintF(Formatstring, Values) __SPrintF(PowerPCBase, (Formatstring), (Values))

APTR __AllocVecPPC(void *, ULONG size, ULONG flags, ULONG align)="\tlwz\tr0,-322(r3)\n\tmtlr\tr0\n\tblrl";
#define AllocVecPPC(size, flags, align) __AllocVecPPC(PowerPCBase, (size), (flags), (align))

LONG __FreeVecPPC(void *, APTR memblock)="\tlwz\tr0,-328(r3)\n\tmtlr\tr0\n\tblrl";
#define FreeVecPPC(memblock) __FreeVecPPC(PowerPCBase, (memblock))

struct TaskPPC * __CreateTaskPPC(void *, struct TagItem * taglist)="\tlwz\tr0,-334(r3)\n\tmtlr\tr0\n\tblrl";
#define CreateTaskPPC(taglist) __CreateTaskPPC(PowerPCBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct TaskPPC * __CreateTaskPPCTags(void *, int dummy, Tag taglist, ...)="\tstw\tr4,28(r1)\n\taddi\tr4,r1,28\n\tlwz\tr0,-334(r3)\n\tmtlr\tr0\n\tblrl";
#define CreateTaskPPCTags(...) __CreateTaskPPCTags(PowerPCBase, 0, __VA_ARGS__)
#endif

VOID __DeleteTaskPPC(void *, struct TaskPPC * PPCtask)="\tlwz\tr0,-340(r3)\n\tmtlr\tr0\n\tblrl";
#define DeleteTaskPPC(PPCtask) __DeleteTaskPPC(PowerPCBase, (PPCtask))

struct TaskPPC * __FindTaskPPC(void *, STRPTR name)="\tlwz\tr0,-346(r3)\n\tmtlr\tr0\n\tblrl";
#define FindTaskPPC(name) __FindTaskPPC(PowerPCBase, (name))

LONG __InitSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-352(r3)\n\tmtlr\tr0\n\tblrl";
#define InitSemaphorePPC(SemaphorePPC) __InitSemaphorePPC(PowerPCBase, (SemaphorePPC))

VOID __FreeSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-358(r3)\n\tmtlr\tr0\n\tblrl";
#define FreeSemaphorePPC(SemaphorePPC) __FreeSemaphorePPC(PowerPCBase, (SemaphorePPC))

VOID __AddSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-364(r3)\n\tmtlr\tr0\n\tblrl";
#define AddSemaphorePPC(SemaphorePPC) __AddSemaphorePPC(PowerPCBase, (SemaphorePPC))

VOID __RemSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-370(r3)\n\tmtlr\tr0\n\tblrl";
#define RemSemaphorePPC(SemaphorePPC) __RemSemaphorePPC(PowerPCBase, (SemaphorePPC))

VOID __ObtainSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-376(r3)\n\tmtlr\tr0\n\tblrl";
#define ObtainSemaphorePPC(SemaphorePPC) __ObtainSemaphorePPC(PowerPCBase, (SemaphorePPC))

LONG __AttemptSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-382(r3)\n\tmtlr\tr0\n\tblrl";
#define AttemptSemaphorePPC(SemaphorePPC) __AttemptSemaphorePPC(PowerPCBase, (SemaphorePPC))

VOID __ReleaseSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-388(r3)\n\tmtlr\tr0\n\tblrl";
#define ReleaseSemaphorePPC(SemaphorePPC) __ReleaseSemaphorePPC(PowerPCBase, (SemaphorePPC))

struct SignalSemaphorePPC * __FindSemaphorePPC(void *, STRPTR name)="\tlwz\tr0,-394(r3)\n\tmtlr\tr0\n\tblrl";
#define FindSemaphorePPC(name) __FindSemaphorePPC(PowerPCBase, (name))

VOID __InsertPPC(void *, struct List * list, struct Node * node, struct Node * pred)="\tlwz\tr0,-400(r3)\n\tmtlr\tr0\n\tblrl";
#define InsertPPC(list, node, pred) __InsertPPC(PowerPCBase, (list), (node), (pred))

VOID __AddHeadPPC(void *, struct List * list, struct Node * node)="\tlwz\tr0,-406(r3)\n\tmtlr\tr0\n\tblrl";
#define AddHeadPPC(list, node) __AddHeadPPC(PowerPCBase, (list), (node))

VOID __AddTailPPC(void *, struct List * list, struct Node * node)="\tlwz\tr0,-412(r3)\n\tmtlr\tr0\n\tblrl";
#define AddTailPPC(list, node) __AddTailPPC(PowerPCBase, (list), (node))

VOID __RemovePPC(void *, struct Node * node)="\tlwz\tr0,-418(r3)\n\tmtlr\tr0\n\tblrl";
#define RemovePPC(node) __RemovePPC(PowerPCBase, (node))

struct Node * __RemHeadPPC(void *, struct List * list)="\tlwz\tr0,-424(r3)\n\tmtlr\tr0\n\tblrl";
#define RemHeadPPC(list) __RemHeadPPC(PowerPCBase, (list))

struct Node * __RemTailPPC(void *, struct Node * list)="\tlwz\tr0,-430(r3)\n\tmtlr\tr0\n\tblrl";
#define RemTailPPC(list) __RemTailPPC(PowerPCBase, (list))

VOID __EnqueuePPC(void *, struct List * list, struct Node * node)="\tlwz\tr0,-436(r3)\n\tmtlr\tr0\n\tblrl";
#define EnqueuePPC(list, node) __EnqueuePPC(PowerPCBase, (list), (node))

struct Node * __FindNamePPC(void *, struct List * list, STRPTR name)="\tlwz\tr0,-442(r3)\n\tmtlr\tr0\n\tblrl";
#define FindNamePPC(list, name) __FindNamePPC(PowerPCBase, (list), (name))

struct TagItem * __FindTagItemPPC(void *, ULONG value, struct TagItem * taglist)="\tlwz\tr0,-448(r3)\n\tmtlr\tr0\n\tblrl";
#define FindTagItemPPC(value, taglist) __FindTagItemPPC(PowerPCBase, (value), (taglist))

ULONG __GetTagDataPPC(void *, ULONG value, ULONG d0arg, struct TagItem * taglist)="\tlwz\tr0,-454(r3)\n\tmtlr\tr0\n\tblrl";
#define GetTagDataPPC(value, d0arg, taglist) __GetTagDataPPC(PowerPCBase, (value), (d0arg), (taglist))

struct TagItem * __NextTagItemPPC(void *, struct TagItem ** tagitem)="\tlwz\tr0,-460(r3)\n\tmtlr\tr0\n\tblrl";
#define NextTagItemPPC(tagitem) __NextTagItemPPC(PowerPCBase, (tagitem))

LONG __AllocSignalPPC(void *, LONG signum)="\tlwz\tr0,-466(r3)\n\tmtlr\tr0\n\tblrl";
#define AllocSignalPPC(signum) __AllocSignalPPC(PowerPCBase, (signum))

VOID __FreeSignalPPC(void *, LONG signum)="\tlwz\tr0,-472(r3)\n\tmtlr\tr0\n\tblrl";
#define FreeSignalPPC(signum) __FreeSignalPPC(PowerPCBase, (signum))

ULONG __SetSignalPPC(void *, ULONG signals, ULONG mask)="\tlwz\tr0,-478(r3)\n\tmtlr\tr0\n\tblrl";
#define SetSignalPPC(signals, mask) __SetSignalPPC(PowerPCBase, (signals), (mask))

VOID __SignalPPC(void *, struct TaskPPC * task, ULONG signals)="\tlwz\tr0,-484(r3)\n\tmtlr\tr0\n\tblrl";
#define SignalPPC(task, signals) __SignalPPC(PowerPCBase, (task), (signals))

ULONG __WaitPPC(void *, ULONG signals)="\tlwz\tr0,-490(r3)\n\tmtlr\tr0\n\tblrl";
#define WaitPPC(signals) __WaitPPC(PowerPCBase, (signals))

LONG __SetTaskPriPPC(void *, struct TaskPPC * task, LONG pri)="\tlwz\tr0,-496(r3)\n\tmtlr\tr0\n\tblrl";
#define SetTaskPriPPC(task, pri) __SetTaskPriPPC(PowerPCBase, (task), (pri))

VOID __Signal68K(void *, struct Task * task, ULONG signals)="\tlwz\tr0,-502(r3)\n\tmtlr\tr0\n\tblrl";
#define Signal68K(task, signals) __Signal68K(PowerPCBase, (task), (signals))

VOID __SetCache(void *, ULONG flags, APTR start, ULONG length)="\tlwz\tr0,-508(r3)\n\tmtlr\tr0\n\tblrl";
#define SetCache(flags, start, length) __SetCache(PowerPCBase, (flags), (start), (length))

APTR __SetExcHandler(void *, struct TagItem * taglist)="\tlwz\tr0,-514(r3)\n\tmtlr\tr0\n\tblrl";
#define SetExcHandler(taglist) __SetExcHandler(PowerPCBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __SetExcHandlerTags(void *, int dummy, Tag taglist, ...)="\tstw\tr4,28(r1)\n\taddi\tr4,r1,28\n\tlwz\tr0,-514(r3)\n\tmtlr\tr0\n\tblrl";
#define SetExcHandlerTags(...) __SetExcHandlerTags(PowerPCBase, 0, __VA_ARGS__)
#endif

VOID __RemExcHandler(void *, APTR xlock)="\tlwz\tr0,-520(r3)\n\tmtlr\tr0\n\tblrl";
#define RemExcHandler(xlock) __RemExcHandler(PowerPCBase, (xlock))

ULONG __Super(void *)="\tlwz\tr0,-526(r3)\n\tmtlr\tr0\n\tblrl";
#define Super() __Super(PowerPCBase)

VOID __User(void *, ULONG key)="\tlwz\tr0,-532(r3)\n\tmtlr\tr0\n\tblrl";
#define User(key) __User(PowerPCBase, (key))

ULONG __SetHardware(void *, ULONG flags, APTR param)="\tlwz\tr0,-538(r3)\n\tmtlr\tr0\n\tblrl";
#define SetHardware(flags, param) __SetHardware(PowerPCBase, (flags), (param))

VOID __ModifyFPExc(void *, ULONG fpflags)="\tlwz\tr0,-544(r3)\n\tmtlr\tr0\n\tblrl";
#define ModifyFPExc(fpflags) __ModifyFPExc(PowerPCBase, (fpflags))

ULONG __WaitTime(void *, ULONG signals, ULONG time)="\tlwz\tr0,-550(r3)\n\tmtlr\tr0\n\tblrl";
#define WaitTime(signals, time) __WaitTime(PowerPCBase, (signals), (time))

struct TaskPtr * __LockTaskList(void *)="\tlwz\tr0,-562(r3)\n\tmtlr\tr0\n\tblrl";
#define LockTaskList() __LockTaskList(PowerPCBase)

VOID __UnLockTaskList(void *)="\tlwz\tr0,-568(r3)\n\tmtlr\tr0\n\tblrl";
#define UnLockTaskList() __UnLockTaskList(PowerPCBase)

VOID __SetExcMMU(void *)="\tlwz\tr0,-574(r3)\n\tmtlr\tr0\n\tblrl";
#define SetExcMMU() __SetExcMMU(PowerPCBase)

VOID __ClearExcMMU(void *)="\tlwz\tr0,-580(r3)\n\tmtlr\tr0\n\tblrl";
#define ClearExcMMU() __ClearExcMMU(PowerPCBase)

VOID __ChangeMMU(void *, ULONG mode)="\tlwz\tr0,-586(r3)\n\tmtlr\tr0\n\tblrl";
#define ChangeMMU(mode) __ChangeMMU(PowerPCBase, (mode))

VOID __GetInfo(void *, struct TagItem * taglist)="\tlwz\tr0,-592(r3)\n\tmtlr\tr0\n\tblrl";
#define GetInfo(taglist) __GetInfo(PowerPCBase, (taglist))

struct MsgPortPPC * __CreateMsgPortPPC(void *)="\tlwz\tr0,-598(r3)\n\tmtlr\tr0\n\tblrl";
#define CreateMsgPortPPC() __CreateMsgPortPPC(PowerPCBase)

VOID __DeleteMsgPortPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-604(r3)\n\tmtlr\tr0\n\tblrl";
#define DeleteMsgPortPPC(port) __DeleteMsgPortPPC(PowerPCBase, (port))

VOID __AddPortPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-610(r3)\n\tmtlr\tr0\n\tblrl";
#define AddPortPPC(port) __AddPortPPC(PowerPCBase, (port))

VOID __RemPortPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-616(r3)\n\tmtlr\tr0\n\tblrl";
#define RemPortPPC(port) __RemPortPPC(PowerPCBase, (port))

struct MsgPortPPC * __FindPortPPC(void *, STRPTR port)="\tlwz\tr0,-622(r3)\n\tmtlr\tr0\n\tblrl";
#define FindPortPPC(port) __FindPortPPC(PowerPCBase, (port))

struct Message * __WaitPortPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-628(r3)\n\tmtlr\tr0\n\tblrl";
#define WaitPortPPC(port) __WaitPortPPC(PowerPCBase, (port))

VOID __PutMsgPPC(void *, struct MsgPortPPC * port, struct Message * message)="\tlwz\tr0,-634(r3)\n\tmtlr\tr0\n\tblrl";
#define PutMsgPPC(port, message) __PutMsgPPC(PowerPCBase, (port), (message))

struct Message * __GetMsgPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-640(r3)\n\tmtlr\tr0\n\tblrl";
#define GetMsgPPC(port) __GetMsgPPC(PowerPCBase, (port))

VOID __ReplyMsgPPC(void *, struct Message * message)="\tlwz\tr0,-646(r3)\n\tmtlr\tr0\n\tblrl";
#define ReplyMsgPPC(message) __ReplyMsgPPC(PowerPCBase, (message))

VOID __FreeAllMem(void *)="\tlwz\tr0,-652(r3)\n\tmtlr\tr0\n\tblrl";
#define FreeAllMem() __FreeAllMem(PowerPCBase)

VOID __CopyMemPPC(void *, APTR source, APTR dest, ULONG size)="\tlwz\tr0,-658(r3)\n\tmtlr\tr0\n\tblrl";
#define CopyMemPPC(source, dest, size) __CopyMemPPC(PowerPCBase, (source), (dest), (size))

struct Message * __AllocXMsgPPC(void *, ULONG length, struct MsgPortPPC * port)="\tlwz\tr0,-664(r3)\n\tmtlr\tr0\n\tblrl";
#define AllocXMsgPPC(length, port) __AllocXMsgPPC(PowerPCBase, (length), (port))

VOID __FreeXMsgPPC(void *, struct Message * message)="\tlwz\tr0,-670(r3)\n\tmtlr\tr0\n\tblrl";
#define FreeXMsgPPC(message) __FreeXMsgPPC(PowerPCBase, (message))

VOID __PutXMsgPPC(void *, struct MsgPort * port, struct Message * message)="\tlwz\tr0,-676(r3)\n\tmtlr\tr0\n\tblrl";
#define PutXMsgPPC(port, message) __PutXMsgPPC(PowerPCBase, (port), (message))

VOID __GetSysTimePPC(void *, struct timeval * timeval)="\tlwz\tr0,-682(r3)\n\tmtlr\tr0\n\tblrl";
#define GetSysTimePPC(timeval) __GetSysTimePPC(PowerPCBase, (timeval))

VOID __AddTimePPC(void *, struct timeval * dest, struct timeval * source)="\tlwz\tr0,-688(r3)\n\tmtlr\tr0\n\tblrl";
#define AddTimePPC(dest, source) __AddTimePPC(PowerPCBase, (dest), (source))

VOID __SubTimePPC(void *, struct timeval * dest, struct timeval * source)="\tlwz\tr0,-694(r3)\n\tmtlr\tr0\n\tblrl";
#define SubTimePPC(dest, source) __SubTimePPC(PowerPCBase, (dest), (source))

LONG __CmpTimePPC(void *, struct timeval * dest, struct timeval * source)="\tlwz\tr0,-700(r3)\n\tmtlr\tr0\n\tblrl";
#define CmpTimePPC(dest, source) __CmpTimePPC(PowerPCBase, (dest), (source))

struct MsgPortPPC * __SetReplyPortPPC(void *, struct Message * message, struct MsgPortPPC * port)="\tlwz\tr0,-706(r3)\n\tmtlr\tr0\n\tblrl";
#define SetReplyPortPPC(message, port) __SetReplyPortPPC(PowerPCBase, (message), (port))

ULONG __SnoopTask(void *, struct TagItem * taglist)="\tlwz\tr0,-712(r3)\n\tmtlr\tr0\n\tblrl";
#define SnoopTask(taglist) __SnoopTask(PowerPCBase, (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __SnoopTaskTags(void *, int dummy, Tag taglist, ...)="\tstw\tr4,28(r1)\n\taddi\tr4,r1,28\n\tlwz\tr0,-712(r3)\n\tmtlr\tr0\n\tblrl";
#define SnoopTaskTags(...) __SnoopTaskTags(PowerPCBase, 0, __VA_ARGS__)
#endif

VOID __EndSnoopTask(void *, ULONG id)="\tlwz\tr0,-718(r3)\n\tmtlr\tr0\n\tblrl";
#define EndSnoopTask(id) __EndSnoopTask(PowerPCBase, (id))

VOID __GetHALInfo(void *, struct TagItem * taglist)="\tlwz\tr0,-724(r3)\n\tmtlr\tr0\n\tblrl";
#define GetHALInfo(taglist) __GetHALInfo(PowerPCBase, (taglist))

VOID __SetScheduling(void *, struct TagItem * taglist)="\tlwz\tr0,-730(r3)\n\tmtlr\tr0\n\tblrl";
#define SetScheduling(taglist) __SetScheduling(PowerPCBase, (taglist))

struct TaskPPC * __FindTaskByID(void *, LONG id)="\tlwz\tr0,-736(r3)\n\tmtlr\tr0\n\tblrl";
#define FindTaskByID(id) __FindTaskByID(PowerPCBase, (id))

LONG __SetNiceValue(void *, struct TaskPPC * task, LONG nice)="\tlwz\tr0,-742(r3)\n\tmtlr\tr0\n\tblrl";
#define SetNiceValue(task, nice) __SetNiceValue(PowerPCBase, (task), (nice))

LONG __TrySemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC, ULONG timeout)="\tlwz\tr0,-748(r3)\n\tmtlr\tr0\n\tblrl";
#define TrySemaphorePPC(SemaphorePPC, timeout) __TrySemaphorePPC(PowerPCBase, (SemaphorePPC), (timeout))

VOID __NewListPPC(void *, struct List* list)="\tlwz\tr0,-772(r3)\n\tmtlr\tr0\n\tblrl";
#define NewListPPC(list) __NewListPPC(PowerPCBase, (list))

ULONG __SetExceptPPC(void *, ULONG signals, ULONG mask, ULONG flag)="\tlwz\tr0,-778(r3)\n\tmtlr\tr0\n\tblrl";
#define SetExceptPPC(signals, mask, flag) __SetExceptPPC(PowerPCBase, (signals), (mask), (flag))

VOID __ObtainSemaphoreSharedPPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-784(r3)\n\tmtlr\tr0\n\tblrl";
#define ObtainSemaphoreSharedPPC(SemaphorePPC) __ObtainSemaphoreSharedPPC(PowerPCBase, (SemaphorePPC))

LONG __AttemptSemaphoreSharedPPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-790(r3)\n\tmtlr\tr0\n\tblrl";
#define AttemptSemaphoreSharedPPC(SemaphorePPC) __AttemptSemaphoreSharedPPC(PowerPCBase, (SemaphorePPC))

VOID __ProcurePPC(void *, struct SignalSemaphorePPC * SemaphorePPC, struct SemaphoreMessage * SemaphoreMessage)="\tlwz\tr0,-796(r3)\n\tmtlr\tr0\n\tblrl";
#define ProcurePPC(SemaphorePPC, SemaphoreMessage) __ProcurePPC(PowerPCBase, (SemaphorePPC), (SemaphoreMessage))

VOID __VacatePPC(void *, struct SignalSemaphorePPC * SemaphorePPC, struct SemaphoreMessage * SemaphoreMessage)="\tlwz\tr0,-802(r3)\n\tmtlr\tr0\n\tblrl";
#define VacatePPC(SemaphorePPC, SemaphoreMessage) __VacatePPC(PowerPCBase, (SemaphorePPC), (SemaphoreMessage))

VOID __CauseInterrupt(void *)="\tlwz\tr0,-808(r3)\n\tmtlr\tr0\n\tblrl";
#define CauseInterrupt() __CauseInterrupt(PowerPCBase)

VOID* __CreatePoolPPC(void *, ULONG flags, ULONG puddle_size, ULONG trehs_size)="\tlwz\tr0,-814(r3)\n\tmtlr\tr0\n\tblrl";
#define CreatePoolPPC(flags, puddle_size, trehs_size) __CreatePoolPPC(PowerPCBase, (flags), (puddle_size), (trehs_size))

VOID __DeletePoolPPC(void *, VOID* poolheader)="\tlwz\tr0,-820(r3)\n\tmtlr\tr0\n\tblrl";
#define DeletePoolPPC(poolheader) __DeletePoolPPC(PowerPCBase, (poolheader))

VOID* __AllocPooledPPC(void *, VOID* poolheader, ULONG size)="\tlwz\tr0,-826(r3)\n\tmtlr\tr0\n\tblrl";
#define AllocPooledPPC(poolheader, size) __AllocPooledPPC(PowerPCBase, (poolheader), (size))

VOID __FreePooledPPC(void *, VOID* poolheader, VOID* ptr, ULONG size)="\tlwz\tr0,-832(r3)\n\tmtlr\tr0\n\tblrl";
#define FreePooledPPC(poolheader, ptr, size) __FreePooledPPC(PowerPCBase, (poolheader), (ptr), (size))

APTR __RawDoFmtPPC(void *, STRPTR formatstring, APTR datastream, void (*putchproc)(), APTR putchdata)="\tlwz\tr0,-838(r3)\n\tmtlr\tr0\n\tblrl";
#define RawDoFmtPPC(formatstring, datastream, putchproc, putchdata) __RawDoFmtPPC(PowerPCBase, (formatstring), (datastream), (putchproc), (putchdata))

LONG __PutPublicMsgPPC(void *, STRPTR portname, struct Message * message)="\tlwz\tr0,-844(r3)\n\tmtlr\tr0\n\tblrl";
#define PutPublicMsgPPC(portname, message) __PutPublicMsgPPC(PowerPCBase, (portname), (message))

LONG __AddUniquePortPPC(void *, struct MsgPortPPC * port)="\tlwz\tr0,-850(r3)\n\tmtlr\tr0\n\tblrl";
#define AddUniquePortPPC(port) __AddUniquePortPPC(PowerPCBase, (port))

LONG __AddUniqueSemaphorePPC(void *, struct SignalSemaphorePPC * SemaphorePPC)="\tlwz\tr0,-856(r3)\n\tmtlr\tr0\n\tblrl";
#define AddUniqueSemaphorePPC(SemaphorePPC) __AddUniqueSemaphorePPC(PowerPCBase, (SemaphorePPC))

BOOL __IsExceptionMode(void *)="\tlwz\tr0,-862(r3)\n\tmtlr\tr0\n\tblrl";
#define IsExceptionMode() __IsExceptionMode(PowerPCBase)

#endif /*  _VBCCINLINE_POWERPC_H  */
