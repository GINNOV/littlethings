;/* appicon.c - Compiled under SAS C 5.10 with:
lc -L -j73 appicon.c
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
#include <workbench/workbench.h> /* This has DiskObject and AppIcon structs */
#include <workbench/startup.h>   /* This has WBStartup and WBArg structs    */
#include <exec/libraries.h>      /* Need this to check library versions     */

#include <clib/icon_protos.h>    /* Icon (DiskObject) function prototypes   */
#include <clib/exec_protos.h>    /* Exec message, port and library functions*/
#include <clib/wb_protos.h>      /* AppIcon function protos                 */

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable SAS Lattice CTRL/C handling */
int chkabort(void) { return(0); }/* really */
#endif

extern struct Library *SysBase;
struct Library *IconBase;
struct Library *WorkbenchBase;

void main(int argc, char **argv)
{
struct DiskObject   *dobj=NULL;
struct MsgPort    *myport=NULL;
struct AppIcon   *appicon=NULL;
struct AppMessage *appmsg=NULL;

LONG dropcount=0L;
ULONG x;
BOOL success=0L;

/* Get the the right version of the Icon Library, initialize IconBase */
if(IconBase = OpenLibrary("icon.library",37))
  {
  /* Get the the right version of the Workbench Library */
  if (WorkbenchBase=OpenLibrary("workbench.library",37))
    {
    /* This is the easy way to get some icon imagery */
    /* Real applications should use custom imagery   */
    dobj=GetDefDiskObject(WBDISK);
    if(dobj!=0)
      {
      /* The type must be set to NULL for a WBAPPICON */
      dobj->do_Type=NULL;

      /* The CreateMsgPort() function is in Exec version 37 and later only */
      myport=CreateMsgPort();
      if(myport)
        {
        /* Put the AppIcon up on the Workbench window */
        appicon=AddAppIconA(0L,0L,"TestAppIcon",myport,NULL,dobj,NULL);
        if(appicon)
          {
          /* For the sake of this example, we allow the AppIcon */
          /* to be activated only five times.                   */
          printf("Drop files on the Workbench AppIcon\n");
          printf("Example exits after 5 drops\n");

          while(dropcount<5)
            {
            /* Here's the main event loop where we wait for */
            /* messages to show up from the AppIcon         */
            WaitPort(myport);

            /* Might be more than one message at the port... */
            while(appmsg=(struct AppMessage *)GetMsg(myport))
              {
              if(appmsg->am_NumArgs==0L)
                {
                /* If NumArgs is 0 the AppIcon was activated directly */
                printf("User activated the AppIcon.\n");
                printf("A Help window for the user would be good here\n");
                }
              else if(appmsg->am_NumArgs>0L)
                {
                /* If NumArgs is >0 the AppIcon was activated by */
                /* having one or more icons dropped on top of it */
                printf("User dropped %ld icons on the AppIcon\n",
                                              appmsg->am_NumArgs);
                for(x=0;x<appmsg->am_NumArgs;x++)
                  {
                  printf("#%ld name='%s'\n",x+1,appmsg->am_ArgList[x].wa_Name);
                  }
                }
              /* Let Workbench know we're done with the message */
              ReplyMsg((struct Message *)appmsg);
              }
            dropcount++;
            }
          success=RemoveAppIcon(appicon);
          }
        /* Clear away any messages that arrived at the last moment */
        while(appmsg=(struct AppMessage *)GetMsg(myport))
            ReplyMsg((struct Message *)appmsg);
        DeleteMsgPort(myport);
        }
      FreeDiskObject(dobj);
      }
    CloseLibrary(WorkbenchBase);
    }
  CloseLibrary(IconBase);
  }
}
