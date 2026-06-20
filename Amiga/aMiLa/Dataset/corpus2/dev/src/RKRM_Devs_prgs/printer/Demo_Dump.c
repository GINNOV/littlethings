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
 * Demo_Dump.c
 *
 * Simple example of dumping a rastport to the printer, changing
 * printer preferences programmatically and handling error codes.
 *
 * Compile with SAS C 5.10a. lc -cfist -v -L Demo_Dump
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/ports.h>
#include <devices/printer.h>
#include <devices/prtbase.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/displayinfo.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;

union printerIO
{
    struct IOStdReq    ios;
    struct IODRPReq    iodrp;
    struct IOPrtCmdReq iopc;
};

struct EasyStruct reqES =
{
    sizeof(struct EasyStruct), 0, "DemoDump",
    "%s",
    NULL,
};

/* Possible printer.device and I/O errors */
static UBYTE *ErrorText[] =
{
    "PDERR_NOERR",
    "PDERR_CANCEL",
    "PDERR_NOTGRAPHICS",
    "INVERTHAM",		/* OBSOLETE */
    "BADDIMENSION",
    "DIMENSIONOVFLOW",	/* OBSOLETE */
    "INTERNALMEMORY",
    "BUFFERMEMORY",
    /* IO_ERRs */
    "IOERR_OPENFAIL",
    "IOERR_ABORTED",
    "IOERR_NOCMD",
    "IOERR_BADLENGTH"
};

/* Requester Action text */
static UBYTE *ActionText[] =
{
    "OK|CANCEL",
    "Continue",
    "Abort",
};

#define OKCANCELTEXT 0
#define CONTINUETEXT 1
#define ABORTTEXT    2

VOID main(VOID);

