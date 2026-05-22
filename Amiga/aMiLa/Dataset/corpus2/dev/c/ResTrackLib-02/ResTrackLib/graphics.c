/******************************************************************************

    MODUL
	graphics.c

    DESCRIPTION

    NOTES

    BUGS

    TODO

    EXAMPLES

    SEE ALSO

    INDEX

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

/**************************************
		Includes
**************************************/
#include <stdio.h>
#include <exec/types.h>

#include <clib/graphics_protos.h>
#ifdef REGARGS
#   include <pragmas/graphics_pragmas.h>

extern struct Library * GfxBase;
#endif



/**************************************
	    Globale Variable
**************************************/


/**************************************
      Interne Defines & Strukturen
**************************************/


/**************************************
	    Interne Variable
**************************************/


/**************************************
	   Interne Prototypes
**************************************/


void __rtl_RectFill (struct RastPort * rp, WORD x1, WORD y1, WORD x2, WORD y2)
{
    if (x2 < x1)
    {
	x2 ^= x1, x1 ^= x2, x2 ^= x1;

	if (y2 < y1)
	{
	    fprintf (stderr, "ERROR: RectFill() x2 < x1 and y2 < y1 (%d, %d, %d, %d)\n", y1, y2, y2, y1);

	    y2 ^= y1, y1 ^= y2, y2 ^= y1;
	}
	else
	{
	    fprintf (stderr, "ERROR: RectFill() x2 < x1 (%d, %d)\n", x1, x2);
	}
    }
    else if (y2 < y1)
    {
	fprintf (stderr, "ERROR: RectFill() y2 < y1 (%d, %d)\n", y2, y1);

	y2 ^= y1, y1 ^= y2, y2 ^= y1;
    }

    RectFill (rp, x1, y1, x2, y2);

} /* __rtl_RectFill */


/******************************************************************************
*****  ENDE graphics.c
******************************************************************************/
