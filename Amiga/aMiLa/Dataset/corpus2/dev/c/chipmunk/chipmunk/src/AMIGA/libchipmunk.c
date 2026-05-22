/*
 *  chipmunk.library
 *
 *  Copyright © 2008 Ilkka Lehtoranta <ilkleht@isoveli.org>
 *  All rights reserved.
 *
 */

#include <proto/exec.h>
#include <proto/muimaster.h>
#include <constructor.h>

void _INIT_4_ChipmunkBase(void) __attribute__((alias("__CSTP_init_ChipmunkBase")));
void _EXIT_4_ChipmunkBase(void) __attribute__((alias("__DSTP_cleanup_ChipmunkBase")));

struct Library *ChipmunkBase;
#define VERSION 1

static const char libname[] = "chipmunk.library";

static CONSTRUCTOR_P(init_ChipmunkBase, 100)
{
	ChipmunkBase = (void *) OpenLibrary((STRPTR) libname, VERSION);

	if (!ChipmunkBase)
	{
		struct Library *MUIMasterBase = OpenLibrary("muimaster.library", 0);

		if (MUIMasterBase)
		{
			static CONST ULONG args[1] = { VERSION };
			MUI_RequestA(NULL, NULL, 0, "Chipmunk startup message", "Abort", "Need version %.10ld of chipmunk.library", &args);
			CloseLibrary(MUIMasterBase);
		}
	}

	return (ChipmunkBase == NULL);
}

static DESTRUCTOR_P(cleanup_ChipmunkBase, 100)
{
	CloseLibrary(ChipmunkBase);
}
