#ifndef STORMPROTOS_POWERPC_SPROTOS_H
#define STORMPROTOS_POWERPC_SPROTOS_H

#ifdef __PPC__

/*
Attention: The names for this PPC functions (all have a suffix "_"
	   are subject to change. As soon as the StormC PPC compiler
	   is able to add the "struct Library *" by default for
	   shared library functions the names will loose the suffix.

	   Please use the __inline functions from the end of this file.
*/

extern "AmigaLib" PowerPCBase {

	/* *** call 68K */
	ULONG Run68K_(struct Library *, struct PPCArgs *) = -300;
	ULONG WaitFor68K_(struct Library *, struct PPCArgs *) = -306;

	/* *** debugging */
	VOID SPrintF_(struct Library *, STRPTR, APTR) = -312;

	/* *** memory */
	APTR AllocVecPPC_(struct Library *, ULONG, ULONG, ULONG) = -324;
	LONG FreeVecPPC_(struct Library *, APTR) = -330;

	/* *** time measurement */
	VOID GetSysTimePPC_(struct Library*, struct timeval *) = -684;
	VOID AddTimePPC_(struct Library*, struct timeval *, struct timeval *) = -690;
	VOID SubTimePPC_(struct Library*, struct timeval *, struct timeval *) = -696;
	LONG CmpTimePPC_(struct Library*, struct timeval *, struct timeval *) = -702;

#ifndef POWERPCLIB_V7
	/* *** more debugging */
	ULONG SnoopTask_(struct Library *, struct TagItem *) = -714;
/*      ULONG SnoopTaskTags_(struct Library *, Tag tag1, ...) = -714; */
	VOID EndSnoopTask_(struct Library *, ULONG) = -720;

	/* *** more memory */
	VOID FreeAllMem_(struct Library *) = -654;
	VOID CopyMemPPC_(struct Library *, APTR, APTR, ULONG) = -660;
	VOID* CreatePoolPPC_(struct Library*, ULONG, ULONG, ULONG) = -816;
	VOID DeletePoolPPC_(struct Library*, VOID*) = -822;
	VOID* AllocPooledPPC_(struct Library*, VOID*, ULONG) = -828;
	VOID FreePooledPPC_(struct Library*, VOID*, VOID*, ULONG) = -834;

	/* *** lists */
	VOID AddHeadPPC_(struct Library *, struct List *, struct Node *) = -408;
	VOID AddTailPPC_(struct Library *, struct List *, struct Node *) = -414;
	VOID EnqueuePPC_(struct Library *, struct List *, struct Node *) = -438;
	struct Node *FindNamePPC_(struct Library *, struct List *, STRPTR) = -444;
	VOID InsertPPC_(struct Library *, struct List *, struct Node *, struct Node *) = -402;
	struct Node *RemHeadPPC_(struct Library *, struct List *) = -426;
	VOID RemovePPC_(struct Library *, struct Node *) = -420;
	struct Node *RemTailPPC_(struct Library *, struct List *) = -432;
	VOID NewListPPC_(struct Library *, struct List*) = -774;

	/* *** semaphores */
	VOID AddSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -366;
	LONG AttemptSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -384;
	struct SignalSemaphorePPC *FindSemaphorePPC_(struct Library *, STRPTR) = -396;
	VOID FreeSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -360;
	LONG InitSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -354;
	VOID ObtainSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -378;
	VOID ReleaseSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -390;
	VOID RemSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -372;
	LONG TrySemaphorePPC_(struct Library *, struct SignalSemaphorePPC *, ULONG) = -750;
	VOID ObtainSemaphoreSharedPPC_(struct Library *, struct SignalSemaphorePPC *) = -786;
	LONG AttemptSemaphoreSharedPPC_(struct Library *, struct SignalSemaphorePPC *) = -792;
	VOID ProcurePPC_(struct Library *, struct SignalSemaphorePPC *, struct SemaphoreMessage *) = -798;
	VOID VacatePPC_(struct Library *, struct SignalSemaphorePPC *, struct SemaphoreMessage *) = -804;
	LONG AddUniqueSemaphorePPC_(struct Library *, struct SignalSemaphorePPC *) = -858;

	/* *** signals */
	LONG AllocSignalPPC_(struct Library *, LONG) = -468;
	VOID FreeSignalPPC_(struct Library *, LONG) = -474;
	ULONG SetSignalPPC_(struct Library *, ULONG, ULONG) = -480;
	VOID SignalPPC_(struct Library *, struct TaskPPC *, ULONG) = -486;
	ULONG WaitPPC_(struct Library *, ULONG) = -492;
	ULONG WaitTime_(struct Library *, ULONG, ULONG) = -552;
	ULONG SetExceptPPC_(struct Library *, ULONG, ULONG, ULONG) = -780;

	/* *** tasks */
	struct TaskPPC *CreateTaskPPC_(struct Library *, struct TagItem *) = -336;
/*      struct TaskPPC *CreateTaskPPCTags_(struct Library *, Tag tag1, ...) = -336; */
	VOID DeleteTaskPPC_(struct Library *, struct TaskPPC *) = -342;
	struct TaskPPC *FindTaskPPC_(struct Library *, STRPTR) = -348;
	struct TaskPtr *LockTaskList_(struct Library *) = -564;
	LONG SetTaskPriPPC_(struct Library *, struct TaskPPC *, LONG) = -498;
	VOID UnLockTaskList_(struct Library *) = -570;
	struct TaskPPC *FindTaskByID_(struct Library *, LONG) = -738;
	LONG SetNiceValue_(struct Library *, struct TaskPPC *, LONG) = -744;

	/* *** ports */
	VOID AddPortPPC_(struct Library *, struct MsgPortPPC *) = -612;
	struct MsgPortPPC *CreateMsgPortPPC_(struct Library *) = -600;
	VOID DeleteMsgPortPPC_(struct Library *, struct MsgPortPPC *) = -606;
	struct MsgPortPPC *FindPortPPC_(struct Library *, STRPTR) = -624;
	struct Message *GetMsgPPC_(struct Library *, struct MsgPortPPC *) = -642;
	VOID PutMsgPPC_(struct Library *, struct MsgPortPPC *, struct Message *) = -636;
	struct Message *WaitPortPPC_(struct Library *, struct MsgPortPPC *) = - 630;
	VOID RemPortPPC_(struct Library *, struct MsgPortPPC *) = -618;
	VOID ReplyMsgPPC_(struct Library *, struct Message *) = -648;
	struct Message *AllocXMsgPPC_(struct Library *, ULONG, struct MsgPortPPC *) = -666;
	VOID FreeXMsgPPC_(struct Library *, struct Message *) = -672;
	VOID PutXMsgPPC_(struct Library *, struct MsgPort *, struct Message *) = -678;
	struct MsgPortPPC *SetReplyPortPPC_(struct Library *, struct Message *, struct MsgPortPPC *) = -708;
	LONG PutPublicMsgPPC_(struct Library *, STRPTR, struct Message *) = -846;
	LONG AddUniquePortPPC_(struct Library *, struct MsgPortPPC *) = -852;

	/* *** tag items */
	struct TagItem *FindTagItemPPC_(struct Library *, ULONG, struct TagItem *) = -450;
	ULONG GetTagDataPPC_(struct Library *, ULONG, ULONG, struct TagItem *) = -456;
	struct TagItem *NextTagItemPPC_(struct Library *, struct TagItem **) = -462;

	/* *** hardware */
	VOID ChangeMMU_(struct Library *, ULONG) = -588;
	VOID GetInfo_(struct Library *, struct TagItem *) = -594;
	VOID SetCache_(struct Library *, ULONG, APTR, ULONG) = -510;
	ULONG SetHardware_(struct Library *, ULONG, APTR) = -540;
	VOID GetHALInfo_(struct Library *, struct TagItem *) = -726;
	VOID SetScheduling_(struct Library *, struct TagItem *) = -732;

	/* *** exceptions */
	VOID ModifyFPExc_(struct Library *, ULONG) = -546;
	VOID RemExcHandler_(struct Library *, APTR) = -522;
	APTR SetExcHandler_(struct Library *, struct TagItem *) = -516;
/*      APTR SetExcHandlerTags_(struct Library *, Tag tag1, ...) = -516; */
	VOID SetExcMMU_(struct Library *) = -576;
	VOID ClearExcMMU_(struct Library *) = -582;
	VOID CauseInterrupt_(struct Library *) = -810;
	BOOL IsExceptionMode_(struct Library *) = -864;

	/* *** supervisor */
	ULONG Super_(struct Library *) = -528;
	VOID User_(struct Library *, ULONG) = -534;

	/* *** 68K connection */
	VOID Signal68K_(struct Library *, struct Task *, ULONG) = -504;

	/* *** formatting */
	APTR RawDoFmtPPC_(struct Library *, STRPTR, APTR, void (*)(), APTR) = -840;

#endif /* POWERPCLIB_V7 */
};

