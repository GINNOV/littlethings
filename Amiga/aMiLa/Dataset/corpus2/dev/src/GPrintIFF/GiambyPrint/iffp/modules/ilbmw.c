/*----------------------------------------------------------------------*
 * ILBMW.C  Support routines for writing ILBM files using IFFParse.
 * (IFF is Interchange Format File.)
 *
 * Based on code by Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 *
 * This version for the Commodore-Amiga computer.
 *
 * mod 06-Apr-92 - Add JM change for separate source and dest modulo
 * 39.5 (11/92) - in putbody, changed bufsize check to compare against
 *                FileRowBytes (amount being written), not rowBytes
 *----------------------------------------------------------------------*/
#define INTUI_V36_NAMES_ONLY

#include "iffp/ilbm.h"
#include "iffp/packer.h"

#include <graphics/gfxbase.h>

extern struct Library *GfxBase;

/*---------- initbmhd -------------------------------------------------*/
long initbmhd(BitMapHeader *bmhd, struct BitMap *bitmap,
	      WORD masking, WORD compression, WORD transparentColor,
	      WORD width, WORD height, WORD pageWidth, WORD pageHeight,
	      ULONG modeid)
    {
    extern struct Library *GfxBase;
    struct DisplayInfo DI;

    D(bug("In InitBMHD\n"));

    if((!bmhd)||(!bitmap)||(!width)||(!height))
	return(CLIENT_ERROR);

    bmhd->w = width;
    bmhd->h = height;
    bmhd->x = bmhd->y = 0;	/* Default position is (0,0).*/
    bmhd->nPlanes = bitmap->Depth;
    bmhd->masking = masking;
    bmhd->compression = compression;
    bmhd->flags = BMHDF_CMAPOK;	/* we will store 8 significant bits */
    bmhd->transparentColor = transparentColor;
    bmhd->pageWidth = pageWidth;
    bmhd->pageHeight = pageHeight;

    bmhd->xAspect = 0;	/* So we can tell when we've got it */
    if(GfxBase->lib_Version >=36)
	{
   	if(GetDisplayInfoData(NULL, (UBYTE *)&DI,
		sizeof(struct DisplayInfo), DTAG_DISP, modeid))
		{
    		bmhd->xAspect =  DI.Resolution.x;
    		bmhd->yAspect =  DI.Resolution.y;
		}
	}

    /* If running under 1.3 or GetDisplayInfoData failed, use old method
     * of guessing aspect ratio
     */
    if(! bmhd->xAspect)
	{
    	bmhd->xAspect =  44;
    	bmhd->yAspect =
		((struct GfxBase *)GfxBase)->DisplayFlags & PAL ? 44 : 52;
    	if(modeid & HIRES)	bmhd->xAspect = bmhd->xAspect >> 1;
    	if(modeid & LACE)	bmhd->yAspect = bmhd->yAspect >> 1;
	}

    return( IFF_OKAY );
    }

/*---------- putcmap ---------------------------------------------------*/
/* This function will accept a table of color values in one of the
 * following forms:
 *  if bitspergun=4,  colortable is words, each with nibbles 0RGB
 *  if bitspergun=8,  colortable is bytes of RGBRGB etc. (like a CMAP)
 *  if bitspergun=32, colortable is ULONGS of RGBRGB etc.
 *     (only the high eight bits of each gun will be written to CMAP)
 */
long putcmap(struct IFFHandle *iff, APTR colortable,
	     UWORD ncolors, UWORD bitspergun)
   {
   long error, offs;
   WORD  *tabw;
   UBYTE *tab8;
   ColorRegister cmapReg;

   D(bug("In PutCMAP\n"));

   if((!iff)||(!colortable))	return(CLIENT_ERROR);

   /* size of CMAP is 3 bytes * ncolors */
   if(error = PushChunk(iff, NULL, ID_CMAP, ncolors * sizeofColorRegister))
	return(error);

   D(bug("Pushed ID_CMAP, error = %ld\n",error));

   if(bitspergun == 4)
	{
   	/* Store each 4-bit value n as nn */
	tabw = (UWORD *)colortable;
   	for( ;  ncolors;  --ncolors )
	    {
      	    cmapReg.red    = ( *tabw >> 4 ) & 0xf0;
      	    cmapReg.red   |= (cmapReg.red >> 4);

      	    cmapReg.green  = ( *tabw      ) & 0xf0;
      	    cmapReg.green |= (cmapReg.green >> 4);

      	    cmapReg.blue   = ( *tabw << 4 ) & 0xf0;
      	    cmapReg.blue  |= (cmapReg.blue >> 4);

      	    if((WriteChunkBytes(iff, (BYTE *)&cmapReg, sizeofColorRegister))
                != sizeofColorRegister)
                        return(IFFERR_WRITE);
      	    ++tabw;
      	    }
	}
   else if((bitspergun == 8)||(bitspergun == 32))
	{
	tab8 = (UBYTE *)colortable;
	offs = (bitspergun == 8) ? 1 : 4;
   	for( ;  ncolors;  --ncolors )
	    {
	    cmapReg.red   = *tab8;
	    tab8 += offs;
	    cmapReg.green = *tab8;
	    tab8 += offs;
	    cmapReg.blue  = *tab8;
	    tab8 += offs;
      	    if((WriteChunkBytes(iff, (BYTE *)&cmapReg, sizeofColorRegister))
                != sizeofColorRegister)
                        return(IFFERR_WRITE);
	    }
	}
   else (error = CLIENT_ERROR);

   D(bug("Wrote registers, error = %ld\n",error));

   error = PopChunk(iff);
   return(error);
   }

