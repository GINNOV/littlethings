;/* dpieee.c - Math DP IEEE example of DPTst(). Run from CLI only!
LC -b1 -cfistq -fi -v -y -j73 dpieee.c
Blink lib:c.o+dpieee.o TO dpieee LIB lib:lcmieee.lib+lib:lc.lib+lib:amiga.lib
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

#include <clib/exec_protos.h>
#include <libraries/mathieeedp.h>

#include <clib/mathieeedoubbas_protos.h>
#include <clib/alib_stdio_protos.h>

struct Library *MathIeeeDoubBasBase;

VOID main(void)
{

DOUBLE num1 = -3.1415926535897/6;  /* 30 degrees in radians */
LONG result;

if (MathIeeeDoubBasBase = OpenLibrary("mathieeedoubbas.library",34))
    {
    result = IEEEDPTst(num1);
    printf("Num1 = %f and result = %d\n",num1,result);

    CloseLibrary(MathIeeeDoubBasBase);
    }
else
    printf("Can't open mathieeedoubbas.library\n");
}
