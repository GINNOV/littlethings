/* Copyright (c) 1986, Greg McGary */
static char sccsid[] = "@(#)bitcount.c	1.1 86/10/09";

/*
	Count the number of 1 bits in the given integer.
*/
static char bitcnt[] = {
/*	0 1 2 3 4 5 6 7	8 9 a b c d e f	*/
	0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4
};
int
bitCount(register unsigned	mask)
{
	register int	nybbles = 8;
	register int	cnt = 0;

	while (mask && nybbles--) {
		cnt += bitcnt[mask&0xf];
		mask >>= 4;
	}
	return cnt;
}
/*
void
bitsCount(register char	*bitv,register int	n)
{
	register int	count = 0;

	while (n--) {
		count += bitcnt[*bitv&0xf] + bitcnt[(*bitv>>4)&0xf];
		bitv++;
	}
}
*/