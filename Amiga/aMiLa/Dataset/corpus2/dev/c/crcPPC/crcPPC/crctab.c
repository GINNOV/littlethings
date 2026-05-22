/* generate crc tables for crc-16 and crc-ccitt */
/* crc-16 is based on the polynomial x^16+x^15+x^2+1 */
/*  The bits are inserted from least to most significant */
/* crc-ccitt is based on the polynomial x^16+x^12+x^5+1 */
/*  The bits are inserted from most to least significant */
/* The prescription for determining the mask to use for a given polynomial
	is as follows:
		1.  Represent the polynomial by a 17-bit number
		2.  Assume that the most and least significant bits are 1
		3.  Place the right 16 bits into an integer
		4.  Bit reverse if serial LSB's are sent first
*/

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#define		M16	0xA001		/* crc-16 mask */
#define		MTT	0x1021		/* crc-ccitt mask */

/* function declarations */
unsigned int updcrc(unsigned int,int,unsigned int);
unsigned int updcrcr(unsigned int,int,unsigned int);
void perr(char *);

/* driver */
main()
{
	int i,j;
	printf("\n\t");
	for(i=0;i<32;i++)
	{
		for(j=0;j<8;j++) printf("0x%04X, ",updcrcr(0,8*i+j,M16));
		printf("\n\t");
	}
	printf("\n\t");
	for(i=0;i<32;i++)
	{
		for(j=0;j<8;j++) printf("0x%04X, ",updcrc(0,8*i+j,MTT));
		printf("\n\t");
	}
}

/* update crc */
unsigned int updcrc(crc,c,mask)
unsigned int crc,mask; int c;
{
	int i;
	c<<=8;
	for(i=0;i<8;i++)
	{
		if((crc ^ c) & 0x8000) crc=(crc<<1)^mask;
		else crc<<=1;
		c<<=1;
	}
	return crc;
}

/* update crc reverse */
unsigned int updcrcr(crc,c,mask)
unsigned int crc,mask; int c;
{
	int i;
	for(i=0;i<8;i++)
	{
		if((crc ^ c) & 1) crc=(crc>>1)^mask;
		else crc>>=1;
		c>>=1;
	}
	return crc;
}

/* error abort */
void perr(s)
char *s;
{
	printf("\n%s",s); exit(1);
}
