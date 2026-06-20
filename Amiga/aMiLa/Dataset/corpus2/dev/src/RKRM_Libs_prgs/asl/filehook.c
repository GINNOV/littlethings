;/* filehook.c - Execute me to compile me with Lattice 5.10
LC -b1 -cfistq -v -y -j73 filehook.c
Blink FROM LIB:c.o,filehook.o TO filehook LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
#include <dos/dosasl.h>
#include <libraries/asl.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/asl_protos.h>
#include <clib/intuition_protos.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void)     { return(0); }  /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }     /* really */
#endif

#define DESTPATLENGTH 20

UBYTE *vers = "$VER: filehook 37.0";

CPTR HookFunc();

struct Library *AslBase = NULL;
struct Library *IntuitionBase = NULL;
struct Window  *window = NULL;

/* this is the pattern matching string that the hook function uses */
UBYTE *sourcepattern = "(#?.info)";
UBYTE pat[DESTPATLENGTH];

void main(int argc, char **argv)
{
    struct FileRequester *fr;

    if (AslBase = OpenLibrary("asl.library", 37L))
    {
        if (IntuitionBase = (struct IntuitionBase *)
                    OpenLibrary("intuition.library", 37L))
        {
            /* This is a V37 dos.library function that turns a pattern matching
            ** string into something the DOS pattern matching functions can
            ** understand.
            */
            ParsePattern(sourcepattern, pat, DESTPATLENGTH);

            /* open a window that gets ACTIVEWINDOW events */
            if (window = (struct Window *)OpenWindowTags(NULL,
                    WA_Title, "ASL Hook Function Example",
                    WA_IDCMP, IDCMP_ACTIVEWINDOW,
                    WA_Flags, WFLG_DEPTHGADGET,
                    TAG_END))
            {
                if (fr = AllocFileRequest())
                {
                    if (AslRequestTags(fr,
                        ASL_Dir, (ULONG)"SYS:Utilities",
                        ASL_Window, window,
                        ASL_TopEdge, 0L,
                        ASL_Height, 200L,
                        ASL_Hail, (ULONG)"Pick an icon, select save",
                        ASL_HookFunc, (ULONG)HookFunc,
                        ASL_FuncFlags, FILF_DOWILDFUNC | FILF_DOMSGFUNC | FILF_SAVE,
                        ASL_OKText, (ULONG)"Save",
                        TAG_DONE))
                    {
                        printf("PATH=%s FILE=%s\n", fr->rf_Dir, fr->rf_File);
                        printf("To combine the path and filename, copy the path\n");
                        printf("to a buffer, add the filename with Dos AddPart().\n");
                    }
                    FreeFileRequest(fr);
                }
                CloseWindow(window);
            }
            CloseLibrary(IntuitionBase);
        }
        CloseLibrary(AslBase);
    }
}




CPTR HookFunc(LONG type, CPTR obj, struct FileRequester *fr)
{
    static BOOL returnvalue;
    switch(type)
    {
        case FILF_DOMSGFUNC:
        /* We got a message meant for the window */
            printf("You activated the window\n");
            return(obj);
            break;
        case FILF_DOWILDFUNC:
        /* We got an AnchorPath structure, should
        ** the requester display this file? */

            /* MatchPattern() is a dos.library function that
            ** compares a matching pattern (parsed by the
            ** ParsePattern() DOS function) to a string and
            ** returns true if they match. */
            returnvalue = MatchPattern(pat,
                    ((struct AnchorPath *)obj)->ap_Info.fib_FileName);

            /* we have to negate MatchPattern()'s return value
            ** because the file requester expects a zero for
            ** a match not a TRUE value */
            return( (CPTR)(! returnvalue) );
            break;
    }
}
