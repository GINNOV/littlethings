;/* updatestrgad.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 updatestrgad.c
Blink FROM LIB:c.o,updatestrgad.o TO updatestrgad LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
** updatestrgad.c - Show the use of a string gadget.  Shows both the use of
** ActivateGadget() and how to properly modify the contents of a string gadget.
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <string.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* our function prototypes */
VOID updateStrGad(struct Window *win, struct Gadget *gad, UBYTE *newstr);
VOID handleWindow(struct Window *win, struct Gadget *gad);

struct Library *IntuitionBase;

/* NOTE that the use of constant size and positioning values are
** not recommended; it just makes it easy to show what is going on.
** The position of the gadget should be dynamically adjusted depending
** on the height of the font in the title bar of the window.  This
** example adapts the gadget height to the screen font. Alternately,
** you could specify your font under V37 with the StringExtend structure.
*/
#define BUFSIZE (100)
#define MYSTRGADWIDTH (200)
#define MYSTRGADHEIGHT (8)

UWORD strBorderData[] =
    {
    0,0, MYSTRGADWIDTH + 3,0, MYSTRGADWIDTH + 3,MYSTRGADHEIGHT + 3,
    0,MYSTRGADHEIGHT + 3, 0,0,
    };
struct Border strBorder =
    {
    -2,-2,1,0,JAM1,5,strBorderData,NULL,
    };
UBYTE strBuffer[BUFSIZE];
UBYTE strUndoBuffer[BUFSIZE];
struct StringInfo strInfo =
    {
    strBuffer,strUndoBuffer,0,BUFSIZE, /* compiler sets remaining fields to zero */
    };
struct Gadget strGad =
    {
    NULL, 20,20,MYSTRGADWIDTH,MYSTRGADHEIGHT,
    GFLG_GADGHCOMP, GACT_RELVERIFY | GACT_STRINGCENTER,
    GTYP_STRGADGET, &strBorder, NULL, NULL,0,&strInfo,0,NULL,
    };

#define ANSCNT 4
UBYTE *answers[ANSCNT] = {"Try again","Sorry","Perhaps","A Winner"};
int ansnum = 0;
UBYTE *activated_txt = "Activated";

/*   main - show the use of a string gadget.
*/
VOID main(int argc, char **argv)
{
struct Window *win;

/* make sure to get intuition version 37, for OpenWindowTags() */
IntuitionBase = OpenLibrary("intuition.library", 37);
if (IntuitionBase)
    {
    /* Load a value into the string gadget buffer.
    ** This will be displayed when the gadget is first created.
    */
    strcpy(strBuffer, "START");

    if (win = OpenWindowTags(NULL,
                            WA_Width, 400,
                            WA_Height, 100,
                            WA_Title,"Activate Window, Enter Text",
                            WA_Gadgets, &strGad,
                            WA_CloseGadget, TRUE,
                            WA_IDCMP, IDCMP_ACTIVEWINDOW |
                                IDCMP_CLOSEWINDOW | IDCMP_GADGETUP,
                            TAG_END))
        {
        handleWindow(win,&strGad);

        CloseWindow(win);
        }
    CloseLibrary(IntuitionBase);
    }
}



/*
** Process messages received by the window.  Quit when the close gadget
** is selected, activate the gadget when the window becomes active.
*/
VOID handleWindow(struct Window *win, struct Gadget *gad)
{
struct IntuiMessage *msg;
struct Gadget *gadget;
ULONG  class;

for (;;)
    {
    Wait(1L << win->UserPort->mp_SigBit);
    while (msg = (struct IntuiMessage *)GetMsg(win->UserPort))
        {
        /* Stash message contents and reply, important when message
        ** triggers some lengthy processing
        */
        class = msg->Class;
        /* If it's a gadget message, IAddress points to Gadget */
        if((class == IDCMP_GADGETUP)||(class == IDCMP_GADGETDOWN))
                gadget = (struct Gadget *)msg->IAddress;
        ReplyMsg((struct Message *)msg);

        switch (class)
            {
            case IDCMP_ACTIVEWINDOW:
                /* activate the string gadget.  This is how to activate a
                ** string gadget in a new window--wait for the window to
                ** become active by waiting for the IDCMP_ACTIVEWINDOW
                ** event, then activate the gadget.  Here we report on
                ** the success or failure.
                */
                if(ActivateGadget(gad,win,NULL))
                    updateStrGad(win,gad,activated_txt);
                break;
            case IDCMP_CLOSEWINDOW:
                /* here is the way out of the loop and the routine.
                ** be sure that the message was replied...
                */
                return;
                break;
            case IDCMP_GADGETUP:
                /* If user hit RETURN in our string gadget for demonstration,
                ** we will change what he entered.  We only have 1 gadget,
                ** so we don't have to check which gadget.
                */
                updateStrGad(win, &strGad, answers[ansnum]);
                if(++ansnum >= ANSCNT) ansnum = 0;  /* point to next answer */
                break;
            }
        }
    }
}



/*
** Routine to update the value in the string gadget's buffer, then
** activate the gadget.
*/
VOID updateStrGad(struct Window *win, struct Gadget *gad, UBYTE *newstr)
{
/* first, remove the gadget from the window.  this must be done before
** modifying any part of the gadget!!!
*/
RemoveGList(win,gad,1);

/* For fun, change the value in the buffer, as well as the cursor and
** initial display position.
*/
strcpy(((struct StringInfo *)(gad->SpecialInfo))->Buffer, newstr);
((struct StringInfo *)(gad->SpecialInfo))->BufferPos = 0;
((struct StringInfo *)(gad->SpecialInfo))->DispPos   = 0;

/* Add the gadget back, placing it at the end of the list (~0)
** and refresh its imagery.
*/
AddGList(win,gad,~0,1,NULL);
RefreshGList(gad,win,NULL,1);

/* Activate the string gadget */
ActivateGadget(gad,win,NULL);
}
