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
 * Terminate_Serial.c
 *
 * This is an example of using a termination array for reads from the serial
 * device. A termination array is set up for the characters Q, E, etx (CTRL-D)
 * and eot (CTRL-C).  The EOFMODE flag is set in io_SerFlags to indicate that
 * we want to use a termination array by sending the SDCMD_SETPARAMS command to
 * the device.  Then, a CMD_READ command is sent to the device with
 * io_Length set to 25.
 *
 * The read will terminate whenever one of the four characters in the termination
 * array is received or when 25 characters have been received.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <devices/serial.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

void main(void)
{
struct MsgPort  *SerialMP;          /* Define storage for one pointer */
struct IOExtSer *SerialIO;         /* Define storage for one pointer */

struct IOTArray Terminators =
{
0x51450403,   /* Q E etx eot */
0x03030303    /* fill to end with lowest value */
};

#define READ_BUFFER_SIZE 25
UBYTE ReadBuff[READ_BUFFER_SIZE];
UWORD ctr;

if (SerialMP=CreatePort(0,0) )
    {
    if (SerialIO=(struct IOExtSer *) CreateExtIO(SerialMP,sizeof(struct IOExtSer)))
        {
        if (OpenDevice(SERIALNAME,0L,(struct IORequest *)SerialIO,0) )
            printf("%s did not open\n",SERIALNAME);
        else
            {
             /* Tell user what we are doing */
             printf("\fLooking for Q, E, EOT or ETX\n");

             /* Set EOF mode flag
              * Set the termination array
              * Send SDCMD_SETPARAMS to the serial device
              */
             SerialIO->io_SerFlags |= SERF_EOFMODE;
             SerialIO->io_TermArray = Terminators;
             SerialIO->IOSer.io_Command  = SDCMD_SETPARAMS;
             if (DoIO((struct IORequest *)SerialIO))
                 printf("Set Params failed ");   /* Inform user of error */
             else
                 {
                 SerialIO->IOSer.io_Length   = READ_BUFFER_SIZE;
                 SerialIO->IOSer.io_Data     = (APTR)&ReadBuff[0];
                 SerialIO->IOSer.io_Command  = CMD_READ;
                 if (DoIO((struct IORequest *)SerialIO))     /* Execute Read */
                     printf("Error: Read failed\n");
                 else
                     {
                      /* Display all characters received */
                      printf("\nThese characters were read:\n\t\t\tASCII\tHEX\n");
                      for (ctr=0;ctr<SerialIO->IOSer.io_Actual;ctr++)
                           printf("\t\t\t  %c\t%x\n",ReadBuff[ctr],ReadBuff[ctr]);
                      printf("\nThe actual number of characters read: %d\n",
                                  SerialIO->IOSer.io_Actual);
                      }
                 }
            CloseDevice((struct IORequest *)SerialIO);
            }

        DeleteExtIO((struct IORequest *)SerialIO);
        }
    else
        printf("Error: Could not create IORequest\n");

    DeletePort(SerialMP);
    }
else
    printf("Error: Could not create message port\n");
}

