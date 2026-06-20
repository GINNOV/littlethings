/************************************************************************
**********                                                     **********
**********           S I M P L E   I N T E R R U P T           **********
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
**  and the "c32" library.
*/


#include <exec/interrupts.h>
#include <hardware/intbits.h>

VOID	IntrProc();	/* forward to interrupt code */
long	IntrCount;	/* vertical blank counter	 */

/* Initialized interrupt structure */
struct Interrupt VertBlank =
{
	NULL,			/* node pred*/
	NULL,			/* node succ*/
	-60,			/* node pri */
	NT_INTERRUPT,		/* node type*/
	"simple.example",	/* node name*/
	(APTR)&IntrCount,	/* data ptr */
	&IntrProc		/* code ptr */
};


#asm	/* Interrupt Server Code */
_IntrProc:
		addq.l	#1,(a1)	; increment IntrCount
		moveq	#0,d0	; Z-flag - do next server
		rts
#endasm


main()	/* Initialization, Main, and Clean-up */
{
	extern int Enable_Abort;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	IntrCount = 0;

	AddIntServer(INTB_VERTB, &VertBlank);

	while (IntrCount < 200) printf("%d\n",IntrCount);

	RemIntServer(INTB_VERTB, &VertBlank);
}
