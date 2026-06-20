/* halloc.c: */
#include <stdio.h>
#include <stdlib.h>
#include "vogl.h"
#include "hershey.h"

/* --------------------------------------------------------------------- */

/*
 * hallocate
 *
 *	Allocate some memory, barfing if malloc returns NULL.
 */
char * hallocate(unsigned size)
{
	char	*p;


	if ((p = (char *)malloc(size)) == (char *)NULL) {
		fprintf(stderr,"hallocate: request for %u bytes returned NULL", size);
		gexit();
		exit(1);
	}

	return (p);
}
