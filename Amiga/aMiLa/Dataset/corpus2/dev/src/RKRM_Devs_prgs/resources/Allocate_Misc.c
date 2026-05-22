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
 * Allocate_Misc.c
 *
 * Example of allocating a miscellaneous resource
 * We will allocate the serial resource and wait till
 * CTRL-C is pressed.  While we are waiting, the
 * query_serial program should be run.  It will try
 * to open the serial device and if unsuccessful, will
 * return the name of the owner.  It will be us!
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <resources/misc.h>

#include <clib/exec_protos.h>
#include <clib/misc_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library *MiscBase = NULL;

void main(int argc, char **argv)
{

UBYTE *owner = NULL;       /* owner of misc resource */

if (!(MiscBase= (struct Library *)OpenResource(MISCNAME)))
    printf("Cannot open %s\n",MISCNAME);
else
   {
    /* Allocate both pieces of the serial hardware */
    if ((owner = AllocMiscResource(MR_SERIALPORT,"Serial Port Hog")) == NULL)
        {
        if ((owner = AllocMiscResource(MR_SERIALBITS,"Serial Port Hog")) == NULL)
            {
            /* Wait for CTRL-C to be pressed */
            printf("\nWaiting for CTRL-C...\n");
            Wait(SIGBREAKF_CTRL_C);

            /* We're back */

            /* Deallocate the serial port register */
            FreeMiscResource(MR_SERIALBITS);
            }
        else
            printf("\nUnable to allocate MR_SERIALBITS because %s owns it\n",owner);

        /* Deallocate the serial port */
        FreeMiscResource(MR_SERIALPORT);
       }
    else
       printf("\nUnable to allocate MR_SERIALPORT because %s owns it\n",owner);
   }
}




