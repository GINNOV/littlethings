;/* simplegtgadget.c -- execute me to compile me
lc -b1 -cfistq -v -y -j73 simplegtgadget
blink FROM LIB:c.o simplegtgadget.o TO simplegtgadget LIB LIB:lc.lib LIB:amiga.lib
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
Simple example of a GadTools gadget.  Compiled with SAS C v5.10a
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/gadgetclass.h>
#include <libraries/gadtools.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* Gadget defines of our choosing, to be used as GadgetID's. */
#define MYGAD_BUTTON    (4)

VOID process_window_events(struct Window *);
VOID gadtoolsWindow(VOID);

struct TextAttr Topaz80 = { "topaz.font", 8, 0, 0, };

struct Library *IntuitionBase;
struct Library *GadToolsBase;


/*
** Open all libraries and run.  Clean up when finished or on error..
*/
void main(void)
{
if ( (IntuitionBase = OpenLibrary("intuition.library", 37)) != NULL )
    {
    if ( (GadToolsBase = OpenLibrary("gadtools.library", 37)) != NULL )
        {
        gadtoolsWindow();

        CloseLibrary(GadToolsBase);
        }
    CloseLibrary(IntuitionBase);
    }
}


/*
** Prepare for using GadTools, set up gadgets and open window.
** Clean up and when done or on error.
*/
VOID gadtoolsWindow(VOID)
{
struct Screen    *mysc;
struct Window    *mywin;
struct Gadget    *glist, *gad;
struct NewGadget ng;
void             *vi;

glist = NULL;

if ( (mysc = LockPubScreen(NULL)) != NULL )
    {
    if ( (vi = GetVisualInfo(mysc, TAG_END)) != NULL )
        {
        /* GadTools gadgets require this step to be taken */
        gad = CreateContext(&glist);

        /* create a button gadget centered below the window title */
        ng.ng_TextAttr   = &Topaz80;
        ng.ng_VisualInfo = vi;
        ng.ng_LeftEdge   = 150;
        ng.ng_TopEdge    = 20 + mysc->WBorTop + (mysc->Font->ta_YSize + 1);
        ng.ng_Width      = 100;
        ng.ng_Height     = 12;
        ng.ng_GadgetText = "Click Here";
        ng.ng_GadgetID   = MYGAD_BUTTON;
        ng.ng_Flags      = 0;
        gad = CreateGadget(BUTTON_KIND, gad, &ng, TAG_END);

        if (gad != NULL)
            {
            if ( (mywin = OpenWindowTags(NULL,
                    WA_Title,     "GadTools Gadget Demo",
                    WA_Gadgets,   glist,      WA_AutoAdjust,    TRUE,
                    WA_Width,       400,      WA_InnerHeight,    100,
                    WA_DragBar,    TRUE,      WA_DepthGadget,   TRUE,
                    WA_Activate,   TRUE,      WA_CloseGadget,   TRUE,
                    WA_IDCMP, IDCMP_CLOSEWINDOW |
                              IDCMP_REFRESHWINDOW | BUTTONIDCMP,
                    WA_PubScreen,   mysc,
                    TAG_END)) != NULL )
                {
                GT_RefreshWindow(mywin, NULL);

                process_window_events(mywin);

                CloseWindow(mywin);
                }
            }
        /* FreeGadgets() must be called after the context has been
        ** created.  It does nothing if glist is NULL
        */
        FreeGadgets(glist);
        FreeVisualInfo(vi);
        }
    UnlockPubScreen(NULL, mysc);
    }
}

/*
** Standard message handling loop with GadTools message handling functions
** used (GT_GetIMsg() and GT_ReplyIMsg()).
*/
VOID process_window_events(struct Window *mywin)
{
struct IntuiMessage *imsg;
struct Gadget *gad;
BOOL  terminated = FALSE;

while (!terminated)
    {
    Wait (1 << mywin->UserPort->mp_SigBit);

    /* Use GT_GetIMsg() and GT_ReplyIMsg() for handling */
    /* IntuiMessages with GadTools gadgets.             */
    while ((!terminated) && (imsg = GT_GetIMsg(mywin->UserPort)))
        {
        /* GT_ReplyIMsg() at end of loop */

        switch (imsg->Class)
            {
            case IDCMP_GADGETUP:       /* Buttons only report GADGETUP */
                gad = (struct Gadget *)imsg->IAddress;
                if (gad->GadgetID == MYGAD_BUTTON)
                        printf("Button was pressed.\n");
                break;
            case IDCMP_CLOSEWINDOW:
                terminated = TRUE;
                break;
            case IDCMP_REFRESHWINDOW:
                /* This handling is REQUIRED with GadTools. */
                GT_BeginRefresh(mywin);
                GT_EndRefresh(mywin, TRUE);
                break;
            }
        /* Use the toolkit message-replying function here... */
        GT_ReplyIMsg(imsg);
        }
    }
}
