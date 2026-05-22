;/* trap_c.c - Execute me to compile me with SAS C 5.10
LC -b0 -cfistq -v -y -j73 trap_c.c
Blink FROM LIB:c.o,trap_c.o,trap_a.o TO trap LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

trap_c.c - C module of sample integer divide-by-zero trap


Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/types.h>
#include <exec/tasks.h>
#include <clib/exec_protos.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) {return(0); }
#endif

extern ULONG trapa();           /* assembler trap code in trap_a.asm */

APTR oldTrapCode;
ULONG countdiv0;

void main(int argc, char **argv)
{
    struct Task *thistask;
    ULONG k,j;

    thistask = FindTask(NULL);

    /* Save our task's current trap code pointer */
    oldTrapCode = thistask->tc_TrapCode;

    /* Point task to our assembler trap handler code.  Ours will just count */
    /* divide-by-zero traps, and pass other traps on to the normal TrapCode */
    thistask->tc_TrapCode = (APTR)trapa;

    countdiv0 = 0L;

    for(k=0; k<4; k++)            /* Let's divide by zero a few times */
       {
       printf("dividing %ld by zero... ",k);
       j = k/0L;
       printf("did it\n");
       }
    printf("\nDivide by zero happened %ld times\n",countdiv0);

    thistask->tc_TrapCode = oldTrapCode;     /* Restore old trap code */
}