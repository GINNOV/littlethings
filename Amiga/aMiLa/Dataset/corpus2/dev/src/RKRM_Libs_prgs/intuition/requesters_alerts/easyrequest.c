;/* easyrequest.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 easyrequest.c
Blink FROM LIB:c.o,easyrequest.o TO easyrequest LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** easyrequest.c - show the use of an easy requester.
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

/* declare the easy request structure.
** this uses many features of EasyRequest(), including:
**     multiple lines of body text separated by '\n'.
**     variable substitution of a string (%s) in the body text.
**     multiple button gadgets separated by '|'.
**     variable substitution in a gadget (long decimal '%ld').
*/
struct EasyStruct myES =
    {
    sizeof(struct EasyStruct),
    0,
    "Request Window Name",
    "Text for the request\nSecond line of %s text\nThird line of text for the request",
    "Yes|%ld|No",
    };

struct Library *IntuitionBase;

/*
** Main routine to show the use of EasyRequest()
*/
VOID main (int argc, char **argv)
{
LONG answer;
LONG number;

number = 3125794;  /* for use in the middle button */

if (IntuitionBase = OpenLibrary("intuition.library",37))
    {
    /* note in the variable substitution:
    **     the string goes in the first open variable (in body text).
    **     the number goes in the second open (gadget text).
    */
    answer = EasyRequest(NULL, &myES, NULL, "(Variable)", number);

    /* Process the answer.  Note that the buttons are numbered in
    ** a strange order.  This is because the rightmost button is
    ** always a negative reply.  The code can use this if it chooses,
    ** with a construct like:
    **
    **     if (EasyRequest())
    **          positive_response();
    */
    switch (answer)
        {
        case 1:
            printf("selected 'Yes'\n");
            break;
        case 2:
            printf("selected '%ld'\n", number);
            break;
        case 0:
            printf("selected 'No'\n");
            break;
        }

    CloseLibrary(IntuitionBase);
    }
}
