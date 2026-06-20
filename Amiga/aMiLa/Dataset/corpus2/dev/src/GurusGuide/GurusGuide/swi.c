/************************************************************************
**********                                                     **********
**********         S O F T W A R E   I N T E R R U P T         **********
**********         -----------------------------------         **********
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


#include <exec/interrupts.h>

long Counter = 0;


/* Interrupt Processing Code */
IntrProc()
{
	int_start();

	Counter++;

	int_end();
}


main()
{
	extern struct Interrupt *MakeIntr();
	extern int Enable_Abort;
	struct Interrupt *intr;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	intr = MakeIntr("softint.example",0,&IntrProc,0);
	if (intr == NULL) exit(100);

	while (Counter < 10)
	{
		Cause(intr);
		printf("%d\n", Counter);
	}

	FreeIntr(intr);
}
