/*
 *	File:					
 *	Description:	
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef	BLACKBORDER_C
#define	BLACKBORDER_C

/*** INCLUDES ************************************************************************/
#include <exec/types.h>
#include <graphics/gfxbase.h>
#include "myinclude:BitMacros.h"

#include <clib/intuition_protos.h>
#include <clib/exec_protos.h>

/*** DEFINES *************************************************************************/
#define	LIBVER	38

/*** GLOBALS *************************************************************************/
char const *version="\0$VER: Blackborder 1.1 (08.12.95)\©1995 Ketil Hunn";

/*** FUNCTIONS ***********************************************************************/
void __main(void)
{
	register struct IntuitionBase	*IntuitionBase;

	if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", LIBVER))
	{
		register struct GfxBase *GfxBase;

		if(GfxBase=(struct GfxBase *)OpenLibrary("graphics.library", LIBVER))
		{
			if(ISBITSET(GfxBase->BP3Bits, BPLCON3_BRDNBLNK))
				CLEARBIT(GfxBase->BP3Bits, BPLCON3_BRDNBLNK);
			else
				SETBIT(GfxBase->BP3Bits, BPLCON3_BRDNBLNK);
			RemakeDisplay();

			CloseLibrary((struct Library *)GfxBase);
		}
		CloseLibrary((struct Library *)IntuitionBase);
	}
}

#endif
