/************************************************************************
**********                                                     **********
**********      T A S K   S I G N A L   I N T E R R U P T      **********
**********      -----------------------------------------      **********
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
#include <hardware/intbits.h>

struct Interrupt *Intr = NULL;
long ASignal = -1;

/* Structure used by interrupt */
struct SigInfo
{
	long counter;
	long signal;
	struct Task *task;
} IntrData;


/* Interrupt Processing Code */
VOID	IntrProc();
#asm
EXECBASE	equ	4
		public	_LVOSignal
_IntrProc:
		addq.l	#1,(a1)+	; counter
		move.l	(a1)+,d0	; signal
		move.l	(a1)+,a1 	; task
		move.l	EXECBASE,a6
		jsr	_LVOSignal(a6)
		moveq	#0,d0		; Z-flag - do next server
		rts
#endasm


main()
{
	int count;

	MainInit();

	AddIntServer(INTB_VERTB, Intr);

	for (count = 0; count < 200; count++)
	{
		Wait(IntrData.signal);
		printf("%d %d\n", count, IntrData.counter);
	}

	RemIntServer(INTB_VERTB, Intr);

	MainExit();
}


MainInit()
{
	extern struct Interrupt *MakeIntr();
	extern long AllocSignal();
	extern struct Task *FindTask();
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	Intr = MakeIntr("signal.example",-60,&IntrProc,&IntrData);
	if (Intr == NULL) MainExit(201);

	ASignal = AllocSignal(-1);
	if (ASignal == -1) MainExit(202);

	IntrData.counter = 0;
	IntrData.signal = 1 << ASignal;
	IntrData.task = FindTask(NULL);
}


MainExit(error)
	int error;
{
	FreeIntr(Intr);

	if (ASignal != -1) FreeSignal(ASignal);

	exit(error);
}
