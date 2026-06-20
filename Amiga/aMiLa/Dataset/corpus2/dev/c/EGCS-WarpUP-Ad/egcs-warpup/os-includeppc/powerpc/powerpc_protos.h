#ifndef WARPUP_GCCLIB_PROTOS_H
#define WARPUP_GCCLIB_PROTOS_H

/*
**  $VER: waprup_protos.h 2.0 (15.03.98)
**  WarpOS Release 14.1
**
**  '(C) Copyright 1998 Haage & Partner Computer GmbH'
**       All Rights Reserved
*/


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

#ifdef __PPC__

extern struct Library *PowerPCBase;

#include <powerpc/warpup_macros.h>

        /* *** call 68K */
#define Run68k(v1) 		PPCLP1	(PowerPCBase,-300,ULONG,	struct PPCArgs *,4,v1)
#define Waitfor68k(v1) 		PPCLP1	(PowerPCBase,-306,ULONG,	struct PPCArgs *,4,v1)

        /* *** debugging */
#define SPrintF(v1,v2) 		PPCLP2NR(PowerPCBase,-312,		STRPTR,4,v1,APTR,5,v2)

        /* *** memory */
#define AllocVecPPC(v1,v2,v3) 	PPCLP3	(PowerPCBase,-324,APTR,		ULONG,4,v1,ULONG,5,v2,ULONG,6,v3)
#define FreeVecPPC(v1)		PPCLP1	(PowerPCBase,-330,LONG,		APTR,4,v1)

        /* *** time measurement */
#define GetSysTimePPC(v1)	PPCLP1NR(PowerPCBase,-684,		struct timeval *,4,v1)
#define AddTimePPC(v1,v2)	PPCLP2NR(PowerPCBase,-690,		struct timeval *,4,v1,struct timeval *,5,v2)
#define SubTimePPC(v1,v2)	PPCLP2NR(PowerPCBase,-696,		struct timeval *,4,v1,struct timeval *,5,v2)
#define CmpTimePPC(v1,v2)	PPCLP2	(PowerPCBase,-702,LONG,		struct timeval *,4,v1,struct timeval *,5,v2)

        /* *** more debugging */
#define SnoopTask(v1)		PPCLP1	(PowerPCBase,-714,ULONG,	struct TagItem *,4,v1)
#define EndSnoopTask(v1)	PPCLP1NR(PowerPCBase,-720,		ULONG,4,v1)

        /* *** more memory */
#define FreeAllMemPPC()		PPCLP0NR(PowerPCBase,-654		)
#define CopyMemPPC(v1,v2,v3)	PPCLP3NR(PowerPCBase,-660,		APTR,4,v1,APTR,5,v2,ULONG,6,v3)

        /* *** lists */
#define AddHeadPPC(v1,v2)	PPCLP2NR(PowerPCBase,-408,		struct List *,4,v1,struct Node *,5,v2)
#define AddTailPPC(v1,v2)	PPCLP2NR(PowerPCBase,-414,		struct List *,4,v1,struct Node *,5,v2)
#define EnqueuePPC(v1,v2)	PPCLP2NR(PowerPCBase,-438,		struct List *,4,v1,struct Node *,5,v2)
#define FindNamePPC(v1,v2)	PPCLP2	(PowerPCBase,-444,struct Node *,struct List *,4,v1,STRPTR,5,v2)
#define	InsertPPC(v1,v2)	PPCLP2NR(PowerPCBase,-402,		struct Node *,4,v1,struct Node *,5,v2)
#define RemHeadPPC(v1)		PPCLP1	(PowerPCBase,-426,struct Node *,struct List *,4,v1)
#define RemovePPC(v1)		PPCLP1NR(PowerPCBase,-420,		struct Node *,4,v1)
#define RemTailPPC(v1)		PPCLP1	(PowerPCBase,-432,struct Node *,struct List *,4,v1)

        /* *** semaphores */
#define AddSemaphorePPC(v1)	PPCLP1NR(PowerPCBase,-366,		struct SignalSemaphorePPC *,4,v1)
#define AttemptSemaphorePPC(v1)	PPCLP1	(PowerPCBase,-384,LONG,		struct SignalSemaphorePPC *,4,v1)
#define FindSemaphorePPC(v1)	PPCLP1	(PowerPCBase,-396,struct SignalSemaphorePPC *,STRPTR,4,v1)
#define FreeSemaphorePPC(v1)	PPCLP1NR(PowerPCBase,-360,		struct SignalSemaphorePPC *,4,v1)
#define InitSemaphorePPC(v1)	PPCLP1	(PowerPCBase,-354,LONG,		struct SignalSemaphorePPC *,4,v1)
#define ObtainSemaphorePPC(v1)	PPCLP1NR(PowerPCBase,-378,		struct SignalSemaphorePPC *,4,v1)
#define	ReleaseSemaphorePPC(v1)	PPCLP1NR(PowerPCBase,-390,		struct SignalSemaphorePPC *,4,v1)
#define RemSemaphorePPC(v1)	PPCLP1NR(PowerPCBase,-372,		struct SignalSemaphorePPC *,4,v1)

        /* *** signals */
#define AllocSignalPPC(v1)	PPCLP1	(PowerPCBase,-468,LONG,		LONG,4,v1)
#define FreeSignalPPC(v1)	PPCLP1NR(PowerPCBase,-474,		LONG,4,v1)
#define SetSignalPPC(v1,v2)	PPCLP2	(PowerPCBase,-480,ULONG,	ULONG,4,v1,ULONG,5,v2)
#define SignalPPC(v1,v2)	PPCLP2NR(PowerPCBase,-486,		struct TaskPPC *,4,v1,ULONG,5,v2)
#define WaitPPC(v1)		PPCLP1	(PowerPCBase,-492,ULONG,	ULONG,4,v1)
#define WaitTime(v1,v2)		PPCLP2	(PowerPCBase,-552,ULONG,	ULONG,4,v1,ULONG,5,v2)

        /* *** tasks */
