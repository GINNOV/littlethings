
#include "iffp/ilbm.h"
#include "iffp/packer.h"

/*----------------------------------------------------------------------*
 * unpacker.c Convert data from "cmpByteRun1" run compression. 11/15/85
 *
 * Based on code by Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 *
 *	control bytes:
 *	 [0..127]   : followed by n+1 bytes of data.
 *	 [-1..-127] : followed by byte to be repeated (-n)+1 times.
 *	 -128       : NOOP.
 *
 * This version for the Commodore-Amiga computer.
 *----------------------------------------------------------------------*/

/*----------- UnPackRow ------------------------------------------------*/

#define UGetByte()	(*source++)
#define UPutByte(c)	(*dest++ = (c))

/* Given POINTERS to POINTER variables, unpacks one row, updating the source
 * and destination pointers until it produces dstBytes bytes.
 */

BOOL unpackrow(BYTE **pSource, BYTE **pDest, WORD srcBytes0, WORD dstBytes0)
    {
    register BYTE *source = *pSource;
    register BYTE *dest   = *pDest;
    register WORD n;
    register WORD srcBytes = srcBytes0;
    register WORD dstBytes = dstBytes0;
    BOOL error = TRUE;	/* assume error until we make it through the loop */
    WORD minus128 = -128;  /* get the compiler to generate a CMP.W */
    register BYTE c;

    while( dstBytes > 0 )  {
	if ( (srcBytes -= 1) < 0 )  goto ErrorExit;
    	n = UGetByte();

    	if (n >= 0) {
	    n += 1;
	    if ( (srcBytes -= n) < 0 )  goto ErrorExit;
	    if ( (dstBytes -= n) < 0 )  goto ErrorExit;
	    do {  UPutByte(UGetByte());  } while (--n > 0);
	    }

    	else if (n != minus128) {
	    n = -n + 1;
	    if ( (srcBytes -= 1) < 0 )  goto ErrorExit;
	    if ( (dstBytes -= n) < 0 )  goto ErrorExit;
	    c = UGetByte();
	    do {  UPutByte(c);  } while (--n > 0);
	    }
	}
    error = FALSE;	/* success! */

  ErrorExit:
    *pSource = source;  *pDest = dest;

#ifdef MYDEBUG
    if(error)
    D(bug("unpackrow exit: srcBytes=%ld->%ld dstBytes=%ld->%ld n=%ld error=%ld\n",
		srcBytes0, srcBytes, dstBytes0, dstBytes, n, error));
#endif
    return(error);
    }


/* end */
