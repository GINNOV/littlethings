;/* semaphore.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 semaphore.c
Blink FROM LIB:c.o,semaphore.o TO semaphore LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

semaphore.c - Exec semaphore example

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
#include <exec/semaphores.h>
#include <clib/exec_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

struct SignalSemaphore LockSemaphore = {0};

VOID main(int argc,char *argv[])
{
    InitSemaphore(&LockSemaphore);
    ObtainSemaphore(&LockSemaphore);  /* Task now owns the semaphore. */

    /*  ...  */

    ReleaseSemaphore(&LockSemaphore); /* Task has released the semaphore. */
}