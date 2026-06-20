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
 ****************************************************************************
 *
 * Changehook_Test.c
 *
 * Demonstrate the use of CBD_CHANGEHOOK command.
 * The program will set a hook and wait for the clipboard data to change.
 * You must put something in the clipboard in order for it to return.
 *
 * Compile with SAS C 5.10: LC -cfist -v -y -L+Hookface.o+cbio.o
 *
 * Requires Kickstart 36 or greater.
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <exec/tasks.h>
#include <exec/io.h>
#include <devices/clipboard.h>
#include <dos/dos.h>
#include <utility/hooks.h>
#include "cb.h"

#include <clib/macros.h>
#include <clib/alib_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>
#include <string.h>


LONG version = 1L;

extern ULONG SysBase, DOSBase;

/* Data to pass around with the clipHook */
struct CHData
{
    struct Task *ch_Task;
    LONG ch_ClipID;
};

struct MsgPort *clip_port;
struct Hook hook;
struct CHData ch;

ULONG clipHook (struct Hook * h, VOID * o, struct ClipHookMsg * msg)
{
struct CHData *ch = (struct CHData *) h->h_Data;

if (ch)
   {
   /* Remember the ID of clip */
   ch->ch_ClipID = msg->chm_ClipID;

   /* Signal the task that started the hook */
   Signal (ch->ch_Task, SIGBREAKF_CTRL_E);
   }

return (0);
}

struct IOClipReq *OpenCB (LONG unit)
{
struct IOClipReq *clipIO;

/* Open clipboard unit 0 */

if (clipIO = CBOpen( 0L ))
    {
    ULONG hookEntry ();

    /* Fill out the IORequest */
    clipIO->io_Data = (char *) &hook;
    clipIO->io_Length = 1;
    clipIO->io_Command = CBD_CHANGEHOOK;

    /* Set up the hook data */
    ch.ch_Task = FindTask (NULL);

    /* Prepare the hook */
    hook.h_Entry = hookEntry;
    hook.h_SubEntry = clipHook;
    hook.h_Data = &ch;

    /* Start the hook */
    if (DoIO (clipIO))
        printf ("unable to set hook\n");
    else
        printf ("hook set\n");

    /* Return success */
    return ( clipIO );
    }

/* return failure */
return (NULL);
}

void CloseCB (struct IOClipReq *clipIO)
{

/* Fill out the IO request */
clipIO->io_Data = (char *) &hook;
clipIO->io_Length = 0;
clipIO->io_Command = CBD_CHANGEHOOK;

    /* Stop the hook */
if (DoIO (clipIO))
    printf ("unable to stop hook\n");
else
    /* Indicate success */
    printf ("hook is stopped\n");

CBClose(clipIO);
}

main (int argc, char **argv)
{
struct IOClipReq *clipIO;

ULONG sig_rcvd;

printf ("Test v%ld\n", version);

if (clipIO=OpenCB (0L))
    {
    sig_rcvd = Wait ((SIGBREAKF_CTRL_C | SIGBREAKF_CTRL_E));

    if (sig_rcvd & SIGBREAKF_CTRL_C)
        printf ("^C received\n");

    if (sig_rcvd & SIGBREAKF_CTRL_E)
        printf ("clipboard change, current ID is %ld\n", ch.ch_ClipID);

    CloseCB(clipIO);
    }
}
