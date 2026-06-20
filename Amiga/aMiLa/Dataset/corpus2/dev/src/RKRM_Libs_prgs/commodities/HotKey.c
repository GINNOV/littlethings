;/* HotKey.c - Simple hot key commodity compiled with SASC 5.10
LC -b0 -cfist -v -j73 hotkey.c
Blink FROM LIB:c.o,hotkey.o TO hotkey LIBRARY LIB:LC.lib,LIB:Amiga.lib
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

#define EVT_HOTKEY 1L

void main(int, char **);
void ProcessMsg(void);

struct Library *CxBase, *IconBase;
struct MsgPort *broker_mp;
CxObj *broker, *filter, *sender, *translate;

struct NewBroker newbroker = {
    NB_VERSION,
    "RKM HotKey",           /* string to identify this broker */
    "A Simple HotKey",
    "A simple hot key commodity",
    NBU_UNIQUE | NBU_NOTIFY,    /* Don't want any new commodities starting with this name. */
    0, 0, 0, 0                  /* If someone tries it, let me know */
};

ULONG cxsigflag;

void main(int argc, char **argv)
{
    UBYTE *hotkey, **ttypes;
    CxMsg *msg;

    if (CxBase = OpenLibrary("commodities.library", 37L))
    {
        /* open the icon.library for the support library */
        /* functions, ArgArrayInit() and ArgArrayDone()  */
        if (IconBase = OpenLibrary("icon.library", 36L))
        {
            if (broker_mp = CreateMsgPort())
            {
                newbroker.nb_Port = broker_mp;
                cxsigflag = 1L << broker_mp->mp_SigBit;

                /* ArgArrayInit() is a support library function (from the 2.0 version
                 * of amiga.lib) that makes it easy to read arguments from either a
                 * CLI or from Workbench's ToolTypes.  Because it uses icon.library,
                 * the library has to be open before calling this function.
                 * ArgArrayDone() cleans up after this function.
                 */
                ttypes = ArgArrayInit(argc, argv);

                /* ArgInt() (also from amiga.lib) searches through the array set up
                 * by ArgArrayInit() for a specific ToolType.  If it finds one, it
                 * returns the numeric value of the number that followed the
                 * ToolType (i.e., CX_PRIORITY=7). If it doesn't find the ToolType,
                 * it returns the default value (the third argument)
                 */
                newbroker.nb_Pri = (BYTE)ArgInt(ttypes, "CX_PRIORITY", 0);

                /* ArgString() works just like ArgInt(), except it returns a pointer to a string
                 * rather than an integer. In the example below, if there is no ToolType
                 * "HOTKEY", the function returns a pointer to "rawkey control esc".
                 */
                hotkey = ArgString(ttypes, "HOTKEY", "rawkey control esc");

                if (broker = CxBroker(&newbroker, NULL))
                {
                    /* CxFilter() is a macro that creates a filter CxObject.  This filter
                     * passes input events that match the string pointed to by hotkey.
                     */
                    if (filter = CxFilter(hotkey))
                    {
                        /* Add a CxObject to another's personal list */
                        AttachCxObj(broker, filter);

                        /* CxSender() creates a sender CxObject.  Every time a sender gets
                         * a CxMessage, it sends a new CxMessage to the port pointed to in
                         * the first argument. CxSender()'s second argument will be the ID
                         * of any CxMessages the sender sends to the port.  The data pointer
                         * associated with the CxMessage will point to a *COPY* of the
                         * InputEvent structure associated with the orginal CxMessage.
                         */
                        if (sender = CxSender(broker_mp, EVT_HOTKEY))
                        {
                            AttachCxObj(filter, sender);

                            /* CxTranslate() creates a translate CxObject. When a translate
                             * CxObject gets a CxMessage, it deletes the original CxMessage
                             * and adds a new input event to the input.device's input stream
                             * after the Commodities input handler. CxTranslate's argument
                             * points to an InputEvent structure from which to create the new
                             * input event.  In this example, the pointer is NULL, meaning no
                             * new event should be introduced, which causes any event that
                             * reaches this object to disappear from the input stream.
                             */
                            if (translate = (CxTranslate(NULL)))
                            {
                                AttachCxObj(filter, translate);

                                /* CxObjError() is a commodities.library function that returns
                                 * the internal accumulated error code of a CxObject.
                                 */
                                if (! CxObjError(filter))
                                {
                                    ActivateCxObj(broker, 1L);
                                    ProcessMsg();
                                }
                            }
                        }
                    }
                    /* DeleteCxObjAll() is a commodities.library function that not only
                     * deletes the CxObject pointed to in its argument, but it deletes
                     * all of the CxObjects that are attached to it.
                     */
                    DeleteCxObjAll(broker);

                    /* Empty the port of all CxMsgs */
                    while(msg = (CxMsg *)GetMsg(broker_mp))
                        ReplyMsg((struct Message *)msg);
                }
                DeletePort(broker_mp);
            }
            /* this amiga.lib function cleans up after ArgArrayInit() */
            ArgArrayDone();
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

    while(returnvalue)
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
                        case EVT_HOTKEY: /* We got the message from the sender CxObject */
                            printf("You hit the HotKey.\n");
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
                        /* Commodities Exchange can be told not only to refuse to launch a
                         * commodity with a name already in use but also can notify the
                         * already running commodity that it happened. It does this by
                         * sending a CXM_COMMAND with the ID set to CXMCMD_UNIQUE.  If the
                         * user tries to run a windowless commodity that is already running,
                         * the user wants the commodity to shut down. */
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
