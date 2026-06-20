/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)gets0.c	1.1 86/10/09";

#include	<stdio.h>

/*
	This is like fgets(3s), except that lines are
	delimited by NULs rather than newlines.  Also,
	we return the number of characters gotten rather
	than the address of buf0.
*/
int
fgets0(char *buf0,int size,register FILE *inFILE)
{
	register char	*buf;
	register int	c;
	register char	*end;

	buf = buf0;
	end = &buf[size];
	while ((c = getc(inFILE)) > 0 && buf < end)
		*buf++ = c;
	*buf = '\0';
	return (buf - buf0);
}
