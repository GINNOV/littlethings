/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    compress_int.c

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 10-Sep-93
    Modified: 01-Nov-95
    _______________________________________________________________________
*/

#define IO_EOF		-1
#define IO_BREAK	-2
#define IO_ERROR	-3

#define MAGIC_HEADER	0x8d		// first data byte after compression

typedef short int	code_int;	// typedefs for compress()/decompress()
typedef long int	count_int;
typedef unsigned char	char_type;

static LONG inptr,	// position in read buffer
	    inreal,	// number of bytes in buffer
	    insize,	// buffer size
	    inleft ;	// number of bytes left to read

/*************************************************************************/

static code_int CompGetChar( void )             // read function for compress()
{
  if ( ! inreal )
  {
    if ( ! inleft ) return( IO_EOF ) ;
    if ( StopMe() ) return( IO_BREAK ) ;
    inreal = MIN( inleft , insize ) ;
    if ( Read( InFile , InBuf , inreal ) != inreal )
    {
      inreal = inleft = 0 ;
      if ( IoErr() ) return( IO_ERROR ) ;
      return( IO_EOF ) ;
    }
    inleft -= inreal ;
    inptr = 0 ;
  }

  inptr++ ;
  inreal-- ;
  return( (code_int)(unsigned char)InBuf[inptr-1] ) ;
}

/*************************************************************************/

static BOOL CompPutChar( char c )               // character write function for compress()
{						// and decompress()
  if ( ! OutBuf )
    FPutC( OutFile , c ) ;
  else
    *OutBuf++ = c ;

  OutSize++ ;
  if ( OutSize <= InSize ) return( TRUE ) ;
  return( FALSE ) ;
}

static BOOL CompPutBuf( char *b , int l )       // buffer write function for compress()
{
  if ( StopMe() ) return( FALSE ) ;

  if ( OutBuf )
  {
    memcpy( OutBuf , b , (size_t)l ) ;
    OutBuf += l ;
  }
  else
  {
    Flush( OutFile ) ;
    if ( Write( OutFile , b , l ) != l ) return( FALSE ) ;
    Flush( OutFile ) ;
  }

  OutSize += l ;
  if ( OutSize < InSize ) return( TRUE ) ;
  return( FALSE ) ;
}

/*************************************************************************/

static BOOL LoadBuffer( void )
{
  BOOL ret = FALSE ;

  if ( inleft )
  {
    inreal = MIN( inleft , insize ) ;
    if ( ReadData( Archive , InBuf , inreal ) )
    {
      ret = TRUE ;
      inleft -= inreal ;
      inptr = 0 ;
    }
  }

  if ( ! ret ) inreal = inleft = 0 ;
  return( ret ) ;
}

static code_int DecompGetByte( void )           // char read function for decompress()
{
  if ( (! inreal) && (! LoadBuffer()) ) return( IO_EOF ) ;

  inptr++ ;
  inreal-- ;
  return( (code_int)(unsigned char)InBuf[inptr-1] ) ;
}

static int DecompGetBuf( BYTE *pBuf , LONG Len )       // block read function for decompress()
{
  LONG k, read ;

  if ( StopMe() ) return( IO_BREAK ) ;

  read = 0 ;
  while ( Len > 0 )
  {
    if ( (! inreal) && (! LoadBuffer()) ) break ;

    k = MIN( Len , inreal ) ;
    memcpy( pBuf , &InBuf[inptr] , k ) ;
    pBuf   += k ;
    inptr  += k ;
    read   += k ;
    inreal -= k ;
    Len    -= k ;
  }

  return( read ) ;
}

/**************************************************************************
 * compress.c - File compression ala IEEE Computer, June 1984.
 *
 * Authors:	Spencer W. Thomas	(decvax!harpo!utah-cs!utah-gr!thomas)
 *		Jim McKie		(decvax!mcvax!jim)
 *		Steve Davies		(decvax!vax135!petsd!peora!srd)
 *		Ken Turkowski		(decvax!decwrl!turtlevax!ken)
 *		James A. Woods		(decvax!ihnp4!ames!jaw)
 *		Joe Orost		(decvax!vax135!petsd!joe)
 * Algorithm:
 *	Modified Lempel-Ziv method (LZW).  Basically finds common
 * substrings and replaces them with a variable size code.  This is
 * deterministic, and can be done on the fly.  Thus, the decompression
 * procedure needs no input table, but tracks the way the table was built.
 *
 * Set USERMEM to the maximum amount of physical user memory available
 * in bytes.  USERMEM is used to determine the maximum BITS that can be used
 * for compression.
 *
 * SACREDMEM is the amount of physical memory saved for others; compress
 * will hog the rest.
 */

