/* ------------------------------------------------------------------
 $VER: stats.main.c 1.01 (12.01.1999)

 main & program functions

 (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.
 amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------------ */

#include <stdio.h>
#include <time.h>

#include <dos/dos.h>
#include <exec/exec.h>
#include <exec/types.h>
#include <exec/lists.h>
#include <easyaudio/easyaudio.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>

#include <clib/exec_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/easyaudio_protos.h>
#include <clib/intuition_protos.h>

#include "Stats.h"

UBYTE *vers = "$VER: Stats v1.01 - © Matthew J Fletcher 2000";

/* ------------------------------------------------------------- */
/* Please note that, this code has been written under gcc libnix */
/* as such it uses auto-library opening and other nice features  */
/* that some amiga compilers do not support. I have explicitly   */
/* opened libs that are not in 3.x ROM, as thats the minimum     */
/* that any decent compiler should support. DICE / GCC-Libnix /  */
/* StormC and perhaps others (allthough i cant be sure) will be  */
/* just fine. -matt                                              */
/* ------------------------------------------------------------- */

int wbmain(void)
{ /* dummy to call main if run from workbench */
	main();
}


int main (void)
{ /* workbench startup & entry point */
int result;

	/* ------------------------ */
	/* open in nice safe manner */
	/* ------------------------ */

	if (SetupScreen() != 0) /* something broke */
	   {
	   CloseDownScreen();
	   exit(20);
	   } /* close anything we might have opened */

	if (OpenStatsWindow() != 0)
	   {
	   CloseStatsWindow();
	   CloseDownScreen();
	   exit(20);
	   } /* close anything we might have opened */
	

	/* ------------------------ */
	/* watch what the user does */
	/* ------------------------ */

	/* we will quit when we get -1 (they clicked quit gadget) */
	do {

	   /* updates happen on a IntuiTick */

	   /* copy sys time to display */
	   comp_time();

	   /* update memory monitor */
	   comp_stats();

	   /* do gui processing */
	   result = HandleStatsIDCMP();

	   } while (result != -1); /* a break */


   /* a seperate procedure will have to call Shutdown() */
   /* to quit - WE dont handle it here */
   Shutdown();
}


void comp_time(void)
{ /* works out time and displays */
time_t time_now;
char buffer[100];

	/* get the time in a buffer */
	time(&time_now);
	sprintf(buffer, "%s", ctime(&time_now));

	/* Print out the current time: */
	GT_SetGadgetAttrs(StatsGadgets[7], StatsWnd, NULL,
					  GTTX_Text, buffer,
					  TAG_END);
} /* end comp_time */


int RebootClicked( void )
{ /* routine when gadget "Reboot" is clicked. */
int result;
long tag;

/* blank us out */
GT_SetGadgetAttrs(StatsGadgets[6], StatsWnd, NULL,
				  GA_Disabled, TRUE,
				  TAG_END);


/* first we check if we realy want to reboot */

 EasyaudioBase = (APTR) OpenLibrary("easyaudio.library", 39);
 if(!EasyaudioBase)
   {
	printf("\nEasyaudio.library opening failed\n");

	/* failure & quit */
	return(-1);
   }

   /* call the requestor function */
   result = EA_Request("ColdReboot ?",
					   "Are you sure you want to reboot ?",
					   "OK|Cancel");


   if (result == 1) /* ok - quit */
		{
		CloseLibrary((APTR) EasyaudioBase);

		/* we just drop sraight out here */
		/* no need for any clean ups */

		ColdReboot(); /* bye bye */
		} /* we are gone */

   /* else we get to play some more */

   /* un-blank us */
   GT_SetGadgetAttrs(StatsGadgets[6], StatsWnd, NULL,
				  GA_Disabled, FALSE,
				  TAG_END);


   CloseLibrary((APTR) EasyaudioBase);
   return(-2);

}


int comp_stats(void)
{ /* works out stats for display */

ULONG memsize, memchunk;
char buffer[100]; /* may need a large buffer */

/* get chip / chunk */
memsize = AvailMem(MEMF_CHIP);
memchunk = AvailMem(MEMF_CHIP|MEMF_LARGEST);

sprintf(buffer, "Total %ld bytes", memsize );
GT_SetGadgetAttrs(StatsGadgets[0], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

sprintf(buffer, "Largest %ld bytes", memchunk );
GT_SetGadgetAttrs(StatsGadgets[1], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

/* get fast / chunk */
memsize = AvailMem(MEMF_FAST);
memchunk = AvailMem(MEMF_FAST|MEMF_LARGEST);

sprintf(buffer, "Total %ld bytes", memsize );
GT_SetGadgetAttrs(StatsGadgets[2], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

sprintf(buffer, "Largest %ld bytes", memchunk );
GT_SetGadgetAttrs(StatsGadgets[3], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

/* get total / chunk */
memsize = AvailMem(MEMF_PUBLIC);
memchunk = AvailMem(MEMF_PUBLIC|MEMF_LARGEST);

sprintf(buffer, "Total %ld bytes", memsize );
GT_SetGadgetAttrs(StatsGadgets[4], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

sprintf(buffer, "Largest %ld bytes", memchunk );
GT_SetGadgetAttrs(StatsGadgets[5], StatsWnd, NULL,
				  GTTX_Text, buffer,
				  TAG_END);

} /* end comp_stats */

