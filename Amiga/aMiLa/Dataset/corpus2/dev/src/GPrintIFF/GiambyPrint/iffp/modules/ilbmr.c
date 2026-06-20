/* ilbmr.c --- ILBM loading routines for use with iffparse */

/*----------------------------------------------------------------------*
 * ILBMR.C  Support routines for reading ILBM files.
 * (IFF is Interchange Format File.)
 *
 * Based on code by Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 * Modified for iffparse.library 05/90
 * This version for the Commodore-Amiga computer.
 *
 * 37.9 04/92
 * 39.1 07/92 - add setcolors() and support for V39 color loading
 * 39.2 09/92 - only check AllShifted for colors that are used.
 * 39.3 09/92 - obey CMAPOK advisories
 * 39.4 09/92 - fix CMAPOK code (39.3 bug was ignoring colors if bit set)
 * 39.5 11/92 - add GetBitMapAttr/destWidthBytes check
 * 39.7  1/93 - clear modeid before calculating one for bad/missing camg
 *----------------------------------------------------------------------*/

#define INTUI_V36_NAMES_ONLY

#include "iffp/ilbm.h"
#include "iffp/packer.h"
#include "iffp/ilbmapp.h"

#define movmem CopyMem

#define MaxSrcPlanes (25)

extern struct Library *GfxBase;

/*---------- loadbody ---------------------------------------------------*/

LONG loadbody(iff, bitmap, bmhd)
struct IFFHandle *iff;
struct BitMap *bitmap;
BitMapHeader *bmhd;
	{
	BYTE *buffer;
	ULONG bufsize;
	LONG error = 1;


	if(!(currentchunkis(iff,ID_ILBM,ID_BODY)))
	    {
	    message(SI(MSG_ILBM_NOBODY));	/* Maybe it's a palette */
	    return(IFF_OKAY);
	    }

	if((bitmap)&&(bmhd))
	    {
	    bufsize = MaxPackedSize(RowBytes(bmhd->w)) << 4;
	    if(!(buffer = AllocMem(bufsize,0L)))
		{
		return(IFFERR_NOMEM);
		}
	    error = loadbody2(iff, bitmap, NULL, bmhd, buffer, bufsize);
	    FreeMem(buffer, bufsize);
	    }
	return(error);
	}


