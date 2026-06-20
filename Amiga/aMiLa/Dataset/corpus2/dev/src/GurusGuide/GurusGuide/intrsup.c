/************************************************************************
**********                                                     **********
**********          I N T E R R U P T   S U P P O R T          **********
**********          ---------------------------------          **********
**********                                                     **********
**********        Copyright (C) 1988 Sassenrath Research       **********
**********                All Rights Reserved.                 **********
**********                                                     **********
**********    Example from the "Guru's Guide, Meditation #1"   **********
**********                                                     **********
/************************************************************************
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
**  Compiled under MANX AZTEC C 3.6A.  Use the +L compiler option.
**  This file is linked with most of the other interrupt examples.
*/

#include <exec/interrupts.h>
#include <exec/memory.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>

/*
**	Interrupt Controller Functions
*/
EnableIntr(intrNum)
	int intrNum;
{
	custom.intena = INTF_SETCLR | (1 << intrNum);
}


DisableIntr(intrNum)
	int intrNum;
{
	custom.intena = (1 << intrNum);
}


RequestIntr(intrNum)
	int intrNum;
{
	custom.intreq = INTF_SETCLR | (1 << intrNum);
}


ClearIntr(intrNum)
	int intrNum;
{
	custom.intreq = (1 << intrNum);
}


/*
**	Structure Functions
*/
struct Interrupt *MakeIntr(name,pri,code,data)
	char *name;
	int  pri;
	VOID (*code)();
	APTR data;
{
	extern struct Interrupt *AllocMem();
	register struct Interrupt *intr;

	intr = AllocMem(sizeof(struct Interrupt), MEMF_PUBLIC);
	if (intr == NULL) return NULL;

	intr->is_Node.ln_Pri = pri;
	intr->is_Node.ln_Type = NT_INTERRUPT;
	intr->is_Node.ln_Name = name;
	intr->is_Data = data;
	intr->is_Code = code;

	return intr;
}


FreeIntr(intr)
	register struct Interrupt *intr;
{
	if (intr == NULL) return;
	if (intr->is_Node.ln_Type != NT_INTERRUPT) return;

	intr->is_Node.ln_Type = 0;

	FreeMem(intr, sizeof(struct Interrupt));
}


/*
**	Handler Functions
*/

extern struct Interrupt *SetIntVector();

struct Interrupt *AddHandler(intrNum,intr)
	int intrNum;
	struct Interrupt *intr;
{
	DisableIntr(intrNum);
	ClearIntr(intrNum);
	SetIntVector(intrNum,intr);	/* ignore result */
}


RemHandler(intrNum,intr)
	int intrNum;
	register struct Interrupt *intr;
{
	register struct Interrupt *retIntr;

	if (intr == NULL) return NULL;

	/*	CRITICAL SECTION: (See text)
	**	Mutually exclude all tasks and interrupts.
	**	Remove the handler if it is really ours
	**	(it could have been replaced already!)
	**	Disable the interrupt if it is ours.
	*/
	Disable();	
	retIntr = SetIntVector(intrNum,NULL);
	if (retIntr != intr) SetIntVector(intrNum,retIntr);
	else DisableIntr(intrNum);
	Enable();
}
