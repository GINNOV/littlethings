
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

/* CloseWindowSafely
**
** these functions close an Intuition window that shares a port with other
** Intuition windows.
**
** We are careful to set the UserPort to NULL before closing, and to free
** any messages that it might have been sent.
*/
#include "exec/types.h"
#include "exec/nodes.h"
#include "exec/lists.h"
#include "exec/ports.h"
#include "intuition/intuition.h"

/*
** function to remove and reply all IntuiMessages on a port that have been
** sent to a particular window (note that we don't rely on the ln_Succ pointer
** of a message after we have replied it)
*/
VOID StripIntuiMessages(struct MsgPort *mp, struct Window *win)
{
struct IntuiMessage *msg;
struct Node *succ;

msg = (struct IntuiMessage *)mp->mp_MsgList.lh_Head;

while (succ = msg->ExecMessage.mn_Node.ln_Succ)
        {
        if (msg->IDCMPWindow == win)
                {
                /* Intuition is about to free this message.
                ** Make sure that we have politely sent it back.
                */
                Remove(msg);

                ReplyMsg(msg);
                }
        msg = (struct IntuiMessage *)succ;
        }
}

/*
** Entry point to CloseWindowSafely()
** Strip all IntuiMessages from an IDCMP which are waiting for a specific
** window.  When the messages are gone, set the UserPort of the window to NULL
** and call ModifyIDCMP(win,0).  This will free the Intuition arts of the
** IDMCMP and trun off message to this port without changing the original
** UserPort (which may be in use by other windows).
*/
VOID CloseWindowSafely(struct Window *win)
{
/* we forbid here to keep out of race conditions with Intuition */
Forbid();

/* send back any messages for this window  that have not yet been processed */
StripIntuiMessages(win->UserPort, win);

/* clear UserPort so Intuition will not free it */
win->UserPort = NULL;

/* tell Intuition to stop sending more messages */
ModifyIDCMP(win, 0L);

/* turn multitasking back on */
Permit();

/* Now it's safe to really close the window */
CloseWindow(win);
}
