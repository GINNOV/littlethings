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
 * Parallel.c
 *
 * Parallel device example
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <devices/parallel.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

VOID main(VOID);

VOID main(VOID)
{
struct MsgPort  *ParallelMP;          /* Define storage for one pointer */
struct IOExtPar *ParallelIO;         /* Define storage for one pointer */
ULONG            WaitMask;          /* Collect all signals here       */
ULONG            Temp;             /* Hey, we all need pockets :-)   */

if (ParallelMP=CreatePort(0,0) )
    {
    if (ParallelIO=(struct IOExtPar *)
        CreateExtIO(ParallelMP,sizeof(struct IOExtPar)) )
        {
        if (OpenDevice(PARALLELNAME,0L,(struct IORequest *)ParallelIO,0) )
            printf("%s did not open\n",PARALLELNAME);
        else
            {
            /* Precalculate a wait mask for the CTRL-C, CTRL-F and message port
             * signals.  When one or more signals are received, Wait() will
             * return.  Press CTRL-C to exit the example.  Press CTRL-F to
             * wake up the example without doing anything. NOTE: A signal
             * may show up without an associated message!
             */
            WaitMask = SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_F |
                       1L << ParallelMP->mp_SigBit;

            ParallelIO->IOPar.io_Command  = CMD_WRITE;
            ParallelIO->IOPar.io_Length   = -1;
            ParallelIO->IOPar.io_Data     = (APTR)"Hey, Jude!\r\n";
            SendIO(ParallelIO);             /* execute write */

            printf("Sleeping until CTRL-C, CTRL-F, or write finish\n");
            while(1)
                {
                Temp = Wait(WaitMask);
                printf("Just woke up (YAWN!)\n");

                if (SIGBREAKF_CTRL_C & Temp)
                    break;

                if (CheckIO(ParallelIO) ) /* If request is complete... */
                    {
                    WaitIO(ParallelIO);   /* clean up and remove reply */
                    printf("%ld bytes sent\n",ParallelIO->IOPar.io_Actual);
                    break;
                    }
                }

            AbortIO(ParallelIO);  /* Ask device to abort request, if pending */
            WaitIO(ParallelIO);   /* Wait for abort, then clean up */

            CloseDevice((struct IORequest *)ParallelIO);
            }
        DeleteExtIO(ParallelIO);
        }
    DeletePort(ParallelMP);
    }
}
