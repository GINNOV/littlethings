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
 ***************************************************************************
 *
 * Keyboard_Events.c
 *
 * This example does not work very well in a system where
 * input.device is active since input.device also actively calls for
 * keyboard events via this call. For that reason, you will not get all of
 * the keyboard events. Neither will the input device; no one will be happy.
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/io.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <devices/inputevent.h>
#include <devices/keyboard.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif


VOID Display_Event(struct InputEvent *keyEvent)
{
    printf("Got key event: KeyCode: %2x  Quailifiers: %4x\n",
               keyEvent->ie_Code,
               keyEvent->ie_Qualifier);
}

VOID main(int argc, char *argv[])
{
struct IOStdReq   *keyRequest;
struct MsgPort    *keyPort;
struct InputEvent *keyEvent;
       SHORT      loop;

    if (keyPort=CreatePort(NULL,NULL))
    {
        if (keyRequest=(struct IOStdReq *)CreateExtIO(keyPort,
                                                  sizeof(struct IOStdReq)))
        {
            if (!OpenDevice("keyboard.device",NULL,
                             (struct IORequest *)keyRequest,NULL))
            {
                if (keyEvent=AllocMem(sizeof(struct InputEvent),MEMF_PUBLIC))
                {
                    for (loop=0;loop<4;loop++)
                    {
                        keyRequest->io_Command=KBD_READEVENT;
                        keyRequest->io_Data=(APTR)keyEvent;

                        /*
                         * We want 1 event, so we just set the
                         * length field to the size, in bytes
                         * of the event.  For multiple events,
                         * set this to a multiple of that size.
                         * The keyboard device NEVER fills partial
                         * events...
                         */
                        keyRequest->io_Length=sizeof(struct InputEvent);
                        DoIO((struct IORequest *)keyRequest);

                            /* Check for CLI startup... */
                        if (argc) Display_Event(keyEvent);
                    }
                    FreeMem(keyEvent,sizeof(struct InputEvent));
                }
                CloseDevice((struct IORequest *)keyRequest);
            }
            DeleteExtIO((struct IORequest *)keyRequest);
        }
        DeletePort(keyPort);
    }
}
