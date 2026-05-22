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
 *       Density module for EpsonX driver.
 */

#include <exec/types.h>
#include "devices/printer.h"
#include "devices/prtbase.h"

SetDensity(density_code)
ULONG density_code;
{
        extern struct PrinterData *PD;
        extern struct PrinterExtendedData *PED;

        /* SPECIAL_DENSITY     0    1    2    3    4    5    6    7 */
        static int XDPI[8] = {120, 120, 120, 240, 120, 240, 240, 240};
        static int YDPI[8] = {72, 72, 144, 72, 216, 144, 216, 216};
        static char codes[8] = {'L', 'L', 'L', 'Z', 'L', 'Z', 'Z', 'Z'};

        PED->ped_MaxColumns =
                PD->pd_Preferences.PaperSize == W_TRACTOR ? 136 : 80;
        density_code /= SPECIAL_DENSITY1;
        /* default is 80 chars (8.0 in.), W_TRACTOR is 136 chars (13.6 in.) */
        PED->ped_MaxXDots =
                (XDPI[density_code] * PED->ped_MaxColumns) / 10;
        PED->ped_XDotsInch = XDPI[density_code];
        PED->ped_YDotsInch = YDPI[density_code];
        if ((PED->ped_YDotsInch = YDPI[density_code]) == 216) {
                PED->ped_NumRows = 24;
        }
        else if (PED->ped_YDotsInch == 144) {
                PED->ped_NumRows = 16;
        }
        else {
                PED->ped_NumRows = 8;
        }
        return((int)codes[density_code]);
}
