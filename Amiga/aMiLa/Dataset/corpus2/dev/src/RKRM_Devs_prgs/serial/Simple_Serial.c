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
 * Simple_Serial.c
 *
 * This is an example of using the serial device.
 * First, we will attempt to create a message port with CreateMsgPort()
 * Next, we will attempt to create the IORequest with CreateExtIO()
 * Then, we will attempt to open the serial device with OpenDevice()
 * If successful, we will write a null-terminated string to it
 * and reverse our steps.
 * If we encounter an error at any time, we will gracefully exit.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <devices/serial.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }/* really */
#endif

extern struct Library *SysBase; /* Used to check the version number of the OS */

VOID main(VOID)
{
struct MsgPort *SerialMP;       /* pointer to our message port */
struct IOExtSer *SerialIO;      /* pointer to our IORequest */

   /* The CreateMsgPort() call is available starting with V36 of the OS */
if(SysBase->lib_Version >= 36)
   {
      /* Create the message port */
   if (SerialMP=CreateMsgPort())
      {
         /* Create the IORequest */
      if (SerialIO = (struct IOExtSer *)
                  CreateExtIO(SerialMP,sizeof(struct IOExtSer)))
         {
            /* Open the serial device */
         if (OpenDevice(SERIALNAME,0,(struct IORequest *)SerialIO,0L))

            /* Inform user that it could not be opened */
            printf("Error: %s did not open\n",SERIALNAME);
         else
            {
            /* device opened, write null-terminated string */
            SerialIO->IOSer.io_Length   = -1;
            SerialIO->IOSer.io_Data    = (APTR)"Amiga ";
            SerialIO->IOSer.io_Command  = CMD_WRITE;
            if (DoIO((struct IORequest *)SerialIO))    /* execute write */
               printf("Write failed.  Error - %d\n",SerialIO->IOSer.io_Error);

            /* Close the serial device */
            CloseDevice((struct IORequest *)SerialIO);
            }
         /* Delete the IORequest */
         DeleteExtIO(SerialIO);
         }
      else
         /* Inform user that the IORequest could be created */
         printf("Error: Could create IORequest\n");

      /* Delete the message port */
      DeleteMsgPort(SerialMP);
      }
   else
      /* Inform user that the message port could not be created */
      printf("Error: Could not create message port\n");
   }
else
   printf("Error: Release 2 (V36) or a later version of the OS required.\n");
}