#define SACREDMEM	0
#define BITS		13
#define HSIZE		9001	// 91% occupancy

/* Defines for header byte */

#define BIT_MASK	0x1f
#define BLOCK_MASK	0x80

/*
 * Masks 0x40 and 0x20 are free.  I think 0x20 should mean that there is
 * a fourth header byte (for expansion).
 */

#define INIT_BITS	9	// initial number of bits/code

static int n_bits;			// number of bits/code
static int maxbits = BITS;		// user settable max # bits/code
static code_int maxcode;		// maximum code, given n_bits
static code_int maxmaxcode = 1 << BITS; // should NEVER generate this code

#define MAXCODE(n_bits) ((1 << (n_bits)) - 1)

static count_int *htab = NULL ;
static unsigned short *codetab = NULL ;
#define htabof(i)       htab[i]
#define codetabof(i)    codetab[i]
static code_int hsize = HSIZE;		// for dynamic table sizing
static count_int fsize;

/*
 * To save much memory, we overlay the table used by compress() with those
 * used by decompress().  The tab_prefix table is the same size and type
 * as the codetab.  The tab_suffix table needs 2**BITS characters.  We
 * get this from the beginning of htab.  The output stack uses the rest
 * of htab, and contains characters.  There is plenty of room for any
 * possible stack (stack used to be 8000 characters).
 */

#define tab_prefixof(i) codetabof(i)
#define tab_suffixof(i) ((char_type *)(htab))[i]
#define de_stack	((char_type *)&tab_suffixof(1<<BITS))

static code_int free_ent = 0;		// first unused entry
static int exit_stat = 0;

static int nomagic = 0; 	// Use a 3-byte magic number header, unless old file
static int zcat_flg = 1;	// Write output on stdout, suppress messages
static int quiet = 1;		// don't tell me about compression

/*
 * block compression parameters -- after all codes are used up,
 * and compression rate changes, start over.
 */

static int block_compress = BLOCK_MASK;
static int clear_flg = 0;
static long int ratio = 0;
#define CHECK_GAP 10000 	// ratio check interval
static count_int checkpoint = CHECK_GAP;

/*
 * the next two codes should not be changed lightly, as they must not
 * lie within the contiguous general code space.
 */

#define FIRST	257	// first free entry
#define CLEAR	256	// table clear output code

static int offset;
static long int in_count = 1;		// length of input read till now
static long int out_count = 0;		// # of codes output (for debugging)

/*************************************************************************/

static BOOL SetupCompTables( void )     // Allocate tables for compress() and decompress()

{
  if ( ! htab ) htab = (count_int *)MyAllocMem( HSIZE*sizeof(count_int) , NULL ) ;
  if ( ! htab ) goto _no_mem ;

  if ( ! codetab ) codetab = (unsigned short *)MyAllocMem( HSIZE*sizeof(unsigned short) , NULL ) ;
  if ( ! codetab )
  {
    MyFreeMem( htab ) ;
    htab = NULL ;
_no_mem:
    return( FALSE ) ;
  }

  return( TRUE ) ;
}

/*************************************************************************/

void CleanupCompTables( void )

/* $DOC
 * FUNCTION
 *	Frees the tables used for internal compression/decompression.
 * $END
 */

{
  if ( htab ) MyFreeMem( htab ) ;
  htab = NULL ;

  if ( codetab ) MyFreeMem( codetab ) ;
  codetab = NULL ;
}

/*****************************************************************
 * TAG( output )
 *
 * Output the given code.
 * Inputs:
 *	code:	A n_bits-bit integer.  If == -1, then EOF.  This assumes
 *		that n_bits =< (long)wordsize - 1.
 * Outputs:
 *	Outputs code to the file.
 * Assumptions:
 *	Chars are 8 bits long.
 * Algorithm:
 *	Maintain a BITS character long buffer (so that 8 codes will
 * fit in it exactly).	Use the VAX insv instruction to insert each
 * code in turn.  When the buffer fills up empty it and start over.
 */

