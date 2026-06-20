;/* appwindow.c - Compiled under SAS C 5.10 with:
lc -L -j73 appwindow.c
quit
*/

/* Requires Kickstart version 37 or later.  Works from the Shell (CLI) only */

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


#include <exec/types.h>          /* Need this for the Amiga variable types  */
#include <workbench/workbench.h> /* This has DiskObject and AppWindow       */
#include <workbench/startup.h>   /* This has WBStartup and WBArg structs    */
#include <exec/libraries.h>      /* Need this to check library versions     */

#include <stdio.h>

#include <clib/intuition_protos.h>
#include <clib/exec_protos.h>
#include <clib/wb_protos.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable SAS Lattice CTRL/C handling */
int chkabort(void) { return(0); }/* really */
#endif

struct Library      *IntuitionBase;
struct Library      *WorkbenchBase;

void main(int argc, char **argv)
{
  struct MsgPort *awport;
  struct Window  *win;
  struct AppWindow *appwin;
  struct IntuiMessage *imsg;
  struct AppMessage *amsg;
  struct WBArg   *argptr;

  ULONG           winsig, appwinsig, signals, id = 1, userdata = 0;
  BOOL            done = FALSE;
  int             i;

  if (IntuitionBase = OpenLibrary("intuition.library", 37))
    {
    if (WorkbenchBase = OpenLibrary("workbench.library", 37))
      {
      /* The CreateMsgPort() function is in Exec version 37 and later only */
      if (awport = CreateMsgPort())
         {
         if (win = OpenWindowTags(NULL,
                                  WA_Width, 200,        WA_Height, 50,
                                  WA_IDCMP, CLOSEWINDOW,
                                  WA_Flags, WINDOWCLOSE | WINDOWDRAG,
                                  WA_Title, "AppWindow",
                                  TAG_DONE))
          {
          if (appwin = AddAppWindow(id, userdata, win, awport, NULL))
            {
            printf("AppWindow added... Drag files into AppWindow\n");
            winsig    = 1L << win->UserPort->mp_SigBit;
            appwinsig = 1L << awport->mp_SigBit;

            while (! done)
              {
              /* Wait for IDCMP messages and AppMessages */
              signals = Wait( winsig | appwinsig );

              if(signals & winsig)      /* Got an IDCMP message */
                {
                while (imsg = (struct IntuiMessage *) GetMsg(win->UserPort))
                  {
                  if (imsg->Class = CLOSEWINDOW)   done = TRUE;
                  ReplyMsg((struct Message *) imsg);
                  }
                }
              if(signals & appwinsig)   /* Got an AppMessage */
                {
                while (amsg = (struct AppMessage *) GetMsg(awport))
                  {
                  printf("AppMsg: Type=%ld, ID=%ld, NumArgs=%ld\n",
                           amsg->am_Type, amsg->am_ID, amsg->am_NumArgs);
                  argptr = amsg->am_ArgList;
                  for (i = 0; i < amsg->am_NumArgs; i++)
                    {
                    printf("   arg(%ld): Name='%s', Lock=%lx\n",
                             i, argptr->wa_Name, argptr->wa_Lock);
                    argptr++;
                    }
                  ReplyMsg((struct Message *) amsg);
                  }
                }
              }     /* done */
            RemoveAppWindow(appwin);
            }
          CloseWindow(win);
          }
        /* Make sure there are no more outstanding messages */
        while(amsg = (struct AppMessage *)GetMsg(awport))
              ReplyMsg((struct Message *)amsg);
        DeleteMsgPort(awport);
        }
      CloseLibrary(WorkbenchBase);
      }
    CloseLibrary(IntuitionBase);
    }
}