#define CreateTaskPPC(v1)	PPCLP1	(PowerPCBase,-336,struct TaskPPC *,struct TagItem *,4,v1)
#define DeleteTaskPPC(v1)	PPCLP1NR(PowerPCBase,-342,		struct TaskPPC *,4,v1)
#define FindTaskPPC(v1)		PPCLP1	(PowerPCBase,-348,struct TaskPPC *,STRPTR,4,v1)
#define LockTaskList()		PPCLP0	(PowerPCBase,-564,struct TaskPtr *)
#define SetTaskPriPPC(v1,v2)	PPCLP2	(PowerPCBase,-498,LONG,		struct TaskPPC *,4,v1,LONG,5,v2)
#define UnLockTaskList()	PPCLP0NR(PowerPCBase,-570		)
#define FindTaskByID(v1)	PPCLP1	(PowerPCBase,-738,struct TaskPPC *,LONG,4,v1)
#define SetNiceValue(v1,v2)	PPCLP2	(PowerPCBase,-744,LONG,		struct TaskPPC *,4,v1,LONG,5,v2)

        /* *** ports */
#define AddPortPPC(v1)		PPCLP1NR(PowerPCBase,-612,		struct MsgPortPPC *,4,v1)
#define CreateMsgPortPPC()	PPCLP0	(PowerPCBase,-600,struct MsgPortPPC *)
#define DeleteMsgPortPPC(v1)	PPCLP1NR(PowerPCBase,-606,		struct MsgPortPPC *,4,v1)
#define FindPortPPC(v1)		PPCLP1	(PowerPCBase,-624,struct MsgPortPPC *,STRPTR,4,v1)
#define GetMsgPPC(v1)		PPCLP1	(PowerPCBase,-642,struct Message *,struct MsgPortPPC *,4,v1)
#define PutMsgPPC(v1,v2)	PPCLP2NR(PowerPCBase,-636,		struct MsgPortPPC *,4,v1,struct Message *,5,v2)
#define WaitPortPPC(v1)		PPCLP1	(PowerPCBase,-630,struct Message *,struct MsgPortPPC *,4,v1)
#define RemPortPPC(v1)		PPCLP1NR(PowerPCBase,-618,		struct MsgPortPPC *,4,v1)
#define ReplyMsgPPC(v1)		PPCLP1NR(PowerPCBase,-648,		struct Message *,4,v1)
#define AllocXMsgPPC(v1,v2)	PPCLP2	(PowerPCBase,-666,struct Message *,ULONG,4,v1,struct MsgPortPPC *,5,v2)
#define FreeXMsgPPC(v1)		PPCLP1NR(PowerPCBase,-672,		struct Message *,4,v1)
#define PutXMsgPPC(v1,v2)	PPCLP2NR(PowerPCBase,-678,		struct MsgPort *,4,v,struct Message *,5,v2)
#define SetReplyPortPPC(v1,v2)	PPCLP2	(PowerPCBase,-708,struct MsgPortPPC *,struct Message *,4,v1,struct MsgPortPPC *,5,v2)

        /* *** tag items */
#define FindTagItemPPC(v1,v2)	PPCLP2	(PowerPCBase,-450,struct TagItem *,ULONG,4,v1,struct TagItem *,5,v2)
#define GetTagDataPPC(v1,v2,v3)	PPCLP3	(PowerPCBase,-456,ULONG,	ULONG,4,v1,ULONG,5,v2,struct TagItem *,6,v3)
#define NextTagItemPPC(v1)	PPCLP1	(PowerPCBase,-462,struct TagItem *,struct TagItem **,4,v1)


        /* *** hardware */
#define ChangeMMU(v1)		PPCLP1NR(PowerPCBase,-588,		ULONG,4,v1)
#define	GetInfo(v1)		PPCLP1NR(PowerPCBase,-594,		struct TagItem *,4,v1)
#define SetCache(v1,v2,v3)	PPCLP3NR(PowerPCBase,-510,		ULONG,4,v1,APTR,5,v2,ULONG,6,v3)
#define SetHardware(v1,v2)	PPCLP2	(PowerPCBase,-540,ULONG,	ULONG,4,v1,APTR,5,v2)
#define GetHALInfo(v1)		PPCLP1NR(PowerPCBase,-726,		struct TagItem *,4,v1)
#define	SetScheduling(v1)	PPCLP1NR(PowerPCBase,-732,		struct TagItem *,4,v1)

        /* *** exceptions */
#define ModifyFPExc(v1)		PPCLP1NR(PowerPCBase,-546,		ULONG,4,v1)
#define RemExcHandler(v1)	PPCLP1NR(PowerPCBase,-522,		APTR,4,v1)
#define	SetExcHandler(v1)	PPCLP1	(PowerPCBase,-516,APTR,		struct TagItem *,4,v1)
#define	SetExcMMU()		PPCLP0NR(PowerPCBase,-576		)
#define	ClearExcMMU()		PPCLP0NR(PowerPCBase,-582		)

        /* *** supervisor */
#define Super()			PPCLP0	(PowerPCBase,-528,ULONG		)
#define User(v1)		PPCLP1NR(PowerPCBase,-534,		ULONG,4,v1)

        /* *** 68K connection */
#define Signal68K(v1,v2)	PPCLP2NR(PowerPCBase,-504,		struct Task *,4,v1,ULONG,5,v2)

#endif /* __PPC__ */

#endif /* POWERPC_GCCLIB_PROTOS_H */
