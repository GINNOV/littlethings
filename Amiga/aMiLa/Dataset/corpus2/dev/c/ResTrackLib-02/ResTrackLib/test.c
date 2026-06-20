/******************************************************************************

    MODUL
	test.c

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
#include "restrack.h"


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


/*****************************************************************************

    NAME
	main

    SYNOPSIS
	int main (int argc, char ** argv);

    FUNCTION
	Tests the restrack.lib.

    INPUTS
	none.

    RESULT
	Many errors and bugs but no GURUs :-)

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

int main (int argc, char ** argv)
{
    APTR mem;
    BPTR fh;
    BPTR lock, old_cd;

    StartResourceTracking (RTL_ALL);

    OpenLibrary ("dos.library", 30L);

    mem = AllocMem (500,0);     /* Find unfreed memory */
    mem = AllocMem (500,0);
    FreeMem (mem, 100);         /* Find illegal FreeMems (wrong size) */
    mem = AllocVec (500,0);
    FreeMem (mem, 100);         /* Find illegal FreeMems (should be FreeVec) */

    lock = Lock ("RAM:", SHARED_LOCK);
    DupLock (lock);             /* unfreed lock */
    old_cd = CurrentDir (lock);

    CreateDir ("testdir");      /* unfreed lock */

    fh = Open ("testdir/test", MODE_NEWFILE);   /* Find unclosed files */

    FreeVec ((APTR)fh);       /* Find illegal FreeVecs */
    UnLock ((BPTR)mem);       /* illegal unlock */

    PrintTrackedResources ();

    FreeMem (0,500);        /* Illegal FreeMem: wrong address */
    Close (0);              /* Illegal Close: wrong address */

    CurrentDir (old_cd);    /* unfreed lock */

    EndResourceTracking ();

} /* main */


/******************************************************************************
*****  ENDE test.c
******************************************************************************/
