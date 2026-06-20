/*
 *    DigConv
 *
 *        © 1996 by Timo C. Nentwig
 *        all rights reserved !
 *
 *        Tcn@techbase.in-berlin.de
 *
 *    Simple tool to convert decimal Digits to
 *    hex, octal and binary.
 *
 *    1.2 - rewrote: ToBin()
 *          rewrote: ToHex()
 *
 */

#include    <exec/types.h>
#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>

	// Prototypes

VOID ToBin (LONG Value);
VOID ToDec (LONG Value);
VOID ToHex (LONG Value);
VOID ToOct (LONG Value);

	// Version

static const STRPTR    __ver =  "$VER: DigConv 1.2 "__AMIGADATE__;

/// main

VOID
main (UWORD ac, STRPTR av[])
{

	if (ac <= 1 || *av [1] == '?')
	{

		printf ("USAGE  : %s <Digit>\n", av [0]);
		printf ("EXAMPLE: %s 524\n",     av [0]);

	}
	else
	{

		LONG     Digit = atol (av[1]);

		ToDec (Digit);
		ToBin (Digit);
		ToHex (Digit);
		ToOct (Digit);

		exit (0);

	}

}

///
/// ToDec ()

VOID
ToDec (LONG Value)
{

		// Hu, ticky code converting decimal to decimal ...

	printf ("Dec:  %ld\n", Value);

}

///
/// ToBin ()

VOID
ToBin (LONG Value)
{

	UBYTE    BinBuffer [34];       // 32 bit + '%' + '\0'
	LONG     i;

	BinBuffer [0] = '%';

	for (i = 0; i < 32 ; i++)
	{

		BinBuffer [31 - i + 1] = '0' + (Value & 1);
		Value = Value >> 1;

	}

	BinBuffer [33] = '\0';

	printf ("Bin: %s\n", BinBuffer);

}

///
/// ToHex ()

VOID
ToHex (LONG Value)
{

	#define MAGIC (2 * sizeof(int) + 1)

	static char      x [MAGIC];
		   STRPTR    s;

	if ( ! (Value))
	{

		return;

	}

	s = x + MAGIC - 1;
	*s= '\0';

	while (Value)
	{

		*--s = "0123456789ABCDEF"[Value & 017];
		Value = (unsigned) Value >> 4;
	}

	printf ("Hex: $%s\n", s);

}

///
/// ToOct ()

VOID
ToOct (LONG Value)
{

	printf ("Oct: \\%o\n", Value);
/*
	UBYTE    OctalBuffer [6];
	LONG     i;

	OctalBuffer [0] = '0';

	for (i = 0 ; i < 3; i++)
	{

		OctalBuffer [2 - i + 1] = '0' + (Value & 7);
		Value = Value >> 3;

	}

	OctalBuffer [4] = '\0';

	printf ("Oct: %s\n", OctalBuffer);
*/
}

///
