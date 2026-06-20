;/* newlookscreen.c - open a screen with the "new look".
lc -b1 -cfist -v -y -j73 newlookscreen
blink LIB:c.o newlookscreen.o TO newlookscreen LIB LIB:lc.lib LIB:amiga.lib
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


#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library *IntuitionBase;

/* Simple routine to demonstrate opening a screen with the new look.
** Simply supply the tag SA_Pens along with a minimal pen specification,
** Intuition will fill in all unspecified values with defaults.
** Since we are not supplying values, all are Intuition defaults.
*/
VOID main(int argc, char **argv)
{
UWORD pens[] = { ~0 };
struct Screen *my_screen;

IntuitionBase = OpenLibrary("intuition.library",0);
if (NULL != IntuitionBase)
    {
    if (IntuitionBase->lib_Version >= 37)
        {
        /* The screen is opened two bitplanes deep so that the
        ** new look will show-up better.
        */
        if (NULL != (my_screen = OpenScreenTags(NULL,
                                     SA_Pens, (ULONG)pens,
                                     SA_Depth, 2,
                                     TAG_DONE)))
            {
            /* screen successfully opened */
            Delay(30L);  /* normally the program would be here */

            CloseScreen(my_screen);
            }
        }
    CloseLibrary(IntuitionBase);
    }
}
