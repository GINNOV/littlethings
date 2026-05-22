/************************************************************************
**********                                                     **********
********** M E S S A G E   S O F T W A R E   I N T E R R U P T **********
********** --------------------------------------------------- **********
**********                                                     **********
**********        Copyright (C) 1988 Sassenrath Research       **********
**********                All Rights Reserved.                 **********
**********                                                     **********
**********    Example from the "Guru's Guide, Meditation #1"   **********
**********                                                     **********
*************************************************************************
**                                                                     **
**                            - NOTICE -                               **
**                                                                     **
**  The "Guru's Guide, Meditation #1" contains detailed information    **
**  about Amiga interrupts as well as a complete discussion of this    **
**  and other examples.  Meditation #1 and all of its examples were    **
**  written by Carl Sassenrath, the architect of Amiga's multitasking  **
**  operating system.  Copies of the "Guru's Guide" may be obtained    **
**  from:                                                              **
**           GURU'S GUIDE, P.O. BOX 1510, UKIAH, CA 95482              **
**                                                                     **
**  Please include a check for $14.95, plus $1.50 shipping ($4.00 if   **
**  outside North America).  CA residents add 6% sales tax.            **
**                                                                     **
**  This example may be used for any purposes, commercial, personal,   **
**  public, and private, so long as ALL of the above text, copyright,  **
**  mailing address, and this notice are retained in their entirety.   **
**                                                                     **
**  THIS EXAMPLE IS PROVIDED WITHOUT WARRANTY OF ANY KIND.             **
**                                                                     **
************************************************************************/

/*
**  COMPILATION NOTE:
**
**  Compiled under MANX AZTEC C 3.6A.  Use the +L compiler option
**  and the "c32" library.  Link with intrsup.o
*/


#include <exec/exec.h>

struct MsgPort *IPort = NULL;
struct MsgPort *RPort = NULL;
struct Interrupt *Intr = NULL;
long ASignal = -1;


/* Interrupt Processing Code */
IntrProc()
{
	extern struct Message *GetMsg();
	struct Message *msg;

	int_start();

	msg = GetMsg(IPort);
	if (msg != NULL) ReplyMsg(msg);

	int_end();
}


main()
{
	struct Message msg;

	MainInit();

	msg.mn_Node.ln_Type = NT_MESSAGE;
	msg.mn_Node.ln_Name = "swi.message";
	msg.mn_ReplyPort = RPort;

	puts("Causing interrupt...");
	PutMsg(IPort, &msg);

	puts("Awaiting reply...");
	WaitPort(RPort);

	puts("Got reply...");
	GetMsg(RPort);

	MainExit();
}


MainInit()
{
	extern struct Interrupt *MakeIntr();
	extern struct MsgPort *CreatePort();
	extern struct Task *FindTask();
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	Intr = MakeIntr("softint.example",-16,&IntrProc,0);
	if (Intr == NULL) MainExit(201);

	ASignal = AllocSignal(-1);
	if (ASignal == -1) MainExit(202);

	IPort = CreatePort("swi.port", 0);
	if (IPort == NULL) MainExit(203);

	RPort = CreatePort("swi.reply.port", 0);
	if (RPort == NULL) MainExit(204);

	IPort->mp_SoftInt = (struct Task *) Intr;
	IPort->mp_Flags = PA_SOFTINT;

	RPort->mp_SigBit = ASignal;
	RPort->mp_SigTask = FindTask(NULL);
	RPort->mp_Flags = PA_SIGNAL;
}


MainExit(error)
	int error;
{
	FreeIntr(Intr);

	if (IPort != NULL) DeletePort(IPort);

	if (RPort != NULL) DeletePort(RPort);

	if (ASignal != -1) FreeSignal(ASignal);

	exit(error);
}
