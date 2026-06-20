/* crc32fj.c */

/* Written and copyright 1999 by Finn Yannick Jacobs
 * No rights were reserved to this, so feel free to
 * manipulate or do with it, what you want or desire :)
 */

/*
 *  Based on "File Verification Using CRC" by Mark R. Nelson in Dr. Dobb's
 *  Journal, May 1992, pp. 64-67.  This program DOES generate the same CRC
 *  values as ZMODEM and PKZIP
 */

#include <stdio.h>
#include <stdlib.h>

#define DEBUG 0

/* crcTab[] -- this crcTable is being build by chksum_crc32GenTab().
 *		so make sure, you call it before using the other
 *		functions!
 */
unsigned long crcTable[256];


/* chksum_crc32Filehandle() --	with a given filehandle, this one
 *				calculates the crc32-checksum until
 *				the end of file.
 *				the crc32 is the result.
 */
unsigned long chksum_crc32Filehandle( FILE *filehandle )
{
	register unsigned long crc;
	int c;
	
	if(DEBUG) printf("File : ");
	crc = 0xFFFFFFFF;
	while( (c=getc( filehandle )) != EOF ) {
		crc = ((crc>>8) & 0x00FFFFFF) ^ crcTable[ (crc^c) & 0xFF ];
		if(DEBUG) printf("%02lX ", c);
	}
	return( crc^0xFFFFFFFF );
} /* end of chksum_crc32Filehandle() */

/* chksum_crc32Block() -- to a given block, this one calculates the
 *				crc32-checksum until the length is
 *				reached. the crc32-checksum will be
 *				the result.
 */
unsigned long chksum_crc32Block( unsigned char *block, unsigned int length )
{
	register unsigned long crc;
	unsigned long i;
	
	if(DEBUG) printf("Mem  : ");
	crc = 0xFFFFFFFF;
	for( i=0; i<length; i++ ) {
		crc = ((crc>>8) & 0x00FFFFFF) ^ crcTable[ (crc^*block++) & 0xFF ];
		if(DEBUG) printf("%02lX ", *block );
	}
	return( crc^0xFFFFFFFF );
} /* end of chksum_crc32Block() */

/* chksum_crc32GenTab() -- to a global crcTable[256], this one will
 *				calculate the crcTable for crc32-checksums.
 *				it is generated to the polynom [..]
 */
void chksum_crc32GenTab()
{
	unsigned long crc, poly;
	int i,j;
	
	poly = 0xEDB88320L;
	for( i=0; i<256; i++) {
		crc = i;
		for( j=8; j>0; j-- ) {
			if( crc&1 ) {
				crc = (crc>>1)^poly;
			} else {
				crc >>=1;
			}
		}
		crcTable[i]=crc;
	}
} /* end of chksum_crc32GenTab() */

/* end of crc32fj.c */
