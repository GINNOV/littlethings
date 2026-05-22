;/* prargs.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfistq -v -y -j73 prargs.c
Blink FROM LIB:c.o,prargs.o LIB LIB:LC.lib,LIB:Amiga.lib TO prargs DEFINE __main=__tinymain
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
** NOTE: main and tinymain are prepended with two underscores.
**
** PrArgs.c - This program prints all Workbench or Shell (CLI) arguments.
*/
#include <exec/types.h>
#include <workbench/startup.h>
#include <clib/dos_protos.h>
#include <clib/icon_protos.h>

#include <stdlib.h>
#include <stdio.h>

#ifdef LATTICE
int CXBRK(void) { return(0); }   /* Disable SAS Lattice CTRL/C handling */
int chkabort(void) { return(0); }/* really */
#endif

void main(int argc, char **argv)
{
struct WBStartup *argmsg;
struct WBArg *wb_arg;
LONG ktr;
BPTR olddir;
FILE *outFile;

/* argc is zero when run from the Workbench,
**         positive when run from the CLI.
*/
if (argc == 0)
    {
    /* AmigaDOS has a special facility that  allows a window  */
    /* with a console and a file handle to be easily created. */
    /* CON: windows allow you to use fprintf() with no hassle */
    if (NULL != (outFile = fopen("CON:0/0/640/200/PrArgs","r+")))
        {
        /* in SAS/Lattice, argv is a pointer to the WBStartup message
        ** when argc is zero.  (run under the Workbench.)
        */
        argmsg = (struct WBStartup *)argv ;
        wb_arg = argmsg->sm_ArgList ;         /* head of the arg list */

        fprintf(outFile, "Run from the workbench, %ld args.\n",
                         argmsg->sm_NumArgs);

        for (ktr = 0; ktr < argmsg->sm_NumArgs; ktr++, wb_arg++)
            {
            if (NULL != wb_arg->wa_Lock)
                {
                /* locks supported, change to the proper directory */
                olddir = CurrentDir(wb_arg->wa_Lock) ;

                /* process the file.
                ** If you have done the CurrentDir() above, then you can
                ** access the file by its name.  Otherwise, you have to
                ** examine the lock to get a complete path to the file.
                */
                fprintf(outFile, "\tArg %2.2ld (w/ lock): '%s'.\n",
                                 ktr, wb_arg->wa_Name);

                /* change back to the original directory when done.
                ** be sure to change back before you exit.
                */
                CurrentDir(olddir) ;
                }
            else
                {
                /* something that does not support locks */
                fprintf(outFile, "\tArg %2.2ld (no lock): '%s'.\n",
                                 ktr, wb_arg->wa_Name);
                }
            }
        /* wait before closing down */
        Delay(500L);
        fclose(outFile);
        }
    }
else
    {
    /* using 'tinymain' from lattice c.
    ** define a place to send the output (originating CLI window = "*")
    ** Note - if you open "*" and your program is RUN, the user will not
    ** be able to close the CLI window until you close the "*" file.
    */
    if (NULL != (outFile = fopen("*","r+")))
        {
        fprintf(outFile, "Run from the CLI, %d args.\n", argc);

        for ( ktr = 0; ktr < argc; ktr++)
            {
            /* print an arg, and its number */
            fprintf(outFile, "\tArg %2.2ld: '%s'.\n", ktr, argv[ktr]);
            }
        fclose(outFile);
        }
    }
}
