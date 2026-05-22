;/* istr.c - Execute me to compile me with SAS C 5.10
LC -b1 -cfis -j73 istr.c
Blink FROM LIB:c.o,istr.o TO istr LIBRARY LIB:LC.lib,LIB:Amiga.lib
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
    #include <stdio.h>
    #include <string.h>

    #include <clib/exec_protos.h>
    #include <clib/utility_protos.h>

    void main(void);
    struct Library *UtilityBase;

    void main(void)
    {
        UBYTE *butter = "Bøtervløøt";
        UBYTE *bread = "Knåckerbrøt";
        UBYTE ch1, ch2;
        LONG result;

        /* Fails silently if < 37 */
        if (UtilityBase = OpenLibrary("utility.library", 37))
        {
                result = Stricmp(butter, bread);

                printf("comparing %s with %s yields %ld\n", butter, bread, result );

                result = Strnicmp(bread, butter, strlen(bread));

                printf("comparing (with length) %s with %s yields %ld\n", bread, butter, result );

                ch1 = ToUpper(0xE6); /* æ ASCII character 230 ae ligature */
                ch2 = ToLower(0xD0); /* Ð ASCII character 208 Icelandic Eth */

                printf("Chars %c %c\n", ch1, ch2);
        }
    }
