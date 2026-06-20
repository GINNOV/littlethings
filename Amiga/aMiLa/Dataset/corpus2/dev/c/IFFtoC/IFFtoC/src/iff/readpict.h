#ifndef READPICT_H
#define READPICT_H
/** ReadPict.h **************************************************************/
/*                                                                          */
/* Read an ILBM raster image file into RAM.   1/23/86.                      */
/*                                                                          */
/* By Jerry Morrison, Steve Shaw, and Steve Hayes, Electronic Arts.         */
/* This software is in the public domain.                                   */
/*                                                                          */
/* USE THIS AS AN EXAMPLE PROGRAM FOR AN IFF READER.                        */  
/*                                                                          */
/* The IFF reader portion is essentially a recursive-descent parser.        */  
/****************************************************************************/
#if defined(__GNUC__)
#pragma pack(2)
#endif



/* ILBMFrame is our "client frame" for reading FORMs ILBM in an IFF file.
 * We allocate one of these on the stack for every LIST or FORM encountered
 * in the file and use it to hold BMHD & CMAP properties. We also allocate
 * an initial one for the whole file. */
typedef struct {
   ClientFrame clientFrame;
   UBYTE foundBMHD;
   UBYTE nColorRegs;
   BitMapHeader bmHdr;
   Color4 colorMap[32 /*1<<MaxAmDepth*/ ];
   /* If you want to read any other property chunks, e.g. GRAB or CAMG, add
    * fields to this record to store them. */
   } ILBMFrame;

/** ReadPicture() ***********************************************************
 *
 * Read a picture from an IFF file, given a file handle open for reading.
 * Allocates BitMap RAM by calling (*Allocator)(size).
 *
 ****************************************************************************/

typedef UBYTE *UBytePtr;

#ifdef FDwAT

typedef UBytePtr Allocator(LONG);
   /* Allocator: a memory allocation procedure which only requires a size
    * argument. (No Amiga memory flags argument.) */

extern IFFP ReadPicture(LONG, struct BitMap *, ILBMFrame *, Allocator *);
                    /*  file, bm,              iFrame,      allocator  */
   /* iFrame is the top level "client frame". */
   /* allocator is a ptr to your allocation procedure. It must always
    *   allocate in Chip memory (for bitmap data). */

   /* PS: Notice how we used two "typedef"s above to make allocator's type
    * meaningful to humans.
    * Consider the usual C style: UBYTE *(*)(), or is it (UBYTE *)(*()) ? */

#else /* not FDwAT */

typedef UBytePtr Allocator();
extern IFFP ReadPicture();

#endif

#if defined(__GNUC__)
#pragma pack()
#endif


#endif READPICT_H

