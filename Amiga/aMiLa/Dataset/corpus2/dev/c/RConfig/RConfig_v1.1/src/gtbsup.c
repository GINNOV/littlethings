/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: gtbsup.c
 * Description: Support functions for use with GadToolsBox generated source
 * Comments: "Lifted" from GadToolsBox source :-)
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>

extern struct Gadget *IObject;
extern ULONG IClass;
extern UWORD Code;
extern UWORD Qualifier;

long ReadIMsg(struct Window *iwnd) {
    struct IntuiMessage *imsg;

    if (imsg = GT_GetIMsg(iwnd->UserPort)) {

        IClass    = imsg->Class;
        Qualifier = imsg->Qualifier;
        Code      = imsg->Code;
        IObject   = imsg->IAddress;

        GT_ReplyIMsg(imsg);

        return TRUE;
    }
    return FALSE;
}

void ClearMsgPort(struct MsgPort *mport) {
    struct IntuiMessage *msg;
    while (msg = GT_GetIMsg(mport)) GT_ReplyIMsg(msg);
}