/*---------- putbody ---------------------------------------------------*/
/* NOTE: This implementation could be a LOT faster if it used more of the
 * supplied buffer. It would make far fewer calls to IFFWriteBytes (and
 * therefore to DOS Write).
 *
 * Incorporates modification by Jesper Steen Moller to accept source
 * rows wider than dest rows, with one modulo variable for source bitplane
 * rows and one for the ILBM bitmap rows.
 */
long putbody(struct IFFHandle *iff, struct BitMap *bitmap, BYTE *mask,
	     BitMapHeader *bmhd, BYTE *buffer, LONG bufsize)
   {
   long error;
   LONG rowBytes = bitmap->BytesPerRow;	   /* for source modulo only */
   LONG FileRowBytes = RowBytes(bmhd->w);  /* width to write in bytes */
   int dstDepth = bmhd->nPlanes;
   UBYTE compression = bmhd->compression;
   int planeCnt;		/* number of bit planes including mask */
   register int iPlane, iRow;
   register LONG packedRowBytes;
   BYTE *buf;
   BYTE *planes[MAXSAVEDEPTH + 1]; /* array of ptrs to planes & mask */

   D(bug("In PutBODY, rows = %ld, rowBytes = %ld, expected %ld\n", bitmap->Rows, rowBytes, RowBytes(bmhd->w)));

   if ( bufsize < MaxPackedSize(FileRowBytes)  || /* Must buffer a comprsd row*/
        compression > cmpByteRun1  ||		  /* bad arg */
	bitmap->Rows != bmhd->h   ||		  /* inconsistent */
	rowBytes < FileRowBytes  ||	          /* inconsistent*/
	bitmap->Depth < dstDepth   ||		  /* inconsistent */
	dstDepth > MAXSAVEDEPTH )		  /* too many for this routine*/
        return(CLIENT_ERROR);

   planeCnt = dstDepth + (mask == NULL ? 0 : 1);

   /* Copy the ptrs to bit & mask planes into local array "planes" */
   for (iPlane = 0; iPlane < dstDepth; iPlane++)
      planes[iPlane] = (BYTE *)bitmap->Planes[iPlane];
   if (mask != NULL)
      planes[dstDepth] = mask;

   /* Write out a BODY chunk header */
   if(error = PushChunk(iff, NULL, ID_BODY, IFFSIZE_UNKNOWN)) return(error);

   /* Write out the BODY contents */
   for (iRow = bmhd->h; iRow > 0; iRow--)  {
      for (iPlane = 0; iPlane < planeCnt; iPlane++)  {

         /* Write next row.*/
         if (compression == cmpNone) {
	    if(WriteChunkBytes(iff,planes[iPlane],FileRowBytes) != FileRowBytes)
		error = IFFERR_WRITE;
            planes[iPlane] += rowBytes; /* Possibly skipping unused bytes */
            }

         /* Compress and write next row.*/
         else {
            buf = buffer;
            packedRowBytes = packrow(&planes[iPlane], &buf, FileRowBytes);
	    /* Note that packrow incremented planes already by FileRowBytes */
            planes[iPlane] += rowBytes-FileRowBytes; /* Possibly skipping unused bytes */
	    if(WriteChunkBytes(iff,buffer,packedRowBytes) != packedRowBytes)
		error = IFFERR_WRITE;
            }

         if(error)	return(error);
         }
      }

   /* Finish the chunk */
   error = PopChunk(iff);
   return(error);
   }
