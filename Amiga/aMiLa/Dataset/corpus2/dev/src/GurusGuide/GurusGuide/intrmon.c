/************************************************************************
**********                                                     **********
**********          I N T E R R U P T   M O N I T O R          **********
**********          ---------------------------------          **********
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
**  This program DOES NOT protect against state changes while
**  accessing system structures.  It may in some cases produce
**  unreliable results.  This example was produced for demonstration
**  and debugging purposes only, and it should be used with care.
*/


/*
**  COMPILATION NOTE:
**
**  Compiled under MANX AZTEC C 3.6A.  Use the +L compiler option
**  and the "c32" library.
*/


#include <exec/exec.h>
#include <exec/execbase.h>
#include <hardware/custom.h>

#define	REG		register
#define	FIRST(n)	(struct Interrupt *)((n)->lh_Head)
#define	EMPTY(n)	((n)->lh_Head == &n->lh_Tail)
#define	NEXTINT(i)	(struct Interrupt *)((i)->is_Node.ln_Succ)
#define	LAST(i)		(((i)->is_Node.ln_Succ)->ln_Succ == 0)


struct ExecBase *EB;


char *IntrName[] =
{
	"TBE",		"DISKBLK",	"SOFTINT",	"PORTS",
	"COPER",	"VERTB",	"BLIT",		"AUD0",
	"AUD1",		"AUD2",		"AUD3",		"RBF",	
	"DSKSYNC",	"EXTER",	"INTEN",	"NMI"
};


char IntrPri[] = {1,1,1,2,3,3,3,4,4,4,4,5,5,6,6,7};


main()
{
	extern VOID *OpenLibrary();

	puts("Guru's Guide Interrupt Table Printer\n");

	EB = OpenLibrary("exec.library", 0);
	if (EB == NULL) exit(100);

	PrintAllIntr();
}


char *GetNodeName(node)
	REG struct Node *node;
{
	if (node == NULL) return "";

	if (node->ln_Name == NULL) return "(missing)";
	else return node->ln_Name;
}


int GetNodePri(node)
	struct Node *node;
{
	if (node == NULL) return 0;

	return node->ln_Pri;
}


PrintAllIntr()
{
	REG int i;
	REG struct IntVector *iv = &EB->IntVects[0];
	APTR sc = (APTR) EB->IntVects[3].iv_Code;

	puts("IV E INTR    P S   CODE     DATA   NPR NAME");
	puts("-- - ------- - - -------- -------- --- -----------------");

	for (i = 0; i < 16; i++, iv++)
	{
		printf("%2d %c %-7s %d ", i,
			(custom.intenar & (1 << i)) ? '*' : ' ',
			IntrName[i],
			IntrPri[i]);

		if (iv->iv_Code == sc)
		{
			PrintServers(iv->iv_Data);
		} else if (iv->iv_Code != 0)
		{
			printf("  %08lx %08lx     %s\n",
				iv->iv_Code,
				iv->iv_Data,
				GetNodeName(iv->iv_Node));
		} else putchar('\n');
	}
}


PrintServers(slist)
	struct List *slist;
{
	REG struct Interrupt *s;

	if (EMPTY(slist))
	{
		puts("*");
		return;
	}

	for (s = FIRST(slist); NEXTINT(s) != 0; s = NEXTINT(s))
	{
		printf("* %08lx %08lx%4d %s\n",
				s->is_Code,
				s->is_Data,
				GetNodePri(s),
				GetNodeName(s));

		if (!LAST(s)) printf("               ");
	}
}
