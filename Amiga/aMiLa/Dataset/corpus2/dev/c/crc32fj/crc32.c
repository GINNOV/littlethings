/* crc32.c - Cycle Redundancy Check 32-bit
 *		for a memoryblock or filestream.
 *
 * (c) 1999 by Finn Yannick Jacobs. This software
 * IS freeware, so feel free to manipulate, delete,
 * change this as you want to ;-)
 * No rights are reserved for this. Look for
 * "crc32fj.c and crc32fj.h" for more details.
 *
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "crc32fj.h"

#define MAX	256

void main()
{
	unsigned char buffer[MAX];
	unsigned long crc;
	int i;
	FILE *filehandle;
	
	/* fill buffer with many zeros */
	for( i=0; i<MAX; i++) buffer[i] = 66;

	/* calculate crcTable instead of having it around :) */
	chksum_crc32GenTab();

	/* calculate crc for buffer in memory */
	crc = chksum_crc32Block( buffer, MAX );
	printf("CRC32: 0x%08lx for <buffer>\n", crc);

	/* save buffer to disk */
	if( (filehandle = fopen( "buffer.crc", "wb" ) ) != NULL ) {
		fwrite( buffer, 1, MAX, filehandle );
		fclose( filehandle );
	}

	/* calculate crc for filestream, e.g. "buffer.crc" */
	if((filehandle = fopen( "buffer.crc", "rb" )) !=NULL ) {
		crc = chksum_crc32Filehandle( filehandle );
		printf("CRC32: 0x%08lx for \"buffer.crc\"\n", crc );
		fclose( filehandle );
	}

	/* are both crc's the same, then there was no problem.
	 * but when, maybe check the file:
	 *  (1) size correct?
	 *  (2) are there only 0x66 = b's?
	 */
} /* end of crc32.c */
