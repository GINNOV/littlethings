/* check.c: */
#include <stdio.h>
#include <stdlib.h>
#include "hershey.h"

/* --------------------------------------------------------------------- */

extern int	hLoaded;

/* --------------------------------------------------------------------- */

/*
 * check_loaded
 *
 * 	Checks and prints out a message if the font isn't loaded.
 */
void check_loaded(char *who)
{
	if (!hLoaded) {
		fprintf(stderr, "%s: no hershey font loaded.\n", who);
		exit(1);
	}
}

/* --------------------------------------------------------------------- */
