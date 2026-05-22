#include <stdio.h>
#include <stdarg.h>

/* From the Hcc.lib by Detlef Wurkner, Placed here by Jason Petty. */

extern int fputc();

long
fprintf(fp, fmt, arg)
	FILE *fp;
	char *fmt;
	int arg;
	{
	return(_printf(fp, fputc, fmt, &arg));
	}

long
vfprintf(fp, fmt, args)
	FILE *fp;
	char *fmt;
	va_list args;
	{
	return(_printf(fp, fputc, fmt, args));
	}

long
printf(fmt, arg)
	char *fmt;
	int arg;
	{
	return(_printf(stdout, fputc, fmt, &arg));
	}

long
vprintf(fmt, args)
	char *fmt;
	va_list args;
	{
	return(_printf(stdout, fputc, fmt, args));
	}
