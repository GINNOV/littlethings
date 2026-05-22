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
 * Get_Filesys.c
 *
 * Example of examining the FileSysRes list
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <resources/filesysres.h>

#include <clib/exec_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct FileSysResource *FileSysResBase = NULL;

void main(int argc, char **argv)
{

struct FileSysEntry *fse;
int x;

/* NOTE - you should actually be in a Forbid while accessing any
 * system list for which no other method of arbitration is available.
 * However, for this example we will be printing the information
 * (which would break a Forbid anyway) so we won't Forbid.
 * In real life, you should Forbid, copy the information you need,
 * Permit, then print the info.
 */
if (!(FileSysResBase = (struct FileSysResource *)OpenResource(FSRNAME)))
    printf("Cannot open %s\n",FSRNAME);
else
    {
    for ( fse = (struct FileSysEntry *)FileSysResBase->fsr_FileSysEntries.lh_Head;
          fse->fse_Node.ln_Succ;
          fse = (struct FileSysEntry *)fse->fse_Node.ln_Succ)
         {
         /* An A3000 running V34 does not have the name field filled in. */
         /* An A2000 running V34 with an A590/2091 controller also does  */ 
         /* not have the name field filled in.                           */
         if(fse->fse_Node.ln_Name)
             printf("Found filesystem creator: %s\n",fse->fse_Node.ln_Name);

         printf("                 DosType: ");
         for (x=24; x>=8; x-=8)
              putchar((fse->fse_DosType >> x) & 0xFF);

         putchar((fse->fse_DosType & 0xFF) + 0x30);

         printf("\n                 Version: %d",(fse->fse_Version >> 16));
         printf(".%ld\n\n",(fse->fse_Version & 0xFFFF));
         }
     }
}
