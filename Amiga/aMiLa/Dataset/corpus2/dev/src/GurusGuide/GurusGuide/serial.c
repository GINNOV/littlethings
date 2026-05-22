/************************************************************************
**********                                                     **********
**********           S E R I A L   I N T E R R U P T           **********
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
**  IMPORTANT WARNING:
**
**  This program will interfere with the proper operation of the Amiga's
**  Serial Device Driver.  Use with care.
*/

/*
**  COMPILATION NOTE:
**
**  Compiled under MANX AZTEC C 3.6A.  Use the +L compiler option
**  and the "c32" library.  Link with intrsup.o.
*/


#include <exec/exec.h>
#include <hardware/intbits.h>
#include <hardware/custom.h>
#include <stdio.h>

#define	TIMEOUT 240		/* 4 seconds */
#define	BAUD_RATE 372		/* 9600 baud */

char IntrName[] = "serial.example";

struct	SigInfo
{
	short	buffer;		/* char buffer */
	short	intrmask;	/* intr to reset */
	long	signal;		/* signal mask */
	struct	Task *task;	/* task to signal */
	long	sig;		/* sig bit to free */
	struct	Interrupt *intr;
} Serial, TimeOut;


/* Interrupt Processing Code */
VOID	SerialCode();
VOID	TimeOutCode();
#asm
TIMEOUT		equ	240
EXECBASE	equ	4
intreq		EQU	$9C	; interrupt request
serdatr		EQU	$18	; serial data read

		public	_LVOSignal

_TimeOutCode:
		subq.w	#1,(a1)			; decr timeout
		move.w	(a1),d0
		bge.s	exit			; expired?
		move.w	#TIMEOUT,(a1)		; reset timeout
		addq.l	#4,a1			; adjust pointer
		bra.s	signal

_SerialCode:
		move.w	serdatr(a0),(a1)+	; get the char
		move.w	(a1)+,intreq(a0) 	; clear the request

signal:
		move.l	(a1)+,d0	 	; the signal
		move.l	(a1)+,a1 	 	; the task
		move.l	EXECBASE,a6
		jsr	_LVOSignal(a6)
exit:
		moveq	#0,d0			; Z-flag - do next server
		rts
#endasm



main()
{
	extern long Wait();
	extern int Enable_Abort;
	long waitsigs;
	char c;

	Enable_Abort = 0;	/* prevent a CTRL-C */

	/* Required for proper clean-up: */
	Serial.sig = TimeOut.sig = -1;

	MakeSigIntr(IntrName,INTB_RBF,0,&SerialCode,&Serial);
	MakeSigIntr(IntrName,INTB_VERTB,-60,&TimeOutCode,&TimeOut);

	/* Set serial baud rate to 9600 */
	custom.serper = BAUD_RATE;

	AddHandler(INTB_RBF,Serial.intr);
	EnableIntr(INTB_RBF);

	TimeOut.buffer = TIMEOUT;
	AddIntServer(INTB_VERTB,TimeOut.intr);

	while (TRUE)
	{
		waitsigs = Wait(Serial.signal | TimeOut.signal);

		if (waitsigs & Serial.signal)
		{
			c = (char)Serial.buffer;
			if (c == 3) break;	/* CTRL-C to stop */
			if (c == 13) c = 10;	/* change CR to LF */
			putchar(c);
			fflush(stdout);		/* force it out */

			/* Reset timeout */
			TimeOut.buffer = TIMEOUT;
		}

		if (waitsigs & TimeOut.signal)
			puts("\nTIMEOUT!");
	}

	DisableIntr(INTB_RBF);
	MainExit(0);
}


MakeSigIntr(iname,ibit,pri,iproc,isig)
	char *iname;
	int ibit;
	VOID (*iproc)();
	register struct SigInfo *isig;
{
	extern	struct Task *FindTask();
	extern struct Interrupt *MakeIntr();
	struct Interrupt *intr;

	isig->sig = AllocSignal(-1);
	if (isig->sig == -1) MainExit(100);

	intr = MakeIntr(iname,pri,iproc,isig);
	if (intr == NULL) MainExit(101);

	isig->buffer = 0;
	isig->intrmask = 1 << ibit;
	isig->signal = 1 << isig->sig;
	isig->task = FindTask(NULL);
	isig->intr = intr;
}


MainExit(error)
	int error;
{
	puts("Terminate!");

	if (Serial.intr != NULL)
	{
		RemHandler(INTB_RBF, Serial.intr);
		FreeIntr(Serial.intr);
	}

	if (TimeOut.intr != NULL)
	{
		RemIntServer(INTB_VERTB, TimeOut.intr);
		FreeIntr(TimeOut.intr);
	}

	if (Serial.sig != -1) FreeSignal(Serial.sig);

	if (TimeOut.sig != -1) FreeSignal(TimeOut.sig);

	exit(error);
}
