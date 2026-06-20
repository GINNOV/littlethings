;/* filepat.c - Execute me to compile me with SASC 5.10
LC -b1 -cfistq -v -y -j73 filepat.c
Blink FROM LIB:c.o,filepat.o TO filepat LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/displayinfo.h>
#include <libraries/asl.h>
#include <workbench/startup.h>

#include <clib/asl_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)     { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }     /* really */
#endif

UBYTE *vers = "$VER: filepat 37.0";

struct Library *AslBase = NULL;
struct Library *IntuitionBase = NULL;
struct Screen *screen = NULL;
struct Window *window = NULL;

void main(int argc, char **argv)
{
    struct FileRequester *fr;
    struct WBArg *frargs;
    int x;

    if (AslBase = OpenLibrary("asl.library", 37L))
    {
        if (IntuitionBase = (struct IntuitionBase *)
                OpenLibrary("intuition.library", 37L))
        {
            if (screen = (struct Screen *)OpenScreenTags(NULL,
                    SA_DisplayID, HIRESLACE_KEY,
                    SA_Title, "ASL Test Screen",
                    TAG_END))
            {
                if (window = (struct Window *)OpenWindowTags(NULL,
                        WA_CustomScreen, screen,
                        WA_Title, "Demo Customscreen, File Pattern, Multi-select",
                        WA_Flags, WINDOWDEPTH | WINDOWDRAG,
                        TAG_END))
                {
                    if (fr = (struct FileRequester *)
                        AllocAslRequestTags(ASL_FileRequest,
                            ASL_Hail, (ULONG)"FilePat/MultiSelect Demo",
                            ASL_Dir,  (ULONG)"libs:",
                            ASL_File, (ULONG)"asl.library",

                            /* Initial pattern string for pattern matching */
                            ASL_Pattern, (ULONG)"~(rexx#?|math#?)",

                            /* Enable multiselection and pattern match gadget */
                            ASL_FuncFlags, FILF_MULTISELECT | FILF_PATGAD,

                            /* This requester comes up on the screen of this
                            ** window (and uses window's message port, if any).
                            */
                            ASL_Window, window,
                            TAG_DONE))
                    {
                        /* Put up file requester */
                        if (AslRequest(fr, 0L))
                        {
                            /* If the file requester's rf_NumArgs field
                            ** is not zero, the user multiselected. The
                            ** number of files is stored in rf_NumArgs.
                            */
                            if (fr->rf_NumArgs)
                            {
                                /* rf_ArgList is an array of WBArg structures
                                ** (see <workbench/startup.h>). Each entry in
                                ** this array corresponds to one of the files
                                ** the user selected (in alphabetical order).
                                */
                                frargs = fr->rf_ArgList;

                                /* The user multiselected, step through
                                ** the list of selected files.
                                */
                                for ( x=0;  x < fr->rf_NumArgs;  x++ )
                                    printf("Argument %d: PATH=%s FILE=%s\n",
                                        x, fr->rf_Dir, frargs[x].wa_Name);
                            }
                            else
                                /* The user didn't multiselect, use the
                                ** normal way to get the file name.
                                */
                                printf("PATH=%s FILE=%s\n", fr->rf_Dir, fr->rf_File);
                        }
                        /* Done with the FileRequester, better return it */
                        FreeAslRequest(fr);
                    }
                    CloseWindow(window);
                }
                CloseScreen(screen);
            }
            CloseLibrary(IntuitionBase);
        }
        CloseLibrary(AslBase);
    }
}
