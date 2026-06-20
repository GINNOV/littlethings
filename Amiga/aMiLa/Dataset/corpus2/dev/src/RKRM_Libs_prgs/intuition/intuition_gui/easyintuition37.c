;/*
lc -L -j73 easyintuition37.c
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

/* easyintuition37.c -- Simple Intuition program for V37
/* (Release 2) and later versions of the operating system. */
/* Compiled with Lattice C v5.04: lc -L easyintuition37.c  */

#include <exec/types.h>             /* The Amiga data types file.         */
#include <intuition/intuition.h>    /* Intuition data strucutres, etc.    */
#include <graphics/displayinfo.h>   /* Release 2 Amiga display mode ID's  */
#include <libraries/dos.h>          /* Official return codes defined here */

#include <clib/exec_protos.h>       /* Exec function prototypes           */
#include <clib/intuition_protos.h>  /* Intuition function prototypes      */

/* Force use of new variable names to help prevent errors  */
#define INTUI_V36_NAMES_ONLY

#ifdef LATTICE                      /* Disable Ctrl-C handling in SAS/C   */
int CXBRK(void)  {return(0);}
void chkabort(void) {return;}
#endif

/* Use lowest non-obsolete version that supplies the functions needed. */
#define INTUITION_REV 37

/* Declare the prototypes of our own functions.  Prototypes for system */
/* functions are declared in the header files in the clib directory.   */
VOID cleanExit( struct Screen *, struct Window *, LONG );
BOOL handleIDCMP( struct Window *);

struct Library *IntuitionBase = NULL;

/* Position and sizes for our window */
#define WIN_LEFTEDGE   20
#define WIN_TOPEDGE    20
#define WIN_WIDTH     400
#define WIN_MINWIDTH   80
#define WIN_HEIGHT    150
#define WIN_MINHEIGHT  20


VOID main(int argc, char *argv[])
{
    /* Declare variables here */
    ULONG signalmask, winsignal, signals;
    BOOL done = FALSE;
    UWORD pens[]={~0};

    struct Screen *screen1 = NULL;
    struct Window *window1 = NULL;

    /* Open the Intuition Library */
    IntuitionBase = OpenLibrary( "intuition.library",INTUITION_REV );
    if (IntuitionBase == NULL)
        cleanExit(screen1, window1, RETURN_WARN);

    /* Open any other required libraries and make */
    /* any assignments that were postponed above  */

    /* Open the screen */
    screen1 = OpenScreenTags(NULL,
                             SA_Pens,  (ULONG)pens,
                             SA_DisplayID, HIRES_KEY,
                             SA_Depth, 2,
                             SA_Title, (ULONG)"Our Screen",
                             TAG_DONE);

    if (screen1 == NULL)
        cleanExit(screen1, window1, RETURN_WARN);

    /* ... and open the window */
    window1 = OpenWindowTags(NULL,
                             /* Specify window dimensions and limits */
                             WA_Left,         WIN_LEFTEDGE,
                             WA_Top,          WIN_TOPEDGE,
                             WA_Width,        WIN_WIDTH,
                             WA_Height,       WIN_HEIGHT,
                             WA_MinWidth,     WIN_MINWIDTH,
                             WA_MinHeight,    WIN_MINHEIGHT,
                             WA_MaxWidth,     ~0,
                             WA_MaxHeight,    ~0,
                             /* Specify the system gadgets we want */
                             WA_CloseGadget,  TRUE,
                             WA_SizeGadget,   TRUE,
                             WA_DepthGadget,  TRUE,
                             WA_DragBar,      TRUE,
                             /* Specify other attributes           */
                             WA_Activate,     TRUE,
                             WA_NoCareRefresh,TRUE,

                             /* Specify the events we want to know about */
                             WA_IDCMP,        IDCMP_CLOSEWINDOW,

                             /* Attach the window to the open screen ...*/
                             WA_CustomScreen, screen1,
                             WA_Title,        "EasyWindow",
                             WA_ScreenTitle,  "Our Screen - EasyWindow is Active",
                             TAG_DONE);
    if (window1 == NULL)
        cleanExit(screen1, window1, RETURN_WARN);

    /* Set up the signals for the events we want to hear about ...   */
    winsignal = 1L << window1->UserPort->mp_SigBit;  /* window IDCMP */
    signalmask = winsignal;   /* we are only waiting on IDCMP events */

    /* Here's the main input event loop where we wait for events.    */
    /* We have asked Intuition to send us CLOSEWINDOW IDCMP events   */
    /* Exec will wake us if any event we are waiting for occurs.     */
    while( !done )
    {
        signals = Wait(signalmask);

        /* An event occurred - now act on the signal(s) we received.*/
        /* We were only waiting on one signal (winsignal) in our    */
        /* signalmask, so we actually know we received winsignal.   */
        if(signals & winsignal)
            done = handleIDCMP(window1);    /* done if close gadget */
    }
    cleanExit(screen1, window1, RETURN_OK); /* Exit the program     */
}

BOOL handleIDCMP( struct Window *win )
{
    BOOL done = FALSE;
    struct IntuiMessage *message = NULL;
    ULONG class;

    /* Examine pending messages */
    while( message = (struct IntuiMessage *)GetMsg(win->UserPort) )
    {
        class = message->Class;  /* get all data we need from message */

        /* When we're through with a message, reply */
        ReplyMsg( (struct Message *)message);

        /* See what events occurred */
        switch( class )
        {
            case IDCMP_CLOSEWINDOW:
                done = TRUE;
                break;
            default:
                break;
        }
    }
    return(done);
}

VOID cleanExit( struct Screen *scrn, struct Window *wind, LONG returnValue )
{
    /* Close things in the reverse order of opening */
    if (wind) CloseWindow( wind );      /* Close window if opened */
    if (scrn) CloseScreen( scrn );      /* Close screen if opened */

    /* Close the library, and then exit */
    if (IntuitionBase) CloseLibrary( IntuitionBase );
    exit(returnValue);
}
