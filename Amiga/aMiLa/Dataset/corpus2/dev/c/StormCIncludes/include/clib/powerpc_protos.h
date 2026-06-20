#ifndef CLIB_POWERPC_PROTOS_H
#define CLIB_POWERPC_PROTOS_H

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#ifndef DEVICES_TIMER_H
#include <devices/timer.h>
#endif

#ifndef POWERPC_PORTSPPC_H
#include <powerpc/portsPPC.h>
#endif

#ifndef POWERPC_TASKS_H
#include <powerpc/tasksPPC.h>
#endif

#ifndef POWERPC_SEMAPHORES_H
#include <powerpc/semaphoresPPC.h>
#endif

#ifndef POWERPC_POWERPC_H
#include <powerpc/powerpc.h>
#endif

#ifndef __PPC__

#ifdef __cplusplus
extern "C" {
#endif

/* *** ppc call */
ULONG RunPPC(struct PPCArgs *);
ULONG WaitForPPC(struct PPCArgs *);
struct TaskPPC *CreatePPCTask(struct TagItem *);
struct TaskPPC *CreatePPCTaskTags(Tag tag1, ...);

/* *** hardware */
ULONG GetCPU(VOID);
void SetCache68K(ULONG,void *,ULONG);
void CausePPCInterrupt(VOID);

/* *** debugging */
VOID PowerDebugMode(ULONG);
VOID SPrintF68K(STRPTR,APTR);

/* *** memory */
APTR AllocVec32(ULONG,ULONG);
VOID FreeVec32(APTR);

/* *** general information */
ULONG GetPPCState(VOID);

#ifndef POWERPCLIB_V7

/* *** ports */
struct Message *AllocXMsg(ULONG,struct MsgPort *);
VOID FreeXMsg(struct Message *);
VOID PutXMsg(struct MsgPortPPC *, struct Message *);

#endif /* POWERPCLIB_V7 */

#ifdef __cplusplus
};
#endif

#ifdef STORMPRAGMAS
#ifndef _INCLUDE_PRAGMA_POWERPC_LIB_H
#include <pragma/powerpc_lib.h>
#endif
#endif

#else /* __PPC__ */

#ifdef __STORM__               /* other syntax for StormC */

#ifndef STORMPROTOS_POWERPC_SPROTOS_H
#include <stormprotos/powerpc_sprotos.h>
#endif

#else   /* __STORM__ */

