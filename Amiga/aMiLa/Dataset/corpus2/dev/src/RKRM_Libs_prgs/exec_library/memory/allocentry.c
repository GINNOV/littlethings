;/* allocentry.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 allocentry.c
Blink FROM LIB:c.o,allocentry.o TO allocentry LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

allocentry.c - example of allocating several memory areas.


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
#include <exec/memory.h>
#include <clib/exec_protos.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

#define ALLOCERROR 0x80000000

struct MemList *memlist;             /* pointer to a MemList structure        */

struct MemBlocks /* define a new structure because C cannot initialize unions */
{
    struct MemList  mn_head;         /* one entry in the header               */
    struct MemEntry mn_body[3];      /* additional entries follow directly as */
} memblocks;                         /* part of the same data structure       */

VOID main(VOID)
{
    memblocks.mn_head.ml_NumEntries = 4; /* 4! Since the MemEntry starts at 1! */

    /* Describe the first piece of memory we want.  Because of our MemBlocks structure */
    /* setup, we reference the first MemEntry differently when initializing it.        */
    memblocks.mn_head.ml_ME[0].me_Reqs = MEMF_CLEAR;
    memblocks.mn_head.ml_ME[0].me_Length = 4000;

    memblocks.mn_body[0].me_Reqs   = MEMF_CHIP | MEMF_CLEAR;   /* Describe the other pieces of    */
    memblocks.mn_body[0].me_Length = 100000;                   /* memory we want. Additional      */
    memblocks.mn_body[1].me_Reqs   = MEMF_PUBLIC | MEMF_CLEAR; /* MemEntries are initialized this */
    memblocks.mn_body[1].me_Length = 200000;                   /* way. If we wanted even more en- */
    memblocks.mn_body[2].me_Reqs   = MEMF_PUBLIC;              /* tries, we would need to declare */
    memblocks.mn_body[2].me_Length = 25000;                    /* a larger MemEntry array in our  */
                                                               /* MemBlocks structure.            */

    memlist = (struct MemList *)AllocEntry((struct MemList *)&memblocks);

    if ((ULONG)memlist & ALLOCERROR)          /* 'error' bit 31 is set (see below). */
    {
       printf("AllocEntry FAILED\n");
       exit(200);
    }
    /* We got all memory we wanted.  Use it and call FreeEntry() to free it */
    printf("AllocEntry succeeded - now freeing all allocated blocks\n");
    FreeEntry(memlist);
}