__inline ULONG Run68K(struct PPCArgs *a1)
{
	extern struct Library *PowerPCBase;
	return Run68K_(PowerPCBase,a1);
}
__inline ULONG WaitFor68K(struct PPCArgs *a1)
{
	extern struct Library *PowerPCBase;
	return WaitFor68K_(PowerPCBase,a1);
}
__inline VOID SPrintF(STRPTR a1, APTR a2)
{
	extern struct Library *PowerPCBase;
	SPrintF_(PowerPCBase,a1,a2);
}
__inline APTR AllocVecPPC(ULONG a1, ULONG a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	return AllocVecPPC_(PowerPCBase,a1,a2,a3);
}
__inline VOID GetSysTimePPC(struct timeval *a1)
{
	extern struct Library *PowerPCBase;
	GetSysTimePPC_(PowerPCBase,a1);
}

__inline VOID AddTimePPC(struct timeval *a1, struct timeval *a2)
{
	extern struct Library *PowerPCBase;
	AddTimePPC_(PowerPCBase,a1,a2);
}

__inline VOID SubTimePPC(struct timeval *a1, struct timeval *a2)
{
	extern struct Library *PowerPCBase;
	SubTimePPC_(PowerPCBase,a1,a2);
}

__inline LONG CmpTimePPC(struct timeval *a1, struct timeval *a2)
{
	extern struct Library *PowerPCBase;
	return CmpTimePPC_(PowerPCBase,a1,a2);
}

