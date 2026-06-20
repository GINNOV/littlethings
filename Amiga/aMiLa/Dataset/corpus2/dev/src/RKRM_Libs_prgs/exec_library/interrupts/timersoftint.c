;/* timersoftint.c - Execute me to compile me with SAS C 5.10
LC -b1 -d0 -cfistq -v -y -j73 timersoftint.c
Blink FROM LIB:c.o,timersoftint.o TO timersoftint LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

timersoftint.c - Timer device software interrupt message port example.

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

#include <exec/memory.h>
#include <exec/interrupts.h>
#include <devices/timer.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

#define MICRO_DELAY 1000
#define OFF     0
#define ON      1
#define STOPPED 2

struct TSIData {
    ULONG tsi_Counter;
    ULONG tsi_Flag;
    struct MsgPort *tsi_Port;
};

struct TSIData *tsidata;

void tsoftcode(void);    /* Prototype for our software interrupt code */

void main(void)
{
    struct MsgPort *port;
    struct Interrupt *softint;
    struct timerequest *tr;

    ULONG endcount;

    /* Allocate message port, data & interrupt structures. Don't use CreatePort() */
    /* or CreateMsgPort() since they allocate a signal (don't need that) for a    */
    /* PA_SIGNAL type port. We need PA_SOFTINT.                                   */
    if (tsidata = AllocMem(sizeof(struct TSIData), MEMF_PUBLIC|MEMF_CLEAR))
    {
        if(port = AllocMem(sizeof(struct MsgPort), MEMF_PUBLIC|MEMF_CLEAR))
        {
            NewList(&(port->mp_MsgList));                             /* Initialize message list */
            if (softint = AllocMem(sizeof(struct Interrupt), MEMF_PUBLIC|MEMF_CLEAR))
            {
                /* Set up the (software)interrupt structure. Note that this task runs at  */
                /* priority 0. Software interrupts may only be priority -32, -16, 0, +16, */
                /* +32. Also not that the correct node type for a software interrupt is   */
                /* NT_INTERRUPT. (NT_SOFTINT is an internal Exec flag). This is the same  */
                /* setup as that for a software interrupt which you Cause(). If our       */
                /* interrupt code was in assembler, you could initialize is_Data here to  */
                /* contain a pointer to shared data structures. An assembler software     */
                /* interrupt routine would receive the is_Data in A1.                     */

                softint->is_Code = tsoftcode;    /* The software interrupt routine */
                softint->is_Data = tsidata;
                softint->is_Node.ln_Pri = 0;

                port->mp_Node.ln_Type = NT_MSGPORT;       /* Set up the PA_SOFTINT message port  */
                port->mp_Flags = PA_SOFTINT;              /* (no need to make this port public). */
                port->mp_SigTask = (struct Task *)softint;     /* pointer to interrupt structure */

                /* Allocate timerequest */
                if (tr = (struct timerequest *) CreateExtIO(port, sizeof(struct timerequest)))
                {
                    /* Open timer.device. NULL is success. */
                    if (!(OpenDevice("timer.device", UNIT_MICROHZ, (struct IORequest *)tr, 0)))
                    {
                        tsidata->tsi_Flag = ON;        /* Init data structure to share globally. */
                        tsidata->tsi_Port = port;

                        /* Send of the first timerequest to start. IMPORTANT: Do NOT   */
                        /* BeginIO() to any device other than audio or timer from      */
                        /* within a software or hardware interrupt. The BeginIO() code */
                        /* may allocate memory, wait or perform other functions which  */
                        /* are illegal or dangerous during interrupts.                 */
                        printf("starting softint. CTRL-C to break...\n");


                        tr->tr_node.io_Command = TR_ADDREQUEST;    /* Initial iorequest to start */
                        tr->tr_time.tv_micro = MICRO_DELAY;        /* software interrupt.        */
                        BeginIO((struct IORequest *)tr);

                        Wait(SIGBREAKF_CTRL_C);
                        endcount = tsidata->tsi_Counter;
                        printf("timer softint counted %ld milliseconds.\n", endcount);

                        printf("Stopping timer...\n");
                        tsidata->tsi_Flag = OFF;

                        while (tsidata->tsi_Flag != STOPPED) Delay(10);

                        CloseDevice((struct IORequest *)tr);
                    }
                    else printf("couldn't open timer.device\n");
                    DeleteExtIO(tr);
                }
                else printf("couldn't create timerequest\n");
                FreeMem(softint, sizeof(struct Interrupt));
            }
            FreeMem(port, sizeof(struct MsgPort));
        }
        FreeMem(tsidata, sizeof(struct TSIData));
    }
}


void tsoftcode(void)
{
    struct timerequest *tr;

    /* Remove the message from the port. */
    tr = (struct timerequest *)GetMsg(tsidata->tsi_Port);

    /* Keep on going if main() hasn't set flag to OFF. */
    if ((tr) && (tsidata->tsi_Flag == ON))
    {
        /* increment counter and re-send timerequest--IMPORTANT: This         */
        /* self-perpetuating technique of calling BeginIO() during a software */
        /* interrupt may only be used with the audio and timer device.        */
        tsidata->tsi_Counter++;
        tr->tr_node.io_Command = TR_ADDREQUEST;
        tr->tr_time.tv_micro = MICRO_DELAY;
        BeginIO((struct IORequest *)tr);
    }
    /* Tell main() we're out of here. */
    else tsidata->tsi_Flag = STOPPED;
}
