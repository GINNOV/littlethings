;/* clibtest.c--Calls the Sample.library functions (execute to compile with Lattice 5.10a)
LC -b1 -cfistq -v -y -j73 clibtest.c
Blink FROM LIB:c.o,clibtest.o TO clibtest LIBRARY LIB:LC.lib,LIB:Amiga.lib
quit ;

 note - you must also link with sample.lib if not using sample_pragmas.h

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
#include <libraries/dos.h>

#include <clib/exec_protos.h>

#include <stdlib.h>
#include <stdio.h>

#include "/sampleinclude/samplebase.h"
#include "/sampleinclude/sample_protos.h"
#include "/sampleinclude/sample_pragmas.h"

#ifdef LATTICE
int CXBRK(void)     { return(0); }      /* Disable Lattice CTRL/C handling */
void chkabort(void) { return; }         /* really */
#endif

struct Library *SampleBase = NULL;

void main(int argc, char **argv)
   {
   LONG n;

   /* Open sample.library */
   if(!(SampleBase=OpenLibrary("sample.library",0)))
      {
      printf("Can't open sample.library\n");
      exit(RETURN_FAIL);
      }
   /* Print library name, ID string, version, revision */
   printf("%s  Version=%ld   Revision=%ld  IdString: %s\n",
             SampleBase->lib_Node.ln_Name, SampleBase->lib_Version,
             SampleBase->lib_Revision, SampleBase->lib_IdString);

   /* Call the two functions */
   n = Double(-7);
   printf("Function Double(-7) returned %ld\n", n);
   n = AddThese(21,4);
   printf("Function AddThese(21,4) returned %ld\n", n);

   CloseLibrary(SampleBase);
   exit(RETURN_OK);
   }