;/* prefnotify.c.  - Execute me to compile me with SAS/C 5.10
lc -cfistq -v -y -j73 prefnotify.c
blink from LIB:c.o,prefnotify.o to prefnotify lib LIB:LC.lib LIB:amiga.lib
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
** prefnotify.c - notified if serial prefs change
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <dos/notify.h>

#include <stdio.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

#define PREFSFILENAME "ENV:sys/serial.prefs"

static UBYTE   *VersTag = "\0$VER: prefnot 37.1 (09.07.91)";

extern struct Library *DOSBase;


void main(int argc, char **argv)
{
BOOL done=FALSE;
struct NotifyRequest *notifyrequest;
UBYTE          *filename;
LONG           signum;
ULONG          signals;

/* We need at least V37 for notification */
if (DOSBase->lib_Version >= 37)
    {
    /* Allocate a NotifyRequest structure */
    if (notifyrequest = AllocMem(sizeof(struct NotifyRequest), MEMF_CLEAR))
        {
        /* And allocate a signalsbit */
        if ((signum = AllocSignal(-1L)) != -1)
            {
            /* Initialize notification request */
            filename = PREFSFILENAME;
            notifyrequest->nr_Name = filename;
            notifyrequest->nr_Flags = NRF_SEND_SIGNAL;
            /* Signal this task */
            notifyrequest->nr_stuff.nr_Signal.nr_Task = (struct Task *) FindTask(NULL);
            /* with this signals bit */
            notifyrequest->nr_stuff.nr_Signal.nr_SignalNum = signum;

            if ((StartNotify(notifyrequest)) == DOSTRUE)
                {
                printf("Select Serial Prefs SAVE or USE to notify this program\n");
                printf("CTRL-C to exit\n\n");
                /* Loop until Ctrl-C to exit */
                while(!done)
                    {
                    signals = Wait(  (1L << signum) | SIGBREAKF_CTRL_C  );
                    if (signals & (1L << signum))
                        printf("Notification signal received.\n");
                    if (signals & SIGBREAKF_CTRL_C)
                        {
                        EndNotify(notifyrequest);
                        done=TRUE;
                        }
                    }
                }
            else printf("Can't start notification\n");
            FreeSignal(signum);
            }
        else printf("No signals available\n");
        FreeMem(notifyrequest, sizeof(struct NotifyRequest));
        }
    else printf("Not enough memory for NotifyRequest.\n");
    }
else printf("Requires at least V37 dos.library\n");
}
