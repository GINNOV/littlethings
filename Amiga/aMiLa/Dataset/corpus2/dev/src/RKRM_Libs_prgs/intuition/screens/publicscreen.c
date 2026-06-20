;/* publicscreen.c - open a screen with the pens from a public screen.
lc -b1 -cfist -v -y -j73 publicscreen
blink FROM LIB:c.o publicscreen.o TO publicscreen LIB LIB:lc.lib LIB:amiga.lib
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

VOID usePubScreenPens(void);

struct Library *IntuitionBase;

/* main(): open libraries, clean up when done.
*/
VOID main(int argc, char **argv)
{
IntuitionBase = OpenLibrary("intuition.library",0);
if ( IntuitionBase != NULL )
    {
    /* Check the version number; Release 2 is */
    /* required for public screen functions   */
    if (IntuitionBase->lib_Version >= 37)
        {
        usePubScreenPens();
        }
    CloseLibrary(IntuitionBase);
    }
}

/* Open a screen that uses the pens of an existing public screen
** (the Workbench screen in this case).
*/
VOID usePubScreenPens(void)
{
struct Screen *my_screen;
struct TagItem screen_tags[2];
UBYTE *pubScreenName = "Workbench";

struct Screen *pub_screen = NULL;
struct DrawInfo *screen_drawinfo = NULL;

/* Get a lock on the Workbench screen */
pub_screen = LockPubScreen(pubScreenName);
if ( pub_screen != NULL )
    {
    /* get the DrawInfo structure from the locked screen */
    screen_drawinfo = GetScreenDrawInfo(pub_screen);
    if ( screen_drawinfo != NULL)
        {
        /* the pens are copied in the OpenScreenTagList() call,
        ** so we can simply use a pointer to the pens in the tag list.
        **
        ** This works better if the depth and colors of the new screen
        ** matches that of the public screen.  Here we are forcing the
        ** workbench screen pens on a monochrome screen (which may not
        ** be a good idea).  You could add the tag:
        **      (SA_Depth, screen_drawinfo->dri_Depth)
        */
        screen_tags[0].ti_Tag  = SA_Pens;
        screen_tags[0].ti_Data = (ULONG)(screen_drawinfo->dri_Pens);
        screen_tags[0].ti_Tag  = TAG_END;
        screen_tags[0].ti_Data = NULL;

        my_screen = OpenScreenTagList(NULL, screen_tags);
        if (my_screen != NULL)
            {
            /* We no longer need to hold the lock on the public screen
            ** or a copy of its DrawInfo structure as we now have our
            ** own screen.  Release the screen.
            */
            FreeScreenDrawInfo(pub_screen,screen_drawinfo);
            screen_drawinfo = NULL;
            UnlockPubScreen(pubScreenName,pub_screen);
            pub_screen = NULL;

            Delay(90);   /* should be rest_of_program */

            CloseScreen(my_screen);
            }
        }
    }

/* These are freed in the main loop if OpenScreenTagList() does
** not fail.  If something goes wrong, free them here.
*/
if ( screen_drawinfo != NULL )
    FreeScreenDrawInfo(pub_screen,screen_drawinfo);
if ( pub_screen!= NULL )
    UnlockPubScreen(pubScreenName,pub_screen);
}