static char buf[BITS];

static char_type lmask[9] = {0xff, 0xfe, 0xfc, 0xf8, 0xf0, 0xe0, 0xc0, 0x80, 0x00};
static char_type rmask[9] = {0x00, 0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff};

static BOOL output( code_int code )
{
    char *bp = buf;
    int l, r_off = offset, bits = n_bits;

    if ( code >= 0 ) {
	/*
	 * Get to the first byte.
	 */
	bp += (r_off >> 3);
	r_off &= 7;
	/*
	 * Since code is always >= 8 bits, only need to mask the first
	 * hunk on the left.
	 */
	*bp = (*bp & rmask[r_off]) | (code << r_off) & lmask[r_off];
	bp++;
	bits -= (8 - r_off);
	code >>= 8 - r_off;
	/* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
	if ( bits >= 8 ) {
	    *bp++ = code;
	    code >>= 8;
	    bits -= 8;
	}
	/* Last bits. */
	if(bits) *bp = code;

	offset += n_bits;
	if ( offset == (n_bits << 3) ) {
	    bp = buf;
	    bits = n_bits;
	    do
	       if (! CompPutChar(*bp++)) return( FALSE ) ;
	    while(--bits);
	    offset = 0;
	}

	/*
	 * If the next entry is going to be too big for the code size,
	 * then increase it, if possible.
	 */
	if ( free_ent > maxcode || (clear_flg > 0))
	{
	    /*
	     * Write the whole buffer, because the input side won't
	     * discover the size increase until after it has read it.
	     */
	    if ( offset > 0 )
		if (! CompPutBuf( buf, n_bits )) return( FALSE ) ;
	    offset = 0;

	    if ( clear_flg ) {
		maxcode = MAXCODE (n_bits = INIT_BITS);
		clear_flg = 0;
	    }
	    else {
		n_bits++;
		if ( n_bits == maxbits )
		    maxcode = maxmaxcode;
		else
		    maxcode = MAXCODE(n_bits);
	    }
	}
    } else {
	/*
	 * At EOF, write the rest of the buffer.
	 */
	l = (offset + 7) / 8 ;
	if ( offset > 0 )
	  if (! CompPutBuf( buf, l )) return( FALSE ) ;
	offset = 0;
    }

    return( TRUE ) ;
}

/*************************************************************************/

static void cl_hash( count_int hsize ) /* reset code table */
{
	count_int *htab_p = htab+hsize;
	long i, m1 = -1;

	i = hsize - 16;
	do {				/* might use Sys V memset(3) here */
		*(htab_p-16) = m1;
		*(htab_p-15) = m1;
		*(htab_p-14) = m1;
		*(htab_p-13) = m1;
		*(htab_p-12) = m1;
		*(htab_p-11) = m1;
		*(htab_p-10) = m1;
		*(htab_p-9) = m1;
		*(htab_p-8) = m1;
		*(htab_p-7) = m1;
		*(htab_p-6) = m1;
		*(htab_p-5) = m1;
		*(htab_p-4) = m1;
		*(htab_p-3) = m1;
		*(htab_p-2) = m1;
		*(htab_p-1) = m1;
		htab_p -= 16;
	} while ((i -= 16) >= 0);

	for ( i += 16; i > 0; i-- ) *--htab_p = m1;
}

/*************************************************************************/

static void cl_block( void )           /* table clear for block compress */
{
    long int rat;

    checkpoint = in_count + CHECK_GAP;

    if(in_count > 0x007fffff) { /* shift will overflow */
	rat = OutSize >> 8;
	if(rat == 0) {          /* Don't divide by zero */
	    rat = 0x7fffffff;
	} else {
	    rat = in_count / rat;
	}
    } else {
	rat = (in_count << 8) / OutSize;      /* 8 fractional bits */
    }
    if ( rat > ratio ) {
	ratio = rat;
    } else {
	ratio = 0;
	cl_hash ( (count_int) hsize );
	free_ent = FIRST;
	clear_flg = 1;
	output ( (code_int) CLEAR ) ;
    }
}

