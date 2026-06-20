;/* remembertest.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 remembertest.c
Blink FROM LIB:c.o,remembertest.o TO remembertest LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

/*
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

/*
** RememberTest - Illustrates the use of AllocRemember() and FreeRemember().
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdlib.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* our function prototypes */
VOID methodOne(VOID);
VOID methodTwo(VOID);

struct IntuitionBase *IntuitionBase;

/* random sizes to demonstrate the Remember functions. */
#define SIZE_A 100L
#define SIZE_B 200L


/*
** main() - Initialize everything.
*/
VOID main(int argc, char **argv)
{
LONG exitVal = RETURN_OK;

IntuitionBase = OpenLibrary("intuition.library", 33L);
if (IntuitionBase == NULL)
    exitVal = RETURN_FAIL;
else
    {
    methodOne();
    methodTwo();

    CloseLibrary(IntuitionBase);
    }
exit(exitVal);
}


/*
** MethodOne
** Illustrates using AllocRemember() to allocate all memory and
** FreeRemember() to free it all.
*/
VOID methodOne(VOID)
{
APTR memBlockA = NULL, memBlockB = NULL;
struct Remember *rememberKey = NULL;

memBlockA = AllocRemember(&rememberKey, SIZE_A, MEMF_CLEAR | MEMF_PUBLIC);
if (memBlockA)
    {
    /*  The memBlockA allocation succeeded; try for memBlockB.  */
    memBlockB = AllocRemember(&rememberKey, SIZE_B, MEMF_CLEAR | MEMF_PUBLIC);
    if (memBlockB)
        {
        /*  Both memory allocations succeeded.
        **  The program may now use this memory.
        */
        }
    }

/* It is not necessary to keep track of the status of each allocation.
** Intuition has kept track of all successful allocations by updating its
** linked list of Remember nodes.  The following call to FreeRemember() will
** deallocate any and all of the memory that was successfully allocated.
** The memory blocks as well as the link nodes will be deallocated because
** the "ReallyForget" parameter is TRUE.
**
** It is possible to have reached the call to FreeRemember()
** in one of three states.  Here they are, along with their results.
**
** 1. Both memory allocations failed.
**       RememberKey is still NULL.  FreeRemember() will do nothing.
** 2. The memBlockA allocation succeeded but the memBlockB allocation failed.
**       FreeRemember() will free the memory block pointed to by memBlockA.
** 3. Both memory allocations were successful.
**       FreeRemember() will free the memory blocks pointed to by
**       memBlockA and memBlockB.
*/
FreeRemember(&rememberKey, TRUE);
}

/*
** MethodTwo
** Illustrates using AllocRemember() to allocate all memory,
** FreeRemember() to free the link nodes, and FreeMem() to
** free the actual memory blocks.
*/
VOID methodTwo(VOID)
{
APTR memBlockA = NULL, memBlockB = NULL;
struct Remember *rememberKey = NULL;

memBlockA = AllocRemember(&rememberKey, SIZE_A, MEMF_CLEAR | MEMF_PUBLIC);
if (memBlockA)
    {
    /*  The memBlockA allocation succeeded; try for memBlockB.  */
    memBlockB = AllocRemember(&rememberKey, SIZE_B, MEMF_CLEAR | MEMF_PUBLIC);
    if (memBlockB)
        {
        /* Both memory allocations succeeded.
        ** For the purpose of illustration, FreeRemember() is called at
        ** this point, but only to free the link nodes.  The memory pointed
        ** to by memBlockA and memBlockB is retained.
        */
        FreeRemember(&rememberKey, FALSE);

        /* Individually free the two memory blocks. The Exec FreeMem()
        ** call must be used, as the link nodes are no longer available.
        */
        FreeMem((VOID *)memBlockA, SIZE_A);
        FreeMem((VOID *)memBlockB, SIZE_B);
        }
    }

/* It is possible to have reached the call to FreeRemember()
** in one of three states.  Here they are, along with their results.
**
** 1. Both memory allocations failed.
**    RememberKey is still NULL.  FreeRemember() will do nothing.
** 2. The memBlockA allocation succeeded but the memBlockB allocation failed.
**    FreeRemember() will free the memory block pointed to by memBlockA.
** 3. Both memory allocations were successful.
**    If this is the case, the program has already freed the link nodes
**    with FreeRemember() and the memory blocks with FreeMem().
**    When FreeRemember() freed the link nodes, it reset RememberKey
**    to NULL.  This (second) call to FreeRemember() will do nothing.
*/
FreeRemember(&rememberKey, TRUE);
}