/* like the old GetBODY */
LONG loadbody2(iff, bitmap, mask, bmhd, buffer, bufsize)
struct IFFHandle *iff;
struct BitMap *bitmap;
BYTE *mask;
BitMapHeader *bmhd;
BYTE *buffer;
ULONG bufsize;
   {
   UBYTE srcPlaneCnt = bmhd->nPlanes;	/* Haven't counted for mask plane yet*/
   WORD srcRowBytes = RowBytes(bmhd->w);
   WORD destRowBytes = bitmap->BytesPerRow;   /* used as a modulo only */
   LONG bufRowBytes = MaxPackedSize(srcRowBytes);
   int nRows = bmhd->h;
   WORD destWidthBytes; 		/* used for width check */
   WORD compression = bmhd->compression;
   register int iPlane, iRow, nEmpty;
   register WORD nFilled;
   BYTE *buf, *nullDest, *nullBuf, **pDest;
   BYTE *planes[MaxSrcPlanes]; /* array of ptrs to planes & mask */
   struct ContextNode *cn;

   cn = CurrentChunk(iff);

   if (compression > cmpByteRun1)
      return(CLIENT_ERROR);

   /* If >=V39, this may be an interleaved bitmap with a BytesPerRow
    * which is truly just a modulo and actually includes ALL planes.
    * So instead, for bounds checking, we use the pixel width of
    * the BitMap rounded up to nearest WORD, since saved ILBMs
    * are always saved as their width rounded up to nearest WORD.
    */
   if(GfxBase->lib_Version >= 39)
	{
	destWidthBytes = RowBytes(GetBitMapAttr(bitmap,BMA_WIDTH));
	}
   else destWidthBytes = destRowBytes;

   /* Complain if client asked for a conversion GetBODY doesn't handle.*/
   if ( srcRowBytes  >	destWidthBytes	||
	 bufsize < bufRowBytes * 2  ||
	 srcPlaneCnt > MaxSrcPlanes )
      return(CLIENT_ERROR);

   if (nRows > bitmap->Rows)   nRows = bitmap->Rows;

   /* Initialize array "planes" with bitmap ptrs; NULL in empty slots.*/
   for (iPlane = 0; iPlane < bitmap->Depth; iPlane++)
      planes[iPlane] = (BYTE *)bitmap->Planes[iPlane];
   for ( ;  iPlane < MaxSrcPlanes;  iPlane++)
      planes[iPlane] = NULL;

   /* Copy any mask plane ptr into corresponding "planes" slot.*/
   if (bmhd->masking == mskHasMask)
	{
	if (mask != NULL)
	     planes[srcPlaneCnt] = mask;  /* If there are more srcPlanes than
	       * dstPlanes, there will be NULL plane-pointers before this.*/
	else
	     planes[srcPlaneCnt] = NULL;  /* In case more dstPlanes than src.*/
	srcPlaneCnt += 1;  /* Include mask plane in count.*/
	}

   /* Setup a sink for dummy destination of rows from unwanted planes.*/
   nullDest = buffer;
   buffer  += srcRowBytes;
   bufsize -= srcRowBytes;

   /* Read the BODY contents into client's bitmap.
    * De-interleave planes and decompress rows.
    * MODIFIES: Last iteration modifies bufsize.*/

   buf = buffer + bufsize;  /* Buffer is currently empty.*/
   for (iRow = nRows; iRow > 0; iRow--)
	{
	for (iPlane = 0; iPlane < srcPlaneCnt; iPlane++)
	    {
	    pDest = &planes[iPlane];

	    /* Establish a sink for any unwanted plane.*/
	    if (*pDest == NULL)
		{
		nullBuf = nullDest;
		pDest	= &nullBuf;
		}

	    /* Read in at least enough bytes to uncompress next row.*/
	    nEmpty  = buf - buffer;	  /* size of empty part of buffer.*/
	    nFilled = bufsize - nEmpty;   /* this part has data.*/
	    if (nFilled < bufRowBytes)
		{
		/* Need to read more.*/

		/* Move the existing data to the front of the buffer.*/
		/* Now covers range buffer[0]..buffer[nFilled-1].*/
		movmem(buf, buffer, nFilled);  /* Could be moving 0 bytes.*/

		if(nEmpty > ChunkMoreBytes(cn))
		    {
		    /* There aren't enough bytes left to fill the buffer.*/
		    nEmpty = ChunkMoreBytes(cn);
		    bufsize = nFilled + nEmpty;  /* heh-heh */
		    }

		/* Append new data to the existing data.*/
		if(ReadChunkBytes(iff, &buffer[nFilled], nEmpty) < nEmpty)
			return(CLIENT_ERROR);

		buf	= buffer;
		nFilled = bufsize;
		nEmpty	= 0;
		}

	    /* Copy uncompressed row to destination plane.*/
	    if(compression == cmpNone)
		{
		if(nFilled < srcRowBytes)  return(IFFERR_MANGLED);
		movmem(buf, *pDest, srcRowBytes);
		buf    += srcRowBytes;
		*pDest += destRowBytes;
		}
	    else
		{
		/* Decompress row to destination plane.*/
		if ( unpackrow(&buf, pDest, nFilled,  srcRowBytes) )
		    /*	pSource, pDest, srcBytes, dstBytes  */
			return(IFFERR_MANGLED);
		else *pDest += (destRowBytes - srcRowBytes);
		}
	    }
	}
   return(IFF_OKAY);
   }


/* ----------- getcolors ------------- */

/* getcolors - allocates a ilbm->colortable for at least 32 registers
 *	and loads CMAP colors into it, setting ilbm->ncolors to number
 *	of colors actually loaded.
 *
 * V39 and above: unless ilbm->IFFPFlags & IFFPF_NOCOLOR32, will also
 *  allocate and build a 32-bit per gun colortable (ilbm->colortable32)
 *  and ilbm->colorrecord for LoadRGB32().
 */

