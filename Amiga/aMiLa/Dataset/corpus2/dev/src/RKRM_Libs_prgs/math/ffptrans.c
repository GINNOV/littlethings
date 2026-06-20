;/* ffptrans.c - Math FFP Transcendental example of SPSin()
LC -b1 -cfistq -ff -v -y -j73 ffptrans.c
blink lib:c.o+ffptrans.o TO ffptrans LIB lib:lcmffp.lib+lib:lc.lib+lib:amiga.lib
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
#include <libraries/mathffp.h>

#include <clib/exec_protos.h>
#include <clib/mathtrans_protos.h>

#include <clib/alib_stdio_protos.h>

struct Library *MathTransBase;

VOID main(void)
{

FLOAT num1 = 3.1415926535897/6;  /* 30 degrees in radians */
FLOAT result;

if (MathTransBase = OpenLibrary("mathtrans.library",0))
    {
    result = SPSin(num1);
    printf("Num1 = %f and result = %f\n",num1,result);

    CloseLibrary(MathTransBase);
    }
else
    printf("Can't open mathffp.library\n");
}
