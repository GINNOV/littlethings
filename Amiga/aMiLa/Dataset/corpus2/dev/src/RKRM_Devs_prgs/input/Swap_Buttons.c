/*
 * Copyright (c) 1992 Commodore-Amiga, Inc.
 * 
 * This example is provided in electronic form by Commodore-Amiga, Inc. for 
 * use with the "Amiga ROM Kernel Reference Manual: Devices", 3rd Edition, 
 * published by Addison-Wesley (ISBN 0-201-56775-X).
 * 
 * The "Amiga ROM Kernel Reference Manual: Devices" contains additional 
 * information on the correct usage of the techniques and operating system 
 * functions presented in these examples.  The source and executable code 
 * of these examples may only be distributed in free electronic form, via 
 * bulletin board or as part of a fully non-commercial and freely 
 * redistributable diskette.  Both the source and executable code (including 
 * comments) must be included, without modification, in any copy.  This 
 * example may not be published in printed form or distributed with any
 * commercial product.  However, the programming techniques and support
 * routines set forth in these examples may be used in the development
 * of original executable software products for Commodore Amiga computers.
 * 
 * All other rights reserved.
 * 
 * This example is provided "as-is" and is subject to change; no
 * warranties are made.  All use is at your own risk. No liability or
 * responsibility is assumed.
 *
 ************************************************************************** 
 *
 * Swap_Buttons.c
 *
 * This example swaps the function of the left and right mouse buttons
 * The C code is just the wrapper that installs and removes the
 * input.device handler that does the work.
 *
 * The handler is written in assembly code since it is important that
 * handlers be as fast as possible while processing the input events.
 *
 *
 * Compile and link as follows:
 *
 * SAS C 5.10:
 *
 *  LC -b1 -cfirst -v -w Swap_Buttons.c
 *
 * Adapt assemble:
 *
 *  HX68 InputHandler.a to InputHandler.o
 *
 * BLink:
 *
 *  BLink from LIB:c.o+Swap_Buttons.o+InputHandler.o LIB LIB:lc.lib LIB:amiga.lib TO Swap_Buttons
 *
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <devices/input.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


UBYTE NameString[]="Swap Buttons";

struct NewWindow mywin={50,40,124,18,0,1,CLOSEWINDOW,
                        WINDOWDRAG|WINDOWCLOSE|SIMPLE_REFRESH|NOCAREREFRESH,
                        NULL,NULL,NameString,NULL,NULL,0,0,0,0,WBENCHSCREEN};

extern VOID ButtonSwap();

extern struct IntuitionBase *IntuitionBase;

/*
 * This routine opens a window and waits for the one event that
 * can happen (CLOSEWINDOW)  This is just to let the user play with
 * the swapped buttons and then close the program...
 */
VOID WaitForUser(VOID)
{
struct Window  *win;

if (IntuitionBase=(struct IntuitionBase *)
                                OpenLibrary("intuition.library",33L))
    {
    if (win=OpenWindow(&mywin))
        {
        WaitPort(win->UserPort);
        ReplyMsg(GetMsg(win->UserPort));

        CloseWindow(win);
        }
    CloseLibrary((struct Library *)IntuitionBase);
    }
}

VOID main(VOID)
{
struct IOStdReq  *inputReqBlk;
struct MsgPort   *inputPort;
struct Interrupt *inputHandler;

if (inputPort=CreatePort(NULL,NULL))
    {
    if (inputHandler=AllocMem(sizeof(struct Interrupt),
                               MEMF_PUBLIC|MEMF_CLEAR))
        {
        if (inputReqBlk=(struct IOStdReq *)CreateExtIO(inputPort,
                                                 sizeof(struct IOStdReq)))
            {
            if (!OpenDevice("input.device",NULL,
                             (struct IORequest *)inputReqBlk,NULL))
                {
                inputHandler->is_Code=ButtonSwap;
                inputHandler->is_Data=NULL;
                inputHandler->is_Node.ln_Pri=100;
                inputHandler->is_Node.ln_Name=NameString;
                inputReqBlk->io_Data=(APTR)inputHandler;
                inputReqBlk->io_Command=IND_ADDHANDLER;
                DoIO((struct IORequest *)inputReqBlk);

                WaitForUser();

                inputReqBlk->io_Data=(APTR)inputHandler;
                inputReqBlk->io_Command=IND_REMHANDLER;
                DoIO((struct IORequest *)inputReqBlk);

                CloseDevice((struct IORequest *)inputReqBlk);
                }
            else
                printf("Error: Could not open input.device\n");

            DeleteExtIO((struct IORequest *)inputReqBlk);
            }
        else
            printf("Error: Could not create IORequest\n");

        FreeMem(inputHandler,sizeof(struct Interrupt));
        }
    else
        printf("Error: Could not allocate interrupt struct memory\n");

    DeletePort(inputPort);
    }
else
    printf("Error: Could not create message port\n");
}
