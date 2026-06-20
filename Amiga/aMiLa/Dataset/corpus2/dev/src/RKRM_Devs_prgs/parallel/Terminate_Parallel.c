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
 ******************************************************************************
 *
 * Terminate_Parallel.c
 *
 * This is an example of using a termination array for writes from the parallel
 * device. A termination array is set up for the characters Q, E, A and %.  The
 * EOFMODE flag is set in io_ParFlags to indicate that we want to use a
 * termination array by sending the PDCMD_SETPARAMS command to the device.
 * Then, a CMD_WRITE command is sent to the device with io_Length set to -1.
 *
 * The write will terminate when one of the four characters in the
 * termination array is sent or when the end of the write buffer has been reached.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 *
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <devices/parallel.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>
#include <string.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

void main(void)
{
struct MsgPort  *ParallelMP;          /* Define storage for one pointer */
struct IOExtPar *ParallelIO;         /* Define storage for one pointer */

struct IOPArray Terminators =
{
0x51454125,   /* Q E A % */
0x25252525    /* fill to end with lowest value, must be in descending order */
};

UBYTE *WriteBuffer = "abcdefghijklmEopqrstuvwxyz";
UWORD ctr;

if (ParallelMP=CreatePort(0,0))
    {
    if (ParallelIO=(struct IOExtPar *)
                    CreateExtIO(ParallelMP,sizeof(struct IOExtPar)) )
        {
        if (OpenDevice(PARALLELNAME,0L,(struct IORequest *)ParallelIO,0) )
            printf("%s did not open\n",PARALLELNAME);
        else
            {
             /* Tell user what we are doing */
             printf("\fWriting until Q, E, A or % encountered in output\n");

             /* Set EOF mode flag
              * Set the termination array
              * Send PDCMD_SETPARAMS to the parallel device
              */
             ParallelIO->io_ParFlags |= PARF_EOFMODE;
             ParallelIO->io_PTermArray = Terminators;
             ParallelIO->IOPar.io_Command  = PDCMD_SETPARAMS;
             if (DoIO((struct IORequest *)ParallelIO))
                 printf("Set Params failed ");   /* Inform user of error */
             else
                 {
                 /* Send buffer */
                 ParallelIO->IOPar.io_Length   = -1;
                 ParallelIO->IOPar.io_Data     = WriteBuffer;
                 ParallelIO->IOPar.io_Command  = CMD_WRITE;
                 if (DoIO((struct IORequest *)ParallelIO))
                     printf("Error: Write failed\n");
                 else
                     {
                      printf("\nThe total buffer length was: %d.\n"
                             "The actual number of characters sent: %d\n",
                             strlen(WriteBuffer),ParallelIO->IOPar.io_Actual);

                      /* Display all characters sent */
                      printf("\nThese characters were sent:\n\t\t\tASCII\tHEX\n");
                      for (ctr=0;ctr<ParallelIO->IOPar.io_Actual;ctr++)
                           printf("\t\t\t%c\t%x\n",*WriteBuffer,*WriteBuffer++);
                      }
                 }

            CloseDevice((struct IORequest *)ParallelIO);
            }

        DeleteExtIO((struct IORequest *)ParallelIO);
        }
    else
        printf("Error: Could not create IORequest\n");

    DeletePort(ParallelMP);
    }
else
    printf("Error: Could not create message port\n");
}
