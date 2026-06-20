;/* allocate.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 allocate.c
Blink FROM LIB:c.o,allocate.o TO allocate LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

allocate.c - example of allocating and using a private memory pool.


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

#define BLOCKSIZE 4000     /* or whatever you need */

VOID main(VOID)
{
    struct MemHeader *mh;
    struct MemChunk  *mc;
    APTR   block1, block2;

    /* Get the MemHeader needed to keep track of our new block. */
    mh = (struct MemHeader *)AllocMem((LONG)sizeof(struct MemHeader), MEMF_CLEAR);
    if (!mh) exit(10);

    /* Get the actual block the above MemHeader will manage. */
    if ( !(mc = (struct MemChunk *)AllocMem(BLOCKSIZE, 0)) )
    {
        FreeMem(mh, (LONG)sizeof(struct MemHeader));
        exit(10);
    }
    mh->mh_Node.ln_Type = NT_MEMORY;
    mh->mh_First        = mc;
    mh->mh_Lower        = (APTR)mc;
    mh->mh_Upper        = (APTR)(BLOCKSIZE + (ULONG)mc);
    mh->mh_Free         = BLOCKSIZE;

    mc->mc_Next  = NULL;                     /* Set up first chunk in the freelist */
    mc->mc_Bytes = BLOCKSIZE;

    block1 = (APTR)Allocate(mh,20);
    block2 = (APTR)Allocate(mh, 314);

    printf("Our MemHeader struct at $%lx. Our block of memory at $%lx\n", mh, mc);
    printf("Allocated from our pool: block1 at $%lx, block2 at $%lx\n", block1, block2);

    FreeMem(mh, (LONG)sizeof(struct MemHeader));
    FreeMem(mc, (LONG)BLOCKSIZE);
}