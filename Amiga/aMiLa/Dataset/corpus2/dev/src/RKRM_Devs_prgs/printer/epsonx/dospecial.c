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
 *       DoSpecial for EpsonX driver.
 */

#include "exec/types.h"
#include "devices/printer.h"
#include "devices/prtbase.h"

#define LMARG   3
#define RMARG   6
#define MARGLEN 8

#define CONDENSED       7
#define PITCH           9
#define QUALITY         17
#define LPI             24
#define INITLEN         26

DoSpecial(command, outputBuffer, vline, currentVMI, crlfFlag, Parms)
char outputBuffer[];
UWORD *command;
BYTE *vline;
BYTE *currentVMI;
BYTE *crlfFlag;
UBYTE Parms[];
{
        extern struct PrinterData *PD;

        int x = 0, y = 0;
        /*
                00-00   \375    wait
                01-03   \033lL  set left margin
                04-06   \033Qq  set right margin
                07-07   \375    wait
        */
        static char initMarg[MARGLEN+1] = "\375\033lL\033Qq\375";
        /*
                00-01   \0335           italics off
                02-04   \033-\000       underline off
                05-06   \033F           boldface off
                07-07   \022            cancel condensed mode
                08-09   \033P           select pica (10 cpi)
                10-12   \033W\000       enlarge off
                13-14   \033H           doublestrike off
                15-17   \033x\000       draft
                18-19   \033T           super/sub script off
                20-22   \033p0          proportional off
                23-24   \0332           6 lpi
                25-25   \015            carriage return
        */
        static char initThisPrinter[INITLEN+1] =
"\0335\033-\000\033F\022\033P\033W\000\033H\033x\000\033T\033p0\0332\015";
        static BYTE ISOcolorTable[10] = {0, 5, 6, 4, 3, 1, 2, 0};

        if (*command == aRIN) {
                while (x < INITLEN) {
                        outputBuffer[x] = initThisPrinter[x];
                        x++;
                }

                if (PD->pd_Preferences.PrintQuality == LETTER) {
                        outputBuffer[QUALITY] = 1;
                }

                *currentVMI = 36; /* assume 1/6 line spacing (36/216 => 1/6) */
                if (PD->pd_Preferences.PrintSpacing == EIGHT_LPI) {
                        outputBuffer[LPI] = '0';
                        *currentVMI = 27; /* 27/216 => 1/8 */
                }

                if (PD->pd_Preferences.PrintPitch == ELITE) {
                        outputBuffer[PITCH] = 'M';
                }
                else if (PD->pd_Preferences.PrintPitch == FINE) {
                        outputBuffer[CONDENSED] = '\017'; /* condensed */
                        outputBuffer[PITCH] = 'P'; /* pica condensed */
                }

                Parms[0] = PD->pd_Preferences.PrintLeftMargin;
                Parms[1] = PD->pd_Preferences.PrintRightMargin;
                *command = aSLRM;
        }

        if (*command == aCAM) { /* cancel margins */
                y = PD->pd_Preferences.PaperSize == W_TRACTOR ? 136 : 80;
                if (PD->pd_Preferences.PrintPitch == PICA) {
                        Parms[1] = (10 * y) / 10;
                }
                else if (PD->pd_Preferences.PrintPitch == ELITE) {
                        Parms[1] = (12 * y) / 10;
                }
                else { /* fine */
                        Parms[1] = (17 * y) / 10;
                }
                Parms[0] = 1;
                y = 0;
                *command = aSLRM;
        }

        if (*command == aSLRM) { /* set left and right margins */
                PD->pd_PWaitEnabled = 253;
                if (Parms[0] == 0) {
                        initMarg[LMARG] = 0;
                }
                else {
                        initMarg[LMARG] = Parms[0] - 1;
                }
                initMarg[RMARG] = Parms[1];
                while (y < MARGLEN) {
                        outputBuffer[x++] = initMarg[y++];
                }
                return(x);
        }

        if (*command == aPLU) {
                if (*vline == 0) {
                        *vline = 1;
                        *command = aSUS2;
                        return(0);
                }
                if (*vline < 0) {
                        *vline = 0;
                        *command = aSUS3;
                        return(0);
                }
                return(-1);
        }

        if (*command == aPLD) {
                if (*vline == 0) {
                        *vline = -1;
                        *command = aSUS4;
                        return(0);
                }
                if (*vline > 0) {
                        *vline = 0;
                        *command = aSUS1;
                        return(0);
                }
                return(-1);
        }

        if (*command == aSUS0) {
                *vline = 0;
        }
        if (*command == aSUS1) {
                *vline = 0;
        }
        if (*command == aSUS2) {
                *vline = 1;
        }
        if (*command == aSUS3) {
                *vline = 0;
        }
        if (*command == aSUS4) {
                *vline = -1;
        }

        if (*command == aVERP0) {
                *currentVMI = 27;
        }

        if (*command == aVERP1) {
                *currentVMI = 36;
        }

        if (*command == aIND) { /* lf */
                outputBuffer[x++] = '\033';
                outputBuffer[x++] = 'J';
                outputBuffer[x++] = *currentVMI;
                return(x);
        }

        if (*command == aRI) { /* reverse lf */
                outputBuffer[x++] = '\033';
                outputBuffer[x++] = 'j';
                outputBuffer[x++] = *currentVMI;
                return(x);
        }

        if (*command == aSFC) {
                if (Parms[0] == 39) {
                        Parms[0] = 30; /* set defaults */
                }
                if (Parms[0] > 37) {
                        return(0); /* ni or background color change */
                }
                outputBuffer[x++] = '\033';
                outputBuffer[x++] = 'r';
                outputBuffer[x++] = ISOcolorTable[Parms[0] - 30];
                /*
                Kludge to get this to work on a CBM_MPS-1250  which interprets
                'ESCr' as go into reverse print mode.  The 'ESCt' tells it to
                get out of reverse print mode.  The 'NULL' is ignored by the
                CBM_MPS-1250 and required by all Epson printers as the
                terminator for the 'ESCtNULL' command which means select
                normal char set (which has no effect).
                */
                outputBuffer[x++] = '\033';
                outputBuffer[x++] = 't';
                outputBuffer[x++] = 0;
                return(x);
        }

        if (*command == aRIS) {
                PD->pd_PWaitEnabled = 253;
        }

        return(0);
}
