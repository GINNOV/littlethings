/************************************************************************
**********                                                     **********
**********              C I A   I N T E R R U P T              **********
**********              -------------------------              **********
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
**  and the "c32" library.  Link with intrsup.o.
*/


#include <exec/exec.h>
#include <hardware/intbits.h>
#include <hardware/cia.h>

struct Task *ATask = NULL;
struct Interrupt *Intr = NULL;
APTR Cia = NULL;
long ASignal = -1;

long Counter = 10;


/* Interrupt Processing Code */
VOID IntrProc()
{
	int_start();

	/* Clear timer-A interrupt */
	SetICR(Cia, CIAICRF_TA);

	if (--Counter <= 0)
	{
		/* Disable timer interrupt */
		AbleICR(Cia, CIAICRF_TA);

		Signal(ATask,1 << ASignal);
	}

	int_end();
}


main()
{
	MainInit();

	if (AddICRVector(Cia,CIAICRB_TA,Intr) != 0)
	{
		puts("CIA-B Timer-A in use.");
		MainExit(300);
	}

	/* At this point, Timer intr is linked  */
	/* and enabled, so it may have happened */
	/* already!  That's why we need this:   */
	ciab.ciacra &= ~CIACRAF_START;	/* stop timer */
	SetICR(Cia,CIAICRF_TA);		/* clear intr */
	SetSignal(0, 1 << ASignal);	/* clear signal */

	/* Set timer counter latch */
	ciab.ciatalo = 0;
	ciab.ciatahi = 0xff;

	/* Start the timer */
	ciab.ciacra |= CIACRAF_START;

	while (Counter > 0)
		printf("%d %2x%02x\n", Counter, ciab.ciatahi, ciab.ciatalo);

	Wait(1 << ASignal);	/* Sync-up */

	ciab.ciacra &= ~CIACRAF_START;	/* stop timer */

	RemICRVector(Cia,CIAICRB_TA,Intr);

	MainExit(0);
}


MainInit()
{
	extern APTR OpenResource();
	extern struct Interrupt *MakeIntr();
	extern struct Task *FindTask();
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	Cia = OpenResource("ciab.resource", 0);
	if (Cia == NULL) MainExit(201);

	Intr = MakeIntr("cia.example",0,&IntrProc,0);
	if (Intr == NULL) MainExit(202);

	ASignal = AllocSignal(-1);
	if (ASignal == -1) MainExit(203);

	ATask = FindTask(NULL);
}


MainExit(error)
	int error;
{
	FreeIntr(Intr);

	if (ASignal != -1) FreeSignal(ASignal);

	exit(error);
}
