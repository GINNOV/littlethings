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
 *****************************************************************************
 *
 *
 *       EpsonX (EX/FX/JX/LX/MX/RX) driver.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/memory.h>
#include "devices/printer.h"
#include "devices/prtbase.h"

#define NUMSTARTCMD     7       /* # of cmd bytes before binary data */
#define NUMENDCMD       1       /* # of cmd bytes after binary data */
#define NUMTOTALCMD     (NUMSTARTCMD + NUMENDCMD)       /* total of above */
#define NUMLFCMD        4       /* # of cmd bytes for linefeed */
#define MAXCOLORBUFS    4       /* max # of color buffers */

#define STARTLEN        19
#define PITCH           1
#define CONDENSED       2
#define LMARG           8
#define RMARG           11
#define DIREC           15

static ULONG TwoBufSize;
static UWORD RowSize, ColorSize, NumColorBufs, dpi_code, spacing;
static UWORD colorcodes[MAXCOLORBUFS];

Render(ct, x, y, status)
long ct, x, y, status;
{
        extern void *AllocMem(), FreeMem();

        extern struct PrinterData *PD;
        extern struct PrinterExtendedData *PED;

        UBYTE *CompactBuf();
        static ULONG BufSize, TotalBufSize, dataoffset;
        static UWORD spacing, colors[MAXCOLORBUFS];
        /*
                00-01   \003P           set pitch (10 or 12 cpi)
                02-02   \022            set condensed fine (on or off)
                03-05   \033W\000       enlarge off
                06-08   \033ln          set left margin to n
                09-11   \033Qn          set right margin to n
                12-12   \015            carriage return
                13-15   \033U1          set uni-directional mode
                16-18   \033t\000       see kludge note below
                Kludge to get this to work on a CBM_MPS-1250  which interprets
                'ESCr' as go into reverse print mode.  The 'ESCt' tells it to
                get out of reverse print mode.  The 'NULL' is ignored by the
                CBM_MPS-1250 and required by all Epson printers as the
                terminator for the 'ESCtNULL' command which means select
                normal char set (which has no effect).
        */

        static UBYTE StartBuf[STARTLEN+1] =
                "\033P\022\033W\000\033ln\033Qn\015\033U1\033t\000";

        UBYTE *ptr, *ptrstart;
        int err;

        switch(status) {
                case 0 : /* Master Initialization */
                        /*
                                ct      - pointer to IODRPReq structure.
                                x       - width of printed picture in pixels.
                                y       - height of printed picture in pixels.
                        */
                        RowSize = x;
                        ColorSize = RowSize + NUMTOTALCMD;
                        if (PD->pd_Preferences.PrintShade == SHADE_COLOR) {
                                NumColorBufs = MAXCOLORBUFS;
                                colors[0] = ColorSize * 3; /* Black */
                                colors[1] = ColorSize * 0; /* Yellow */
                                colors[2] = ColorSize * 1; /* Magenta */
                                colors[3] = ColorSize * 2; /* Cyan */
                                colorcodes[0] = 4; /* Yellow */
                                colorcodes[1] = 1; /* Magenta */
                                colorcodes[2] = 2; /* Cyan */
                                colorcodes[3] = 0; /* Black */
                        }
                        else { /* grey-scale or black&white */
                                NumColorBufs = 1;
                                colors[0] = ColorSize * 0; /* Black */
                                colorcodes[0] = 0; /* Black */
                        }
                        BufSize = ColorSize * NumColorBufs + NUMLFCMD;
                        if (PED->ped_YDotsInch == 216) {
                                TwoBufSize = BufSize * 3;
                                TotalBufSize = BufSize * 6;
                        }
                        else if (PED->ped_YDotsInch == 144) {
                                TwoBufSize = BufSize * 2;
                                TotalBufSize = BufSize * 4;
                        }
                        else {
                                TwoBufSize = BufSize * 1;
                                TotalBufSize = BufSize * 2;
                        }
                        PD->pd_PrintBuf = AllocMem(TotalBufSize, MEMF_PUBLIC);
                        if (PD->pd_PrintBuf == NULL) {
                                err = PDERR_BUFFERMEMORY;
                        }
                        else {
                                dataoffset = NUMSTARTCMD;
                                /*
                                        This printer prints graphics within its
                                        text margins.  This code makes sure the
                                        printer is in 10 cpi and then sets the
                                        left and right margins to their minimum
                                        and maximum values (respectively).  A
                                        carriage return is sent so that the
                                        print head is at the leftmost position
                                        as this printer starts printing from
                                        the print head's position.  The printer
                                        is put into unidirectional mode to
                                        reduce wavy vertical lines.
                                */
                                StartBuf[PITCH] = 'P'; /* 10 cpi */
                                StartBuf[CONDENSED] = '\022'; /* off */
                                /* left margin of 1 */
                                StartBuf[LMARG] = 0;
                                /* right margin of 80 or 136 */
                                StartBuf[RMARG] = PD->pd_Preferences.
                                        PaperSize == W_TRACTOR ? 136 : 80;
                                /* uni-directional mode */
                                StartBuf[DIREC] = '1';
                                err = (*(PD->pd_PWrite))(StartBuf, STARTLEN);
                        }
                        break;

                case 1 : /* Scale, Dither and Render */
                        /*
                                ct      - pointer to PrtInfo structure.
                                x       - 0.
                                y       - row # (0 to Height - 1).
                        */
                        Transfer(ct, y, &PD->pd_PrintBuf[dataoffset], colors,
                                BufSize);
                        err = PDERR_NOERR; /* all ok */
                        break;

                case 2 : /* Dump Buffer to Printer */
                        /*
                                ct      - 0.
                                x       - 0.
                                y       - # of rows sent (1 to NumRows).

                        */
                        /* white-space strip */
                        ptrstart = &PD->pd_PrintBuf[dataoffset - NUMSTARTCMD];
                        if (PED->ped_YDotsInch == 72) {
                                /* y range : 1 to 8 */
                                y = y * 3 - spacing;
                                ptr = CompactBuf(ptrstart + NUMSTARTCMD,
                                        ptrstart, y, 1);
                        }
                        else if (PED->ped_YDotsInch == 144) {
                                /* y range : 1 to 16 */
                                ptr = CompactBuf(ptrstart + NUMSTARTCMD,
                                        ptrstart, 2, 1);
                                if (y > 1) {
                                        ptr = CompactBuf(&PD->pd_PrintBuf[
                                                dataoffset + BufSize],
                                                ptr, y * 3 / 2 - 2, 0);
                                }
                        }
                        else if (PED->ped_YDotsInch == 216) {
                                /* y range : 1 to 24 */
                                ptr = CompactBuf(ptrstart + NUMSTARTCMD,
                                        ptrstart, 1, 1);
                                if (y > 1) {
                                        ptr = CompactBuf(&PD->pd_PrintBuf[
                                                dataoffset + BufSize],
                                                ptr, 1, 0);
                                }
                                if (y > 2) {
                                        ptr = CompactBuf(&PD->pd_PrintBuf[
                                                dataoffset + BufSize * 2],
                                                ptr, y - 2, 0);
                                }
                        }
                        err = (*(PD->pd_PWrite))(ptrstart, ptr - ptrstart);
                        if (err == PDERR_NOERR) {
                                dataoffset = (dataoffset == NUMSTARTCMD ?
                                        TwoBufSize : 0) + NUMSTARTCMD;
                        }
                        break;

                case 3 : /* Clear and Init Buffer */
                        /*
                                ct      - 0.
                                x       - 0.
                                y       - 0.
                        */
                        ClearAndInit(&PD->pd_PrintBuf[dataoffset]);
                        err = PDERR_NOERR;
                        break;

                case 4 : /* Close Down */
                        /*
                                ct      - error code.
                                x       - io_Special flag from IODRPReq.
                                y       - 0.
                        */
                        err = PDERR_NOERR; /* assume all ok */
                        /* if user did not cancel print */
                        if (ct != PDERR_CANCEL) {
                                /* restore preferences pitch and margins */
                                if (PD->pd_Preferences.PrintPitch == ELITE) {
                                        StartBuf[PITCH] = 'M'; /* 12 cpi */
                                }
                                else if (PD->pd_Preferences.PrintPitch == FINE) {
                                        StartBuf[CONDENSED] = '\017'; /* on */
                                }
                                StartBuf[LMARG] =
                                        PD->pd_Preferences.PrintLeftMargin - 1;
                                StartBuf[RMARG] =
                                        PD->pd_Preferences.PrintRightMargin;
                                StartBuf[DIREC] = '0'; /* bi-directional */
                                err = (*(PD->pd_PWrite))(StartBuf, STARTLEN);
                        }
                        (*(PD->pd_PBothReady))();
                        if (PD->pd_PrintBuf != NULL) {
                                FreeMem(PD->pd_PrintBuf, TotalBufSize);
                        }
                        break;

                case 5 :  /* Pre-Master Initialization */
                        /*
                                ct      - 0 or pointer to IODRPReq structure.
                                x       - io_Special flag from IODRPReq.
                                y       - 0.
                        */
                        /* kludge for sloppy tractor mechanism */
                        spacing = PD->pd_Preferences.PaperType == SINGLE ?
                                1 : 0;
                        dpi_code = SetDensity(x & SPECIAL_DENSITYMASK);
                        err = PDERR_NOERR;
                        break;
        }
        return(err);
}

