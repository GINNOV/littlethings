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
 * Get_Disk_Unit_ID.c
 *
 * Example of getting the UnitID of a disk
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <resources/disk.h>

#include <clib/exec_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */

/* There is no amiga.lib stub for this function so a pragma is required
 * This is a pragma for SAS C
 * Your compiler may require a different format
 */
#pragma libcall DiskBase GetUnitID 1e 1
#endif

struct Library *DiskBase = NULL;

LONG GetUnitID(long);

void main(int argc, char **argv)
{
LONG ids= 0;
LONG type;

if (!(DiskBase= (struct Library *)OpenResource(DISKNAME)))
    printf("Cannot open %s\n,DISKNAME");
else
   {
    printf("Defined drive types are:\n");
    printf("  AMIGA  $00000000\n");
    printf("  5.25'' $55555555\n");
    printf("  AMIGA  $00000000 (high density)\n"); /* Commodore-only product */
    printf("  None   $FFFFFFFF\n\n");

    /* What are the UnitIDs? */
     for (ids = 0; ids < 4; ids++)
        {
         type = GetUnitID(ids);
         printf("The UnitID for unit %d is $%08lx\n",ids,type);
        }
   }
}
