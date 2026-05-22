/* -------------------------------------------------------------------------- */
/* Using PAR: as a ~VOLUME~ in read mode to input 8 bit binary data into      */
/* a user buffer for manipulation by any C(++) means available.               */
/* Original copyright goes to (C)B.Walker, G0LCU, (now Public Domain).        */
/* Compiled under Dice-C V3.16, from the CLI/Shell prompt.                    */
/* Use "dcc -o PAR_READ PAR_READ.c" without the quotes inside the Shell/CLI.  */
/* This requires NO special compiler directives. There is a small flaw in     */
/* this code however but for this DEMO it is not a problem NOR is it a bug.   */
/* There are NO prototype(s), define(s) or struct(ures) in this code at all.  */
/* -------------------------------------------------------------------------- */
/* The compiled code REQUIRES the ~PAR_READ.lha~ archive in the hard/hack     */
/* drawer of AMINET. Without the special hardware attached to the parallel    */
/* port the program will hang, so beware!!!                                   */
/* SEE THE ~PAR_READ.lha~ FOR FULL INSTRUCTIONS ON THE HARDWARE REQUIRED.     */
/* -------------------------------------------------------------------------- */
/* Now tested with the vbccm68k V0.810 C compiler, using "vc PAR_READ.c"      */
/* without the quotes inside the Shell/CLI to give a running file ~a.out~     */
/* also included in this archive. (Uploaded to AMINET again 23-07-2006.)      */
/* -------------------------------------------------------------------------- */

/* Standard includes. */
#include <stdio.h>

/* Main program start. */
main()
{
	/* variable list. */
	void *par_in_read_mode;
	unsigned char mybyte;
	int n;

	/* Just loop for 10 times, roughly about one */
	/* second per sample on a standard A1200. */
	for(n=1; n<=10; n++)
	{
		/* Open the parallel port in PAR: ~volume~, read mode. */
		par_in_read_mode = fopen("PAR:", "rb");

		/* Read a byte from the ~port~. */
		fread(&mybyte, 1, 1, par_in_read_mode);

		/* Immediately close the opened PAR: ~volume~. */
		fclose(par_in_read_mode);

		/* Print the values to the screen. */
		printf("Value of character read is:- %u.\n", mybyte);
	}
}

/* Can it be any simpler I wonder?... */
