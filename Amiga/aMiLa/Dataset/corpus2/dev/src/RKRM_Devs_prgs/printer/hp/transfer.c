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
 *      Example transfer routine for HP_LaserJet driver.
 *
 *      Transfer() should be written in assembly code for speed
 */

#include <exec/types.h>
#include <devices/prtgfx.h>

Transfer(PInfo, y, ptr)
struct PrtInfo *PInfo;
UWORD y;        /* row # */
UBYTE *ptr;     /* ptr to buffer */
{
        static UBYTE bit_table[] = {128, 64, 32, 16, 8, 4, 2, 1};
        UBYTE *dmatrix, Black, dvalue, threshold;
        union colorEntry *ColorInt;
        UWORD x, width, sx, *sxptr, bit;

        /* pre-compute */
        /* printer non-specific, MUST DO FOR EVERY PRINTER */
        x = PInfo->pi_xpos; /* get starting x position */
        ColorInt = PInfo->pi_ColorInt; /* get ptr to color intensities */
        sxptr = PInfo->pi_ScaleX;
        width = PInfo->pi_width; /* get # of source pixels */

        /* pre-compute threshold; are we thresholding? */
        if (threshold = PInfo->pi_threshold) { /* thresholding */
                dvalue = threshold ^ 15; /* yes, so pre-compute dither value */
                do { /* for all source pixels */
                        /* pre-compute intensity value for Black */
                        Black = ColorInt->colorByte[PCMBLACK];
                        ColorInt++; /* bump ptr for next time */

                        sx = *sxptr++;

                        /* dither and render pixel */
                        do { /* use this pixel 'sx' times */
                                /* if we should render Black */
                                if (Black > dvalue) {
                                        /* set bit */
                                        *(ptr + (x >> 3)) |= bit_table[x & 7];
                                }
                                ++x; /* done 1 more printer pixel */
                        } while (--sx);
                } while (--width);
        }
        else { /* not thresholding, pre-compute ptr to dither matrix */
                dmatrix = PInfo->pi_dmatrix + ((y & 3) << 2);
                do { /* for all source pixels */
                        /* pre-compute intensity value for Black */
                        Black = ColorInt->colorByte[PCMBLACK];
                        ColorInt++; /* bump ptr for next time */

                        sx = *sxptr++;

                        /* dither and render pixel */
                        do { /* use this pixel 'sx' times */
                                /* if we should render Black */
                                if (Black > dmatrix[x & 3]) {
                                        /* set bit */
                                        *(ptr + (x >> 3)) |= bit_table[x & 7];
                                }
                                ++x; /* done 1 more printer pixel */
                        } while (--sx);
                } while (--width);
        }
}
