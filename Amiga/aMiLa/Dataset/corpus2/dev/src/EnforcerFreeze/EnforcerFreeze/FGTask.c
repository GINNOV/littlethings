
#include "EnforcerFreeze.h"
#include <proto/exec.h>



#define WAIT_STACK_SIZE 4256
#define MAX_PRI 	 99

struct FGArgs {
    /* ---- Input */
    struct Task    *ParentTask;
    struct MsgPort *PassPort;
    struct List    *FrozenTasks;

    /* ---- Output */
    BOOL	    OK;
    struct MsgPort *ChildPort;
}; /* struct FGArgs */


__stdargs __interrupt void FGTask(void) {
    /* ---- just an endless loop */
    ULONG sigs;
    struct ExecBase *SysBase = *ABSEXECBASE;
    struct FGArgs *arg = FindTask(NULL)->tc_UserData;

    /* **** INITIALIZE */

    /* ---- Allocate Resources */
    arg->ChildPort = CreateMsgPort();

    /* ---- Tell Daddy our Status */
    arg->OK = arg->ChildPort ? TRUE : FALSE;
    Signal(arg->ParentTask, -1);

    /* ---- If Something Failed, Wait 4ever */
    if (!arg->OK)
	Wait(0);


    /* **** Main loop: wait 4 message, freeze sendertask, send it to Daddy */

    do {
	struct EMessage *msg;
	sigs = Wait(-1);
	while (msg = (struct EMessage *)GetMsg(arg->ChildPort)) {
	    Forbid();
	    Remove (&msg->msg.mn_Node);
	    Remove (&msg->HitTask->tc_Node);
	    AddTail(arg->FrozenTasks, &msg->HitTask->tc_Node);
	    msg->HitTask->tc_Node.ln_Pri = msg->tc_Pri;
	    PutMsg(arg->PassPort, &msg->msg);
	    Permit();
	} /* while */

	if ((sigs != -1) && (sigs & DOS_BREAK_SIGNALS)) {
	    Signal (arg->ParentTask, sigs & DOS_BREAK_SIGNALS);
	} /* if */
    } while (sigs != -1);

    /* **** TERMINATE */

    /* ---- Free Resources */
    DeleteMsgPort (arg->ChildPort);

    /* ---- Tell Daddy, we are done */
    Signal (arg->ParentTask, -1);

    /* ---- Wait 4ever */
    Wait (0);
} /* FGTask */

struct Task* CreateFGTask (struct MsgPort *port)
{
    struct ExecBase *SysBase = *ABSEXECBASE;
    struct Task   *tc;
    struct FGArgs *arg;
    STRPTR stack;

    if (!port)
	return NULL;

    /* ---- BAD STYLE: we are allocating 3 structs in one call */
    if (tc = AllocVec(sizeof (struct Task) + sizeof (struct FGArgs) + WAIT_STACK_SIZE, MEMF_PUBLIC|MEMF_CLEAR)) {
	arg = (APTR)(tc + 1);
	stack = (STRPTR)(arg + 1) + WAIT_STACK_SIZE;

	/* ---- Minimal Task initialisation */
	tc->tc_Node.ln_Pri  = MAX_PRI-1;
	tc->tc_Node.ln_Type = NT_TASK;
	tc->tc_Node.ln_Name = CHILDTASKNAME;
	tc->tc_SPLower	    = stack - WAIT_STACK_SIZE;
	tc->tc_SPUpper	    = stack;
	tc->tc_SPReg	    = stack;
	tc->tc_UserData     = arg;

	/* ---- arguments */
	arg->ParentTask  = FindTask(NULL);
	arg->FrozenTasks = &TrapData.FrozenTasks;
	arg->PassPort	 = port;
	arg->OK 	 = FALSE;

	//NewList (arg->FrozenTasks);

	SetSignal(0, -1);
	if (AddTask(tc, FGTask, NULL)) {
	    Wait(-1);
	    if (arg->OK != FALSE) {
		TrapData.InterPort = arg->ChildPort;
		return tc;
	    } /* if */
	    RemTask(tc);
	} /* if */
	FreeVec(tc);
    } /* if */
    return NULL;
} /* CreateFGTask */

void DeleteFGTask (struct Task *tc) {
    struct ExecBase *SysBase = *ABSEXECBASE;
    if (tc) {
	SetSignal(0, -1);
	Signal	 (tc,-1);
	Wait	 (-1);
	Forbid	 ();
	RemTask  (tc);
	Permit	 ();
	FreeVec  (tc);
    } /* if */
} /* DeleteFGTask */

void FGPostProcessMsg (struct EMessage *msg, ULONG selection) {
    struct Task     *tc      = msg->HitTask;
    struct ExecBase *SysBase = *ABSEXECBASE;
    UBYTE	     tcstate;

    if (selection == SEL_FREEZE)
	return;

    tcstate = tc->tc_State;
    if (selection == SEL_INVALID || selection == SEL_WAITLIST || selection == SEL_WAIT0)
	tc->tc_State = TS_INVALID;

    Forbid();
    /* ---- Reengage Task */
    Remove (&tc->tc_Node);
    Enqueue((tc->tc_State != TS_READY)? &SysBase->TaskWait : &SysBase->TaskReady, &tc->tc_Node);
    //Enqueue(&SysBase->TaskWait, &tc->tc_Node);
    switch (selection) {
    case SEL_MINPRI:
	SetTaskPri (tc, MIN_PRI);
	break;
    case SEL_DECREASE:
	SetTaskPri (tc, MAX(MIN_PRI,tc->tc_Node.ln_Pri-TrapData.Decrease));
	break;
    case SEL_REMOVE:
	RemTask(tc);
	break;
    case SEL_SIGNAL:
	Signal(tc, tc->tc_SigWait|tc->tc_SigAlloc);
	break;
    case SEL_BREAK:
	Signal(tc, SIGBREAKF_CTRL_C);
	break;
    case SEL_WAITLIST:
	tc->tc_State = tcstate;
	break;
    case SEL_INVALID:
	tc->tc_State = TS_INVALID;
	break;
    case SEL_WAIT0:
	tc->tc_State   = TS_WAIT;
	tc->tc_SigWait = 0;
	break;
    case SEL_CONTINUE:
	;/* nop - we have already reengaged the task */

    /* case SEL_FREEZE: see above */
    default:
	;
    } /* switch */
    Permit();
} /* FGPostProcessMsg */


