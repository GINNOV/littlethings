;/* displayalert.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 displayalert.c
Blink FROM LIB:c.o,displayalert.o TO displayalert LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** displayalert.c -  This program implements a recoverable alert
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


/* Each string requires its own positioning information, as explained
** in the manual.  Hex notation has been used to specify the positions of
** the text. Hex numbers start with a backslash, an "x" and the characters
** that make up the number.
**
** Each line needs 2 bytes of X position, and 1 byte of Y position.
**   In our 1st line: x = \x00\xF0 (2 bytes) and y = \x14 (1 byte)
**   In our 2nd line: x = \x00\xA0 (2 bytes) and y = \x24 (1 byte)
** Each line is null terminated plus a continuation character (0=done).
** This example assumes that the complier will concatenate adjacent
** strings into a single string with no extra NULLs.  The compiler does
** add the terminating NULL at the end of the entire string...The entire
** alert must end in TWO NULLs, one for the end of the string, and one
** for the NULL continuation character.
*/

UBYTE *alertMsg =
    "\x00\xF0\x14" "OH NO, NOT AGAIN!" "\x00\x01"
    "\x00\x80\x24" "PRESS MOUSEBUTTON:   LEFT=TRUE   RIGHT=FALSE" "\x00";

struct Library *IntuitionBase;

VOID main(int argc, char **argv)
{
if (IntuitionBase = OpenLibrary("intuition.library",33))
    {
    if (DisplayAlert(RECOVERY_ALERT, alertMsg, 52))
        printf("Alert returned TRUE\n");
    else
        printf("Alert returned FALSE\n");

    CloseLibrary(IntuitionBase);
    }
}
