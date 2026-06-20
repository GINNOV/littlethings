/* compute crc's */
/* crc-16 is based on the polynomial x^16+x^15+x^2+1 */
/*  The data is assumed to be fed in from least to most significant bit */
/* crc-ccitt is based on the polynomial x^16+x^12+x^5+1 */
/*  The data is fed in from most to least significant bit */
/* The prescription for determining the mask to use for a given polynomial
	is as follows:
		1.  Represent the polynomial by a 17-bit number
		2.  Assume that the most and least significant bits are 1
		3.  Place the right 16 bits into an integer
		4.  Bit reverse if serial LSB's are sent first
*/
/* Usage : crc2 [filename] */

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#define		M16	0xA001		/* crc-16 mask */
#define		MTT	0x1021		/* crc-ccitt mask */

/* function declarations */
unsigned short int updcrc(unsigned short int,int,unsigned short int);
unsigned short int updcrcr(unsigned short int,int,unsigned short int);
void perr(char *);

/* variables */
char filename[100];
unsigned short int crc16,crctt;
int ch;
unsigned long num;
FILE *fp;

/* driver */
main(argc,argv)
int argc; char **argv;
{
	if(argc>2) perr("Usage:  crc2 [filename]");
	if(argc==2) strcpy(filename,argv[1]);
	else
	{
		printf("\nEnter filename:  "); gets(filename);
	}
	if((fp=fopen(filename,"rb"))==NULL) perr("Can't open file");
	num=0L; crc16=crctt=0;
	while((ch=fgetc(fp))!=EOF)
	{
		num++;
		crc16=updcrcr(crc16,ch,M16);
		crctt=updcrc(crctt,ch,MTT);
	}
	fclose(fp);
	printf("\nNumber of bytes = %lu\nCRC16 = %04X\nCRCTT = %04X",
		(unsigned long) num, (unsigned long) crc16, (unsigned long) crctt);
}

/* update crc */
unsigned short int updcrc(crc,c,mask)
unsigned short int crc,mask; int c;
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
unsigned short int updcrcr(crc,c,mask)
unsigned short int crc,mask; int c;
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
