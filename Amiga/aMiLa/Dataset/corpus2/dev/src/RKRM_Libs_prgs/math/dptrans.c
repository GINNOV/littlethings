;/* dptrans.c - Math Double-Precision Transcendental example of IEEEDPSin()
LC -b1 -cfistq -fi -v -y -j73 dptrans.c
Blink lib:c.o+dptrans.o TO dptrans LIB lib:lcmieee.lib+lib:lc.lib+lib:amiga.lib
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
 * Run from CLI only!
 */

#include <exec/types.h>

#include <clib/exec_protos.h>
#include <libraries/mathieeedp.h>

#include <clib/mathieeedoubtrans_protos.h>

#include <clib/alib_stdio_protos.h>

struct Library *MathIeeeDoubTransBase;

VOID main(void)
{

DOUBLE num1 = 3.1415926535897/4;
DOUBLE result;

if (MathIeeeDoubTransBase = OpenLibrary("mathieeedoubtrans.library",34))
    {
    result = IEEEDPSin(num1);
    printf("The double precision sine of 45 degrees is %f\n",result);

    CloseLibrary(MathIeeeDoubTransBase);
    }
else
    printf("Can't open mathieeedoubtrans.library\n");
}
