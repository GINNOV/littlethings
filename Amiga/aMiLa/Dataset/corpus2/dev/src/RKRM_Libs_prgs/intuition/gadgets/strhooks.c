;/* strhooks.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 strhooks.c
Blink FROM LIB:c.o,strhooks.o TO strhooks LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
**   strhooks.c - string gadget hooks demo
**
** WARNING: This file contains "callback" functions.
** You must disable stack checking (SAS -v flag) for them to work.
*/
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <utility/hooks.h>
#include <devices/inputevent.h>
#include <intuition/intuition.h>
#include <intuition/sghooks.h>
#include <graphics/displayinfo.h>

#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>
#include <clib/exec_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

/* our function prototypes */
BOOL IsHexDigit(UBYTE test_char);
ULONG str_hookRoutine(struct Hook *hook, struct SGWork *sgw, ULONG *msg);
void initHook(struct Hook *hook, ULONG (*ccode)());
VOID handleWindow(struct Vars *vars);

struct Library    *IntuitionBase;
struct Library    *UtilityBase;

#define SG_STRLEN     (44)
#define MYSTRGADWIDTH (200)
#define INIT_LATER      0

/* A border for the string gadget */
UWORD strBorderData[] = /* init elements 5 and 7 later (height adjust) */
    {
    0,0,  MYSTRGADWIDTH + 3,0,  MYSTRGADWIDTH + 3,INIT_LATER,
    0,INIT_LATER,   0,0,
    };
struct Border strBorder =
    {
    -2,-2, 1, 0,JAM1,5,strBorderData,NULL,
    };

/* We'll dynamically allocate/clear most structures, buffers */
struct Vars
    {
    struct Window      *sgg_Window;
    struct Gadget       sgg_Gadget;
    struct StringInfo   sgg_StrInfo;
    struct StringExtend sgg_Extend;
    struct Hook         sgg_Hook;
    UBYTE               sgg_Buff[SG_STRLEN];
    UBYTE               sgg_WBuff[SG_STRLEN];
    UBYTE               sgg_UBuff[SG_STRLEN];
    };

/*   Main entry point.
**
** Open all required libraries, set-up the string gadget.
** Prepare the hook, open the sgg_Window and go...
*/
VOID main(int argc, char **argv)
{
struct Vars   *vars;
struct Screen   *screen;
struct DrawInfo *drawinfo;

if (IntuitionBase = OpenLibrary("intuition.library", 37L))
    {
    if (UtilityBase = OpenLibrary("utility.library", 37L))
        {
        /* get the correct pens for the screen. */
        if (screen = LockPubScreen(NULL))
            {
            if (drawinfo = GetScreenDrawInfo(screen))
                {
                vars = (struct Vars *)AllocMem(sizeof(struct Vars),MEMF_CLEAR);
                if (vars != NULL)
                    {
                    vars->sgg_Extend.Pens[0] = drawinfo->dri_Pens[FILLTEXTPEN];
                    vars->sgg_Extend.Pens[1] = drawinfo->dri_Pens[FILLPEN];
                    vars->sgg_Extend.ActivePens[0] = drawinfo->dri_Pens[FILLTEXTPEN];
                    vars->sgg_Extend.ActivePens[1] = drawinfo->dri_Pens[FILLPEN];
                    vars->sgg_Extend.EditHook = &(vars->sgg_Hook);
                    vars->sgg_Extend.WorkBuffer = vars->sgg_WBuff;

                    vars->sgg_StrInfo.Buffer = vars->sgg_Buff;
                    vars->sgg_StrInfo.UndoBuffer = vars->sgg_UBuff;
                    vars->sgg_StrInfo.MaxChars = SG_STRLEN;
                    vars->sgg_StrInfo.Extension = &(vars->sgg_Extend);

                    /* There should probably be a border around the string gadget.
                    ** As is, it is hard to locate when disabled.
                    */
                    vars->sgg_Gadget.LeftEdge = 20;
                    vars->sgg_Gadget.TopEdge = 30;
                    vars->sgg_Gadget.Width = MYSTRGADWIDTH;
                    vars->sgg_Gadget.Height = screen->RastPort.TxHeight;
                    vars->sgg_Gadget.Flags = GFLG_GADGHCOMP | GFLG_STRINGEXTEND;
                    vars->sgg_Gadget.Activation = GACT_RELVERIFY;
                    vars->sgg_Gadget.GadgetType = GTYP_STRGADGET;
                    vars->sgg_Gadget.SpecialInfo = &(vars->sgg_StrInfo);
                    vars->sgg_Gadget.GadgetRender = (APTR)&strBorder;
                    strBorderData[5] = strBorderData[7] =
                          screen->RastPort.TxHeight + 3;

                    initHook(&(vars->sgg_Hook), str_hookRoutine);

                    if (vars->sgg_Window = OpenWindowTags(NULL,
                            WA_PubScreen,       screen,
                            WA_Left,      21,   WA_Top,       20,
                            WA_Width,    500,   WA_Height,   150,
                            WA_MinWidth,  50,   WA_MaxWidth,  ~0,
                            WA_MinHeight, 30,   WA_MaxHeight, ~0,
                            WA_SimpleRefresh, TRUE,
                            WA_NoCareRefresh, TRUE,
                            WA_RMBTrap,       TRUE,
                            WA_IDCMP,         IDCMP_GADGETUP | IDCMP_CLOSEWINDOW,
                            WA_Flags,         WFLG_CLOSEGADGET | WFLG_NOCAREREFRESH |
                                              WFLG_DRAGBAR | WFLG_DEPTHGADGET |
                                              WFLG_SIMPLE_REFRESH,
                            WA_Title,         "String Hook Accepts HEX Digits Only",
                            WA_Gadgets,       &(vars->sgg_Gadget),
                            TAG_DONE))
                        {
                        handleWindow(vars);

                        CloseWindow(vars->sgg_Window);
                        }
                    FreeMem(vars,sizeof(struct Vars));
                    }
                FreeScreenDrawInfo(screen, drawinfo);
                }
            UnlockPubScreen(NULL, screen);
            }
        CloseLibrary(UtilityBase);
        }
    CloseLibrary(IntuitionBase);
    }
}


