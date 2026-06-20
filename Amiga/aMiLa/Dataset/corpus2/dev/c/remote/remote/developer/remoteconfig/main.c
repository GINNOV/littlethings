/* -----------------------------------------------------------------------------

  remoteconfig - add/remove entries to application database

  10/1997 Dietmar Eilert (public domain)

  dcc main.c -// -mRR -r -proto -3.0 -l /library/dlib/remotesr.lib -o //bin/remoteconfig

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

char Version[] = "$VER: remoteconfig 1.0 (" __COMMODORE_DATE__ ")";

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

    puts("remoteconfig 10/1997 Dietmar Eilert. Public Domain.");

    if (RemoteBase = OpenLibrary("remote.library", 37)) {

        // manually initialize remote.library (we want to see the error code)

        if (error = RemoteInit()) {

            puts(RemoteError(error));
        }
        else {

            ULONG argArray[] = { 0, 0, 0, 0, 0 };

            struct RDArgs *rdArgs;

            // parse arguments

            if (rdArgs = ReadArgs("ADD/K,DEL/K,VALIDATE/S,FOLDER/K,DEEP/S", argArray, NULL)) {

                if (argArray[0]) {                   // ADD/K

                    if (error = RemoteAdd((char *)argArray[0]))

                        puts(RemoteError(error));
                }

                if (argArray[1]) {                   // DEL/K

                    if (error = RemoteRemove((char *)argArray[1]))

                        puts(RemoteError(error));
                }

                if (argArray[2]) {                   // VALIDATE/S

                    if (argArray[4])                 // DEEP/S
                        error = RemoteValidate((char *)argArray[3], REMOTE_VALIDATE_DEEP);
                    else
                        error = RemoteValidate((char *)argArray[3], REMOTE_VALIDATE_SMART);

                    if (error)
                        puts(RemoteError(error));
                    else
                        puts("Validated.");
                }

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
