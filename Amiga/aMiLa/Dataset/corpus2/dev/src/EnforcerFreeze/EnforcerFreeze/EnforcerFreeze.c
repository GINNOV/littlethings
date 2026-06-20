#define PRE_ENFORCER 0 /* ==1 -> This version must be run BEFORE Enforcer */
#define ETA 2 /* ==54; 3 Longs mit x+2,x+4,x+6 */
#define ZETA 0
#define STDSSPDIFF 0x54
#define RTE_DIST   2
/******************************************************************************

    MODULE
	EnforcerFreeze.c

    DESCRIPTION
	Freeze Nasty Processes, which produce Enforcer Hits

	GENERAL
	    EnforcerFreeze creates a busy Task at priority -127 and
	    installs an additional TrapHanlder for Address Faults
	    (for that reason, it might be incompatible with VMM);
	    whenever an Enforcerhit occurs, the priority of the
	    hitting Task is set to -128 (I knew not better possibility
	    to freeze a task) and a message is sent to the EnforcerFreeze
	    Process.EnforcerFreeze now prompts the user with a message
	    that one task has produced a Hit and asks what to do.

	* The Traphandler may be temporarily disabled by sending CTL-D
	  the process; it may be re-enabled by sending CTL-E to the process.

	* The Requester can be turned off
	  either by not specifying REQUEST on start
	  or by sending CTL-F (as a toggle) to the Process
	  it may be re-enabled by againsending CTL-F to the process.

	  If there is no Requester active, we just decrease the task
	  priority for each hit automatically

	  The decrease in Priority, we perform (either on user request or
	  automatically) can be set on start w/ the DECREMENT keyword

	* We currently can queue up to 16 Enforcerhits while proimpting
	  for user decision; (the according processes are "stopped" up
	  to the moment, the user decides, what to do) if there occur more
	  hits, while we are prompting for User-Input (or the hell why)
	  the TrapCode acts, like if REQUESTMODE was turned off (decrease
	  Priority)

	* The Priority of the handlertask can be set on startup
	  (0 <= priority <= 19)

	* Tasks just moved into the "Waitinglist" can be reactivated
	  by just changing their priority. If they were already waiting,
	  this selection has no effect.

	* Tasks marked "Invalid" can be reactivated e.g. via ARTM
	  (freeze & activate -> the status is changed, and the right
	  list is used)

	* Tasks marked w/ "Wait-0" can not be reactivated such easy:
	  U have to know, if they were waiting or running, and if
	  waiting, for which signals, in order to reinstall the original
	  state (hopeless); this way should be used only, if a task shall
	  be stopped forever (also past EnforcerFreeze-termination)

	* Frozen Tasks are moved into a private List, and can thus
	  _not_ be found via FindTask or Monitors any more

	* If EnforcerFreeze is quit (via CTL-C) the the "frozen" programs
	  are restarted w/ Priority -128 (in the waitinglist)


	- Unfortunately We have to wait up to QUANTUM for a taskswitch,
	  so there may be produced many hits, before we can stop the task...
	  (I have counted up to 3000 in the following loop
	  "int x = 0; while (!(pr->pr_Task.tc_SigMask)) x+=*(STRPTR)NULL;" )
	  Up to now, all tries to freeze the current task before a
	  taskswitch have been unsuccessful ... (I have no documentation
	  about 680x0, so this won't change so fast) (I have tried to simulate
	  a JSR "Wait(0)" on the user-stack, but the only result is: the
	  machine is freezing (see ForeignFreeze.asm))


	BACKGROUNDTASK MODE: (optional)
	* Minimal Priority means: the task is stopped, since the BGTask
	  has Priority -127

	* while the user is prompted for input, the hitting Task is stopped
	  by minimizing its priority (so it's still accessible)

	- The BackgroundTask needs lots of CPU time (e.g. Blanker won't show
	  its patterns any more)

	- EnforcerFreeze QUIT does not work in connection w/ BG-Tasks

	FOREGROUNDTASK MODE: (default)
	* Minimal Priority does _not_ stop a task, since it gets all remaining
	  time, if other tasks are waiting ...

	* The hitting tasks are removed from the task list, while the user is
	  prompted for a decision

	* The Signals CTL-CDEF are passed to the Parenttask, if they are
	  send to the childtask.

	  (I currently cannot remember any contra)

    NOTES
	Kickstart 2.0+ required
	compiles w/ SAS/C v6.51

	CLI only (currently)

	!!!!! RUNS ONLY ON 68030, NEEDS ENFORCER RUNNING !!!!!!!!
	it needs an MMU to run, but how can we test that?

    WARNING
	This Program is highly experimental!

	* It is changing System Vectors, so the machine might hopelessly
	  crash; never checked interference w/ Viruskillers, nor tested
	  together w/ VMM etc.
	* It is poking in Task Structures and Exec TaskList ...
	* It is using Forbid/Permit (and perhaps even not enough)
	* Nobody is AmigaGER was able to tell me about doing it,
	  and I did not find any note in GuruBook nor in RKRM,
	  so it is just a try.
	* No Betatesting yet - I am always in a great lack of testers =8*}
	* According to exec/AllocTrap(), direct write to Exception
	  table is not allowed, but we do so; thus we are illegal

	*** Use only at Your own risk! ***
	(Dont't blame me for Your damage)

    BUGS
	* Task must be halted for REQUEST mode
	  or
	* Requestmode should do some security checks
	  else we might be hitting ourself =8-}


    TODO
	**** Immediate Trapping
	     we must currently wait for the next taskswitch to occur,
	     before the hitting task is suspended; that means, that up
	     to 10000 additional hits might occur (which then are skipped)
	     (sorry, but i have no idea, how to speed up this taskswitch)

	*! Task/Program exclusion list (not only input.device)
	*! RexxDest - instead of Request send a string to an ARexxPort
	  (e.g. Port="REXX"
		String="ENFORCERHIT TASK=$(tc) PRI=$(tp) STATE=$(ts) \
			    LIST=$(&TrapData.FrozenTasks) MODE=$(bg|fg)")
	* Commodities interface?
	* GUI? (better via RexxDest)
	* ARexx Port?
	    MODE	FREEZE|DRECREASE|REQUEST|SLEEP/S
	    SET 	DECREMENTVALUE/K/N
	    FREEZE	TASKNAME/K,TASKID/K/N
	    FROZENTASKS  STEM/K
	    WAITINGTASKS STEM/K
	    QUIT	FORCE/S
	* better message handling? (there may be lost hits ...)
	* RemTask/Ctl-DEF Choices?

    EXAMPLES
	no chance

    SEE ALSO
	Enforcer

    INDEX

    HISTORY
	(12-02-95 b_noll T created .c.Template)
	(20-02-95 b_noll T added includes section)
	(21-02-95 b_noll T added version/format-prefix/offset)
	(20-03-95 b_noll T added args diagnostics)
	11-04-95 b_noll created
	12-04-95 b_noll cleanup
	22-04-95 b_noll removed FREEZE/S given up the ForeignFreeze Try 8-(
	26-04-95 b_noll added QUIT option
	31-05-95 b_noll tried in vane to use Reschedule

    AUTHOR
	Bernd Noll, Brunnenstrasse 55, D-67661 Kaiserslautern
	b_noll@informatik.uni-kl.de

******************************************************************************/

