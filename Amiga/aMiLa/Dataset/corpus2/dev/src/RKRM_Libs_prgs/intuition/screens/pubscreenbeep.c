;/* pubscreenbeep.c - Execute me to compile me with SAS 5.10
LC -b1 -cfistq -v -y -j73 pubscreenbeep.c
blink LIB:c.o pubscreenbeep.o TO pubscreenbeep LIB LIB:lc.lib LIB:amiga.lib
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


#include <exec/types.h>               /* Amiga data types.               */
#include <exec/libraries.h>
#include <intuition/intuition.h>      /* Lots of important Intuition     */
#include <intuition/screens.h>        /* structures we will be using.    */

#include <clib/exec_protos.h>         /* Function prototypes             */
#include <clib/intuition_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }     /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }     /* really */
#endif

struct Library *IntuitionBase;        /* Intuition library base           */

/* Simple example of how to find a public screen to work with in Release 2.
 */

VOID main(int argc, char **argv)
{
struct Screen  *my_wbscreen_ptr;     /* Pointer to the Workbench screen */

/* Open the library before you call any functions */
IntuitionBase = OpenLibrary("intuition.library",0);
if (NULL != IntuitionBase)
   {
   if(IntuitionBase->lib_Version>=36)
      {
      /* OK, we have the right version of the OS so we can use
      ** the new public screen functions of Release 2 (V36)
      */
      if(NULL!=(my_wbscreen_ptr=LockPubScreen("Workbench")))
          {
          /* OK found the Workbench screen.                      */
          /* Normally the program would be here.  A window could */
          /* be opened or the attributes of the screen copied    */
          DisplayBeep(my_wbscreen_ptr);

          UnlockPubScreen(NULL,my_wbscreen_ptr);
          }
      }
   else
      {
      /* Prior to Release 2 (V36), there were no public screens,     */
      /* just Workbench.  In those older systems, windows can be     */
      /* opened on Workbench without locking or a pointer by setting */
      /* the Type=WBENCHSCREEN in struct NewWindow.  Attributes can  */
      /* be obtained by setting the Type argument to WBENCHSCREEN in */
      /* the call to GetScreenData().                                */
      }
   CloseLibrary(IntuitionBase);
   }
}
