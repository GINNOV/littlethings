;/* tag1.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfis -j73 tag1.c
Blink FROM LIB:c.o,tag1.o TO tag1 LIBRARY LIB:LC.lib,LIB:Amiga.lib
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

#include <exec/types.h>
#include <exec/libraries.h>
#include <utility/tagitem.h>
#include <intuition/intuition.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/utility_protos.h>

extern struct Library *SysBase;
struct Library *IntuitionBase, *UtilityBase;

int main (int argc, char **argv)
{
    struct TagItem *tags;
    struct Window  *win;

    /* For this example we need Version 2.0 */
    if (IntuitionBase = OpenLibrary ("intuition.library", 37))
    {
        /* We need the utility library for this example */
        if (UtilityBase = OpenLibrary ("utility.library", 37))
        {

        /****************************************************************/
        /* This section allocates a tag array, fills it in with values, */
        /* and then uses it.                                            */
        /****************************************************************/

            /* Allocate a tag array */
            if (tags = AllocateTagItems (7))
            {
                /* Fill in our tag array */
                tags[0].ti_Tag = WA_Width;
                tags[0].ti_Data = 320;
                tags[1].ti_Tag = WA_Height;
                tags[1].ti_Data = 50;
                tags[2].ti_Tag = WA_Title;
                tags[2].ti_Data = (ULONG) "RKM Tag Example 1";
                tags[3].ti_Tag = WA_IDCMP;
                tags[3].ti_Data = IDCMP_CLOSEWINDOW;
                tags[4].ti_Tag = WA_CloseGadget;
                tags[4].ti_Data = TRUE;
                tags[5].ti_Tag = WA_DragBar;
                tags[5].ti_Data = TRUE;
                tags[6].ti_Tag = TAG_DONE;

                /* Open the window, using the tag attributes as the
                 * only description. */
                if (win = OpenWindowTagList (NULL, tags))
                {
                    /* Wait for an event to occur */
                    WaitPort (win->UserPort);

                    /* Close the window now that we're done with it */
                    CloseWindow (win);
                }

                /* Free the tag list now that we're done with it */
                FreeTagItems(tags);
            }

        /****************************************************************/
        /* This section builds the tag array on the stack, and passes   */
        /* the array to a function.                                     */
        /****************************************************************/

            /* Now use the VarArgs (or stack based) version. */
            if (win = OpenWindowTags ( NULL,
                                       WA_Width, 320,
                                       WA_Height, 50,
                                       WA_Title, (ULONG)"RKM Tag Example 1",
                                       WA_IDCMP, IDCMP_CLOSEWINDOW,
                                       WA_CloseGadget, TRUE,
                                       WA_DragBar, TRUE,
                                       TAG_DONE))
            {
                /* Wait for an event to occur */
                WaitPort (win->UserPort);

                /* Close the window now that we're done with it */
                CloseWindow (win);
            }

            /* Close the library now */
            CloseLibrary (UtilityBase);
        }

        /* Close the library now that we're done with it */
        CloseLibrary (IntuitionBase);
    }
}
