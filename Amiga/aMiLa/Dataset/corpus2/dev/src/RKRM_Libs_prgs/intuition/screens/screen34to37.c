;/* screen34to37.c - Execute me to compile me with SAS 5.10
LC -b1 -cfistq -v -y -j73 screen34to37.c
blink FROM LIB:c.o screen34to37.o TO screen34to37 LIB LIB:lc.lib LIB:amiga.lib
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


#define INTUI_V36_NAMES_ONLY         /* We'll use the newer Intuition names. */

#include <exec/types.h>              /* Amiga data types.              */
#include <intuition/intuition.h>     /* Lots of important Intuition    */
#include <intuition/screens.h>       /* structures we will be using.   */

#include <clib/exec_protos.h>        /* Function prototypes            */
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>

#ifdef LATTICE
int CXBRK(void)    { return(0); }    /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }    /* really */
#endif

struct Library *IntuitionBase;       /* Intuition library base          */

/* Simple example to show how to open a custom screen that gives the new look
 * under V37, yet still works with older version of the operating system.
 * Attach the tag SA_Pens and a minimal pen specification to ExtNewScreen,
 * and call the old OpenScreen() function.  The tags will be ignored by
 * V34 and earlier versions of the OS.  In V36 and later the tags are
 * accepted by Intuition.
*/

VOID main(int argc, char **argv)
{
UWORD pens[] = { ~0 };               /* This is the minimal pen specification*/
struct Screen      *my_screen;       /* Pointer to our new, custom screen    */
struct ExtNewScreen myscreen_setup;  /* Same as NewScreen with tags attached */
struct TagItem      myscreen_tags[2];/* A small tag array                    */

/* Open the library before you call any functions */
IntuitionBase = OpenLibrary("intuition.library",0);
if (NULL != IntuitionBase)
   {
      /* Fill in the tag list with the minimal pen specification */
      myscreen_tags[0].ti_Tag=SA_Pens;
      myscreen_tags[0].ti_Data=(ULONG) pens;
      myscreen_tags[1].ti_Tag=TAG_DONE;

      /* The screen is opened two bitplanes deep so that the
      ** new look will show-up better.
      **/
      myscreen_setup.LeftEdge=0;
      myscreen_setup.TopEdge=0;
      myscreen_setup.Width=640;              /* Smaller values here reduce   */
      myscreen_setup.Height=STDSCREENHEIGHT; /* drawing area and save memory.*/
      myscreen_setup.Depth=2;                /* Two planes means 4 colors.   */
      myscreen_setup.DetailPen=0;            /* Normal V34 pen colors.       */
      myscreen_setup.BlockPen=1;
      myscreen_setup.ViewModes=HIRES;
      myscreen_setup.Type=CUSTOMSCREEN | NS_EXTENDED; /* Extended NewScreen flag */
      myscreen_setup.Font=NULL;
      myscreen_setup.DefaultTitle="My Screen";
      myscreen_setup.Gadgets=NULL;
      myscreen_setup.CustomBitMap=NULL;
      /* Attach the pen specification tags to the ExtNewScreen structure */
      myscreen_setup.Extension=myscreen_tags;

      if (NULL != (my_screen =
        OpenScreen((struct NewScreen *)&myscreen_setup)));
          {
          /* screen successfully opened */

          Delay(200L);  /* normally the program would be here */

          CloseScreen(my_screen);
          }
      CloseLibrary(IntuitionBase);
   }
}
