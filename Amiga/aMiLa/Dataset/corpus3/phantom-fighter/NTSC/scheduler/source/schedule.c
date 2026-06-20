/*
 * Actual Scheduler routine
 *
 * Written and Designed by Billy Newport March 1988
 *
 * (c) Emerald Software Ltd.
 */

#include "GameParam.h"
 
#include "scheduler.h"
#include <exec/memory.h>
#include "debug.h"
#include "Displist.h"
#include <hardware/custom.h>
#define usingDLEs

SCH_PEQE CurrentEQE;

SCH_EQE DummyEQE;

/******** Assembler Includes ***********/

extern SCH_PEQE FetchNextEQE();
extern void MyDebug();

#asm
		include	"header:scheduler.i"

		public	_FreeEQE
		public	_CreateEvent
                public	_DoNextAndRepeat
                public	_DoAfterAndRepeat
		public	_PurgeEvent
                XREF	_SCH_GQ_Event_Queue,_sys_time,_RemQue,_InsQue
                XREF	_AllocEQE,_EnqueueEvent,_SCH_GQ_Free_Event_Queue

;- - - - - - - - - - - FreeEQE - - - - - - - - - - - - - - - - - - - - -
;
; FUNCTION FreeEQE(SCH_PEQE EQE)
;
; ACTION
;    Place the non-resident EQE in the Free EQE queue
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
_FreeEQE:	move.l	4(sp),-(sp)
		move.l	_SCH_GQ_Free_Event_Queue,-(sp)
 
		movea.l	(sp),a0
		lea.l	_BadEQEFunction,a1
                move.l	a1,EQE_function(a0)
                jsr	_InsQue
                addq.l	#8,sp
                rts

		dseg
DummyName:	dc.b	'4','2',0
		cseg
                
;- - - - - - - - - - - CreateEvent - - - - - - - - - - - - - - - - - - - - -
;
; FUNCTION CreateEvent((*function)(),void *param,ULONG period,char *name)
;
; ACTION
;    Creates an event for the function specified. It is executed every
;    period ticks, and param is its parameter. name is the debugging
;    field (char *)
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                
_CreateEvent:	jsr	_AllocEQE	;D0 has EQE handle
		movea.l	d0,a0		;Get in address register
		lea.l	DummyName,a1
                move.l	a1,EQE_name(a0)

                move.l	4(sp),EQE_function(a0)
                move.l	8(sp),EQE_param(a0)
                move.l	12(sp),EQE_period(a0)
		move.l	16(sp),EQE_name(a0)
                move.l	#0,EQE_flags(a0)
                move.l	EQE_period(a0),-(sp)
                move.l	a0,-(sp)
                jsr	_EnqueueEvent
		move.l	(sp)+,d0
                addq.l	#4,sp
                rts
;;
;- - - - - - - - - - - DoNextAndRepeat - - - - - - - - - - - - - - - - -
;
; FUNCTION DoNextAndRepeat((*function)(),void *param,ULONG period,char *name)
;
; ACTION
;    Creates an event for the function specified. It is executed every
;    period ticks, and param is its parameter. name is the debugging
;    field (char *), but it is executed on the next tick initially 
;    regardless of the period.
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_DoNextAndRepeat:
		jsr	_AllocEQE	;D0 has EQE handle
		movea.l	d0,a0		;Get in address register
		lea.l	DummyName,a1
                move.l	a1,EQE_name(a0)

                move.l	4(sp),EQE_function(a0)
                move.l	8(sp),EQE_param(a0)
                move.l	12(sp),EQE_period(a0)
		move.l	16(sp),EQE_name(a0)
                move.l	#0,EQE_flags(a0)
                move.l	#1,-(sp)
                move.l	a0,-(sp)
                jsr	_EnqueueEvent
		move.l	(sp)+,d0
                addq.l	#4,sp
                rts
