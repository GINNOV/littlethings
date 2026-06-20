;/* fontreq.c - Execute me to compile me with Lattice 5.10
LC -b1 -cfistq -v -y -j73 fontreq.c
Blink FROM LIB:c.o,fontreq.o TO fontreq LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
#include <libraries/asl.h>

#include <clib/asl_protos.h>
#include <clib/exec_protos.h>

#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)     { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }     /* really */
#endif

UBYTE *vers = "$VER: fontreq 37.0";

struct Library *AslBase = NULL;

/* Our replacement strings for the "mode" cycle gadget.  The
** first string is the cycle gadget's label.  The other strings
** are the actual strings that will appear on the cycle gadget.
*/
UBYTE *modelist[] =
{
    "RKM Modes",
    "Mode 0",
    "Mode 1",
    "Mode 2",
    "Mode 3",
    "Mode 4",
    NULL
};


void main(int argc, char **argv)
{
    struct FontRequester *fr;

    if (AslBase = OpenLibrary("asl.library", 37L))
    {
        if (fr = (struct FontRequester *)
            AllocAslRequestTags(ASL_FontRequest,
                /* tell the requester to use my custom mode names */
                ASL_ModeList, modelist,

                /* Supply initial values for requester */
                ASL_FontName, (ULONG)"topaz.font",
                ASL_FontHeight, 11L,
                ASL_FontStyles, FSF_BOLD | FSF_ITALIC,
                ASL_FrontPen,  0x00L,
                ASL_BackPen,   0x01L,

                /* Only display font sizes between 8 and 14, inclusive. */
                ASL_MinHeight, 8L,
                ASL_MaxHeight, 14L,

                /* Give all the gadgetry, but only display fixed width fonts */
                ASL_FuncFlags, FONF_FRONTCOLOR | FONF_BACKCOLOR |
                    FONF_DRAWMODE | FONF_STYLES | FONF_FIXEDWIDTH,
                TAG_DONE))
        {
            /* Pop up the requester */
            if (AslRequest(fr, NULL))
            {
                /* The user selected something,  report their choice */
                printf("%s\n  YSize = %d  Style = 0x%x   Flags = 0x%x\n"
                       "  FPen = 0x%x   BPen = 0x%x   DrawMode = 0x%x\n",
                               fr->fo_Attr.ta_Name,
                               fr->fo_Attr.ta_YSize,
                               fr->fo_Attr.ta_Style,
                               fr->fo_Attr.ta_Flags,
                               fr->fo_FrontPen,
                               fr->fo_BackPen,
                               fr->fo_DrawMode);
            }
            else
                /* The user cancelled the requester, or some kind of error
                ** occurred preventing the requester from opening. */
                printf("Request Cancelled\n");
            FreeAslRequest(fr);
        }
        CloseLibrary(AslBase);
    }
}
