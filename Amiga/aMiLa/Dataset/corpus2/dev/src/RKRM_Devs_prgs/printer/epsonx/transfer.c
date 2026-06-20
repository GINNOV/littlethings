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
 *       C-language Transfer routine for EpsonX driver.
 */

#include <exec/types.h>
#include <devices/printer.h>
#include <devices/prtbase.h>
#include <devices/prtgfx.h>

Transfer(PInfo, y, ptr, colors, BufOffset)
struct PrtInfo *PInfo;
UWORD y;                /* row # */
UBYTE *ptr;             /* ptr to buffer */
UWORD *colors;          /* indexes to color buffers */
ULONG BufOffset;        /* used for interleaved printing */
{
        extern struct PrinterData *PD;
        extern struct PrinterExtendedData *PED;

        static UWORD bit_table[8] = {128, 64, 32, 16, 8, 4, 2, 1};
        union colorEntry *ColorInt;
        UBYTE *bptr, *yptr, *mptr, *cptr, Black, Yellow, Magenta, Cyan;
        UBYTE *dmatrix, dvalue, threshold;
        UWORD x, width, sx, *sxptr, color, bit, x3;

        /* printer non-specific, MUST DO FOR EVERY PRINTER */
        x = PInfo->pi_xpos;
        ColorInt = PInfo->pi_ColorInt;
        sxptr = PInfo->pi_ScaleX;
        width = PInfo->pi_width;

        /* printer specific */
        if (PED->ped_YDotsInch == 216)
        {
                BufOffset *= y % 3;
                y /= 3;
        }
        else if (PED->ped_YDotsInch == 144)
        {
                BufOffset *= y & 1;
                y /= 2;
        }
        else
        {
                BufOffset = 0;
        }
        bit = bit_table[y & 7];
        bptr = ptr + colors[0] + BufOffset;
        yptr = ptr + colors[1] + BufOffset;
        mptr = ptr + colors[2] + BufOffset;
        cptr = ptr + colors[3] + BufOffset;

        /* pre-compute threshold; are we thresholding? */
        if (threshold = PInfo->pi_threshold)
        { /* thresholding */
                dvalue = threshold ^ 15;
                bptr += x;
                do { /* for all source pixels */
                        /* pre-compute intensity values for Black component */
                        Black = ColorInt->colorByte[PCMBLACK];
                        ColorInt++;

                        sx = *sxptr++;

                        do { /* use this pixel 'sx' times */
                                if (Black > dvalue)
                                {
                                        *bptr |= bit;
                                }
                                bptr++; /* done 1 more printer pixel */
                        } while (--sx);
                } while (--width);
        }
        else
        { /* not thresholding, pre-compute ptr to dither matrix */
                dmatrix = PInfo->pi_dmatrix + ((y & 3) << 2);
                if (PD->pd_Preferences.PrintShade == SHADE_GREYSCALE)
                {
                        do { /* for all source pixels */
                                /* pre-compute intensity values for Black */
                                Black = ColorInt->colorByte[PCMBLACK];
                                ColorInt++;

                                sx = *sxptr++;

                                do { /* use this pixel 'sx' times */
                                        if (Black > dmatrix[x & 3])
                                        {
                                                *(bptr + x) |= bit;
                                        }
                                        x++; /* done 1 more printer pixel */
                                } while (--sx);
                        } while (--width);
                }
                else
                { /* color */
                        do { /* for all source pixels */
                                /* compute intensity values for each color */
                                Black = ColorInt->colorByte[PCMBLACK];
                                Yellow = ColorInt->colorByte[PCMYELLOW];
                                Magenta = ColorInt->colorByte[PCMMAGENTA];
                                Cyan = ColorInt->colorByte[PCMCYAN];
                                ColorInt++;

                                sx = *sxptr++;

                                do { /* use this pixel 'sx' times */
                                        x3 = x >> 3;
                                        dvalue = dmatrix[x & 3];
                                        if (Black > dvalue)
                                        {
                                                *(bptr + x) |= bit;
                                        }
                                        else
                                        { /* black not rendered */
                                                if (Yellow > dvalue)
                                                {
                                                        *(yptr + x) |= bit;
                                                }
                                                if (Magenta > dvalue)
                                                {
                                                        *(mptr + x) |= bit;
                                                }
                                                if (Cyan > dvalue)
                                                {
                                                        *(cptr + x) |= bit;
                                                }
                                        }
                                        ++x; /* done 1 more printer pixel */
                                } while (--sx);
                        } while (--width);
                }
        }
}