/**************************************************************************
 * compress stdin to stdout
 *
 * Algorithm:  use open addressing double hashing (no chaining) on the
 * prefix code / next character combination.  We do a variant of Knuth's
 * algorithm D (vol. 3, sec. 6.4) along with G. Knott's relatively-prime
 * secondary probe.  Here, the modular division first probe is gives way
 * to a faster exclusive-or manipulation.  Also do block compression with
 * an adaptive reset, whereby the code table is cleared when the compression
 * ratio decreases, but after the table fills.	The variable-length output
 * codes are re-sized at this point, and a special CLEAR code is generated
 * for the decompressor.  Late addition:  construct the table according to
 * file size for noticeable speed improvement on small files.  Please direct
 * questions about this implementation to ames!jaw.
 */

static BOOL compress( void )
{
    long fcode;
    int disp, hshift ;
    code_int i = 0, c, ent, hsize_reg ;

    if ( ! SetupCompTables() ) return( FALSE ) ;

    /* set up variables for output buffer handling */

    insize = ( OutBuf ) ? InSize : IOMAXDATA ;
    inleft = ( OutBuf ) ?      0 : InSize ;
    inreal = ( OutBuf ) ? InSize : 0 ;
    inptr  = 0 ;

    /* write header byte */

    OutSize = 0 ;
    if (! CompPutChar((char)(maxbits | block_compress))) return( FALSE ) ;

    /* other initializations */

    offset = 0;
    out_count = 0;
    clear_flg = 0;
    ratio = 0;
    in_count = 1;
    checkpoint = CHECK_GAP;
    maxcode = MAXCODE(n_bits = INIT_BITS);
    free_ent = ((block_compress) ? FIRST : 256 );

    ent = CompGetChar() ;
    if ( ent == IO_EOF ) return( FALSE ) ;
    if ( ent == IO_BREAK ) return( FALSE ) ;
    if ( ent == IO_ERROR ) return( FALSE ) ;

    hshift = 0;
    for ( fcode = (long) hsize;  fcode < 65536L; fcode *= 2L ) hshift++;
    hshift = 8 - hshift;		/* set hash code range bound */

    hsize_reg = hsize;
    cl_hash( (count_int) hsize_reg);            /* clear hash table */

    while ( (c = CompGetChar()) != IO_EOF ) {
	if ( c == IO_BREAK ) return( FALSE ) ;
	if ( c == IO_ERROR ) return( FALSE ) ;

	in_count++;
	fcode = (long) (((long) c << maxbits) + ent);
	i = ((c << hshift) ^ ent);      /* xor hashing */

	if ( htabof (i) == fcode ) {
	    ent = codetabof (i);
	    continue;
	} else if ( (long)htabof (i) < 0 )      /* empty slot */
	    goto nomatch;
	disp = hsize_reg - i;		/* secondary hash (after G. Knott) */
	if ( i == 0 )
	    disp = 1;
probe:
	if ( (i -= disp) < 0 )
	    i += hsize_reg;

	if ( htabof (i) == fcode ) {
	    ent = codetabof (i);
	    continue;
	}
	if ( (long)htabof (i) > 0 )
	    goto probe;
nomatch:
	if (! output ( (code_int) ent )) return( FALSE ) ;
	out_count++;
	ent = c;
	if ( free_ent < maxmaxcode ) {
	    codetabof (i) = free_ent++; /* code -> hashtable */
	    htabof (i) = fcode;
	}
	else if ( (count_int)in_count >= checkpoint && block_compress )
	    cl_block ();
    }
    /*
     * Put out the final code.
     */
    if (! output( (code_int)ent )) return( FALSE ) ;
    out_count++;
    if (! output( (code_int)-1 )) return( FALSE ) ;

    return( TRUE ) ;
}

/*****************************************************************
 * TAG( getcode )
 *
 * Read one code from the standard input.  If EOF, return -1.
 * Inputs:
 *	stdin
 * Outputs:
 *	code or -1 is returned.
 */

