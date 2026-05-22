;/* vertb.c - Execute me to compile me with SAS C 5.10
LC -d0 -b1 -cfistq -v -y -j73 vertb.c
Blink FROM LIB:c.o,vertb.o,vertbserver.o TO vertb LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

vertb.c - Vertical blank interrupt server example.  Must be linked with vertbserver.o.

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


#include <exec/memory.h>
#include <exec/interrupts.h>
#include <dos/dos.h>
#include <hardware/custom.h>
#include <hardware/intbits.h>
#include <clib/exec_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

extern void VertBServer();  /* proto for asm interrupt server */

void main(void)
{
    struct Interrupt *vbint;
    ULONG counter = 0;
    ULONG endcount;
                                                                         /* Allocate memory for  */
    if (vbint = AllocMem(sizeof(struct Interrupt), MEMF_PUBLIC|MEMF_CLEAR))   /* interrupt node. */
    {
        vbint->is_Node.ln_Type = NT_INTERRUPT;         /* Initialize the node. */
        vbint->is_Node.ln_Pri = -60;
        vbint->is_Node.ln_Name = "VertB-Example";
        vbint->is_Data = (APTR)&counter;
        vbint->is_Code = VertBServer;


        AddIntServer(INTB_VERTB, vbint); /* Kick this interrupt server to life. */

        printf("VBlank server will increment a counter every frame.\n");
        printf("counter started at zero, CTRL-C to remove server\n");

        Wait(SIGBREAKF_CTRL_C);
        endcount = counter;
        printf("%ld vertical blanks occurred\nRemoving server\n", endcount);

        RemIntServer(INTB_VERTB, vbint);
        FreeMem(vbint, sizeof(struct Interrupt));
    }
    else printf("Can't allocate memory for interrupt node\n");
}