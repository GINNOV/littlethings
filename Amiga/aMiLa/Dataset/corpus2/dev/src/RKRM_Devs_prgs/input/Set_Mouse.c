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
 * Set_Mouse.c
 *
 * This example sets the mouse at x=100 and y=200
 *
 * Compile with SAS C 5.10: LC -b1 -cfistq -v -y -L
 * Requires Kickstart 36 or greater.
 *
 * Run from CLI only
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <devices/input.h>
#include <devices/inputevent.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }  /* Disable SAS CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif

struct IntuitionBase *IntuitionBase;
extern struct Library *SysBase;

void main(void)
{
struct IOStdReq   *InputIO;           /* I/O request block */
struct MsgPort    *InputMP;           /* Message port */
struct InputEvent *FakeEvent;         /* InputEvent pointer */
struct IEPointerPixel *NeoPix;        /* New mouse position pointer */
struct Screen *PubScreen;             /* Screen pointer */

if(SysBase->lib_Version>=36)
   {
   if (InputMP = CreateMsgPort())
      {
      if (FakeEvent = AllocMem(sizeof(struct InputEvent),MEMF_PUBLIC))
         {
         if (NeoPix  = AllocMem(sizeof(struct IEPointerPixel),MEMF_PUBLIC))
            {
            if (InputIO = CreateIORequest(InputMP,sizeof(struct IOStdReq)))
               {
               if (!OpenDevice("input.device",NULL,
                              (struct IORequest *)InputIO,NULL))
                  {
                     /* Open Intuition library */
                  if (IntuitionBase = (struct IntuitionBase *)
                        OpenLibrary("intuition.library",36L))
                     {
                     /* Get pointer to screen and lock screen */
                     if (PubScreen = (struct Screen *)LockPubScreen(NULL))
                        {
                        /* Set up IEPointerPixel fields */
                        NeoPix->iepp_Screen =(struct Screen *)PubScreen; /* WB screen */
                        NeoPix->iepp_Position.X = 100;  /* put pointer at x = 100 */
                        NeoPix->iepp_Position.Y = 200;  /* put pointer at y = 200 */

                        /* Set up InputEvent fields */
                        FakeEvent->ie_EventAddress = (APTR)NeoPix; /* IEPointerPixel */
                        FakeEvent->ie_NextEvent = NULL;
                        FakeEvent->ie_Class = IECLASS_NEWPOINTERPOS; /* new mouse pos */
                        FakeEvent->ie_SubClass = IESUBCLASS_PIXEL;   /* on pixel */
                        FakeEvent->ie_Code = IECODE_NOBUTTON;
                        FakeEvent->ie_Qualifier = NULL;   /* absolute positioning */

                        InputIO->io_Data = (APTR)FakeEvent;   /* InputEvent */
                        InputIO->io_Length = sizeof(struct InputEvent);
                        InputIO->io_Command = IND_WRITEEVENT;
                        DoIO((struct IORequest *)InputIO);

                        UnlockPubScreen(NULL,PubScreen);  /* Unlock screen */
                        }
                     else
                        printf("Could not get pointer to screen\n");

                     CloseLibrary(IntuitionBase);  /* Close intuition library */
                     }
                  else
                     printf("Error: Could not open V36 or higher intuition.library\n");

                  CloseDevice((struct IORequest *)InputIO);
                  }
               else
                  printf("Error: Could not open input.device\n");

               DeleteIORequest(InputIO);
               }
            else
               printf("Error: Could not create IORequest\n");

            FreeMem(NeoPix,sizeof(struct IEPointerPixel));
            }
         else
            printf("Error: Could not allocate memory for NeoPix\n");

         FreeMem(FakeEvent,sizeof(struct InputEvent));
         }
      else
         printf("Error: Could not allocate memory for FakeEvent\n");

      DeleteMsgPort(InputMP);
      }
   else
      printf("Error: Could not create message port\n");
   }
else
   printf("Error: Release2 (V36) or a later version of the OS is required\n");
}