static code_int getcode( void )
{
    code_int code;
    static int offset = 0, size = 0;
    static char_type buf[BITS];
    int r_off, bits;
    char_type *bp = buf;

    if ( clear_flg > 0 || offset >= size || free_ent > maxcode ) {
	/*
	 * If the next entry will be too big for the current code
	 * size, then we must increase the size.  This implies reading
	 * a new buffer full, too.
	 */
	if ( free_ent > maxcode ) {
	    n_bits++;
	    if ( n_bits == maxbits )
		maxcode = maxmaxcode;	/* won't get any bigger now */
	    else
		maxcode = MAXCODE(n_bits);
	}
	if ( clear_flg > 0) {
	    maxcode = MAXCODE (n_bits = INIT_BITS);
	    clear_flg = 0;
	}
	size = DecompGetBuf( buf , n_bits );
	if ( size == IO_BREAK ) return( IO_BREAK ) ;    /* breaked */
	if ( size <= 0 ) return( IO_EOF ) ;             /* end of file */
	offset = 0;
	/* Round size down to integral number of codes */
	size = (size << 3) - (n_bits - 1);
    }
    r_off = offset;
    bits = n_bits;

    /*
     * Get to the first byte.
     */
    bp += (r_off >> 3);
    r_off &= 7;
    /* Get first part (low order bits) */
    code = (*bp++ >> r_off);
    bits -= (8 - r_off);
    r_off = 8 - r_off;		    /* now, offset into code word */
    /* Get any 8 bit parts in the middle (<=1 for up to 16 bits). */
    if ( bits >= 8 ) {
       code |= *bp++ << r_off;
       r_off += 8;
       bits -= 8;
    }
    /* high order bits. */
    code |= (*bp & rmask[bits]) << r_off;

    offset += n_bits;

    return code;
}

/*
 * Decompress stdin to stdout.	This routine adapts to the codes in the
 * file building the "string" table on-the-fly; requiring no table to
 * be stored in the compressed file.  The tables used herein are shared
 * with those of the compress() routine.  See the definitions above.
 */

static BOOL decompress( void )
{
    int finchar ;
    char_type *stackp;
    code_int code, oldcode, incode;

    if ( ! SetupCompTables() ) return( FALSE ) ;

    maxbits = DecompGetByte();        /* set -b from file */
    if ( maxbits != MAGIC_HEADER ) return( FALSE ) ;

    block_compress = maxbits & BLOCK_MASK;
    maxbits &= BIT_MASK;
    maxmaxcode = 1 << maxbits;

    /*
     * As above, initialize the first 256 entries in the table.
     */
    maxcode = MAXCODE(n_bits = INIT_BITS);
    for ( code = 255; code >= 0; code-- ) {
	tab_prefixof(code) = 0;
	tab_suffixof(code) = (char_type)code;
    }
    free_ent = ((block_compress) ? FIRST : 256 );

    finchar = oldcode = getcode();
    if ( oldcode == IO_EOF ) return( FALSE ) ;
    if ( oldcode == IO_BREAK ) return( FALSE ) ;

			  /* first code must be 8 bits = char */
    OutSize = 0 ;
    if (! CompPutChar( (char)finchar )) return( FALSE ) ;
    stackp = de_stack;

    FOREVER {
	code = getcode() ;
	if ( code == IO_EOF ) break ;
	if ( code == IO_BREAK ) break ;

	if ( (code == CLEAR) && block_compress ) {
	    for ( code = 255; code >= 0; code-- )
		tab_prefixof(code) = 0;
	    clear_flg = 1;
	    free_ent = FIRST - 1;

	    code = getcode() ;
	    if ( code == IO_EOF ) break ;
	    if ( code == IO_BREAK ) break ;
	}
	incode = code;
	/*
	 * Special case for KwKwK string.
	 */
	if ( code >= free_ent ) {
	    *stackp++ = finchar;
	    code = oldcode;
	}

	/*
	 * Generate output characters in reverse order
	 */
	while ( code >= 256 ) {
	    *stackp++ = tab_suffixof(code);
	    code = tab_prefixof(code);
	}
	*stackp++ = finchar = tab_suffixof(code);

	/*
	 * And put them out in forward order
	 */
	do
	    if (! CompPutChar ( *--stackp )) return( FALSE ) ;
	while ( stackp > de_stack );

	/*
	 * Generate the new entry.
	 */
	if ( (code=free_ent) < maxmaxcode ) {
	    tab_prefixof(code) = (unsigned short)oldcode;
	    tab_suffixof(code) = finchar;
	    free_ent = code+1;
	}
	/*
	 * Remember previous code.
	 */
	oldcode = incode;
    }

    return( (BOOL)(code == IO_EOF) ) ;
}

