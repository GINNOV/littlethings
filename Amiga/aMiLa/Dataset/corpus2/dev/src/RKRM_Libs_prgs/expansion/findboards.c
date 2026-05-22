;/* findboards.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 findboards.c
Blink FROM LIB:c.o,findboards.o TO findboards LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit
*/

/*
Copyright (c) 1992 Commodore-Amiga, Inc.

This example is provided in electronic form by Commodore-Amiga, Inc. for
use with the "Amiga ROM Kernel Reference Manual: Libraries", 3rd Edition,
published by Addison-Wesley (ISBN 0-201-56774-1).

The "Amiga ROM Kernel Reference Manual: Libraries" contains additional
information on the correct usage of the techniques and operating system
functions presented in these examples.  The source and executable code
of these examples may only be distributed in free electronic form, via
bulletin board or as part of a fully non-commercial and freely
redistributable diskette.  Both the source and executable code (including
comments) must be included, without modification, in any copy.  This
example may not be published in printed form or distributed with any
commercial product.  However, the programming techniques and support
routines set forth in these examples may be used in the development
of original executable software products for Commodore Amiga computers.

All other rights reserved.

This example is provided "as-is" and is subject to change; no
warranties are made.  All use is at your own risk. No liability or
responsibility is assumed.
*/

#include <exec/types.h>
#include <exec/memory.h>
#include <libraries/dos.h>
#include <libraries/configvars.h>

#include <clib/exec_protos.h>
#include <clib/expansion_protos.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct Library   *ExpansionBase = NULL;

void main(int argc, char **argv)
{
    struct ConfigDev *myCD;
    UWORD m,i;
    UBYTE p,f,t;

    if((ExpansionBase=OpenLibrary("expansion.library",0L))==NULL)
	exit(RETURN_FAIL);

    /*--------------------------------------------------*/
    /* FindConfigDev(oldConfigDev,manufacturer,product) */
    /* oldConfigDev = NULL for the top of the list      */
    /* manufacturer = -1 for any manufacturer           */
    /* product      = -1 for any product                */
    /*--------------------------------------------------*/

    myCD = NULL;
    while(myCD=FindConfigDev(myCD,-1L,-1L)) /* search for all ConfigDevs */
	{
	printf("\n---ConfigDev structure found at location $%lx---\n",myCD);

	/* These values were read directly from the board at expansion time */
	printf("Board ID (ExpansionRom) information:\n");

	t = myCD->cd_Rom.er_Type;
	m = myCD->cd_Rom.er_Manufacturer;
	p = myCD->cd_Rom.er_Product;
	f = myCD->cd_Rom.er_Flags;
	i = myCD->cd_Rom.er_InitDiagVec;

	printf("er_Manufacturer         =%d=$%04x=(~$%4x)\n",m,m,(UWORD)~m);
	printf("er_Product              =%d=$%02x=(~$%2x)\n",p,p,(UBYTE)~p);

	printf("er_Type                 =$%02x",myCD->cd_Rom.er_Type);
	if(myCD->cd_Rom.er_Type & ERTF_MEMLIST)
	    printf("  (Adds memory to free list)\n");
	else printf("\n");

	printf("er_Flags                =$%02x=(~$%2x)\n",f,(UBYTE)~f);
	printf("er_InitDiagVec          =$%04x=(~$%4x)\n",i,(UWORD)~i);


	/* These values are generated when the AUTOCONFIG(tm) software
	 * relocates the board
	 */
	printf("Configuration (ConfigDev) information:\n");
	printf("cd_BoardAddr            =$%lx\n",myCD->cd_BoardAddr);
	printf("cd_BoardSize            =$%lx (%ldK)\n",
	       myCD->cd_BoardSize,((ULONG)myCD->cd_BoardSize)/1024);

	printf("cd_Flags                =$%x",myCD->cd_Flags);
	if(myCD->cd_Flags & CDF_CONFIGME)
	    printf("\n");
	else printf("  (driver clears CONFIGME bit)\n");
	}
    CloseLibrary(ExpansionBase);
}
