;/* hooks1.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfis -j73 hooks1.c
Blink FROM LIB:c.o,hooks1.o TO hooks1 LIBRARY LIB:LC.lib,LIB:Amiga.lib
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

    #include <exec/types.h>
    #include <exec/libraries.h>
    #include <utility/hooks.h>
    #include <dos.h>

    #include <clib/exec_protos.h>
    #include <clib/dos_protos.h>
    #include <clib/utility_protos.h>

    #include <stdio.h>

    extern struct Library *SysBase;
    struct Library *UtilityBase;

    #define ASM     __asm
    #define REG(x)  register __ ## x

    /* This function converts register-parameter Hook calling
     * convention into standard C conventions.  It requires a C
     * compiler that supports registerized parameters, such as
     * SAS/C 5.xx or greater.
     */

    ULONG ASM
    hookEntry(REG(a0) struct Hook *h, REG(a2) VOID *o, REG(a1) VOID *msg)
    {
        return ((*(ULONG (*)(struct Hook *,VOID *,VOID *))(h->h_SubEntry))(h, o, msg));
    }

    /* This simple function is used to initialize a Hook */
    VOID InitHook (struct Hook *h, ULONG (*func)(), VOID *data)
    {
        /* Make sure a pointer was passed */
        if (h)
        {
            /* Fill in the Hook fields */
            h->h_Entry = (ULONG (*)()) hookEntry;
            h->h_SubEntry = func;
            h->h_Data = data;
        }
    }

    /* This function only prints out a message indicating that we are
     * inside the callback function.
     */

    ULONG MyFunction (struct Hook *h, VOID *o, VOID *msg)
    {
        /* Obtain access to the global data segment */
        geta4();

        /* Debugging function to send a string to the serial port */
        printf("Inside MyFunction()\n");

        return (1);
    }

    int main (int argc, char **argv)
    {
        struct Hook h;

        /* Open the utility library */
        if (UtilityBase = OpenLibrary ("utility.library", 36))
        {
            /* Initialize the callback Hook */
            InitHook (&h, MyFunction, NULL);

            /* Use the utility library function to invoke the Hook */
            CallHookPkt (&h, NULL, NULL);

            /* Close utility library now that we're done with it */
            CloseLibrary (UtilityBase);
        }
        else printf ("Couldn't open utility.library\n");
    }
