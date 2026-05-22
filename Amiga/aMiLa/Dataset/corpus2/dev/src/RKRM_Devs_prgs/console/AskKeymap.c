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
 ***************************************************************************
 *
 * AskKeymap.c
 *
 * Example of using the CD_ASKKEYMAP command.
 *
 * Compile with SAS C 5.10
 *  lc -b1 -cfistq -v -y -L AskKeymap.c
 *
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/libraries.h>

#include <devices/console.h>
#include <devices/keymap.h>
#include <devices/conunit.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

extern struct Library *SysBase;


VOID main(VOID)
{
struct MsgPort *ConsoleMP;       /* pointer to our message port */
struct IOStdReq *ConsoleIO;      /* pointer to our IORequest */
struct KeyMap  *keymap;		 /* pointer to keymap */
int i,j;
UBYTE *prt;

    /* Release 2 (V36) or a later version of the OS is required */
if(SysBase->lib_Version>=36)
    {
        /* Create the message port */
    if (ConsoleMP=CreateMsgPort())
        {
            /* Create the IORequest */
        if (ConsoleIO = CreateIORequest(ConsoleMP,sizeof(struct IOStdReq)))
            {
                /* Open the Console device */
            if ( OpenDevice("console.device",CONU_LIBRARY,
                               (struct IORequest *)ConsoleIO,0L) )

                /* Inform user that it could not be opened */
                printf("Error: console.device did not open\n");
            else
                {
                   /* Allocate memory for the keymap */
	        if (keymap = (struct KeyMap *)AllocMem(sizeof(struct KeyMap),
                                                      MEMF_PUBLIC | MEMF_CLEAR))
                    {
               	    /* device opened, send query command to it */
           	    ConsoleIO->io_Length = sizeof(struct KeyMap);
                    /* where to put it */
	    	    ConsoleIO->io_Data = (APTR)keymap;
	    	    ConsoleIO->io_Command = CD_ASKKEYMAP;
            	    if (DoIO((struct IORequest *)ConsoleIO))

                        /* Inform user that Askkeymap failed */
                        printf("AskKeyMap failed. Error - %d\n",
                                  ConsoleIO->io_Error);
                    else
             	        {
                        /* print values for top row of keyboard */
                        prt = (UBYTE *)keymap->km_LoKeyMap;
                        printf("Result of CD_ASKKEYMAP for top row of keyboard\n\n");
                        printf("\tShift\n");
                        printf("\tAlt\tAlt\tShift\tNo Qualifier\n");
                        for(j=0;j<14;j++)
                            {
                            for (i=0;i<4;i++)
                                 printf("\t%c",*prt++);
                            printf("\n");
                            }
                        }

	            /* Deallocate the memory for the keymap */
	            FreeMem(keymap,sizeof(struct KeyMap));
	            }
                else
                    printf("Error: Could not allocate memory for keymap\n");

                /* Close the Console device */
                CloseDevice((struct IORequest *)ConsoleIO);
                }

            /* Delete the IORequest */
            DeleteIORequest(ConsoleIO);
            }
        else
            /* Inform user that the IORequest could be created */
            printf("Error: Could create IORequest\n");

        /* Delete the message port */
        DeleteMsgPort(ConsoleMP);
        }
    else
        /* Inform user that the message port could not be created */
        printf("Error: Could not create message port\n");
    }
else
    /* Inform user that this program reuqires Release 2 or later */
    printf("Error: Release 2 (V36) or a later version of the OS required\n");
}
