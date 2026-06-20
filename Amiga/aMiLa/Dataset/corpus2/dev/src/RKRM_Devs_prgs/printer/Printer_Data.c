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
 * Printer_Data.c
 *
 * Example getting driver specifics.
 *
 * Compiled with SAS C 5.10a. lc -cfist -v -L Printer_Data
 *
 * Run from CLI only.  Note: under 1.3, opening the printer 
 * device will cause an Enforcer hit.
 *
 */

#include <exec/types.h>
#include <exec/ports.h>
#include <devices/printer.h>
#include <devices/prtbase.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/alib_stdio_protos.h>

union printerIO
{
    struct IOStdReq    ios;
    struct IODRPReq    iodrp;
    struct IOPrtCmdReq iopc;
};

VOID main(VOID);

VOID main(VOID)
{
struct MsgPort  *PrinterMP;
union printerIO *PIO;
struct PrinterData *PD;
struct PrinterExtendedData *PED;

/* Create non-public messageport. Could use CreateMsgPort() for this, that's
 * V37 specific however.
 */
if (PrinterMP = (struct MsgPort *)CreatePort(0,0))
    {
    /* Allocate printerIO union */
    if (PIO = (union printerIO *)CreateExtIO(PrinterMP, sizeof(union printerIO)))
        {
        /* Open the printer.device */
        if (!(OpenDevice("printer.device",0,(struct IORequest *)PIO,0)))
            {

            /* Now that we've got the device opened, let's see what we've got.
             * First, get a pointer to the printer data.
             */
            PD = (struct PrinterData *)PIO->iodrp.io_Device;
            /* And a pointer to the extended data */
            PED = (struct PrinterExtendedData *)&PD->pd_SegmentData->ps_PED;

            /* See the <devices/prtbase.h> include file for more details on
             * the PrinterData and PrinterExtendedData structures.
             */
            printf("Printername: '%s', Version: %ld, Revision: %ld\n",
            PED->ped_PrinterName, PD->pd_SegmentData->ps_Version,
            PD->pd_SegmentData->ps_Revision);

            printf("PrinterClass: 0x%lx, ColorClass: 0x%lx\n",
            PED->ped_PrinterClass, PED->ped_ColorClass);

            printf("MaxColumns: %ld, NumCharSets: %ld, NumRows: %ld\n",
                PED->ped_MaxColumns, PED->ped_NumCharSets,PED->ped_NumRows);

            printf("MaxXDots: %ld, MaxYDots: %ld, XDotsInch: %ld, YDotsInch: %ld\n",
                PED->ped_MaxXDots, PED->ped_MaxYDots, PED->ped_XDotsInch, PED->ped_YDotsInch);

            CloseDevice((struct IORequest *)PIO);
            }
         else
             printf("Can't open printer.device\n");
        DeleteExtIO((struct IORequest *)PIO);
        }
    else
        printf("Can't CreateExtIO\n");
    DeletePort((struct MsgPort *)PrinterMP);
    }
}
