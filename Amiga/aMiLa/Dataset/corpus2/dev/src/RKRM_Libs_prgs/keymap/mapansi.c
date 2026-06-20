;/* mapansi.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 mapansi.c
Blink FROM LIB:c.o,mapansi.o TO mapansi LIBRARY LIB:LC.lib,LIB:Amiga.lib
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

/*
mapansi.c - converts a string to input events using MapANSI() function.

            This example will also take the created input events
            and add them to the input stream using the simple
            commodities.library function AddIEvents().  Alternately,
            you could open the input.device and use the input device
            command IND_WRITEEVENT to add events to the input stream.
*/

#include       <exec/types.h>
#include       <exec/memory.h>
#include       <exec/io.h>
#include       <dos/dos.h>
#include       <devices/input.h>
#include       <devices/inputevent.h>

#include       <clib/exec_protos.h>
#include       <clib/dos_protos.h>
#include       <clib/keymap_protos.h>
#include       <clib/commodities_protos.h>

#include       <stdio.h>
#include       <stdlib.h>

#ifdef LATTICE
int CXBRK(void)  { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }  /* really */
#endif

struct Library          *KeymapBase = NULL;       /* MapAnsi() function    */
struct Library          *CxBase = NULL;           /* AddIEvents() function */

struct InputEvent       *InputEvent = NULL;       /* we'll allocate this */

/* prototypes for our program functions */

void openall(void);
void closeall(void);
void closeout(UBYTE *errstring, LONG rc);


void main(int argc, char **argv)
{
    UBYTE               *string;
    UBYTE               *tmp1;
    UBYTE               *tmp2;
    UBYTE               iebuffer[6];            /* Space for two dead keys */
                                                /* + 1 key + qualifiers    */
    COUNT               i;
    LONG                rc = 0;


    openall();

    string = ";String converted to input events and sent to input device\n";

    InputEvent->ie_Class = IECLASS_RAWKEY;

    /* Turn each character into an InputEvent */
    tmp1 = string;

    while (*tmp1)
    {
        /* Convert one character, use default key map */
        i = MapANSI(tmp1, 1, iebuffer, 3, NULL);

        /* Make sure we start without deadkeys */
        InputEvent->ie_Prev1DownCode = InputEvent->ie_Prev1DownQual = 0;
        InputEvent->ie_Prev2DownCode = InputEvent->ie_Prev2DownQual = 0;

        tmp2 = iebuffer;

        switch (i)
        {
          case -2:
            printf("Internal error\n", NULL);
            rc = RETURN_FAIL;
            break;

          case -1:
            printf("Overflow\n", NULL);
            rc = RETURN_FAIL;
            break;

          case 0:
            printf("Can't generate code\n", NULL);
            break;

          case 3:
            InputEvent->ie_Prev2DownCode = *tmp2++;
            InputEvent->ie_Prev2DownQual = *tmp2++;
            /* FALL THROUGH */

          case 2:
            InputEvent->ie_Prev1DownCode = *tmp2++;
            InputEvent->ie_Prev1DownQual = *tmp2++;
            /* FALL THROUGH */

          case 1:
            InputEvent->ie_Code = *tmp2++;
            InputEvent->ie_Qualifier = *tmp2;
            break;
        }

        if (rc == RETURN_OK)
        {
            /* Send the key down event */
            AddIEvents(InputEvent);

            /* Create a key up event */
            InputEvent->ie_Code |= IECODE_UP_PREFIX;

            /* Send the key up event */
            AddIEvents(InputEvent);
         }

        if (rc != RETURN_OK)
            break;

        tmp1++;
    }

    closeall();
    exit(rc);
}


void openall(void)
{
    KeymapBase = OpenLibrary("keymap.library", 37);
    if (KeymapBase == NULL)  closeout("Kickstart 2.0 required", RETURN_FAIL);

    CxBase = OpenLibrary("commodities.library", 37);
    if (CxBase == NULL)  closeout("Kickstart 2.0 required", RETURN_FAIL);

    InputEvent = AllocMem(sizeof(struct InputEvent), MEMF_CLEAR);
    if (InputEvent == NULL)  closeout("Can't allocate input event",RETURN_FAIL);
}


void closeall()
{
    if (InputEvent)    FreeMem(InputEvent, sizeof(struct InputEvent));
    if (CxBase)        CloseLibrary(CxBase);
    if (KeymapBase)    CloseLibrary(KeymapBase);
}


void closeout(UBYTE *errstring, LONG rc)
{
    if(*errstring)     printf("%s\n",errstring);
    closeall();
    exit(rc);
}
