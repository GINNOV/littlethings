
#include <clib/macros.h>
#include <dos/dosextens.h>
#include <exec/execbase.h>
#include <exec/ports.h>
#include <exec/memory.h>

#ifndef ABSEXECBASE
#define ABSEXECBASE ((struct ExecBase **)4L)
#endif

struct EMessage {
    struct Message msg;
    struct Task    *HitTask;
    BYTE	    tc_Pri;	/* Original Prio;  (Prio  is temporarily set to
					MIN_PRI in order to make sure, our task
					gains control) */
    UBYTE	    tc_State;	/* Original State; (State is temporarily set to
					INVALID in order to show, that we have
					already trapped a hit -> no request) */
    APTR	    tc_PC;	/* PC when hit occured */
    APTR	    CurrentSSP; /* top of Supervisor stack */
#ifdef ZETA
    ULONG	    Elapsed;
    ULONG	    check;
    ULONG	    superstack[ZETA];
#endif
}; /* struct EMessage */

struct _TData {
    struct ExecBase *MyExecBase;       /* SysBase */
    __asm void	   (*OldVector)(void); /* Next TrapHandler */
    __asm void	   (*OwnVector)(void); /* only is assembled w/DEFINE USE_OwnVector */
    struct Task     *InputTask;        /* Do not trap this one */
    struct Task     *RecentTask;       /* This one need not be trapped */
    ULONG	     Active;	       /* Traphandler may be temporarily disabled */
    STRPTR	     CallingSSP;       /* Ptr 2 Stackframe for ForeignFreeze */
    /* ---- Fields above are referenced also in ASM-Part! ---- */

    UBYTE	     Decrease;	    /* Amount to decrease Task Pri */
    UBYTE	     pad0;
    UWORD	     FreeMsges;     /* # of free HitMsges */
    struct EMessage *MsgPtr;	    /* Array of HitMsges  */
    struct MsgPort  *ReportPort;    /* Port to send HitMsges to */
    struct MsgPort  *ReplyPort;     /* Not used Yet */
    struct MsgPort  *InterPort;     /* Internal use: see FGTask.c */
    ULONG	     Illegal;	    /* Internal Use: Test dangerous things */
    STRPTR	     InitialSSP;    /* Internal Use: SupervisorStack w/o Hit */
    struct MinList   FrozenTasks;   /* All Frozen Tasks */
    APTR	     Argv;	    /* CLI Args to Main process */
};


/* ---- The currently possible User decisions */
#define SEL_INVALID    6 /* Mark invalid + put into waitlist */
#define SEL_WAITLIST   5 /* just put into waitlist */
#define SEL_MINPRI     4 /* decrease priority to MIN_PRI */
#define SEL_DECREASE   3 /* drecrease priority one step */
#define SEL_BREAK      2 /* send break signal */
#define SEL_FREEZE     1 /* remove from tasklist - *DANGER* */
#define SEL_CONTINUE   0 /* NOP */
#define SEL_REMOVE    -1 /* RemTask() */
#define SEL_WAIT0     -2 /* set waitmask 0 and put into waitlist */
#define SEL_SIGNAL    -3 /* send signals */
#define SEL_

/* ---- TrapStubs.ASM */
extern	     far struct _TData TrapData;
extern	__asm __interrupt void TrapVector   (void);
extern	__asm __interrupt void TrapVector040(void);
extern	__asm __interrupt void TrapCode     (void);
extern	__asm __interrupt void TrapCodeNOP  (void);

/* ---- ForeignFreeze.ASM */
extern __asm void InstallForeignFreeze(register __a0 APTR);

/* ---- BGTask.c, FGTask.c */
#define CHILDTASKNAME "EnforcerFreeze SupportTask"

/* ---- Exec List Functions, which can be used also w/ MinLists */
extern void	       AddMinTail (struct MinList *, struct Node *);
extern struct MinNode *RemMinHead (struct MinList *);
extern void	       MinEnqueue (struct MinList *, struct Node *);
#pragma libcall SysBase AddMinTail f6 9802
#pragma libcall SysBase RemMinHead 102 801
#pragma libcall SysBase MinEnqueue 10e 9802


#define MMU_TRAP     2
#define MIN_PRI   -128
#define NUM_MSGES   16
//#define IS_SUSPENDED(tc) (tc->tc_Node.ln_Pri == MIN_PRI)
#define IS_SUSPENDED(tc) (tc->tc_State == TS_INVALID)

#define DOS_BREAK_SIGNALS (SIGBREAKF_CTRL_C| SIGBREAKF_CTRL_D| SIGBREAKF_CTRL_E| SIGBREAKF_CTRL_F)