LONG getcolors(struct ILBMInfo *ilbm)
	{
	struct IFFHandle	*iff;
	LONG error;

	if(!(iff=ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

	if(!(error = alloccolortable(ilbm)))
	   error = loadcmap(ilbm);
	if(error) freecolors(ilbm);

	return(error);
	}


/* alloccolortable - allocates ilbm->colortable and sets ilbm->ncolors
 *	to the number of colors we have room for in the table.
 *
 * V39 and above: unless ilbm->IFFPFlags & IFFPF_NOCOLOR32, will also
 *  allocate and build a 32-bit per gun colortable (ilbm->colortable32)
 *  and ilbm->colorrecord for LoadRGB32()
 */

LONG alloccolortable(struct ILBMInfo *ilbm)
	{
	struct IFFHandle	*iff;
	struct	StoredProperty	*sp;

	LONG	error = CLIENT_ERROR;
	ULONG	ctabsize;
	USHORT	ncolors;

	if(!(iff=ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

	if(sp = FindProp (iff, ID_ILBM, ID_CMAP))
		{
		/*
		 * Compute the size table we need
		 */
		ncolors = sp->sp_Size / 3;		/* how many in CMAP */
		ncolors = MAX(ncolors, 32);		/* alloc at least 32 */

		ctabsize = ncolors * sizeof(Color4);
		if(ilbm->colortable =
		   (Color4 *)AllocMem(ctabsize,MEMF_CLEAR|MEMF_PUBLIC))
		    {
		    ilbm->ncolors = ncolors;
		    ilbm->ctabsize = ctabsize;
		    error = 0L;

		    if((GfxBase->lib_Version >= 39)&&
				(!(ilbm->IFFPFlags & IFFPF_NOCOLOR32)))
			{
			ctabsize = (ncolors * sizeof(Color32))+(4 * sizeof(WORD));
			if(ilbm->colorrecord = (WORD *)
			   AllocMem(ctabsize,MEMF_CLEAR|MEMF_PUBLIC))
			    {
			    ilbm->crecsize = ctabsize;
			    ilbm->colortable32 = (Color32 *)(&ilbm->colorrecord[2]);
			    ilbm->colorrecord[0] = ncolors;	/* For LoadRGB32 */
			    ilbm->colorrecord[1] = 0;
			    }
			else error = IFFERR_NOMEM;
			}
		    }
		else error = IFFERR_NOMEM;
		}

	if(error)	freecolors(ilbm);
	return(error);
	}


void freecolors(struct ILBMInfo *ilbm)
	{
	if(ilbm->colortable)
		{
		FreeMem(ilbm->colortable, ilbm->ctabsize);
		}
	ilbm->colortable = NULL;
	ilbm->ctabsize = 0;

	if(ilbm->colorrecord)
		{
		FreeMem(ilbm->colorrecord, ilbm->crecsize);
		}
	ilbm->colorrecord  = NULL;
	ilbm->colortable32 = NULL;
	ilbm->crecsize = 0;
	}



/* loadcmap - note interface change for V39
 *
 * Passed ILBMInfo
 *
 * Sets ncolors (and colorrecord if using it) to the number actually read.
 *
 *  New for V39 and above: If bmhd->flags BMHDF_CMAPOK is set,
 *  or if ILBMInfo->IFFPFlags IFFPF_CMAPOK is set, the 32-bit gun code
 *  will assume the CMAP contains 8-bit significant guns (R,G,B)
 *  and will not scale apparent 4-bit nibbles to 8 bits prior to
 *  scaling to 32 bits.  In the absence of either of these flags,
 *  if whole usable CMAP contains RGB values whose low nibbles are all 0,
 *  this code will first scale the RGB values to 8 bits ($30 becomes $33, etc)
 */

LONG loadcmap(struct ILBMInfo *ilbm)
    {
    struct StoredProperty	*sp;
    LONG			k;
    ULONG			ncolors, gun, ncheck;
    UBYTE			*rgb, rb, gb, bb;
    ULONG			nc, r, g, b;
    struct IFFHandle	*iff;
    BOOL AllShifted;


    if(!(iff=ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

    if(!(ilbm->colortable))
	{
	message(SI(MSG_ILBM_NOCOLORS));
	return(1);
	}

    if(!(sp = FindProp (iff, ID_ILBM, ID_CMAP)))	return(1);


    rgb = sp->sp_Data;

    /* file has this many colors */
    nc = sp->sp_Size / sizeofColorRegister;
    ncolors = nc;

    /* if ILBMInfo can't hold that many, we'll load less */
    if(ilbm->ncolors < ncolors) ncolors = ilbm->ncolors;
    /* set to how many we are loading */
    ilbm->ncolors = ncolors;

    /* how many colors to check for shifted nibbles (i.e. used colors) */
    ncheck = 1 << ilbm->Bmhd.nPlanes;
    if(ncheck > ncolors) ncheck = ncolors;

    if((GfxBase->lib_Version >= 39)
		&& (!(ilbm->IFFPFlags & IFFPF_NOCOLOR32))
			&&(ilbm->colorrecord))
	{
	ilbm->colorrecord[0] = ncolors;

	/* Assign to 32-bit table, examine for all-shifted nibbles at same time */
	AllShifted = TRUE;
	k = 0;
	while (ncheck--)
	    {
	    ilbm->colortable32[k].r = rb = *rgb++;
	    ilbm->colortable32[k].g = gb = *rgb++;
	    ilbm->colortable32[k].b = bb = *rgb++;
	    if(((rb & 0x0F) || (gb & 0x0F) || (bb & 0x0F)))
			AllShifted=FALSE;
	    k++;
	    }

	/* If no file/user indication that this is an 8-bit significant CMAP... */
	if( (!(ilbm->IFFPFlags & IFFPF_CMAPOK)) &&
		(!(ilbm->Bmhd.flags & BMHDF_CMAPOK)) )
	    {
	    /* If all nibbles appear shifted (4 bit), duplicate the nibbles */
	    if(AllShifted)
		{
		for(k = 0; k <nc; k++)
		    {
		    ilbm->colortable32[k].r |= (ilbm->colortable32[k].r >> 4);
		    ilbm->colortable32[k].g |= (ilbm->colortable32[k].g >> 4);
		    ilbm->colortable32[k].b |= (ilbm->colortable32[k].b >> 4);
		    }
		}
	    }

	/* Now scale to 32 bits */
	for(k = 0; k <nc; k++)
	    {
	    gun = ilbm->colortable32[k].r;
	    ilbm->colortable32[k].r |= ((gun << 24) | (gun << 16) | (gun << 8));
	    gun = ilbm->colortable32[k].g;
	    ilbm->colortable32[k].g |= ((gun << 24) | (gun << 16) | (gun << 8));
	    gun = ilbm->colortable32[k].b;
	    ilbm->colortable32[k].b |= ((gun << 24) | (gun << 16) | (gun << 8));
	    }
	}

    /* always make old-style table */
    rgb = sp->sp_Data;
    ncolors = nc;
    k = 0;
    while (ncolors--)
	 {
	 r = (*rgb++ & 0xF0) << 4;
	 g = *rgb++ & 0xF0;
	 b = *rgb++ >> 4;
	 ilbm->colortable[k] = r | g | b;
	 k++;
	 }
    return(0);
    }


/* setcolors - sets vp to ilbm->colortable or ilbm->colortable32
 *
 * V39 and above: unless ilbm->IFFPFlags & IFFPF_NOCOLOR32, will
 *  use 32-bit per gun colortable (ilbm->colortable32) and functions
 *
 * Returns client error if there is no ilbm->vp
 */
LONG setcolors(struct ILBMInfo *ilbm, struct ViewPort *vp)
    {
    LONG nc;
    LONG error = 0L;

    if(!(vp))	return(CLIENT_ERROR);

    nc = MIN(ilbm->ncolors,vp->ColorMap->Count);
    if((GfxBase->lib_Version >= 39)&&
		(! (ilbm->IFFPFlags & IFFPF_NOCOLOR32))&&
			(ilbm->colorrecord))
	{
	LoadRGB32(vp, (ULONG *)ilbm->colorrecord);
	}
    else if(ilbm->colortable)
	{
	LoadRGB4(vp, ilbm->colortable, nc);
	}
    error = CLIENT_ERROR;
    return(error);
    }


/*
 * Returns CAMG or computed mode for storage in ilbm->camg
 *
 * ilbm->Bmhd structure must be initialized prior to this call.
 */
ULONG getcamg(struct ILBMInfo *ilbm)
	{
	struct IFFHandle *iff;
	struct StoredProperty *sp;
	UWORD  wide,high,deep;
	ULONG modeid = 0L;

	if(!(iff=ilbm->ParseInfo.iff))	return(0L);

	wide = ilbm->Bmhd.pageWidth;
	high = ilbm->Bmhd.pageHeight;
	deep = ilbm->Bmhd.nPlanes;

	/*
	 * Grab CAMG's idea of the viewmodes.
	 */
	if (sp = FindProp (iff, ID_ILBM, ID_CAMG))
		{
		modeid = (* (ULONG *) sp->sp_Data);

		/* knock bad bits out of old-style 16-bit viewmode CAMGs
		 */
		if((!(modeid & MONITOR_ID_MASK))||
		  ((modeid & EXTENDED_MODE)&&(!(modeid & 0xFFFF0000))))
		   modeid &=
		    (~(EXTENDED_MODE|SPRITES|GENLOCK_AUDIO|GENLOCK_VIDEO|VP_HIDE));

		/* check for bogus CAMG like DPaintII brushes
		 * with junk in upper word and extended bit
		 * not set in lower word.
		 */
		if((modeid & 0xFFFF0000)&&(!(modeid & 0x00001000))) sp=NULL;

		}

	if(!sp) {
		/*
		 * No CAMG (or bad CAMG) present; use computed modes.
		 */
		modeid = 0L;		/* added in 39.6 */
		if (wide >= 640)	modeid = HIRES;
		if (high >= 400)	modeid |= LACE;
		if (deep == 6)
			{
			modeid |= ilbm->EHB ? EXTRA_HALFBRITE : HAM;
			}
		}

	if(ilbm->IFFPFlags & IFFPF_NOMONITOR) modeid &= (~MONITOR_ID_MASK);

	return(modeid);
	}
