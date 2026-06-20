;/* PopShell.c - Simple hot key commodity compiled with SASC 5.10
LC -b0 -cfist -v -j73 popshell.c
Blink FROM LIB:c.o,popshell.o TO popshell LIBRARY LIB:LC.lib,LIB:Amiga.lib
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

#include <exec/libraries.h>
#include <libraries/commodities.h>
#include <dos/dos.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>
#include <clib/commodities_protos.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }
#endif


void main(int, char **);
void ProcessMsg(void);

#define EVT_HOTKEY 1L
struct Library *CxBase, *IconBase;
struct MsgPort *broker_mp;
CxObj *broker, *filter, *sender, *translate;

struct NewBroker newbroker =
{
    NB_VERSION,
    "RKM PopShell",           /* string to identify this broker */
    "A Simple PopShell",
    "A simple PopShell commodity",
    NBU_UNIQUE | NBU_NOTIFY,      /* Don't want any new commodities starting with this name. */
    0, 0, 0, 0                    /* If someone tries it, let me know */
};

UBYTE *newshell = "\rllehswen";  /* "newshell" spelled backwards */
struct InputEvent *ie;
ULONG cxsigflag;


void main(int argc, char **argv)
{
    UBYTE *hotkey, **ttypes;
    CxMsg *msg;

    if (CxBase = OpenLibrary("commodities.library", 37L))
    {
        if (IconBase = OpenLibrary("icon.library", 36L))
        {
            if (broker_mp = CreateMsgPort())
            {
                newbroker.nb_Port = broker_mp;
                cxsigflag = 1L << broker_mp->mp_SigBit;
                ttypes = ArgArrayInit(argc, argv);
                newbroker.nb_Pri = (BYTE)ArgInt(ttypes, "CX_PRIORITY", 0);
                hotkey = ArgString(ttypes, "HOTKEY", "rawkey control esc");

                if (broker = CxBroker(&newbroker, NULL))
                {
                    /* HotKey() is an amiga.lib function that creates a filter, sender */
                    /* and translate CxObject and connects them to report a hot key    */
                    /* press and delete its input event. */
                    if (filter = HotKey(hotkey, broker_mp, EVT_HOTKEY))
                    {
                        AttachCxObj(broker, filter); /* Add a CxObject to another's personal list */

                        if (! CxObjError(filter))
                        {
                            /* InvertString() is an amiga.lib function that creates a linked */
                            /* list of input events which would translate into the string    */
                            /* passed to it.  Note that it puts the input events in the      */
                            /* opposite order in which the corresponding letters appear in   */
                            /* the string.  A translate CxObject expects them backwards.     */
                            if (ie = InvertString(newshell, NULL))
                            {
                                ActivateCxObj(broker, 1L);
                                ProcessMsg();
                                /* we have to release the memory allocated by InvertString.       */
                                FreeIEvents(ie);
                            }
                        }
                    }
                    /* DeleteCxObjAll() is a commodities.library function that not only      */
                    /* deletes the CxObject pointed to in its argument, but deletes all of   */
                    /* the CxObjects attached to it.                                         */
                    DeleteCxObjAll(broker);

                    /* Empty the port of all CxMsgs */
                    while(msg = (CxMsg *)GetMsg(broker_mp))
                        ReplyMsg((struct Message *)msg);
                }
                DeletePort(broker_mp);
            }
            ArgArrayDone();  /* this amiga.lib function cleans up after ArgArrayInit() */
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
    ULONG sigrcvd, msgid, msgtype;
    LONG returnvalue = 1L;

    while (returnvalue)
    {
        sigrcvd = Wait(SIGBREAKF_CTRL_C | cxsigflag);

        while(msg = (CxMsg *)GetMsg(broker_mp))
        {
            msgid = CxMsgID(msg);
            msgtype = CxMsgType(msg);
            ReplyMsg((struct Message *)msg);

            switch(msgtype)
            {
                case CXM_IEVENT:
                    printf("A CXM_EVENT, ");
                    switch(msgid)
                    {
                        case EVT_HOTKEY:
                            /* We got the message from the sender CxObject */
                            printf("You hit the HotKey.\n");
                            /* Add the string "newshell" to input * stream.  If a shell       */
                            /* gets it, it'll open a new shell.                               */
                            AddIEvents(ie);
                            break;
                        default:
                            printf("unknown.\n");
                            break;
                    }
                    break;
                case CXM_COMMAND:
                    printf("A command: ");
                    switch(msgid)
                    {
                        case CXCMD_DISABLE:
                            printf("CXCMD_DISABLE\n");
                            ActivateCxObj(broker, 0L);
                            break;
                        case CXCMD_ENABLE:
                            printf("CXCMD_ENABLE\n");
                            ActivateCxObj(broker, 1L);
                            break;
                        case CXCMD_KILL:
                            printf("CXCMD_KILL\n");
                            returnvalue = 0L;
                            break;
                        case CXCMD_UNIQUE:
                        /* Commodities Exchange can be told not only to refuse to launch a    */
                        /* commodity with a name already in use but also can notify the       */
                        /* already running commodity that it happened.  It does this by       */
                        /* sending a CXM_COMMAND with the ID set to CXMCMD_UNIQUE.  If the    */
                        /* user tries to run a windowless commodity that is already running,  */
                        /* the user wants the commodity to shut down.                         */
                            printf("CXCMD_UNIQUE\n");
                            returnvalue = 0L;
                            break;
                        default:
                            printf("Unknown msgid\n");
                            break;
                    }
                    break;
                default:
                    printf("Unknown msgtype\n");
                    break;
            }
        }

        if (sigrcvd & SIGBREAKF_CTRL_C)
        {
            returnvalue = 0L;
            printf("CTRL C signal break\n");
        }
    }
}
