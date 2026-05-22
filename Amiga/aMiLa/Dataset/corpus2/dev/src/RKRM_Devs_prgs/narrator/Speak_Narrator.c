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
 * Speak_Narrator.c
 *
 * This example program sends a string of phonetic text to the narrator
 * device twice, changing some of the characteristics the second time.
 *
 * Compile with SAS C 5.10  lc -b1 -cfistq -v -y -L
 *
 * Requires Kickstart V37 or greater.
 */

#include <exec/types.h>
#include <exec/exec.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <devices/narrator.h>


#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>

#include <string.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }    /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); } /* really */
#endif

extern struct Library *SysBase;   /* Used to check the OS the version number */

void main(void)
{
struct  MsgPort     *VoiceMP;
struct  narrator_rb *VoiceIO;
UBYTE   *PhoneticText    = "DHIHS IHZ AHMIY5GAH SPIY5KIHNX.";
BYTE    audio_chan[4]   = {3, 5, 10, 12};

   /* Check the version number of the operating system */
if(SysBase->lib_Version>=36)
   {
      /* Create the message port */
   if (VoiceMP=CreateMsgPort())
      {
         /* Create the IORequest */
      if (VoiceIO = CreateIORequest(VoiceMP,sizeof(struct narrator_rb)))
         {
         /*   Set the NEWIORB bit in the flags field to use the new fields */
         VoiceIO->flags = NDF_NEWIORB;

            /* Open the narrator device */
         if (OpenDevice("narrator.device",0,(struct IORequest *)VoiceIO,0L))

            /* Inform user that it could not be opened */
            printf("Error: narrator.device did not open\n");

         else
            {
             /* Speak the string using the default parameters */
             VoiceIO->ch_masks = &audio_chan[0];
             VoiceIO->nm_masks = sizeof(audio_chan);
             VoiceIO->message.io_Command = CMD_WRITE;
             VoiceIO->message.io_Data = PhoneticText;
             VoiceIO->message.io_Length = strlen(PhoneticText);
             DoIO(VoiceIO);

             /* Now change some of the characteristics:
              *   Raise the first formant, lower the third formant,
              *	   and move 50% of the way towards AO.
              * and speak it again.
              */

            VoiceIO->A1adj = -32;		/* Shut off first formant  */
            VoiceIO->A3adj =  11;		/* Raise the third formant */
            VoiceIO->centralize = 50;		/* Move 50% of the way 	   */
            VoiceIO->centphon = "AO";		/* towards AO		   */
            DoIO(VoiceIO);

            /* Close the narrator device */
            CloseDevice((struct IORequest *)VoiceIO);
            }
         /* Delete the IORequest */
         DeleteIORequest(VoiceIO);
         }
      else
         /* Inform user that the IORequest could be created */
         printf("Error: Could not create IORequest\n");

      /* Delete the message port */
      DeleteMsgPort(VoiceMP);
      }
   else
      /* Inform user that the message port could not be created */
      printf("Error: Could not create message port\n");
   }
else
   printf("Error: Release 2 (V36) or a later version of the OS required.\n");
}