;- - - - - - - - - - - DoAfterAndRepeat - - - - - - - - - - - - - - - - -
;
; FUNCTION DoAfterAndRepeat((*function)(),
;                           void *param,
;                           ULONG period,
;                           char *name,
;                           ULONG after)
;
; ACTION
;    Creates an event for the function specified. It is executed every
;    period ticks, and param is its parameter. name is the debugging
;    field (char *), but it is executed initially after 'after' ticks 
;    regardless of the period.
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_DoAfterAndRepeat:
		jsr	_AllocEQE	;D0 has EQE handle
		movea.l	d0,a0		;Get in address register
		lea.l	DummyName,a1
                move.l	a1,EQE_name(a0)

                move.l	4(sp),EQE_function(a0)
                move.l	8(sp),EQE_param(a0)
                move.l	12(sp),EQE_period(a0)
		move.l	16(sp),EQE_name(a0)
                move.l	#0,EQE_flags(a0)
                move.l	20(sp),-(sp)
                move.l	a0,-(sp)
                jsr	_EnqueueEvent
		move.l	(sp)+,d0
                addq.l	#4,sp
                rts
;;
		dseg
EmptyEQE:	dc.b	'Unused EQE',0
		cseg
		XREF	_BadEQEFunction

;- - - - - - - - - - - PurgeEvent  - - - - - - - - - - - - - - - - - - -
;
; FUNCTION PurgeEvent(SCH_PEQE EQE)
;
; ACTION
;    The will remove an EQE from the queue it is resident in, if any
;
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

_PurgeEvent:	move.l	4(sp),a0
		andi.l	#EQE_Fpending,EQE_flags(a0)
                beq.s	10$
                move.l	a0,-(sp)
                jsr	_RemQue
		move.l	(sp)+,a0
		eori.l	#EQE_Fpending,EQE_flags(a0)
10$:		rts                

#endasm

extern DSP_PDLE DSP_DisplayList;
extern DSP_PDLE DSP_GroundObjects;

ULONG PrevEQEPtr;
char *PrevEQENames[32];
                
ULONG sys_time=0;
ULONG WatchDog;

char Sched_Alive;
extern BYTE AliensAvailable,BScroll2Go;

#ifdef P_CHECK
ULONG per_avg_delay_sum;
ULONG per_avg_delay_cnt;
ULONG per_avg_jobcnt_sum;
ULONG per_avg_jobcnt_cnt;
ULONG per_avg_enque_sum;
ULONG per_avg_enque_cnt;
#endif

#ifdef DEEP_DEBUG
#undef DEEP_DEBUG
#endif
/* Declare Event queue pointer */

SCH_PEQE SCH_GQ_Event_Queue[NUMPARTITIONS];

#define MyQueue SCH_GQ_Event_Queue[qn]

/* This initialises the schedulers pending event queue */

extern void ReturnAllEvents();

void NullFunction(param,EQE)
{
  ;
}

void InitialiseEventQueue()
{
  int qn;
  for(qn=0;qn<NUMPARTITIONS;qn++) {
    MyQueue=AllocEQE();
    if(!MyQueue) {
      DoAlert("Can't initialise Event Queue\n");
      ReturnAllEvents();
      exit(0);
    }
    MyQueue->flink=MyQueue; /* Make queue */
    MyQueue->blink=MyQueue;
    MyQueue->expire=-1;
  }
  sys_time=0;
}

/* This lets the schedule know about a new event Ev which is to be done
 * in delta_t ticks. */

ULONG TimeWarp;

/*
 *Main execution loop
 */
 

/*
 * This moves around the current jobs and does them
 * This queue must never be empty or its infinite loop time
 *
 * The scheduler should always be here
 */

extern WORD TimeForChecking;

