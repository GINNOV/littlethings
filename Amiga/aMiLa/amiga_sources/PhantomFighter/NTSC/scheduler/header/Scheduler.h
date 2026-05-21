/*
 * Scheduler include file
 *
 *
 * Written by Billy Newport
 *
 */
#ifndef SCHEDULERH
#define SCHEDULERH

#include <exec/types.h>

struct SCH_Event_Queue_Entry
{
  struct SCH_Event_Queue_Entry *flink,
                     *blink;
  ULONG  expire;		/* Time to trigger event */
  void   (*function)();         /* Event handler */
  char   *param;		/* Parameter to pass to handler */
  ULONG  flags;			/* Flags */

/* For priority events like scroll */
#define EQE_kernel    0x40000000L
/* Set if EQE currently in CurrentQ */
#define EQE_pending    0x80000000L
#define EQE_User0      0x1L
#define EQE_User1      0x2L
#define EQE_User2      0x4L
#define EQE_User3      0x8L

  ULONG  period;		/* For periodic events */
  char   *name;			/* For conversational Debugging */
};

typedef struct SCH_Event_Queue_Entry SCH_EQE;
typedef struct SCH_Event_Queue_Entry *SCH_PEQE;

struct SCH_queue {
  struct SCH_queue *flink,
                   *blink;
};

/*
 * Listhead for the pending event queue
 */

#define NUMPARTITIONS 1
#define SelectQ(a)  qn=(a)&(NUMPARTITIONS-1)

extern SCH_PEQE SCH_GQ_Event_Queue[NUMPARTITIONS];
extern SCH_PEQE SCH_GQ_Free_Event_Queue;
extern char Sched_Alive;
extern ULONG sys_time;

extern SCH_PEQE AllocEQE();
extern void FreeEQE();
extern void InsQue();
extern void *RemQue();

#ifdef P_CHECK
extern ULONG per_avg_displ_sum;
extern ULONG per_avg_displ_cnt;
extern ULONG per_avg_delay_sum;
extern ULONG per_avg_delay_cnt;
extern ULONG per_avg_jobcnt_sum;
extern ULONG per_avg_jobcnt_cnt;
extern ULONG per_avg_enque_sum;
extern ULONG per_avg_enque_cnt;
#endif

#define ALLOCEQE (SCH_PEQE)RemQue(SCH_GQ_Free_Event_Queue->flink)
#define FREEEQE(a)  InsQue(SCH_GQ_Free_Event_Queue,a)
#define PURGEEQE(a) if(a->flags&EQE_pending){a->flags&=~EQE_pending;(void)RemQue(a);}

#define ENQUEUEEVENT(E,P) E->expire=sys_time+P
#endif
