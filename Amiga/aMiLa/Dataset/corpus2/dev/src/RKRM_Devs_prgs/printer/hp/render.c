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
 *        HP_LaserJet driver.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include <devices/prtbase.h>
#include <devices/printer.h>

#define NUMSTARTCMD     7       /* # of cmd bytes before binary data */
#define NUMENDCMD       0       /* # of cmd bytes after binary data */
#define NUMTOTALCMD (NUMSTARTCMD + NUMENDCMD)   /* total of above */

extern SetDensity();
/*
        00-04   \033&l0L        perf skip mode off
        05-11   \033*t075R      set raster graphics resolution (dpi)
        12-16   \033*r0A        start raster graphics
*/
char StartCmd[18] = "\033&l0L\033*t075R\033*r0A";

Render(ct, x, y, status)
long ct, x, y, status;
{
        extern void *AllocMem(), FreeMem();

        extern struct PrinterData *PD;
        extern struct PrinterExtendedData *PED;

        static UWORD RowSize, BufSize, TotalBufSize, dataoffset;
        static UWORD huns, tens, ones; /* used to program buffer size */
        UBYTE *ptr, *ptrstart;
        int i, err;

        err=PDERR_NOERR;
        switch(status) {
                case 0 : /* Master Initialization */
                        /*
                                ct      - pointer to IODRPReq structure.
                                x       - width of printed picture in pixels.
                                y       - height of printed picture in pixels.
                        */
                        RowSize = (x + 7) / 8;
                        BufSize = RowSize + NUMTOTALCMD;
                        TotalBufSize = BufSize * 2;
                        PD->pd_PrintBuf = AllocMem(TotalBufSize, MEMF_PUBLIC);
                        if (PD->pd_PrintBuf == NULL) {
                                err = PDERR_BUFFERMEMORY; /* no mem */
                        }
                        else {
                                ptr = PD->pd_PrintBuf;
                                *ptr++ = 27;
                                *ptr++ = '*';
                                *ptr++ = 'b';   /* transfer raster graphics */
                                *ptr++ = huns | '0';
                                *ptr++ = tens | '0';
                                *ptr++ = ones | '0';    /* printout width */
                                *ptr = 'W';             /* terminator */
                                ptr = &PD->pd_PrintBuf[BufSize];
                                *ptr++ = 27;
                                *ptr++ = '*';
                                *ptr++ = 'b';   /* transfer raster graphics */
                                *ptr++ = huns | '0';
                                *ptr++ = tens | '0';
                                *ptr++ = ones | '0';    /* printout width */
                                *ptr = 'W';             /* terminator */
                                dataoffset = NUMSTARTCMD;
                        /* perf skip mode off, set dpi, start raster gfx */
                                err = (*(PD->pd_PWrite))(StartCmd, 17);
                        }
                        break;

                case 1 : /* Scale, Dither and Render */
                        /*
                                ct      - pointer to PrtInfo structure.
                                x       - 0.
                                y       - row # (0 to Height - 1).
                        */
                        Transfer(ct, y, &PD->pd_PrintBuf[dataoffset]);
                        err = PDERR_NOERR; /* all ok */
                        break;

                case 2 : /* Dump Buffer to Printer */
                        /*
                                ct      - 0.
                                x       - 0.
                                y       - # of rows sent (1 to NumRows).

                                White-space strip.
                        */
                        i = RowSize;
                        ptrstart = &PD->pd_PrintBuf[dataoffset - NUMSTARTCMD];
                        ptr = ptrstart + NUMSTARTCMD + i - 1;
                        while (i > 0 && *ptr == 0) {
                                i--;
                                ptr--;
                        }
                        ptr = ptrstart + 3; /* get ptr to density info */
                        *ptr++ = (huns = i / 100) | '0';
                        *ptr++ = (i - huns * 100) / 10 | '0';
                        *ptr = i % 10 | '0'; /* set printout width */
                        err = (*(PD->pd_PWrite))(ptrstart, i + NUMTOTALCMD);
                        if (err == PDERR_NOERR) {
                                dataoffset = (dataoffset == NUMSTARTCMD ?
                                        BufSize : 0) + NUMSTARTCMD;
                        }
                        break;

                case 3 : /* Clear and Init Buffer */
                        /*
                                ct      - 0.
                                x       - 0.
                                y       - 0.
                        */
                        ptr = &PD->pd_PrintBuf[dataoffset];
                        i = RowSize;
                        do {
                                *ptr++ = 0;
                        } while (--i);
                        break;

                case 4 : /* Close Down */
                        /*
                                ct      - error code.
                                x       - io_Special flag from IODRPReq struct
                                y       - 0.
                        */
                        err = PDERR_NOERR; /* assume all ok */
                        /* if user did not cancel the print */
                        if (ct != PDERR_CANCEL) {
                                /* end raster graphics, perf skip mode on */
                                if ((err = (*(PD->pd_PWrite))
                                        ("\033*rB\033&l1L", 9)) == PDERR_NOERR) {
                                        /* if want to unload paper */
                                        if (!(x & SPECIAL_NOFORMFEED)) {
                                                /* eject paper */
                                                err = (*(PD->pd_PWrite))
                                                        ("\014", 1);
                                        }
                                }
                        }
                        /*
                                flag that there is no alpha data waiting that
                                needs a formfeed (since we just did one)
                        */
                        PED->ped_PrintMode = 0;
                         /* wait for both buffers to empty */
                        (*(PD->pd_PBothReady))();
                        if (PD->pd_PrintBuf != NULL) {
                                FreeMem(PD->pd_PrintBuf, TotalBufSize);
                        }
                        break;

                case 5 : /* Pre-Master Initialization */
                        /*
                                ct      - 0 or pointer to IODRPReq structure.
                                x       - io_Special flag from IODRPReq struct
                                y       - 0.
                        */
                        /* select density */
                        SetDensity(x & SPECIAL_DENSITYMASK);
                        break;
        }
        return(err);
}
