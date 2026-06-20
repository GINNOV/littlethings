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
 * Get_Systime.c
 *
 * Get system time example
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <devices/timer.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct timerequest *TimerIO;
struct MsgPort *TimerMP;
struct Message *TimerMSG;

VOID main(VOID);

void main()
{
LONG error;
ULONG days,hrs,secs,mins,mics;

if (TimerMP = CreatePort(0,0))
    {
    if (TimerIO = (struct timerequest *)
        CreateExtIO(TimerMP,sizeof(struct timerequest)) )
        {
            /* Open with UNIT_VBLANK, but any unit can be used */
        if (!(error=OpenDevice(TIMERNAME,UNIT_VBLANK,(struct IORequest *)TimerIO,0L)))
            {

            /* Issue the command and wait for it to finish, then get the reply */
            TimerIO->tr_node.io_Command = TR_GETSYSTIME;
            DoIO((struct IORequest *) TimerIO);

            /* Get the results and close the timer device */
            mics=TimerIO->tr_time.tv_micro;
            secs=TimerIO->tr_time.tv_secs;

            /* Compute days, hours, etc. */
            mins=secs/60;
            hrs=mins/60;
            days=hrs/24;
            secs=secs%60;
            mins=mins%60;
            hrs=hrs%24;

            /* Display the time */
            printf("\nSystem Time (measured from Jan.1,1978)\n");
            printf("  Days   Hours  Minutes Seconds Microseconds\n");
            printf("%6ld %6ld %6ld %6ld %10ld\n",days,hrs,mins,secs,mics);

            /* Close the timer device */
            CloseDevice((struct IORequest *) TimerIO);
            }
        else
            printf("\nError: Could not open timer device\n");

        /* Delete the I/O request structure */
        DeleteExtIO(TimerIO);
        }
    else
        printf("\nError: Could not create I/O structure\n");

    /* Delete the port */
    DeletePort(TimerMP);
    }
else
    printf("\nError: Could not create port\n");
}
