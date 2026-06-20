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
 * Read_BattClock.c
 *
 * Example of reading the BattClock and converting its output to
 * a useful measure of time by calling the Amiga2Date() utility function.
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <dos/dos.h>
#include <utility/date.h>
#include <resources/battclock.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/battclock_protos.h>
#include <clib/utility_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

VOID main(VOID);

struct Library *UtilityBase = NULL;
struct Library *BattClockBase;

VOID main(VOID)
{
UBYTE *Days[] ={"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
UBYTE *Months[] = {"January","February","March","April","May","June",
                   "July","August","September","October","November","December"};
UBYTE *ampm;
ULONG AmigaTime;

struct ClockData MyClock;

if (UtilityBase = (struct Library *)OpenLibrary("utility.library",33))
    {
    if (BattClockBase= OpenResource(BATTCLOCKNAME))
        {
        /* Get number of seconds till now */
        AmigaTime = ReadBattClock();

        /* Convert to a ClockData structure */
        Amiga2Date(AmigaTime,&MyClock);

        printf("\nRobin, tell everyone the BatDate and BatTime");

        /* Print the Date */
        printf("\n\nOkay Batman, the BatDate is ");
        printf("%s, %s %d, %d",Days[MyClock.wday],Months[MyClock.month-1],
                               MyClock.mday,MyClock.year);

        /* Convert military time to normal time and set AM/PM */
        if (MyClock.hour < 12)
            ampm = "AM";        /* hour less than 12, must be morning */
        else
            {
            ampm = "PM";         /* hour greater than 12,must be night */
            MyClock.hour -= 12;  /* subtract the extra 12 of military */
            };

        if (MyClock.hour == 0)
            MyClock.hour = 12;   /* don't forget the 12s */

        /* Print the time */
        printf("\n             the BatTime is ");
        printf("%d:%02d:%02d %s\n\n",MyClock.hour,MyClock.min,MyClock.sec,ampm);
        }
    else
       printf("Error: Unable to open the %s\n",BATTCLOCKNAME);

    /* Close the utility library */
    CloseLibrary(UtilityBase);
    }

else
    printf("Error: Unable to open utility.library\n");
}
