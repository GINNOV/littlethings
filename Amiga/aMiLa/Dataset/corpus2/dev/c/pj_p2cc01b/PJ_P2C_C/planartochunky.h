/* The header file for Planar to Chunky function by Paymaan Jafari */

#ifndef PLANARTOCHUNKY_H
#define PLANARTOCHUNKY_H

#include	<stdio.h>
#include	<stdlib.h>
#include	<exec/types.h>

#define		BitsPerByte 8
#define		AND_FILTER	(1 << 7)


/* this function needs 4 parameters:
**
**Function:	PlanarToChunky()
**
**short:		Converts a planar picture data to chunky data.
**
**Inputs:
**	chunky_byte:	is a pointer to a clear allocated public memory that
**			it's size is (ImageByteSize * Depth) bytes.
**
**	*Planes:	is an array of pointers to the BitPlane, normally
**			it is a Planes[] in BitMap structure.
**
**	ImageByteSize:	is the size of each plane in bytes. It can be
**			calculated using (BytesPerRow * Height) both
**			from BitMap structure.
**
**	Depth:		is Depth of planar image, normally the Depth
**			in the BitMap structure.  It supports up to 8
**			bits depth images.
**
**Results:
**	A pointer to the converted chunky image or FALSE (0) for error.
**
**See Also:
**	ReadPixelArray8(), ReadPixel#?(), ReadChunkyPixel#?()
**
**Bugs:
**	Not tested for bugs yet.
**
**Author:	Paymaan Jafari Taayemeh of PALAPAL Amiga Programmers Group,
**	<payman@ctools.pp.se>
**	<palapal@ctools.pp.se>
**	<http://www.ctools.pp.se/palapal/>
*/

UBYTE *PlanarToChunky (	UBYTE *chunky_byte,
			UBYTE *Planes,
			int ImageByteSize,
			int Depth);
#endif