UBYTE *CompactBuf(ptrstart, ptr2start, y, flag)
UBYTE *ptrstart, *ptr2start;
long y;
int flag; /* 0 - not first pass, !0 - first pass */
{
        static int x;
        UBYTE *ptr, *ptr2;
        long ct;
        int i;

        ptr2 = ptr2start; /* where to put the compacted data */
        if (flag) {
                x = 0; /* flag no transfer required yet */
        }
        for (ct=0; ct<NumColorBufs; ct++, ptrstart += ColorSize) {
                i = RowSize;
                ptr = ptrstart + i - 1;
                while (i > 0 && *ptr == 0) {
                        i--;
                        ptr--;
                }
                if (i != 0) { /* if data */
                        *(++ptr) = 13;                  /* <cr> */
                        ptr = ptrstart - NUMSTARTCMD;
                        *ptr++ = 27;
                        *ptr++ = 'r';
                        *ptr++ = colorcodes[ct];        /* color */
                        *ptr++ = 27;
                        *ptr++ = dpi_code;              /* density */
                        *ptr++ = i & 0xff;
                        *ptr++ = i >> 8;                /* size */
                        i += NUMTOTALCMD;
                        if (x != 0) { /* if must transfer data */
                                /* get src start */
                                ptr = ptrstart - NUMSTARTCMD;
                                do { /* transfer and update dest ptr */
                                        *ptr2++ = *ptr++;
                                } while (--i);
                        }
                        else { /* no transfer required */
                                ptr2 += i; /* update dest ptr */
                        }
                }
                if (i != RowSize + NUMTOTALCMD) { /* if compacted or 0 */
                        x = 1; /* flag that we need to transfer next time */
                }
        }
        *ptr2++ = 13; /* cr */
        *ptr2++ = 27;
        *ptr2++ = 'J';
        *ptr2++ = y; /* y/216 lf */
        return(ptr2);
}

ClearAndInit(ptr)
UBYTE *ptr;
{
        ULONG *lptr, i, j;

        /*
                Note : Since 'NUMTOTALCMD + NUMLFCMD' is > 3 bytes if is safe
                to do the following to speed things up.
        */
        i = TwoBufSize - NUMTOTALCMD - NUMLFCMD;
        j = (ULONG)ptr;
        if (!(j & 1)) { /* if on a word boundary, clear by longs */
                i = (i + 3) / 4;
                lptr = (ULONG *)ptr;
                do {
                        *lptr++ = 0;
                } while (--i);
        }
        else { /* clear by bytes */
                do {
                        *ptr++ = 0;
                } while (--i);
        }
        return(0);
}
