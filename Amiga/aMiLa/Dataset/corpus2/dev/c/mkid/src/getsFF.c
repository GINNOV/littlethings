/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)getsFF.c	1.1 86/10/09";

#include	<stdio.h>

int
getsFF(char *buf0,register FILE *inFILE)
{
	register char	*buf = buf0;

	while (((*buf++ = getc(inFILE)) & 0xff) != 0xff)
		;
	return (buf - buf0 - 1);
}

void
skipFF(register FILE *inFILE)
{
	while ((getc(inFILE) & 0xff) != 0xff)
		;
	return;
}