/**************************************
	    Includes
**************************************/

#ifndef   EXEC_LIBRARIES_H
# include <exec/libraries.h>
#endif /* EXEC_LIBRARIES_H */

#ifndef   CLIB_EXEC_PROTOS_H
# include <clib/exec_protos.h>
#endif /* CLIB_EXEC_PROTOS_H */

#ifndef   DOS_DOS_H
# include <dos/dos.h>
#endif /* DOS_DOS_H */

#ifndef   CLIB_DOS_PROTOS_H
# include <clib/dos_protos.h>
#endif /* CLIB_DOS_PROTOS_H */

#include <proto/dos.h>
#define __USE_SYSBASE 1
#undef	_USEOLDEXEC_
#include <proto/exec.h>


/* ******************** USER INCLUDES ******************** */

#include <clib/macros.h>
#include <dos/dosextens.h>
#include <exec/execbase.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <proto/intuition.h>

#include "EnforcerFreeze.h"
#include "SV_Shorties.h"


/* ******************** USER INCLUDES ******************** */

/**************************************
	 Defines & Structures
**************************************/

#ifndef ABSEXECBASE
#define ABSEXECBASE ((struct ExecBase **)4L)
#endif

struct _arg {
/* ******************** USER FORMAT ******************** */
#define FORMAT "DECREMENT/N/K,REQUEST/S,TASKPRI/N/K,ILLEGAL/S,BG=USEGBTASK/S,QUIT/S"