/*
** This is an example string editing hook, which shows the basics of
** creating a string editing function.  This hook restricts entry to
** hexadecimal digits (0-9, A-F, a-f) and converts them to upper case.
** To demonstrate processing of mouse-clicks, this hook also detects
** clicking on a character, and converts it to a zero.
**
** NOTE: String editing hooks are called on Intuition's task context,
** so the hook may not use DOS and may not cause Wait() to be called.
*/

ULONG str_hookRoutine(struct Hook *hook, struct SGWork *sgw, ULONG *msg)
{
UBYTE *work_ptr;
ULONG return_code;

/* Hook must return non-zero if command is supported.
** This will be changed to zero if the command is unsupported.
*/
return_code = ~0L;

if (*msg == SGH_KEY)
    {
    /* key hit -- could be any key (Shift, repeat, character, etc.) */

    /* allow only upper case characters to be entered.
    ** act only on modes that add or update characters in the buffer.
    */
    if ((sgw->EditOp == EO_REPLACECHAR) ||
        (sgw->EditOp == EO_INSERTCHAR))
        {
        /* Code contains the ASCII representation of the character
        ** entered, if it maps to a single byte.  We could also look
        ** into the work buffer to find the new character.
        **
        **     sgw->Code == sgw->WorkBuffer[sgw->BufferPos - 1]
        **
        ** If the character is not a legal hex digit, don't use
        ** the work buffer and beep the screen.
        */
        if (!IsHexDigit(sgw->Code))
            {
            sgw->Actions |= SGA_BEEP;
            sgw->Actions &= ~SGA_USE;
            }
        else
            {
            /* And make it upper-case, for nicety */
            sgw->WorkBuffer[sgw->BufferPos - 1] = ToUpper(sgw->Code);
            }
        }
    }
else if (*msg == SGH_CLICK)
    {
    /* mouse click
    ** zero the digit clicked on
    */
    if (sgw->BufferPos < sgw->NumChars)
        {
        work_ptr = sgw->WorkBuffer + sgw->BufferPos;
        *work_ptr = '0';
        }
    }
else
    {
    /* UNKNOWN COMMAND
    ** hook should return zero if the command is not supported.
    */
    return_code = 0;
    }

return(return_code);
}



/*
** This is a function which converts register-parameter
** hook calling convention into standard C conventions.
** It only works with SAS C 5.0+
**
** Without the fancy __asm stuff, you'd probably need to
** write this in assembler.
**
** You could conceivably declare all your C hook functions
** this way, and eliminate the middleman (you'd initialize
** the h_Entry field to your C function's address, and not
** bother with the h_SubEntry field).
**
** This is nice and easy, though, and since we're using the
** small data model, using a single interface routine like this
** (which does the necessary __saveds), it might
** actually turn out to be smaller to use a single entry point
** like this rather than declaring each of many hooks __saveds.
*/
ULONG __saveds __asm hookEntry(register __a0 struct Hook *hookptr,
    register __a2 void  *object,
    register __a1 void  *message)
{
return((*hookptr->h_SubEntry)(hookptr, object, message));
}


/*
** Initialize the hook to use the hookEntry() routine above.
*/
void initHook(struct Hook *hook, ULONG (*ccode)())
{
hook->h_Entry    = hookEntry;
hook->h_SubEntry = ccode;
hook->h_Data     = 0;   /* this program does not use this */
}

/*
** Process messages received by the sgg_Window.  Quit when the close gadget
** is selected.
*/
VOID handleWindow(struct Vars *vars)
{
struct IntuiMessage *msg;
ULONG  class;
USHORT code;

for (;;)
    {
    Wait(1L << vars->sgg_Window->UserPort->mp_SigBit);
    while (msg =
            (struct IntuiMessage *)GetMsg(vars->sgg_Window->UserPort))
        {
        /* Stash message contents and reply, important when message
        ** triggers some lengthy processing
        */
        class = msg->Class;
        code  = msg->Code;
        ReplyMsg((struct Message *)msg);

        switch (class)
            {
            case IDCMP_GADGETUP:
                /* if a code is set in the hook after an SGH_KEY
                ** command, where SGA_END is set on return from
                ** the hook, the code will be returned in the Code
                ** field of the IDCMP_GADGETUP message.
                */
                break;
            case IDCMP_CLOSEWINDOW:
                return;
                break;
            }
        }
    }
}


/*
** IsHexDigit()
**
** Return TRUE if the character is a hex digit (0-9, A-F, a-f)
*/
BOOL IsHexDigit(UBYTE test_char)
{
test_char = ToUpper(test_char);
if (((test_char >= '0') && (test_char <= '9')) ||
    ((test_char >= 'A') && (test_char <= 'F')))
    return(TRUE);
else
    return(FALSE);
}
