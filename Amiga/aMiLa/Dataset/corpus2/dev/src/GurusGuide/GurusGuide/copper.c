/************************************************************************
**********                                                     **********
**********           C O P P E R   I N T E R R U P T           **********
**********           -------------------------------           **********
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
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <graphics/gfxmacros.h>
#include <graphics/copper.h>
#include <intuition/intuition.h>

APTR GfxBase = NULL;
APTR IntuitionBase = NULL;

struct Task *ATask = NULL;
struct Interrupt *Intr = NULL;
struct Screen *AScreen = NULL;
struct ViewPort *VPort = NULL;
struct UCopList	*CoprList = NULL;
struct UCopList	*SaveList = NULL;
long ASignal = -1;

long Count = 120;

/* Intuition Screen Specification */
struct NewScreen ScreenSpec =
{
	0,0,
	320,200,4,
	0,0,0,
	CUSTOMSCREEN,
	0,
	(UBYTE *) "Copper Example",
	0
};


/* Interrupt Processing Code */
VOID IntrProc()
{
	int_start();

	if (--Count <= 0) Signal(ATask,1 << ASignal);

	int_end();
}


main()
{
	MainInit();

	VPort = &AScreen->ViewPort;

	/* Save old user copper list */
	SaveList = VPort->UCopIns;

	/* Build a Copper List */
	CINIT(CoprList,100);
	CWAIT(CoprList,100, 0); /* Video Line 100 */
	CMOVE(CoprList,custom.intreq,INTF_SETCLR | INTF_COPER);
	CEND(CoprList);

	/* Insert new user copper list */
	VPort->UCopIns = CoprList;
	MakeScreen(AScreen);
	RethinkDisplay();

	/* Setup copper interrupt */
	AddIntServer(INTB_COPER, Intr);

	/* Something else to do... */
	while (Count > 0) printf("%d\n",Count);

	Wait(1 << ASignal);	/* Sync-up */

	/* Clean up */
	RemIntServer(INTB_COPER, Intr);

	MainExit(0);
}


MainInit()
{
	extern APTR OpenLibrary();
	extern struct Screen *OpenScreen();
	extern struct Interrupt *MakeIntr();
	extern long AllocSignal();
	extern struct Task *FindTask();
	extern void *AllocMem();
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	GfxBase = OpenLibrary("graphics.library", 30);
	if (GfxBase == NULL) MainExit(201);

	IntuitionBase = OpenLibrary("intuition.library", 30);
	if (GfxBase == NULL) MainExit(202);

	AScreen = OpenScreen(&ScreenSpec);
	if (AScreen == NULL) MainExit(210);

	CoprList = AllocMem(sizeof(*CoprList), MEMF_CLEAR);
	if (CoprList == NULL) MainExit(220);

	ASignal = AllocSignal(-1);
	if (ASignal == -1) MainExit(230);

	Intr = MakeIntr("copper.example",0,&IntrProc,0);
	if (Intr == NULL) MainExit(240);

	ATask = FindTask(NULL);
}


MainExit(error)
	int error;
{
	if (AScreen != NULL) 
	{
		VPort->UCopIns = SaveList; /* restore it */
		MakeScreen(AScreen);
		RethinkDisplay();
		CloseScreen(AScreen);
	}

	if (CoprList != NULL)
	{
		/* Free intermediate copper list */
		FreeCopList(CoprList->FirstCopList);

		FreeMem(CoprList,sizeof(*CoprList));
	}

	FreeIntr(Intr);

	if (ASignal != -1) FreeSignal(ASignal);

	if (IntuitionBase != NULL)
		CloseLibrary(IntuitionBase);

	if (GfxBase != NULL)
		CloseLibrary(GfxBase);

	exit(error);
}
