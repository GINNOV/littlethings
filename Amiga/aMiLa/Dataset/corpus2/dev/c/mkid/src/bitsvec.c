/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)bitsvec.c	1.1 86/10/09";

#include	<stdio.h>
#include	"bitops.h"
#include	"string.h"
#include	"extern.h"
#include	"id.h"

int vecToBits(register char *bitArray,register char *vec,int size);
int bitsToVec(register char *vec,char *bitArray,int bitCount,int size);
char * intToStr(register int i,int size);
int strToInt(register char *bufp,int size);

int
vecToBits(register char *bitArray,register char *vec,int size)
{
	register int	i;
	int		count;

	for (count = 0; (*vec & 0xff) != 0xff; count++) {
		i = strToInt(vec, size);
		BITSET(bitArray, i);
		vec += size;
	}
	return count;
}

int
bitsToVec(register char *vec,char *bitArray,int bitCount,int size)
{
	register char	*element;
	register int	i;
	int		count;

	for (count = i = 0; i < bitCount; i++) {
		if (!BITTST(bitArray, i))
			continue;
		element = intToStr(i, size);
		switch (size) {
		case 4: *vec++ = *element++;
		case 3: *vec++ = *element++;
		case 2: *vec++ = *element++;
		case 1: *vec++ = *element;
		}
		count++;
	}
	*vec = (char)0xff;

	return count;
}

char *
intToStr(register int i,int size)
{
	static char	buf0[4];
	register char	*bufp = &buf0[size];

	switch (size)
	{
	case 4:	*--bufp = (i & 0xff); i >>= 8;
	case 3: *--bufp = (i & 0xff); i >>= 8;
	case 2: *--bufp = (i & 0xff); i >>= 8;
	case 1: *--bufp = (i & 0xff);
	}
	return buf0;
}

int
strToInt(register char *bufp,int size)
{
	register int	i = 0;

	bufp--;
	switch (size)
	{
	case 4: i |= (*++bufp & 0xff); i <<= 8;
	case 3: i |= (*++bufp & 0xff); i <<= 8;
	case 2: i |= (*++bufp & 0xff); i <<= 8;
	case 1: i |= (*++bufp & 0xff);
	}
	return i;
}