VOID main(VOID)
{
struct MsgPort  *PrinterMP;
union printerIO *PIO;
struct PrinterData *PD;
struct PrinterExtendedData *PED;
struct Screen *pubscreen;
struct ViewPort *vp;
STRPTR textbuffer;
LONG modeID, i,j;
ULONG dcol[5], drow[5];
ULONG signal;

/* Fails silently if not V37 or greater. Nice thing to do would be to put up
 * a V33 requester of course.
 */

/* Set up once */
reqES.es_GadgetFormat = ActionText[CONTINUETEXT];

if (IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library", 37))
    {
    /* Using graphics.library to get the displaymodeID of the public screen,
     * which we'll pass to the printer.device.
     */
    if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 37))
        {
        if (textbuffer = (STRPTR)AllocMem(256, MEMF_CLEAR))
            {
            /* Create non-public messageport. Since we depend on V37 already, we'll
             * use the new Exec function.
             */
            if (PrinterMP = CreateMsgPort())
                {
                /* Allocate printerIO union */
                if (PIO = (union printerIO *)CreateExtIO(PrinterMP, sizeof(union printerIO)))
                    {
                    /* Open the printer.device */
                    if (!(OpenDevice("printer.device",0,(struct IORequest *)PIO,0)))
                        {
                        /* Yahoo, we've got it.
                         * We'll use the PrinterData structure to get to the the printer
                         * preferences later on. The PrinterExtendedData structure will
                         * reflect the changes we'll make to the preferences.
                         */

                        PD = (struct PrinterData *)PIO->iodrp.io_Device;
                        PED = (struct PrinterExtendedData *)&PD->pd_SegmentData->ps_PED;

                        /* We're all set. We'll grab the default public screen (normally
                         * Workbench) and see what happens when we dump it with different
                         * densities.
                         * Next we'll put up a nice requester for the user and ask if
                         * (s)he wants to actually do the dump.
                         */

                        if (pubscreen = LockPubScreen(NULL))
                            {
                            vp = &(pubscreen->ViewPort);
                            /* Use graphics.library/GetVPModeID() to get the ModeID of the screen. */
                            if ((modeID = GetVPModeID(vp)) != INVALID_ID)
                                {
                                /* Seems we got a valid ModeID for the default public screen (surprise).
                                 * Do some fake screen dumps with densities 1, 3, 5 and 7. Depending on
                                 * the driver, one or more may be the same.
                                 */

                                /* Fill in those parts of the IODRPRequest which won't change */
                                PIO->iodrp.io_Command = PRD_DUMPRPORT;
                                PIO->iodrp.io_RastPort = &(pubscreen->RastPort);
                                PIO->iodrp.io_ColorMap = vp->ColorMap;
                                PIO->iodrp.io_Modes = modeID;
                                PIO->iodrp.io_SrcX = pubscreen->LeftEdge;
                                PIO->iodrp.io_SrcY = pubscreen->TopEdge;
                                PIO->iodrp.io_SrcWidth = pubscreen->Width;
                                PIO->iodrp.io_SrcHeight = pubscreen->Height;

                                for (i = 1,j=0; i < 8; i+=2,j++)
                                    {
                                    /* On return these will contain the actual dump dimension */
                                    PIO->iodrp.io_DestCols = 0;
                                    PIO->iodrp.io_DestRows = 0;
                                    /* We'll simply change our local copy of the
                                     * Preferences structure. Likewise we could change
                                     * all printer-related preferences.
                                     */
                                    PD->pd_Preferences.PrintDensity = i;
                                    PIO->iodrp.io_Special = SPECIAL_NOPRINT|SPECIAL_ASPECT;

                                    /* No need to do asynchronous I/O here */
                                    DoIO((struct IORequest *)PIO);

                                    if (PIO->iodrp.io_Error == 0)
                                        {
                                        dcol[j] = PIO->iodrp.io_DestCols;
                                        drow[j] = PIO->iodrp.io_DestRows;
                                        }
                                    else
                                        {
                                        j = PIO->iodrp.io_Error;
                                        if (j < 0)
                                            j = j * -1 + 7;

                                        sprintf(textbuffer, "Error: %s\n", ErrorText[j]);
                                        reqES.es_GadgetFormat = ActionText[CONTINUETEXT];
                                        EasyRequest(NULL, &reqES, NULL, textbuffer);
                                        break;
                                        }
                                    }
                                /* Simple, lazy way to check if we encountered any problems */
                                if (i == 9)
                                    {
                                    /* Build an 'intelligent' requester */
                                    sprintf(textbuffer,
                                        "%s: %5ld x %5ld\n%s: %5ld x %5ld\n%s: %5ld x%5ld\n%s: %5ld x %5ld\n\n%s",
                                        "Density 1", dcol[0], drow[0],
                                        "Density 3", dcol[1], drow[1],
                                        "Density 5", dcol[2], drow[2],
                                        "Density 7", dcol[3], drow[3],
                                        "Print screen at highest density?");
                                    reqES.es_GadgetFormat = ActionText[OKCANCELTEXT];

                                    /* Obviously the choice presented to the user here is a very
                                     * simple one. To print or not to print. In a real life
                                     * application, a requester could be presented, inviting
                                     * the user to select density, aspect, dithering etc.
                                     * The fun part is, of course, that the user can, to a certain
                                     * degree, be informed about the effects of her/his selections.
                                     */
                                    if (EasyRequest(NULL, &reqES, NULL, textbuffer))
                                        {
                                        /* We've still got the density preference set to the highest
                                         * density, so no need to change that.
                                         * All we do here is re-initialize io_DestCols/Rows and remove
                                         * the SPECIAL_NOPRINT flag from io_Special.
                                         */
                                        PIO->iodrp.io_DestCols = 0;
                                        PIO->iodrp.io_DestRows = 0;
                                        PIO->iodrp.io_Special &= ~SPECIAL_NOPRINT;

                                        /* Always give the user a change to abort.
                                         * So we'll use SendIO(), instead of DoIO(), to be asynch and
                                         * catch a possible user request to abort printing. Normally,
                                         * the user would be presented with a nice, fat, ABORT requester.
                                         * However, since this example doesn't even open a window, and is
                                         * basically a 'GraphicDumpDefaultPubscreen' equivalent, we'll use
                                         * CTRL-C as the user-abort. Besides that, got to keep it short.
                                         */
                                        SendIO((struct IORequest *)PIO);

                                        /* Now Wait() for either a user signal (CTRL-C) or a signal from
                                         * the printer.device
                                         */
                                        signal = Wait(1 << PrinterMP->mp_SigBit | SIGBREAKF_CTRL_C);

                                        if (signal & SIGBREAKF_CTRL_C)
                                            {
                                            /* User wants to abort */
                                            AbortIO((struct IORequest *)PIO);
                                            WaitIO((struct IORequest *)PIO);
                                            }

                                        if (signal & (1 << PrinterMP->mp_SigBit))
                                            {
                                            /* printer is either ready or an error has occurred */
                                            /* Remove any messages */
                                            while(GetMsg(PrinterMP));
                                            }
                                         /* Check for errors (in this case we count user-abort as an error) */
                                        if (PIO->iodrp.io_Error != 0)
                                            {
                                            j = PIO->iodrp.io_Error;
                                            if (j < 0)
                                                j = j * -1 + 7;
                                            sprintf(textbuffer, "Error: %s\n", ErrorText[j]);
                                            reqES.es_GadgetFormat = ActionText[CONTINUETEXT];
                                            EasyRequest(NULL, &reqES, NULL, textbuffer);
                                            }

                                        } /* else user doesn't want to print */
                                    }
                                }
                            else
                                /* Say what? */
                                EasyRequest(NULL, &reqES, NULL, "Invalid ModeID\n");
                            UnlockPubScreen(NULL, pubscreen);
                            }
                        else
                            EasyRequest(NULL, &reqES, NULL, "Can't lock Public Screen\n");

                        CloseDevice((struct IORequest *)PIO);
                        }
                    else
                        EasyRequest(NULL, &reqES, NULL, "Can't open printer.device\n");

                    DeleteExtIO((struct IORequest *)PIO);
                    }
                else
                    EasyRequest(NULL, &reqES, NULL, "Can't create Extented I/O Request\n");
                DeleteMsgPort(PrinterMP);
                }
            else
                EasyRequest(NULL, &reqES, NULL, "Can't create Message port\n");
            /* else Out of memory? 256 BYTES? */
            FreeMem(textbuffer,256);
            }
        CloseLibrary(GfxBase);
        } /* else MAJOR confusion */
    CloseLibrary(IntuitionBase);
    }
}
