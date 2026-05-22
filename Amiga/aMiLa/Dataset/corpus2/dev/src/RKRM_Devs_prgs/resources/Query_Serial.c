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
 * Query_Serial.c
 *
 * We will try to open the serial device and if unsuccessful,
 * will return the name of the owner.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <resources/misc.h>
#include <devices/serial.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>

#include <stdio.h>
#include <stdlib.h>

#ifdef LATTICE
#include <clib/misc_protos.h>
#include <stdio.h>
int CXBRK(void) { return(0); }  /* Disable SAS CTRL-C handling */
void main(void);
#endif

#define UNIT_NUMBER 0

struct Library *MiscBase;

/* our functions */
void cleanexit(UBYTE *,LONG);
void cleanup(void);

struct MsgPort  *SerialMP;         /* Message port pointer */
struct IOExtSer *SerialIO;         /* IORequest pointer */

void main()
{
UWORD status;    /* return value of SDCMD_QUERY */
UBYTE *user;     /* name of serial port owner if not us */

if (SerialMP=CreatePort(NULL,NULL) )
    {
    if (SerialIO=(struct IOExtSer *)
           CreateExtIO(SerialMP,sizeof(struct IOExtSer)) )
        {
        if (OpenDevice(SERIALNAME,UNIT_NUMBER,(struct IORequest *)SerialIO,0))
            {
            printf("\n%s did not open",SERIALNAME);

            MiscBase= (struct Library *)OpenResource(MISCNAME);

            /* Find out who has the serial device */
            if ((user = AllocMiscResource(MR_SERIALPORT,"Us")) == NULL)
                {
                printf("\n");
                FreeMiscResource(MR_SERIALPORT);
                }
            else
                printf(" because %s owns it \n\n",user);

            /* Clean up */
            cleanup();
            }
        else
            {
            SerialIO->IOSer.io_Command  = SDCMD_QUERY;
            SendIO((struct IORequest *)SerialIO);             /* execute query */

            status = SerialIO->io_Status;                    /* store returned status */

            printf("\tThe serial port status is %x\n",status);

            AbortIO((struct IORequest *)SerialIO);
            WaitIO((struct IORequest *)SerialIO);

            CloseDevice((struct IORequest *)SerialIO);
            cleanup();
            }
        }
    else
         cleanexit("Can't create IORequest\n",RETURN_FAIL);
    }
else
    cleanexit("Can't create message port\n",RETURN_FAIL);
}


void cleanexit(UBYTE *s,LONG n)
{
if (*s)
    printf(s);
cleanup();
exit(n);
}

void cleanup()
{
if (SerialIO)
    DeleteExtIO(SerialIO);
if (SerialMP)
    DeletePort(SerialMP);
}
