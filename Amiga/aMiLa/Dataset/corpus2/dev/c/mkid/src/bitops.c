/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)bitops.c	1.1 86/10/09";

#include	"bitops.h"

char *
bitsset(register char *s1,register char *s2,register int n)
{
	while (n--)
		*s1++ |= *s2++;

	return s1;
}

char *
bitsclr(register char *s1,register char *s2,register int n)
{
	while (n--)
		*s1++ &= ~*s2++;

	return s1;
}

char *
bitsand(register char *s1,register char *s2,register int n)
{
	while (n--)
		*s1++ &= *s2++;

	return s1;
}

char *
bitsxor(register char *s1,register char *s2,register int n)
{
	while (n--)
		*s1++ ^= *s2++;

	return s1;
}

int
bitstst(register char *s1,register char *s2,register int n)
{
	while (n--)
		if (*s1++ & *s2++)
			return 1;

	return 0;
}

int
bitsany(register char *s,register int n)
{
	while (n--)
		if (*s++)
			return 1;

	return 0;
}
