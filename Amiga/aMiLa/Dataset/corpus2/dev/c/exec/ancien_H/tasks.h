/* Tasks.h - exec library function prototypes */

#ifndef EXEC_TASKS_H
#define EXEC_TASKS_H
/*
**	Copyright (C) 1986, by MTS Associates, Jacksonville FL
**
**	Updated: 11/17/86, TFH
*/

#ifndef EXEC_NODES_H
#include "exec/nodes.h"
#endif !EXEC_NODES_H

#ifndef EXEC_LISTS_H
#include "exec/lists.h"
#endif !EXEC_LISTS_H

#ifndef EXEC_PORTS_H
#include "exec/ports.h"
#endif

struct Task : public Node {
    UBYTE   tc_Flags;
    UBYTE   tc_State;
    BYTE    tc_IDNestCnt;	/* intr disabled nesting*/
    BYTE    tc_TDNestCnt;	/* task disabled nesting*/
    SigBits tc_SigAlloc;        /* sigs allocated	*/
    SigBits tc_SigWait;		/* sigs we are waiting for */
    SigBits tc_SigRecvd;	/* sigs we have received */
    SigBits tc_SigExcept;	/* sigs we will take excepts for */
    UWORD   tc_TrapAlloc;       /* traps allocated	*/
    UWORD   tc_TrapAble;        /* traps enabled	*/
    APTR    tc_ExceptData;	/* points to except data */
    APTR    tc_ExceptCode;	/* points to except code */
    APTR    tc_TrapData;	/* points to trap code	*/
    APTR    tc_TrapCode;	/* points to trap data	*/
    APTR    tc_SPReg;		/* stack pointer	*/
    APTR    tc_SPLower;		/* stack lower bound	*/
    APTR    tc_SPUpper;		/* stack upper bound + 2*/
    VOID    (*tc_Switch)();	/* task losing CPU	*/
    VOID    (*tc_Launch)();	/* task getting CPU	*/
    uList tc_MemEntry;		/* allocated memory	*/
    APTR    tc_UserData;        /* per task data	*/

	friend void AddTask(Task *t,
		const APTR initalPC, const APTR finalPC);
	friend Task * FindTask(const TEXT *name);
	friend void RemTask(struct Task *t);
	friend int SetTaskPri(struct Task *t, const int pri);
	void remove() {RemTask (this); }
	void signal(const SigBits s) { Signal(this, s); } 
};

/*----- Flag Bits ------------------------------------------*/
#define TB_PROCTIME	0 
#define TB_STACKCHK 	4
#define TB_EXCEPT	5 
#define TB_SWITCH	6 
#define TB_LAUNCH	7 

/*----- Task States ----------------------------------------*/
enum TaskState {
	TS_INVALID,	//	0 
	TS_ADDED,	//	1 
	TS_RUN,		//	2 
	TS_READY,	//	3 
	TS_WAIT,	//	4 
	TS_EXCEPT,	//	5 
	TS_REMOVED	//	6 
};

/*----- Predefined Signals -------------------------------------*/

#define SIGF_ABORT	(1L<<0)
#define SIGF_CHILD	(1L<<1)
#define SIGF_BLIT	(1L<<4)
#define SIGF_DOS	(1L<<8)

void Forbid();
void Permit();

#endif