void DoMainLoop()
{
   register SCH_PEQE Head;
   register SCH_PEQE EQE;
   
   Head=SCH_GQ_Event_Queue[0];
   
   WatchDog=-1;
   SetUpInterrupt();
   Sched_Alive=(char)1;
   custom.clxcon=0xf57f;		/* Gimme Every-Thing */
   while(Sched_Alive) {
      EQE=Head->flink;
      WatchDog=10;
      if(TimeForChecking) {
         CollisionCheck();		/* Bobs against Bobs */
         CollisionCheckSprites(DSP_GroundObjects);
         if(custom.clxdat&0x1e)		/* Sprite hits Bob */
            CollisionCheckSprites(DSP_DisplayList);
            TimeForChecking=0;
      }
      if(Head->expire<=sys_time) {
         CurrentEQE=Head;
/*         *(WORD *)0xdff180=0xf;*/
         (*Head->function)(Head->param,Head);
/*         *(WORD *)0xdff180=0xf00;*/
      }
      Head=EQE;
   }
   RemoveInterrupt();
}


/*
 * Scheduler memory routines
 *
 */
 


extern void *AllocMem();

SCH_PEQE SCH_GQ_Free_Event_Queue;

/* Allocate and intialise the EQE pool */

/********************************************
 * This sets up the free queue
 *
 */
 
void EmptyFreeEventQueue()
{
  SCH_PEQE i;
  int j;
  SCH_GQ_Free_Event_Queue->flink=SCH_GQ_Free_Event_Queue;
  SCH_GQ_Free_Event_Queue->blink=SCH_GQ_Free_Event_Queue;
  i=SCH_GQ_Free_Event_Queue;
  for(j=1;j<MAXEVENTS;j++) {
    InsQue(SCH_GQ_Free_Event_Queue,++i);
    i->function=MyDebug;
  }
}

void AllocateFreeEventQueue()
{ /* AllocateFreeEventQueue */
  BYTE *start;
  start=AllocMem(sizeof(struct SCH_Event_Queue_Entry)*MAXEVENTS,0L);
  SCH_GQ_Free_Event_Queue=(struct SCH_Event_Queue_Entry *)start;
  if(!start)
    {
    DoAlert("InitFEQ-F: No memory for EQE pool");
    SCH_GQ_Free_Event_Queue=NULL;
    }
  EmptyFreeEventQueue();
}

/* Free up the EQE pool */

void ReturnAllEvents()
{
  if(SCH_GQ_Free_Event_Queue)
    FreeMem(SCH_GQ_Free_Event_Queue,sizeof(struct SCH_Event_Queue_Entry)*MAXEVENTS);
#ifdef P_CHECK
  Display_Stats();
#endif
}

/* This allocates a Event Queue Entry and returns its address */

extern void MyDebug();
extern void WaitLeftButton();

void BadEQEFunction(param,EQE)
char *param;
SCH_PEQE EQE;
{
   WatchDog=-1;
   dprintf("Bad EQE\n");
   dprintf("Last name is %s\n",EQE->name);
   dprintf("Press Left button for Schedule info :- \n");
   WaitLeftButton();
   MyDebug();
}
   
SCH_PEQE AllocEQE()
{
  register SCH_PEQE t;
  /* Queue Empty */
  if (SCH_GQ_Free_Event_Queue->flink==SCH_GQ_Free_Event_Queue)
    DoAlert("AllocEQE-F: Can't Allocate an EQE");

  t=RemQue(SCH_GQ_Free_Event_Queue->flink);
  t->function=BadEQEFunction;
  return t;
}

/*****************************************************************
 * This initialises every-thing to do with the scheduling system *
 *****************************************************************/
 
void InitialiseScheduling()
{
  EmptyFreeEventQueue();
  InitialiseEventQueue();			/* Empty SCheduler queue */
  CurrentEQE=&DummyEQE;
  CurrentEQE->name="No EQE's executed";
}

   
#undef EnqueueEvent

void EnqueueEvent(Ev,delta_t)
SCH_PEQE Ev;
ULONG delta_t;
{
  Ev->expire=sys_time+delta_t;
  if(Ev->flags^EQE_pending) {
     InsQue(SCH_GQ_Event_Queue[0],Ev);
     Ev->flags|=EQE_pending;
  }
}

