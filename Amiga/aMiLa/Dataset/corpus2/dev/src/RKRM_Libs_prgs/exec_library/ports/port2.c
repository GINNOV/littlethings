;/* port2.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 port2.c
Blink FROM LIB:c.o,port2.o TO port2 LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

port2.c - port and message example, run at the same time as port1.c

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

#include <exec/types.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL-C handling */
int chkabort(void) {return(0);}
#endif

BOOL SafePutToPort(struct Message *, STRPTR);

struct XYMessage {
    struct Message xy_Msg;
    WORD           xy_X;
    WORD           xy_Y;
};

void main(int argc, char **argv)
{
    struct MsgPort *xyreplyport;
    struct XYMessage *xymsg, *reply;
                                                           /* Using CreatePort() with no name       */
    if (xyreplyport = CreatePort(0,0))                     /* because this port need not be public. */
    {
        if (xymsg = (struct XYMessage *) AllocMem(sizeof(struct XYMessage), MEMF_PUBLIC | MEMF_CLEAR))
        {
            xymsg->xy_Msg.mn_Node.ln_Type = NT_MESSAGE;                /* make up a message,        */
            xymsg->xy_Msg.mn_Length = sizeof(struct XYMessage);        /* including the reply port. */
            xymsg->xy_Msg.mn_ReplyPort = xyreplyport;
            xymsg->xy_X = 10;                                   /* our special message information. */
            xymsg->xy_Y = 20;

            printf("Sending to port1: x = %d y = %d\n", xymsg->xy_X, xymsg->xy_Y);
                                                                   /* port2 will simply try to put  */

            if (SafePutToPort((struct Message *)xymsg, "xyport"))  /* one message to port1 wait for */
            {                                                      /*  the reply, and then exit     */
                WaitPort(xyreplyport);
                if (reply = (struct XYMessage *)GetMsg(xyreplyport))
                    printf("Reply contains: x = %d y = %d\n",         /* We don't ReplyMsg since   */
                            xymsg->xy_X, xymsg->xy_Y);                /* WE initiated the message. */

                      /* Since we only use this private port for receiving replies, and we sent     */
                      /* only one and got one reply there is no need to cleanup. For a public port, */
                      /* or if you pass a pointer to the port to another process, it is a very good */
                      /* habit to always handle all messages at the port before you delete it.      */
            }
            else printf("Can't find 'xyport'; start port1 in a separate shell\n");
            FreeMem(xymsg, sizeof(struct XYMessage));
        }
        else printf("Couldn't get memory\n");
        DeletePort(xyreplyport);
    }
    else printf("Couldn't create xyreplyport\n");
}


BOOL SafePutToPort(struct Message *message, STRPTR portname)
{
    struct MsgPort *port;

    Forbid();
    port = FindPort(portname);
    if (port) PutMsg(port, message);
    Permit();
    return(port ? TRUE : FALSE); /* FALSE if the port was not found */

         /* Once we've done a Permit(), the port might go away and leave us with an invalid port    */
}        /* address. So we return just a BOOL to indicate whether the message has been sent or not. */
