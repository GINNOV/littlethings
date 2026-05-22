;/* divert.c - commodity to monitor user inactivity - compiled with SASC 5.10
LC -b0 -cfist -v -j73 divert.c
Blink FROM LIB:c.o,divert.o TO divert LIBRARY LIB:LC.lib,LIB:Amiga.lib NODEBUG SC SD
quit; */

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

#include <exec/libraries.h>
#include <libraries/commodities.h>
#include <dos/dos.h>
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>
#include <clib/commodities_protos.h>
#include <devices/inputevent.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif

#define TIMER_CLICKS 100

void main(int, char **);
void ProcessMsg(void);
void CxFunction(CxMsg *, CxObj *);

struct Library *CxBase, *IconBase;
struct MsgPort *broker_mp;
CxObj *broker, *cocustom, *cosignal;

struct NewBroker newbroker =
{
    NB_VERSION,
    "Divert",           /* string to identify this broker */
    "Divert",
    "show divert",
    NBU_UNIQUE | NBU_NOTIFY,  /* Don't want any new commodities starting with this name. */
    0, 0, 0, 0                /* If someone tries it, let me know                        */
};

struct Task *task;
ULONG cxsigflag, signal, cxobjsignal;

void main(int argc, char **argv)
{
    UBYTE **ttypes;
    CxMsg *msg;

    if (CxBase = OpenLibrary("commodities.library", 37L))
    {
        /* open the icon.library for support library functions, ArgArrayInit() and ArgArrayDone() */
        if (IconBase = OpenLibrary("icon.library", 36L))
        {
            if (broker_mp = CreateMsgPort())
            {
                newbroker.nb_Port = broker_mp;
                cxsigflag = 1L << broker_mp->mp_SigBit;

                /* ArgArrayInit() is a support library function (in the 2.0 version of amiga.lib) */
                /* that makes it easy to read arguments from either a CLI or from Workbench's     */
                /* ToolTypes. Because it uses icon.library, the library has to be open before     */
                /* before calling this function.  ArgArrayDone() cleans up after this function.   */
                ttypes = ArgArrayInit(argc, argv);

                /* ArgInt() (in amiga.lib) searches through the array set up by ArgArrayInit()    */
                /* for a specific ToolType.  If it finds one, it returns the numeric value of the */
                /* number that followed the ToolType (i.e., CX_PRIORITY=7).  If it  doesn't find  */
                /* the ToolType, it returns the default value (the third argument)                */
                newbroker.nb_Pri = (BYTE)ArgInt(ttypes, "CX_PRIORITY", 0);

                if (broker = CxBroker(&newbroker, NULL))
                {
                    /* CxCustom() takes two arguments, a pointer to the custom function           */
                    /* and an ID. Commodities Exchange will assign that ID to any CxMsg           */
                    /* passed to the custom  function.                                            */
                    if (cocustom = CxCustom(CxFunction, 0L))
                    {
                        AttachCxObj(broker, cocustom);

                        /* Allocate a signal bit for the signal CxObj */
                        if ( (signal = (ULONG)AllocSignal(-1L)) != -1)
                        {
                            /* set up the signal mask */
                            cxobjsignal = 1L << signal;
                            cxsigflag |= cxobjsignal;

                            /* CxSignal takes two arguments, a pointer to the task to signal      */
                            /* (normally the commodity) and the number of the signal bit the      */
                            /* commodity acquired to signal with.                                 */
                            task = FindTask(NULL);
                            if (cosignal = CxSignal(task, signal))
                            {
                                AttachCxObj(cocustom, cosignal);
                                ActivateCxObj(broker, 1L);
                                ProcessMsg();
                            }
                            FreeSignal(signal);
                        }
                    }
                    /* DeleteCxObjAll() is a commodities.library function that not only deletes   */
                    /* the CxObject pointed to in its argument, but it deletes all of the         */
                    /* CxObjects that are attached to it.                                         */
                    DeleteCxObjAll(broker);

                    /* Empty the port of all CxMsgs */
                    while(msg = (CxMsg *)GetMsg(broker_mp))
                        ReplyMsg((struct Message *)msg);
                }
                DeletePort(broker_mp);
            }
            ArgArrayDone();   /* this amiga.lib function cleans up after ArgArrayInit()           */
            CloseLibrary(IconBase);
        }
        CloseLibrary(CxBase);
    }
}

void ProcessMsg(void)
{
    extern struct MsgPort *broker_mp;
    extern CxObj *broker;
    extern ULONG cxsigflag;
    CxMsg *msg;
    ULONG sigrcvd, msgid;
    LONG returnvalue = 1L;

    while (returnvalue)
    {
        sigrcvd = Wait(SIGBREAKF_CTRL_C | cxsigflag);

        while(msg = (CxMsg *)GetMsg(broker_mp))
        {
            msgid = CxMsgID(msg);
            ReplyMsg((struct Message *)msg);

            switch(msgid)
            {
                case CXCMD_DISABLE:
                    ActivateCxObj(broker, 0L);
                    break;
                case CXCMD_ENABLE:
                    ActivateCxObj(broker, 1L);
                    break;
                case CXCMD_KILL:
                    returnvalue = 0L;
                    break;
                case CXCMD_UNIQUE:
                    returnvalue = 0L;
                    break;
            }
        }

        if (sigrcvd & SIGBREAKF_CTRL_C) returnvalue = 0L;

        /* Check to see if the signal CxObj signalled us. */
        if (sigrcvd & cxobjsignal) printf("Got Signal\n");
    }
}

/* The custom function for the custom CxObject.  Any code for a custom CxObj must be short        */
/* and sweet because it runs as part of the input.device task.                                    */
void CxFunction(register CxMsg *cxm, CxObj *co)
{
    struct InputEvent *ie;
    static ULONG time = 0L;

    /* Get the struct InputEvent associated with this CxMsg. Unlike the InputEvent                */
    /* extracted from a CxSender's CxMsg, this is a *REAL* input event, be careful with it.       */
    ie = (struct InputEvent *)CxMsgData(cxm);

    /* This custom function counts the number of timer events that go by while no other input     */
    /* events occur.  If it counts more than a certain amount of timer events, it clears the      */
    /* count and diverts the timer event CxMsg to the custom object's personal                    */
    /* list.  If an event besides a timer event passes by, the timer event count is reset.        */
    if (ie->ie_Class == IECLASS_TIMER)
    {
        time++;
        if (time >= TIMER_CLICKS)
        {
            time = 0L;
            DivertCxMsg(cxm, co, co);
        }
    }
    else
        time = 0L;
}
