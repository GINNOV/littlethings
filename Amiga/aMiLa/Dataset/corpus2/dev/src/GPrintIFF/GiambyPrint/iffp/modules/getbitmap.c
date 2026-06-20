
/*----------------------------------------------------------------------*
 * GETBITMAP.C  Support routines for reading ILBM files.
 * (IFF is Interchange Format File.)
 *
 * Based on code by Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 * Modified for iffparse.library by CBM 04/90
 * This version for the Commodore-Amiga computer.
 *
 * 09/15/92 - conditionally use AllocBitMap instead of AllocRaster
 * 39.5 (11/92) - use RowBits() macro name instead of BitsPerRow()
 *----------------------------------------------------------------------*/

#include <clib/graphics_protos.h>
#include "iffp/ilbm.h"
#include "iffp/packer.h"
#include "iffp/ilbmapp.h"

/* createbrush
 *
 * Passed an initialized ILBMInfo with a parsed IFFHandle (chunks parsed,
 * stopped at BODY),
 * gets the bitmap and colors
 * Sets up ilbm->brbitmap, ilbm->colortable, ilbm->ncolors
 * Returns 0 for success
 */
LONG createbrush(struct ILBMInfo *ilbm)
	{
	int error;

	error 			= getbitmap(ilbm);
	if(!error) error 	= loadbody(ilbm->ParseInfo.iff,
						ilbm->brbitmap,&ilbm->Bmhd);
	if(!error) 		getcolors(ilbm);
	if(error)  		deletebrush(ilbm);
	return(error);
	}

/* deletebrush
 *
 * closes and deallocates created brush bitmap and colors
 */
void deletebrush(ilbm)
struct ILBMInfo		*ilbm;
	{
	freebitmap(ilbm);
	freecolors(ilbm);
	}


/* getbitmap
 *
 * Passed an initialized ILBMInfo with parsed IFFHandle (chunks parsed,
 * stopped at BODY), allocates a BitMap structure and planes just large
 * enough for the BODY.  Generally used for brushes but may be used
 * to load backgrounds without displaying, or to load deep ILBM's.
 * Sets ilbm->brbitmap.  Returns 0 for success.
 */
LONG getbitmap(struct ILBMInfo *ilbm)
	{
	struct IFFHandle	*iff;
	BitMapHeader	*bmhd;
	USHORT			wide, high;
	LONG  error = NULL;
	int k, extra=0;
	BYTE deep;

	if(!(iff=ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

	ilbm->brbitmap = NULL;

	if (!( bmhd = (BitMapHeader *)
			findpropdata(iff, ID_ILBM, ID_BMHD)))
		{
		message(SI(MSG_ILBM_NOBMHD));
		return(IFFERR_SYNTAX);
		}

	*(&ilbm->Bmhd) = *bmhd;	/* copy contents of BMHD */

	wide = RowBits(bmhd->w);
	high = bmhd->h;
	deep = bmhd->nPlanes;

	ilbm->camg = getcamg(ilbm);

	D(bug("allocbitmap: bmhd=$%lx wide=%ld high=%ld deep=%ld\n",
			bmhd,wide,high,deep));
	/*
	 * Allocate Bitmap and planes
	 */
        extra = deep > 8 ? deep - 8 : 0;

	if(GfxBase->lib_Version >= 39)
	    {
	    if(!(ilbm->brbitmap = 
		AllocBitMap(wide,high,deep,BMF_DISPLAYABLE|BMF_CLEAR, NULL)))
		    error = IFFERR_NOMEM;
	    }
	else if(ilbm->brbitmap = AllocMem(sizeof(struct BitMap) + (extra<<2),MEMF_CLEAR))
	    {
	    InitBitMap(ilbm->brbitmap,deep,wide,high);
	    for(k=0; k<deep && (!error); k++) 
		{
		if(!(ilbm->brbitmap->Planes[k] = AllocRaster(wide,high))) error = 1;
		if(! error)
			BltClear(ilbm->brbitmap->Planes[k],RASSIZE(wide,high),0);
		}
	    }
	else error = IFFERR_NOMEM;

	if(error)	
	    {
	    freebitmap(ilbm);
	    message(SI(MSG_ILBM_NORASTER));
	    }

	return(error);
	}

	
/* freebitmap
 *
 * deallocates ilbm->brbitmap BitMap structure and planes 
 */
void freebitmap(struct ILBMInfo * ilbm)
	{
	int k, extra=0;

	if(ilbm->brbitmap)
	    {
	    if(GfxBase->lib_Version >= 39)
		{
		FreeBitMap(ilbm->brbitmap);
		}
	    else
		{
		for(k=0; k< ilbm->brbitmap->Depth; k++) 
		    {
		    if(ilbm->brbitmap->Planes[k]) 
			FreeRaster(ilbm->brbitmap->Planes[k],
					   (USHORT)(ilbm->brbitmap->BytesPerRow << 3),
					   ilbm->brbitmap->Rows);
		    }

            	extra = ilbm->brbitmap->Depth > 8 ? ilbm->brbitmap->Depth - 8 : 0;
	    	FreeMem(ilbm->brbitmap,sizeof(struct BitMap) + (extra << 2));
		}
	    ilbm->brbitmap = NULL;
	    }
	}

/* end */
