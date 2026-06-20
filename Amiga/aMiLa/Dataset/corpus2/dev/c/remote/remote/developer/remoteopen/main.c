/* -----------------------------------------------------------------------------

  remoteopen - uses remote.library to start an application

  10/1997 Dietmar Eilert (public domain)

  dcc main.c -// -mRR -r -proto -3.0 -l /library/dlib/remotesr.lib -o //bin/remoteopen

  ------------------------------------------------------------------------------
*/

/// "includes"

#define Prototype extern

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <exec/exec.h>
#include <exec/types.h>
#include <dos/dos.h>
#include <clib/alib_protos.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>

// remote.library includes

#include "/library/include/remote.h"

#include "/library/clib/remote_protos.h"

///
/// "prototypes"

Prototype int main(int, char **);

///
/// "globals"

char Version[] = "$VER: remoteopen 1.0 (" __COMMODORE_DATE__ ")";

struct Library *RemoteBase;

///
/// "misc"

/* ----------------------------------- main ------------------------------------

 DOS entry point

*/

int
main(argc, argv)

int    argc;
char **argv;
{
    int error = 0;

    puts("remoteopen 10/1997 Dietmar Eilert. Public Domain.");

    if (RemoteBase = OpenLibrary("remote.library", 37)) {

        // manually initialize remote.library (we want to see the error code)

        if (error = RemoteInit()) {

            puts(RemoteError(error));
        }
        else {

            ULONG argArray[] = { 0, 0, 0 };

            struct RDArgs *rdArgs;

            // parse arguments

            if (rdArgs = ReadArgs("CLASS/A,FILE/K,APP/K", argArray, NULL)) {

                // open file in application

                if (error = RemoteOpen((UBYTE *)argArray[0], (UBYTE *)argArray[2], (UBYTE *)argArray[1], REMOTE_OPEN_ASYNC))

                    puts(RemoteError(error));

                FreeArgs(rdArgs);
            }
            else {

                error = 20;

                puts("Syntax error.");
            }
        }

        CloseLibrary(RemoteBase);
    }
    else {

        error = 20;

        puts("remote.library missing");
    }

    return(error);
}   

///