__inline VOID FreeVecPPC(APTR a1)
{
	extern struct Library *PowerPCBase;
	FreeVecPPC_(PowerPCBase,a1);
}

#ifndef POWERPCLIB_V7
__inline ULONG SnoopTask(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	return SnoopTask_(PowerPCBase,a1);
}
__inline ULONG SnoopTaskTags(Tag tag1, ...)
{
	extern struct Library *PowerPCBase;
	return SnoopTask_(PowerPCBase,(struct TagItem *) &tag1);
}
__inline VOID EndSnoopTask(ULONG a1)
{
	extern struct Library *PowerPCBase;
	EndSnoopTask_(PowerPCBase,a1);
}
__inline VOID FreeAllMem()
{
	extern struct Library *PowerPCBase;
	FreeAllMem_(PowerPCBase);
}
__inline VOID CopyMemPPC(APTR a1, APTR a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	CopyMemPPC_(PowerPCBase,a1,a2,a3);
}
__inline VOID* CreatePoolPPC(ULONG a1, ULONG a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	return CreatePoolPPC_(PowerPCBase,a1,a2,a3);
}
__inline VOID DeletePoolPPC(VOID* a1)
{
	extern struct Library *PowerPCBase;
	DeletePoolPPC_(PowerPCBase,a1);
}
__inline VOID* AllocPooledPPC(VOID* a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	return AllocPooledPPC_(PowerPCBase,a1,a2);
}
__inline VOID FreePooledPPC(VOID* a1, VOID* a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	FreePooledPPC_(PowerPCBase,a1,a2,a3);
}
__inline VOID AddHeadPPC(struct List *a1, struct Node *a2)
{
	extern struct Library *PowerPCBase;
	AddHeadPPC_(PowerPCBase,a1,a2);
}
__inline VOID AddTailPPC(struct List *a1, struct Node *a2)
{
	extern struct Library *PowerPCBase;
	AddTailPPC_(PowerPCBase,a1,a2);
}
__inline VOID EnqueuePPC(struct List *a1, struct Node *a2)
{
	extern struct Library *PowerPCBase;
	EnqueuePPC_(PowerPCBase,a1,a2);
}
__inline struct Node *FindNamePPC(struct List *a1, STRPTR a2)
{
	extern struct Library *PowerPCBase;
	return FindNamePPC_(PowerPCBase,a1,a2);
}
__inline VOID InsertPPC(struct List *a1, struct Node *a2, struct Node *a3)
{
	extern struct Library *PowerPCBase;
	InsertPPC_(PowerPCBase,a1,a2,a3);
}
__inline struct Node *RemHeadPPC(struct List *a1)
{
	extern struct Library *PowerPCBase;
	return RemHeadPPC_(PowerPCBase,a1);
}
__inline VOID RemovePPC(struct Node *a1)
{
	extern struct Library *PowerPCBase;
	RemovePPC_(PowerPCBase,a1);
}
__inline struct Node *RemTailPPC(struct List *a1)
{
	extern struct Library *PowerPCBase;
	return RemTailPPC_(PowerPCBase,a1);
}
__inline void NewListPPC(struct List *a1)
{
	extern struct Library *PowerPCBase;
	NewListPPC_(PowerPCBase,a1);
}
__inline VOID AddSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	AddSemaphorePPC_(PowerPCBase,a1);
}
__inline LONG AttemptSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	return AttemptSemaphorePPC_(PowerPCBase,a1);
}
__inline struct SignalSemaphorePPC *FindSemaphorePPC(STRPTR a1)
{
	extern struct Library *PowerPCBase;
	return FindSemaphorePPC_(PowerPCBase,a1);
}
__inline VOID FreeSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	FreeSemaphorePPC_(PowerPCBase,a1);
}
__inline LONG InitSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	return InitSemaphorePPC_(PowerPCBase,a1);
}
__inline VOID ObtainSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	ObtainSemaphorePPC_(PowerPCBase,a1);
}
__inline VOID ReleaseSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	ReleaseSemaphorePPC_(PowerPCBase,a1);
}
__inline VOID RemSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	RemSemaphorePPC_(PowerPCBase,a1);
}
__inline LONG TrySemaphorePPC(struct SignalSemaphorePPC *a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	return TrySemaphorePPC_(PowerPCBase,a1,a2);
}
__inline VOID ObtainSemaphoreSharedPPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	ObtainSemaphoreSharedPPC_(PowerPCBase,a1);
}
__inline LONG AttemptSemaphoreSharedPPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	return AttemptSemaphoreSharedPPC_(PowerPCBase,a1);
}
__inline VOID ProcurePPC(struct SignalSemaphorePPC *a1, struct SemaphoreMessage *a2)
{
	extern struct Library *PowerPCBase;
	ProcurePPC_(PowerPCBase,a1,a2);
}
__inline VOID VacatePPC(struct SignalSemaphorePPC *a1, struct SemaphoreMessage *a2)
{
	extern struct Library *PowerPCBase;
	VacatePPC_(PowerPCBase,a1,a2);
}
__inline LONG AddUniqueSemaphorePPC(struct SignalSemaphorePPC *a1)
{
	extern struct Library *PowerPCBase;
	return AddUniqueSemaphorePPC_(PowerPCBase,a1);
}
__inline LONG AllocSignalPPC(LONG a1)
{
	extern struct Library *PowerPCBase;
	return AllocSignalPPC_(PowerPCBase,a1);
}
__inline VOID FreeSignalPPC(LONG a1)
{
	extern struct Library *PowerPCBase;
	FreeSignalPPC_(PowerPCBase,a1);
}
__inline ULONG SetSignalPPC(ULONG a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	return SetSignalPPC_(PowerPCBase,a1,a2);
}
__inline VOID SignalPPC(struct TaskPPC *a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	SignalPPC_(PowerPCBase,a1,a2);
}
__inline ULONG WaitPPC(ULONG a1)
{
	extern struct Library *PowerPCBase;
	return WaitPPC_(PowerPCBase,a1);
}
__inline ULONG WaitTime(ULONG a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	return WaitTime_(PowerPCBase,a1,a2);
}
__inline ULONG SetExceptPPC(ULONG a1, ULONG a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	return SetExceptPPC_(PowerPCBase,a1,a2,a3);
}
__inline struct TaskPPC *CreateTaskPPC(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	return CreateTaskPPC_(PowerPCBase,a1);
}
__inline struct TaskPPC *CreateTaskPPCTags(Tag tag1, ...)
{
	extern struct Library *PowerPCBase;
	return CreateTaskPPC_(PowerPCBase,(struct TagItem *) &tag1);
}
__inline VOID DeleteTaskPPC(struct TaskPPC *a1)
{
	extern struct Library *PowerPCBase;
	DeleteTaskPPC_(PowerPCBase,a1);
}
__inline struct TaskPPC *FindTaskPPC(STRPTR a1)
{
	extern struct Library *PowerPCBase;
	return FindTaskPPC_(PowerPCBase,a1);
}
__inline struct TaskPtr *LockTaskList()
{
	extern struct Library *PowerPCBase;
	return LockTaskList_(PowerPCBase);
}
__inline LONG SetTaskPriPPC(struct TaskPPC *a1, LONG a2)
{
	extern struct Library *PowerPCBase;
	return SetTaskPriPPC_(PowerPCBase,a1,a2);
}
__inline VOID UnLockTaskList()
{
	extern struct Library *PowerPCBase;
	UnLockTaskList_(PowerPCBase);
}
__inline struct TaskPPC *FindTaskByID(LONG a1)
{
	extern struct Library *PowerPCBase;
	return FindTaskByID_(PowerPCBase,a1);
}
__inline LONG SetNiceValue(struct TaskPPC *a1, LONG a2)
{
	extern struct Library *PowerPCBase;
	return SetNiceValue_(PowerPCBase,a1,a2);
}
__inline VOID AddPortPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	AddPortPPC_(PowerPCBase,a1);
}
__inline struct MsgPortPPC *CreateMsgPortPPC()
{
	extern struct Library *PowerPCBase;
	return CreateMsgPortPPC_(PowerPCBase);
}
__inline VOID DeleteMsgPortPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	DeleteMsgPortPPC_(PowerPCBase,a1);
}
__inline struct MsgPortPPC *FindPortPPC(STRPTR a1)
{
	extern struct Library *PowerPCBase;
	return FindPortPPC_(PowerPCBase,a1);
}
__inline struct Message *GetMsgPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	return GetMsgPPC_(PowerPCBase,a1);
}
__inline VOID PutMsgPPC(struct MsgPortPPC *a1, struct Message *a2)
{
	extern struct Library *PowerPCBase;
	PutMsgPPC_(PowerPCBase,a1,a2);
}
__inline struct Message* WaitPortPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	return WaitPortPPC_(PowerPCBase,a1);
}
__inline VOID RemPortPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	RemPortPPC_(PowerPCBase,a1);
}
__inline VOID ReplyMsgPPC(struct Message *a1)
{
	extern struct Library *PowerPCBase;
	ReplyMsgPPC_(PowerPCBase,a1);
}
__inline struct Message *AllocXMsgPPC(ULONG a1, struct MsgPortPPC *a2)
{
	extern struct Library *PowerPCBase;
	return AllocXMsgPPC_(PowerPCBase,a1,a2);
}
__inline VOID FreeXMsgPPC(struct Message *a1)
{
	extern struct Library *PowerPCBase;
	FreeXMsgPPC_(PowerPCBase,a1);
}
__inline VOID PutXMsgPPC(struct MsgPort *a1, struct Message *a2)
{
	extern struct Library *PowerPCBase;
	PutXMsgPPC_(PowerPCBase,a1,a2);
}
__inline struct MsgPortPPC *SetReplyPortPPC(struct Message *a1, struct MsgPortPPC *a2)
{
	extern struct Library *PowerPCBase;
	return SetReplyPortPPC_(PowerPCBase,a1,a2);
}
__inline LONG PutPublicMsgPPC(STRPTR a1, struct Message *a2)
{
	extern struct Library *PowerPCBase;
	return PutPublicMsgPPC_(PowerPCBase,a1,a2);
}
__inline LONG AddUniquePortPPC(struct MsgPortPPC *a1)
{
	extern struct Library *PowerPCBase;
	return AddUniquePortPPC_(PowerPCBase,a1);
}
__inline struct TagItem *FindTagItemPPC(ULONG a1, struct TagItem *a2)
{
	extern struct Library *PowerPCBase;
	return FindTagItemPPC_(PowerPCBase,a1,a2);
}
__inline ULONG GetTagDataPPC(ULONG a1, ULONG a2, struct TagItem *a3)
{
	extern struct Library *PowerPCBase;
	return GetTagDataPPC_(PowerPCBase,a1,a2,a3);
}
__inline struct TagItem *NextTagItemPPC(struct TagItem **a1)
{
	extern struct Library *PowerPCBase;
	return NextTagItemPPC_(PowerPCBase,a1);
}
__inline VOID ChangeMMU(ULONG a1)
{
	extern struct Library *PowerPCBase;
	ChangeMMU_(PowerPCBase,a1);
}
__inline VOID GetInfo(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	GetInfo_(PowerPCBase,a1);
}
__inline VOID SetCache(ULONG a1, APTR a2, ULONG a3)
{
	extern struct Library *PowerPCBase;
	SetCache_(PowerPCBase,a1,a2,a3);
}
__inline ULONG SetHardware(ULONG a1, APTR a2)
{
	extern struct Library *PowerPCBase;
	return SetHardware_(PowerPCBase,a1,a2);
}
__inline VOID GetHALInfo(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	GetHALInfo_(PowerPCBase,a1);
}
__inline VOID SetScheduling(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	SetScheduling_(PowerPCBase,a1);
}
__inline VOID ModifyFPExc(ULONG a1)
{
	extern struct Library *PowerPCBase;
	ModifyFPExc_(PowerPCBase,a1);
}
__inline VOID RemExcHandler(APTR a1)
{
	extern struct Library *PowerPCBase;
	RemExcHandler_(PowerPCBase,a1);
}
__inline APTR SetExcHandler(struct TagItem *a1)
{
	extern struct Library *PowerPCBase;
	return SetExcHandler_(PowerPCBase,a1);
}
__inline APTR SetExcHandlerTags(Tag tag1, ...)
{
	extern struct Library *PowerPCBase;
	return SetExcHandler_(PowerPCBase,(struct TagItem *) &tag1);
}
__inline VOID SetExcMMU()
{
	extern struct Library *PowerPCBase;
	SetExcMMU_(PowerPCBase);
}
__inline VOID ClearExcMMU()
{
	extern struct Library *PowerPCBase;
	ClearExcMMU_(PowerPCBase);
}
__inline VOID CauseInterrupt()
{
	extern struct Library *PowerPCBase;
	CauseInterrupt_(PowerPCBase);
}
__inline BOOL IsExceptionMode()
{
	extern struct Library *PowerPCBase;
	return IsExceptionMode_(PowerPCBase);
}
__inline ULONG Super()
{
	extern struct Library *PowerPCBase;
	return Super_(PowerPCBase);
}
__inline VOID User(ULONG a1)
{
	extern struct Library *PowerPCBase;
	User_(PowerPCBase,a1);
}
__inline VOID Signal68K(struct Task *a1, ULONG a2)
{
	extern struct Library *PowerPCBase;
	Signal68K_(PowerPCBase,a1,a2);
}
__inline APTR RawDoFmtPPC(STRPTR a1, APTR a2, void (*a3)(), APTR a4)
{
	extern struct Library *PowerPCBase;
	return RawDoFmtPPC_(PowerPCBase,a1,a2,a3,a4);
}

#endif /* POWERPCLIB_V7 */
#endif /* __PPC__ */

#endif /* STORMPROTOS_POWERPC_SPROTOS_H */
