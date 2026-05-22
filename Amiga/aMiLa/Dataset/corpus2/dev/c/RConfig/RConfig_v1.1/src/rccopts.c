/*
 * RConfig -- Replacement Library Configuration
 *   Copyright 1992 by Anthon Pang, Omni Communications Products
 *
 * Source File: rccopts.c
 * Description: CCOPTS Control
 * Comments: For use within RConfig only.
 */

#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/intuition_protos.h>
#include "rc2.h"

/*
 *  Global variables
 */
extern struct Gadget *IObject;
extern ULONG IClass;
extern UWORD Code;
extern UWORD Qualifier;
extern UWORD WaitPointerImage[];
extern struct EasyStruct myES;

extern long ReadIMsg(struct Window *iwnd);
extern void ClearMsgPort(struct MsgPort *mport);

int uservars = 0; /* initial value */
ULONG ccopts[10] = {
    TRUE, FALSE, TRUE, TRUE, TRUE,
    TRUE, FALSE, FALSE, TRUE, TRUE
};

void CCOPTS() {
    int notok;
    struct Requester waitRequest;
    int i;

    /*
     *  Block input to main window with invisible requester
     *  and change pointer to busy ptr image as visual cue
     */
    InitRequester(&waitRequest);
    if (Request(&waitRequest, RConfigWnd))
        SetPointer(RConfigWnd, WaitPointerImage, 16, 16, -6, 0);
    else {
        EasyRequest(NULL, &myES, NULL, "Unable to initialize requester.");
        return;
    }

    notok = OpenCCOPTSWindow();
    if (notok) {
        EasyRequest(NULL, &myES, NULL, "Unable to open window.");
        goto CCOPTSFail;
    }

    while (1) {
        WaitPort(CCOPTSWnd->UserPort);
        while(ReadIMsg(CCOPTSWnd)) {

            switch (IClass) {
              case IDCMP_REFRESHWINDOW:
                GT_BeginRefresh(CCOPTSWnd);
                CCOPTSRender(); /* re-draw texts and boxes */
                GT_EndRefresh(CCOPTSWnd, TRUE);
                break;

              case IDCMP_CLOSEWINDOW:
                goto CCOPTSQuit;
                break;

              case IDCMP_GADGETUP:
                switch (IObject->GadgetID) {
                  case GD_susr:
                    uservars = ~uservars;
                    break;
                    
                  case GD_Done:
                    goto CCOPTSQuit;
                    break;
                }
                break;
            }
        }
    }

CCOPTSQuit:
    ClearMsgPort(CCOPTSWnd->UserPort);

CCOPTSFail:
    for (i=0; i<= 9; i++) {
        ccopts[i] = CCOPTSGadgets[i]->Flags & GFLG_SELECTED;
    }

    CloseCCOPTSWindow();
    ClearPointer(RConfigWnd);
    EndRequest(&waitRequest, RConfigWnd);
}
