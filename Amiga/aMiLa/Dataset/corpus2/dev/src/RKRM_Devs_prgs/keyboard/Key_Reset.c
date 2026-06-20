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
 *****************************************************************************
 *
 * Key_Reset.c
 *
 * This is in two parts...
 *
 * Compile this C code with SAS C 5.10:
 *	lc -b1 -cfistq -v -y Key_Reset
 *
 * Assemble the ASM code with Adapt
 *  HX68 KeyHandler.a to KeyHandler.o
 *
 * Link with:
 *      Blink FROM LIB:c.o+Key_Reset.o+keyhandler.o TO Key_Reset LIB LIB:lc.lib LIB:amiga.lib
 */

/*
 * Keyboard device reset handler example...
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <devices/keyboard.h>
#include <intuition/intuition.h>
#include <exec/interrupts.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>


#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
void main();
#endif

extern VOID ResetHandler();

UBYTE NameString[]="Reset Handler Test";

struct NewWindow mywin={0,0,178,10,0,1,CLOSEWINDOW,
                        WINDOWDRAG|WINDOWCLOSE|SIMPLE_REFRESH|NOCAREREFRESH,
                        NULL,NULL,NameString,NULL,NULL,0,0,0,0,WBENCHSCREEN};

extern struct IntuitionBase *IntuitionBase;

struct MyData
    {
    struct Task  *MyTask;
           ULONG MySignal;
    };

/*
 * This routine opens a window and waits for the one event that
 * can happen (CLOSEWINDOW)
 */
short WaitForUser(ULONG MySignal)
{
struct Window  *win;
       short   ret=0;

    if (IntuitionBase=(struct IntuitionBase *)
                                    OpenLibrary("intuition.library",0L))
    {
        if (win=(struct Window *)OpenWindow(&mywin))
        {
            ret=(MySignal==Wait(MySignal | (1L << win->UserPort->mp_SigBit)));
            CloseWindow(win);
        }
        CloseLibrary((struct Library *)IntuitionBase);
    }
    return(ret);
}

VOID main(int argc, char *argv[])
{
struct IOStdReq  *KeyIO;
struct MsgPort   *KeyMP;
struct Interrupt *keyHandler;
struct MyData    MyDataStuff;
       ULONG     MySignal;

    if ((MySignal=AllocSignal(-1L))!=-1)
    {
        MyDataStuff.MyTask=FindTask(NULL);
        MyDataStuff.MySignal=1L << MySignal;
        if (KeyMP=CreatePort(NULL,NULL))
        {
            if (keyHandler=AllocMem(sizeof(struct Interrupt),
                                       MEMF_PUBLIC|MEMF_CLEAR))
            {
                if (KeyIO=(struct IOStdReq *)CreateExtIO(KeyMP,
                                                     sizeof(struct IOStdReq)))
                {
                    if (!OpenDevice("keyboard.device",NULL,
                                     (struct IORequest *)KeyIO,NULL))
                    {
                        keyHandler->is_Code=ResetHandler;
                        keyHandler->is_Data=(APTR)&MyDataStuff;

                        /*
                         * Note that only software interrupt priorities
                         * can be used for the .ln_Pri on the reset
                         * handler...
                         */
                        keyHandler->is_Node.ln_Pri=16;

                        keyHandler->is_Node.ln_Name=NameString;
                        KeyIO->io_Data=(APTR)keyHandler;
                        KeyIO->io_Command=KBD_ADDRESETHANDLER;
                        DoIO((struct IORequest *)KeyIO);

                        if (WaitForUser(MyDataStuff.MySignal))
                        {
                            if (argc) /* Check for CLI */
                            {
                                printf("System going down\n");
                                printf("Cleaning up...\n");
                                /* Show a delay, like cleanup... */
                                Delay(20);
                                printf("*Poof*\n");
                            }

                            /* We are done with our cleanup */
                            KeyIO->io_Data=(APTR)keyHandler;
                            KeyIO->io_Command=KBD_RESETHANDLERDONE;
                            DoIO((struct IORequest *)KeyIO);
                            /*
                             * Note that since the above call
                             * tells the system it is safe to reboot
                             * and will cause the reboot if this
                             * task was the last to say so, the call
                             * never really returns...  The system
                             * just reboots...
                             */
                        }

                        KeyIO->io_Data=(APTR)keyHandler;
                        KeyIO->io_Command=KBD_REMRESETHANDLER;
                        DoIO((struct IORequest *)KeyIO);

                        CloseDevice((struct IORequest *)KeyIO);
                    }
                    DeleteExtIO((struct IORequest *)KeyIO);
                }
                FreeMem(keyHandler,sizeof(struct Interrupt));
            }
            DeletePort(KeyMP);
        }
        FreeSignal(MySignal);
    }
}