    ULONG *decrement;
    ULONG  request;
    ULONG *taskpri;
    ULONG  illegal;
    ULONG  usebgtask;
    ULONG  quit;

/* ******************** USER FORMAT ******************** */
}; /* struct _argv */

#define MAXPATHLEN 256
#define MAXLINELEN 256

#define VERSIONPREFIX	"$VER: "
#define VERSIONOFFSET	0
#define FORMATPREFIX	"$ARG: "
#define FORMATOFFSET	6

/**************************************
	    Implementation
**************************************/

/* ******************** USER ADDES ******************** */

void NewMinList (struct MinList *l);
#define NewMinList(l) NewList((struct List *)(l))

/* ******************** USER ADDES ******************** */



long _main (void)
{
    const char* version = VERSIONPREFIX "EnforcerFreeze 1.0 " __AMIGADATE__ + VERSIONOFFSET;
    long retval = RETURN_FAIL;
    struct ExecBase*SysBase = *ABSEXECBASE;
    struct Library* DOSBase;
    struct Library* IntuitionBase;

    if (DOSBase = OpenLibrary (DOSNAME, 37)) {
	if (IntuitionBase = OpenLibrary("intuition.library",37)) {
	    struct _arg argv = { 0 };
	    APTR   args;
	    retval   = RETURN_ERROR;
	    if (args = (void *)ReadArgs(FORMATPREFIX FORMAT + FORMATOFFSET, (LONG*)&argv, NULL)) {

/* ******************** USER BODY ******************** */ /* outdented 8 chars */

	struct Process *pr = (struct Process *)FindTask(NULL);
	struct EMessage *_msg  = NULL; /* all msges */
	struct MsgPort	*_port = NULL; /* _signal port */
	struct MsgPort	*_rport= NULL; /* replyport */
	struct Task	*_task2= NULL; /* childtask */
extern	struct Task *CreateBGTask(void);
extern	void	     DeleteBGTask(struct Task *);
extern	void	     BGPostProcessMsg (struct EMessage *, ULONG);
extern	struct Task *CreateFGTask(struct MsgPort *);
extern	void	     DeleteFGTask(struct Task *);
extern	void	     FGPostProcessMsg (struct EMessage *, ULONG);
extern	void	     TrapMsg(struct EMessage *);

	/* TrapData.FreezeIt	= argv.freeze	? 1 : 0; */
	TrapData.Decrease    = argv.decrement? MIN(*argv.decrement,20): 1;
	TrapData.InputTask   = FindTask("input.device");
	TrapData.FreeMsges   = NUM_MSGES;
	TrapData.MyExecBase  = SysBase;
	TrapData.OwnVector   = TrapCode;
	TrapData.Active      = 1;
	TrapData.Illegal     = argv.illegal;
	TrapData.Argv	     = &argv;

	NewMinList (&TrapData.FrozenTasks);

	if (argv.quit) {
	    struct Task *tc;
	    tc = FindTask (CHILDTASKNAME);
	    if (!tc) {
		Printf	("%s is not running\n", "EnforcerFreeze");
		SetIoErr(ERROR_OBJECT_NOT_FOUND);
		retval = RETURN_WARN;
	    } else {
		Signal (tc, SIGBREAKF_CTRL_C);
		Printf ("Signalled %s to terminate\n", "EnforcerFreeze");
		retval = RETURN_OK;
	    } /* if */
	} else if (!(SysBase->AttnFlags & AFF_68030)) {
	    PutStr ("This Program can be run ONLY on 68030 machines!\n");
	    retval = RETURN_FAIL;
#if PRE_ENFORCER
	} else if (FindTask("« Enforcer »")) {
	    PutStr ("Enforcer is already running!\n");
	    retval = RETURN_WARN;
#else
	} else if (!FindTask("« Enforcer »")) {
	    PutStr ("Enforcer is obviously not running!\n");
	    retval = RETURN_WARN;
#endif
	} else if (FindTask(CHILDTASKNAME)) {
	    PutStr ("EnforcerFreeze is already running!\n");
	    retval = RETURN_WARN;
	} else {
	    _msg  = AllocVec(sizeof(struct EMessage[NUM_MSGES]), MEMF_CLEAR|MEMF_PUBLIC);
	    _port = CreateMsgPort();
	    _rport= CreateMsgPort();
	    _task2= argv.usebgtask ? CreateBGTask() : CreateFGTask(_port);
	    if (_msg && _port && _task2 && _rport) {
		void __asm (**vbr)(void);
		void __asm (*vector)(void);
		void *ssp;
		ULONG sigmask;
		//const UWORD	  getvbr[] = { 0x4e7a, 0x0801, 0x4e73 }; /* movec.l VBR,d0; rte */

		retval	= RETURN_OK;
		sigmask =   SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_D |
			    SIGBREAKF_CTRL_E | SIGBREAKF_CTRL_F |
			    (1 <<  _port->mp_SigBit) |
			    (1 << _rport->mp_SigBit);

		if (argv.taskpri)
		    SetTaskPri(&pr->pr_Task, MIN(19,MAX(0,*argv.taskpri)));
		    /* Priority must be lower than input, but should be higher than slow tasks */

		TrapData.MsgPtr      = _msg;
		TrapData.ReplyPort   = _rport;
		TrapData.ReportPort  = argv.request ? (argv.usebgtask ? _port : TrapData.InterPort) : NULL;
		TrapData.InitialSSP  = ssp = (void*)Supervisor((APTR)a7d0);

		vbr = (void*)Supervisor((APTR)vbrd0);

//vbr = NULL;
		if (vbr) /* always true with running Enforcer */
		{
		    vector = (SysBase->AttnFlags & AFF_68040) ?
					    TrapVector040 : TrapVector;

		    PutStr ("EnforcerFreeze installed");
		    Forbid();
		    TrapData.OldVector = vbr[MMU_TRAP];
		    vbr[MMU_TRAP]      = vector;
		    do {
			Permit();

			do {
			    struct EMessage *msg;
			    ULONG	    sigs;
			    ULONG	    rv;
			    BYTE	    tp;
			    UBYTE	    ts;
			    struct Task    *tc;
			    struct EasyStruct es = {
				sizeof (struct EasyStruct),
				0,
				"EnforcerFreeze",
				"Task '%s' (Pri %ld) has caused an Enforcerhit.",
				"Freeze|Send Ctl-C|Decrease Prio|Minimal Pri|WaitList|Mark Invalid|Continue"
			    };
			    sigs = Wait(sigmask);

			    /* ---- walk through pending msges */
			    if (sigs & (1 << _port->mp_SigBit))
				while (msg = (struct EMessage *)GetMsg(_port)) {
				    tc = msg->HitTask;
				    tp = msg->tc_Pri;
				    ts = msg->tc_State;

				    /* ERROR - missing security check */
				    Forbid();
				    if (tc->tc_State == TS_INVALID)
					tc->tc_State = ts;
				    if (TrapData.RecentTask == tc)
					TrapData.RecentTask = NULL;
				    Permit();

				    rv = EasyRequest(NULL, &es, 0, tc->tc_Node.ln_Name, tp);

				    argv.usebgtask ? BGPostProcessMsg(msg,rv): FGPostProcessMsg(msg,rv);

				    /* ---- Allow reuse of msg ptr */
				    Forbid();
				    ReplyMsg(&msg->msg);
				    TrapData.FreeMsges++;
				    //msg->msg.mn_Node.ln_Type = NT_REPLYMSG;
				    Permit();

				} /* while */


			    /* ---- FORBID Requests - _TOGGLE_ */
			    if (sigs & SIGBREAKF_CTRL_F)
				TrapData.ReportPort = TrapData.ReportPort ? NULL : _port;

			    /* ---- ENABLE System */
			    if (sigs & SIGBREAKF_CTRL_E) {
				TrapData.Active     = 1L;
				TrapData.RecentTask = NULL;
			    } /* if */

			    /* ---- DISABLE System */
			    if (sigs & SIGBREAKF_CTRL_D)
				TrapData.Active = 0L;

			    /* ---- until CLOSEDOWN System */
			    if ((sigs & SIGBREAKF_CTRL_C))
				break;

			} while (1);

			TrapData.Active = 0;
			Printf ("Trying to terminate\n");
			Forbid ();
		    } while (vbr[MMU_TRAP] != vector);
		    vbr[MMU_TRAP] = TrapData.OldVector;
		    Permit();
		    Printf ("Terminated\n");
		} /* if vbr!=0 */
	    } /* if all data allocated */

	    /* ---- free all allocations */
	    if (_task2)
		argv.usebgtask ? DeleteBGTask(_task2) : DeleteFGTask(_task2);
	    if (_port)
		DeletePort(_port);
	    if (_rport)
		DeletePort(_rport);
	    if (_msg)
		FreeVec(_msg);


	    {
		struct Task *tc;
		/* ---- Move all frozen tasks at minimal priority into WaitList */
		Forbid();
		while (tc = (struct Task *)RemMinHead(&TrapData.FrozenTasks)) {
		    tc->tc_Node.ln_Pri = MIN_PRI;
		    Enqueue(&SysBase->TaskWait, &tc->tc_Node);
		    SetTaskPri(tc, MIN_PRI);
		} /* while */
		Permit();
	    }
	} /* if right cpu */

/* ******************** USER BODY ******************** */
		FreeArgs (args);
	    } /* if */

	    if (retval > RETURN_WARN)
		PrintFault(IoErr(), "EnforcerFreeze");

	    CloseLibrary (IntuitionBase);
	} /* if */
	CloseLibrary (DOSBase);
    } /* if */

    return (retval);
} /* _main */

