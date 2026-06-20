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
 * Read_Potinp.c
 *
 * An example of using the potgo.resource to read pins 9 and 5 of
 * port 1 (the non-mouse port).  This bypasses the gameport.device.
 * When the right or middle button on a mouse plugged into port 1 is pressed,
 * the read value will change.
 *
 * Use of port 0 (mouse) is unaffected.
 *
 * Compile with SAS 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <resources/potgo.h>
#include <hardware/custom.h>

#include <clib/exec_protos.h>
#include <clib/potgo_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) {return(0);}  /* Disable SAS Ctrl-C checking */
int chkabort(void) { return(0); }  /* really */
#endif

struct PotgoBase *PotgoBase;
ULONG potbits;
UWORD value;

#define UNLESS(x) if(!(x))
#define UNTIL(x)  while(!(x))

#define OUTRY 1L<<15
#define DATRY 1L<<14
#define OUTRX 1L<<13
#define DATRX 1L<<12

extern struct Custom far custom;

void main(int argc,char **argv)
{
UNLESS (PotgoBase=(struct PotgoBase *)OpenResource("potgo.resource"))
        return;


potbits=AllocPotBits(OUTRY|DATRY|OUTRX|DATRX);

/* Get the bits for the right and middle mouse buttons on the alternate mouse port. */

if (potbits != (OUTRY|DATRY|OUTRX|DATRX))
    {
    printf("Pot bits are already allocated! %lx\n",potbits);
    FreePotBits(potbits);
    return;
    }

/* Set all ones in the register (masked by potbits) */
WritePotgo(0xFFFFFFFFL,potbits);

printf("\nPlug a mouse into the second port.  This program will indicate when\n");
printf("the right or middle button (if the mouse is so equipped) is pressed.\n");
printf("Stop the program with Control-C. Press return now to begin.\n");

getchar();

UNTIL (SIGBREAKF_CTRL_C & SetSignal(0L,0L))
      /* until CTRL-C is pressed */
      {
      /* Read word at $DFF016 */
        value = custom.potinp;

      /* Show what was read (restricted to our allocated bits) */
      printf("POTINP = $%lx\n",value & potbits);
      }

FreePotBits(potbits);
}
