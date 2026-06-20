#ifndef _VBCCINLINE_THREADPOOL_H
#define _VBCCINLINE_THREADPOOL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __CreateThreadPoolTagList(ULONG maxthreads, CONST struct TagItem * tags, void *) =
	"\tlwz\t0,-28(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CreateThreadPoolTagList(maxthreads, tags) __CreateThreadPoolTagList((maxthreads), (tags), ThreadPoolBase)

VOID __DeleteThreadPool(APTR threadpool, void *) =
	"\tlwz\t0,-34(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define DeleteThreadPool(threadpool) __DeleteThreadPool((threadpool), ThreadPoolBase)

ssize_t __QueueWorkItem(APTR thread, THREADFUNC func, APTR userdata, void *) =
	"\tlwz\t0,-40(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueueWorkItem(thread, func, userdata) __QueueWorkItem((thread), (func), (userdata), ThreadPoolBase)

BOOL __SendWorkItemMessage(APTR thread, ssize_t work_id, struct Message * message, void *) =
	"\tlwz\t0,-46(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SendWorkItemMessage(thread, work_id, message) __SendWorkItemMessage((thread), (work_id), (message), ThreadPoolBase)

WORKITEMSTATUS __AbortWorkItem(APTR thread, ssize_t id, void *) =
	"\tlwz\t0,-52(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AbortWorkItem(thread, id) __AbortWorkItem((thread), (id), ThreadPoolBase)

BOOL __AbortWorkQueue(APTR thread, void *) =
	"\tlwz\t0,-58(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define AbortWorkQueue(thread) __AbortWorkQueue((thread), ThreadPoolBase)

WORKITEMSTATUS __CheckWorkItem(APTR threadpool, ssize_t work_id, void *) =
	"\tlwz\t0,-64(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CheckWorkItem(threadpool, work_id) __CheckWorkItem((threadpool), (work_id), ThreadPoolBase)

BOOL __CheckWorkQueue(APTR threadpool, void *) =
	"\tlwz\t0,-70(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define CheckWorkQueue(threadpool) __CheckWorkQueue((threadpool), ThreadPoolBase)

VOID __WaitWorkItem(APTR thread, ssize_t work_id, void *) =
	"\tlwz\t0,-76(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define WaitWorkItem(thread, work_id) __WaitWorkItem((thread), (work_id), ThreadPoolBase)

VOID __WaitWorkQueue(APTR thread, void *) =
	"\tlwz\t0,-82(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define WaitWorkQueue(thread) __WaitWorkQueue((thread), ThreadPoolBase)

BOOL __IsCurrentThread(APTR thread, ssize_t work_id, void *) =
	"\tlwz\t0,-88(5)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define IsCurrentThread(thread, work_id) __IsCurrentThread((thread), (work_id), ThreadPoolBase)

WORKITEMSTATUS __SignalWorkItem(APTR thread, ssize_t work_id, ULONG signalmask, void *) =
	"\tlwz\t0,-94(6)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SignalWorkItem(thread, work_id, signalmask) __SignalWorkItem((thread), (work_id), (signalmask), ThreadPoolBase)

ssize_t __GetCurrentWorkItem(APTR threadpool, void *) =
	"\tlwz\t0,-100(4)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetCurrentWorkItem(threadpool) __GetCurrentWorkItem((threadpool), ThreadPoolBase)

#endif /*  _VBCCINLINE_THREADPOOL_H  */