/* ******************** USER ADDES ******************** */


/* **** We do NOT expect any Taskswitches inside this Trap; is this assumption right? */
__asm __interrupt void TrapCode (void) {
    struct _TData *td = &TrapData;
    struct Task *tc;
    struct EMessage *msg;
    struct ExecBase *SysBase;

    SysBase = td->MyExecBase;
    tc	    = SysBase->ThisTask;

    /* ---- Don't touch Input.task nor "secondary Hits" */
    if ((tc != td->InputTask) /* && (td->InitialSSP - STDSSPDIFF == td->CallingSSP) && !IS_SUSPENDED(tc) */ && (tc->tc_State != TS_INVALID)) {

	if ((msg = td->MsgPtr) && td->ReportPort && td->FreeMsges) {
	    td->FreeMsges--;
	    while (msg->msg.mn_Node.ln_Type == NT_MESSAGE)
		++msg;

	    msg->HitTask       = tc;
	    msg->tc_Pri        = tc->tc_Node.ln_Pri;
	    msg->tc_State      = tc->tc_State;
	    PutMsg (td->ReportPort, &msg->msg);

	    /* ---- is used to notify "task is already invalid" */
	    tc->tc_Node.ln_Pri = MIN_PRI;
	    tc->tc_State       = TS_INVALID;

	} else {
	    /* if (td->FreezeIt)
		tc->tc_Node.ln_Pri = MIN_PRI;
	    else */
		if (tc->tc_Node.ln_Pri  - td->Decrease > MIN_PRI)
		    tc->tc_Node.ln_Pri -= td->Decrease;
		else
		    tc->tc_Node.ln_Pri = MIN_PRI;
		td->RecentTask = NULL;
	} /* if */
    } else {
	td->RecentTask = NULL;
    } /* if */
} /* TrapCode */

__asm __interrupt void TrapCodeNOP (void) {
} /* TrapCodeNOP */

/*
void NewMinList (struct MinList *l)
{
    NewList((struct List *)l);
} /* NewMinList */

/* ******************** USER ADDES ******************** */


/******************************************************************************
*****  END EnforcerFreeze.c
******************************************************************************/
