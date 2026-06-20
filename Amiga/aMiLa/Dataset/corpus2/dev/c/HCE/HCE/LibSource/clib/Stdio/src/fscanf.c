#include <stdio.h>

/* From the Hcc.lib by Detlef Wurkner, Placed here by Jason Petty. */

extern int fgetc(), fungetc();

long
fscanf(fp, fmt, arg)
	FILE *fp;
	char *fmt, *arg;
	{
	return(_scanf(fp, fgetc, fungetc, fmt, &arg));
	}

long
scanf(fmt, arg)
	char *fmt, *arg;
	{
	return(_scanf(stdin, fgetc, fungetc, fmt, &arg));
	}
