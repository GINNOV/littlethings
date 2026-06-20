/************************************************************************
**********                                                     **********
**********            A U D I O   I N T E R R U P T            **********
**********            -----------------------------            **********
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
**  IMPORTANT WARNING:
**  
**  This example steals the AUD0 interrupt vector.  This action
**  defeats the purpose of the Audio Device - but we wanted to
**  keep the example short and to the point.  We advise you to
**  read the documentation for the Audio Device.
*/

/*
**  COMPILATION NOTE:
**
**  Compiled under MANX AZTEC C 3.6A.  Use the +L compiler option
**  and the "c32" library.  Link with intrsup.o.
*/


#include <exec/exec.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>
#include <hardware/intbits.h>

#define	SIZE 256	/* wave size */

struct Interrupt *Intr = NULL;
struct Task *ATask = NULL;
long ASignal = -1;

char *WaveForm = NULL;

short RepCount;		/* wave rep counter */
short Part;		/* ADSR envelope count */
short Volume;

/* Attack, decay, sustain, release tables: */
char ADSR[] = { 3, 3, 5,20 }; /* Reps */
char Ramp[] = {20,-5, 0,-2 }; /* Incr */

/* Periods for several "notes" */
short Period[] = { 100,200,300,400,3000,0 };


/* Interrupt Processing Code */
VOID IntrProc()
{
	int_start();

	/* Next ADSR part? */
	if (--RepCount <= 0)
	{
		++Part;
		RepCount = ADSR[Part];
	}

	/* Finished with note? */
	if (Part > 3)
	{
		Volume = 0;
		DisableIntr(INTB_AUD0);
		Signal(ATask,1 << ASignal);
	}
	else /* Change volume & clip */
	{
		Volume += Ramp[Part];
		if (Volume < 0) Volume = 0;
		else if (Volume > 63) Volume = 63;
	}

	custom.aud[0].ac_vol = Volume;
	ClearIntr(INTB_AUD0);

	int_end();
}


main()
{
	struct AudChannel *ac;
	int n;

	MainInit();

	/* Generate unfiltered noise: */
	for (n = 0; n < SIZE; n++)
		WaveForm[n] = (char)rand();

	AddHandler(INTB_AUD0, Intr);

	/* Turn on audio DMA */
	custom.dmacon = DMAF_SETCLR | DMAF_AUD0 | DMAF_MASTER;

	ac = &custom.aud[0];
	ClearIntr(INTB_AUD0);

	for (n = 0; Period[n] > 0; n++)
	{
		Volume = 0;
		Part = 0;
		RepCount = ADSR[0];
		ac->ac_per = Period[n];
		ac->ac_ptr = (UWORD *)WaveForm;
		ac->ac_len = SIZE/2;
		ac->ac_vol = Volume;

		EnableIntr(INTB_AUD0);

		Wait(1 << ASignal);
	}

	/* Turn off audio DMA */
	custom.dmacon = DMAF_AUD0;

	RemHandler(INTB_AUD0, Intr);

	MainExit(0);
}


MainInit()
{
	extern struct Interrupt *MakeIntr();
	extern long AllocSignal();
	extern struct Task *FindTask();
	extern void *AllocMem();
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	Intr = MakeIntr("audio.example",0,&IntrProc,0);
	if (Intr == NULL) MainExit(201);

	/* Audio DMA needs waveform in chip memory */
	WaveForm = AllocMem(SIZE, MEMF_CHIP | MEMF_CLEAR);
	if (WaveForm == NULL) MainExit(202);

	ASignal = AllocSignal(-1);
	if (ASignal == -1) MainExit(203);

	ATask = FindTask(NULL);
}


MainExit(error)
	int error;
{
	FreeIntr(Intr);

	if (WaveForm != NULL) FreeMem(WaveForm, SIZE);

	if (ASignal != -1) FreeSignal(ASignal);

	exit(error);
}
