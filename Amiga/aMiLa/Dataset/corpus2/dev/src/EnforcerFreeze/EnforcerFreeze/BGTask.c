
#include "EnforcerFreeze.h"
#include <proto/exec.h>

/* it is shorter, if we kill the childtask instead of signalling it to quit ... */

#define MIN_STACK_SIZE 100 /* We would _perhaps_ need only 72 bytes */

__interrupt void BGTask(void) {
    /* ---- just an endless loop */
    while (1);
} /* BGTask */

struct Task *CreateBGTask (void) {
    struct ExecBase *SysBase = *ABSEXECBASE;
    struct Task *tc;
    STRPTR stack;
    /* ---- BAD STYLE: we are allocating 2 structs in one call */
    if (tc = AllocVec(sizeof (struct Task) + MIN_STACK_SIZE, MEMF_PUBLIC|MEMF_CLEAR)) {
	stack = (STRPTR)(tc + 1) + MIN_STACK_SIZE;

	/* ---- Minimal initialisation */
	tc->tc_Node.ln_Pri  = MIN_PRI + 1;
	tc->tc_Node.ln_Type = NT_TASK;
	tc->tc_Node.ln_Name = CHILDTASKNAME;
	tc->tc_SPLower	    = stack - MIN_STACK_SIZE;
	tc->tc_SPUpper	    = stack;
	tc->tc_SPReg	    = stack;
	if (AddTask(tc, BGTask, NULL))
	    return tc;
	FreeVec(tc);
    } /* if */
    return NULL;
} /* CreateTask */

void DeleteBGTask (struct Task *tc) {
    struct ExecBase *SysBase = *ABSEXECBASE;
    if (tc) {
	Forbid();
	RemTask(tc);
	Permit();
	FreeVec(tc);
    } /* if */
} /* DeleteBGTask */

void BGPostProcessMsg (struct EMessage *msg, ULONG selection)
{
    struct Task     *tc      = msg->HitTask;
    struct ExecBase *SysBase = *ABSEXECBASE;
    UBYTE	     tp      = msg->tc_Pri;

    Forbid();
    switch (selection) {
    case SEL_MINPRI:
	/* set minimal pri */
	/* Already done in Trap ... SetTaskPri(tc, MIN_PRI); */
	break;
    case SEL_DECREASE:
	/* decrease pri */
	SetTaskPri(tc, MAX(MIN_PRI, tp - TrapData.Decrease));
	break;
    case SEL_REMOVE:
	RemTask(tc);
	break;
    case SEL_SIGNAL:
	Signal(tc, tc->tc_SigWait|tc->tc_SigAlloc);
	/* re-set old pri; task had been frozen ... */
	SetTaskPri(tc, tp);
	break;
    case SEL_BREAK:
	Signal(tc, SIGBREAKF_CTRL_C);
	/* re-set old pri; task had been frozen ... */
	SetTaskPri(tc, tp);
	break;


    case SEL_WAITLIST:
    case SEL_INVALID:
    case SEL_WAIT0:
    case SEL_FREEZE:
	SetTaskPri (tc, tp);
	Remove	   (&tc->tc_Node);
	if (selection == SEL_FREEZE)
	    AddTail(&TrapData.FrozenTasks, &tc->tc_Node);
	else {
	    Enqueue(&SysBase->TaskWait, &tc->tc_Node);
	    if (selection == SEL_WAIT0) {
		tc->tc_State   = TS_WAIT;
		tc->tc_SigWait = 0;
	    } /* if */
	    if (selection == SEL_INVALID) {
		tc->tc_State   = TS_INVALID;
	    } /* if */
	} /* if */
	break;
    case SEL_CONTINUE:
	/* re-set old pri; task had been frozen ... */
	SetTaskPri(tc, tp);

   default:
       ;
    } /* switch */
    Permit();
} /* BGPostProcessMsg */


