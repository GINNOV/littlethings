/* ------------------------------------------------------------------
 $VER: stats.supp.c 1.01 (12.01.1999)

 support program functions

 (C) Copyright 1999-2000 Matthew J Fletcher - All Rights Reserved.
 amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------------ */

#include <stdio.h>

#include <dos/dos.h>
#include <exec/types.h>

#include <clib/exec_protos.h>

#include "Stats.h"

void Shutdown(void)
{ /* program shutdown and garbage collector */

	CloseStatsWindow();
	CloseDownScreen();
	exit(0);
}

int StatsCloseWindow( void )
{ /* routine for "IDCMP_CLOSEWINDOW" */

 /* dumy cos we close elsewhere */
	return(-1);
}


int StatsIntuiTicks(void)
{ /* intuitions clock ticking */
	return(1);
}

int StatsIDCMPUpdate(void)
{
	return(2);
}

int StatsActiveWindow( void )
{ /* routine for "IDCMP_ACTIVEWINDOW". */
}

int StatsInActiveWindow( void )
{ /* routine for "IDCMP_INACTIVEWINDOW". */
}