#ifdef __cplusplus
extern "C" {
#endif

ULONG Run68K(struct PPCArgs *);
ULONG WaitFor68K(struct PPCArgs *);

/* *** debugging */
VOID SPrintF(STRPTR, APTR);

/* *** memory */
APTR AllocVecPPC(ULONG, ULONG, ULONG);
LONG FreeVecPPC(APTR);

/* *** time measurement */
VOID GetSysTimePPC(struct timeval *);
VOID AddTimePPC(struct timeval *, struct timeval *);
VOID SubTimePPC(struct timeval *, struct timeval *);
LONG CmpTimePPC(struct timeval *, struct timeval *);

#ifndef POWERPCLIB_V7
/* *** more debugging */
ULONG SnoopTask(struct TagItem *);
ULONG SnoopTaskTags(Tag tag1, ...);
VOID EndSnoopTask(ULONG);

/* *** more memory */
VOID FreeAllMem(VOID);
VOID CopyMemPPC(APTR, APTR, ULONG);
VOID* CreatePoolPPC(ULONG, ULONG, ULONG);
VOID DeletePoolPPC(VOID*);
VOID* AllocPooledPPC(VOID*, ULONG);
VOID FreePooledPPC(VOID*, VOID*, ULONG);

/* *** lists */
VOID AddHeadPPC(struct List *, struct Node *);
VOID AddTailPPC(struct List *, struct Node *);
VOID EnqueuePPC(struct List *, struct Node *);
struct Node *FindNamePPC(struct List *, STRPTR);
VOID InsertPPC(struct List *, struct Node *, struct Node *);
struct Node *RemHeadPPC(struct List *);
VOID RemovePPC(struct Node *);
struct Node *RemTailPPC(struct List *);
VOID NewListPPC(struct List*);

/* *** semaphores */
VOID AddSemaphorePPC(struct SignalSemaphorePPC *);
LONG AttemptSemaphorePPC(struct SignalSemaphorePPC *);
struct SignalSemaphorePPC *FindSemaphorePPC(STRPTR);
VOID FreeSemaphorePPC(struct SignalSemaphorePPC *);
LONG InitSemaphorePPC(struct SignalSemaphorePPC *);
VOID ObtainSemaphorePPC(struct SignalSemaphorePPC *);
VOID ReleaseSemaphorePPC(struct SignalSemaphorePPC *);
VOID RemSemaphorePPC(struct SignalSemaphorePPC *);
LONG TrySemaphorePPC(struct SignalSemaphorePPC *, ULONG);
VOID ObtainSemaphoreSharedPPC(struct SignalSemaphorePPC *);
LONG AttemptSemaphoreSharedPPC(struct SignalSemaphorePPC *);
VOID ProcurePPC(struct SignalSemaphorePPC *, struct SemaphoreMessage *);
VOID VacatePPC(struct SignalSemaphorePPC *, struct SemaphoreMessage *);
LONG AddUniqueSemaphorePPC(struct SignalSemaphorePPC *);

/* *** signals */
LONG AllocSignalPPC(LONG);
VOID FreeSignalPPC(LONG);
ULONG SetSignalPPC(ULONG, ULONG);
VOID SignalPPC(struct TaskPPC *, ULONG);
ULONG WaitPPC(ULONG);
ULONG WaitTime(ULONG, ULONG);
ULONG SetExceptPPC(ULONG, ULONG, ULONG);

/* *** tasks */
struct TaskPPC *CreateTaskPPC(struct TagItem *);
struct TaskPPC *CreateTaskPPCTags(Tag tag1, ...);
VOID DeleteTaskPPC(struct TaskPPC *);
struct TaskPPC *FindTaskPPC(STRPTR);
struct TaskPtr *LockTaskList(VOID);
LONG SetTaskPriPPC(struct TaskPPC *, LONG);
VOID UnLockTaskList(VOID);
struct TaskPPC *FindTaskByID(LONG);
LONG SetNiceValue(struct TaskPPC *, LONG);

/* *** ports */
VOID AddPortPPC(struct MsgPortPPC *);
struct MsgPortPPC *CreateMsgPortPPC(VOID);
VOID DeleteMsgPortPPC(struct MsgPortPPC *);
struct MsgPortPPC *FindPortPPC(STRPTR);
struct Message *GetMsgPPC(struct MsgPortPPC *);
VOID PutMsgPPC(struct MsgPortPPC *, struct Message *);
struct Message *WaitPortPPC(struct MsgPortPPC *);
VOID RemPortPPC(struct MsgPortPPC *);
VOID ReplyMsgPPC(struct Message *);
struct Message *AllocXMsgPPC(ULONG, struct MsgPortPPC *);
VOID FreeXMsgPPC(struct Message *);
VOID PutXMsgPPC(struct MsgPort *, struct Message *);
struct MsgPortPPC *SetReplyPortPPC(struct Message *, struct MsgPortPPC *);
LONG PutPublicMsgPPC(STRPTR, struct Message *);
LONG AddUniquePortPPC(struct MsgPortPPC *);

/* *** tag items */
struct TagItem *FindTagItemPPC(ULONG, struct TagItem *);
ULONG GetTagDataPPC(ULONG, ULONG, struct TagItem *);
struct TagItem *NextTagItemPPC(struct TagItem **);

/* *** hardware */
VOID ChangeMMU(ULONG);
VOID GetInfo(struct TagItem *);
VOID SetCache(ULONG, APTR, ULONG);
ULONG SetHardware(ULONG, APTR);
VOID GetHALInfo(struct TagItem *);
VOID SetScheduling(struct TagItem *);

/* *** exceptions */
VOID ModifyFPExc(ULONG);
VOID RemExcHandler(APTR);
APTR SetExcHandler(struct TagItem *);
APTR SetExcHandlerTags(Tag tag1, ...);
VOID SetExcMMU(VOID);
VOID ClearExcMMU(VOID);
VOID CauseInterrupt(VOID);
BOOL IsExceptionMode(VOID);

/* *** supervisor */
ULONG Super(VOID);
VOID User(ULONG);

/* *** 68K connection */
VOID Signal68K(struct Task *, ULONG);

/* *** formatting */
APTR RawDoFmtPPC(STRPTR, APTR, void (*)(void), APTR);

#endif /* POWERPCLIB_V7 */

#ifdef __cplusplus
};
#endif


#endif /* __STORM__ */

#endif /* __PPC__ */


#endif /* CLIB_POWERPC_PROTOS_H */
