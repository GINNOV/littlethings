/*
 * TetiSoft 13-01-91
 *
 * Changed Returnvalue of sscanf to long.
 *
 * From the Hcc.lib by Detlef Wurkner, Placed here by Jason Petty. */

#include <stdio.h>

static int sgetc(s)
	unsigned char **s;
	{
	register unsigned char c;

	c = *(*s)++;
	return((c == '\0') ? EOF : c);
	}

static int sungetc(c, s)
	int c;
	unsigned char **s;
	{
	if(c == EOF)
		c = '\0';
	return(*--(*s) = c);
	}

long
sscanf(buf, fmt, arg)
	unsigned char *buf;
	unsigned char *fmt;
	int arg;
	{
	return(_scanf(&buf, sgetc, sungetc, fmt, &arg));
	}
