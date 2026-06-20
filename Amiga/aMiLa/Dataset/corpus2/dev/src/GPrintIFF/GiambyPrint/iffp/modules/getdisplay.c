
/*----------------------------------------------------------------------*
 * GETDISPLAY.C  Support routines for reading/displaying ILBM files.
 * (IFF is Interchange Format File.)
 *
 * Based on code by Jerry Morrison and Steve Shaw, Electronic Arts.
 * This software is in the public domain.
 * Modified for iffparse.library by CBM 04/90
 * This version for the Commodore-Amiga computer.
 *
 * 37.9  04/92 - use vp->ColorMap->Count instead of MAXAMCOLORREG
 * 37.10 07/92 - use scr->RastPort.BitMap instead of &scr->BitMap
 *			for future compatibility
 * 39.1  07/92 - add support for V39 color loading
 * 39.10 08/93 - add maxdisplaydepth() function (use instead of MAXAMDEPTH)
 *----------------------------------------------------------------------*/
#define INTUI_V36_NAMES_ONLY

#include "iffp/ilbm.h"
#include "iffp/packer.h"
#include "iffp/ilbmapp.h"

extern struct Library *GfxBase;

/* showilbm
 *
 * Passed an ILBMInfo initilized with with a not-in-use ParseInfo.iff
 *   IFFHandle and desired propchks, collectchks, stopchks, and a filename,
 *   will load and display an ILBM, initializing ilbm->Bmhd, ilbm->camg,
 *   ilbm->scr, ilbm->win, ilbm->vp, ilbm->srp, ilbm->wrp,
 *   ilbm->colortable, and ilbm->ncolors.
 *
 *   Note that ncolors may be more colors than you can LoadRGB4.
 *   Use MIN(ilbm->ncolors,vp->ColorMap->Count) for color count if you
 *   change the colors yourself using 1.3/2.0 functions.
 *
 * V39 - unless ilbm->IFFPFlags & IFFPF_NOCOLOR32, will do 32-bit
 *   color load under V39 and higher
 *
 * Returns 0 for success or an IFFERR (libraries/iffparse.h)
 */

LONG showilbm(struct ILBMInfo *ilbm, UBYTE *filename)
{
LONG error = 0L;

    if(!(ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

    if(!(error = openifile((struct ParseInfo *)ilbm, filename, IFFF_READ)))
	{

	error = parseifile((struct ParseInfo *)ilbm,
				ID_FORM, ID_ILBM,
				ilbm->ParseInfo.propchks,
				ilbm->ParseInfo.collectchks,
				ilbm->ParseInfo.stopchks);

	if((!error)||(error == IFFERR_EOC)||(error == IFFERR_EOF))
	    {

	    if(contextis(ilbm->ParseInfo.iff,ID_ILBM,ID_FORM))
		{
		if(error = createdisplay(ilbm))
		    {
		    deletedisplay(ilbm);
		    }
		}
	    else
		{
		message(SI(MSG_ILBM_NOILBM));
		error = NOFILE;
		}
	    }
	if(error)	closeifile((struct ParseInfo *)ilbm);
	}
    return(error);
}


/* unshowilbm
 *
 * frees and closes everything alloc'd/opened by showilbm
 * returns BOOL Success under V36 and above, always TRUE under <V36
 */
BOOL unshowilbm(struct ILBMInfo *ilbm)
{
	if(deletedisplay(ilbm))
	    {
	    closeifile((struct ParseInfo *)ilbm);
	    return(TRUE);
	    }
	else return(FALSE);
}



/* createdisplay
 *
 * Passed a initialized ILBMInfo with parsed IFFHandle (chunks parsed,
 * stopped at BODY),
 * opens/allocs the display and colortable, and displays the ILBM.
 *
 * If successful, sets up ilbm->Bmhd, ilbm->camg, ilbm->scr, ilbm->win,
 *   ilbm->vp,	ilbm->wrp, ilbm->srp and also ilbm->colortable and
 *   ilbm->ncolors.
 *
 * Note that ncolors may be more colors than you can LoadRGB4.
 *   Use MIN(ilbm->ncolors,vp->ColorMap->Count) for color count if you
 *   change the colors yourself using 1.3/2.0 functions.
 *
 * V39 - unless ilbm->IFFPFlags & IFFPF_NOCOLOR32, will do 32-bit
 *   color load under V39 and higher
 *
 * Returns 0 for success or an IFFERR (libraries/iffparse.h)
 */

LONG createdisplay(struct ILBMInfo *ilbm)
	{
	LONG error;

	error			= getdisplay(ilbm);

	if(!error)
		error	= loadbody(ilbm->ParseInfo.iff,
					ilbm->scr->RastPort.BitMap,&ilbm->Bmhd);

	if(!error)
		{
		if(!(getcolors(ilbm)))	setcolors(ilbm,ilbm->vp);
		}
	if(error)  deletedisplay(ilbm);
	return(error);
	}


/* deletedisplay
 *
 * closes and deallocates created display and colors
 * returns BOOL Success under V36 and above, always TRUE under <V36
 */
BOOL deletedisplay(struct ILBMInfo *ilbm)
	{
	if(freedisplay(ilbm))
	    {
	    freecolors(ilbm);
	    return(TRUE);
	    }
	else return(FALSE);
	}



/* getdisplay
 *
 * Passed an initialized ILBMInfo with a parsed IFFHandle (chunks parsed,
 * stopped at BODY),
 * gets the dimensions and mode for the display and calls the external
 * routine opendisplay().  Our opendisplay() is in the screen.c
 * module.  It opens a 2.0 or 1.3, ECS or non-ECS screen and window.
 * It also does 2.0 overscan centering based on the closest user prefs.
 *
 * If successful, sets up ilbm->Bmhd, ilbm->camg, ilbm->scr, ilbm->win,
 *   ilbm->vp, ilbm->wrp, ilbm->srp
 *
 * Returns 0 for success or an IFFERR (libraries/iffparse.h)
 */
LONG getdisplay(struct ILBMInfo *ilbm)
	{
	struct IFFHandle *iff;
	BitMapHeader *bmhd;
	ULONG				modeid;
	UWORD				wide, high, deep, maxdepth;


	if(!(iff=ilbm->ParseInfo.iff))	return(CLIENT_ERROR);

	if(!(bmhd = (BitMapHeader *)findpropdata(iff, ID_ILBM, ID_BMHD)))
		{
		message (SI(MSG_ILBM_NOBMHD));
		return(IFFERR_SYNTAX);
		}

	*(&ilbm->Bmhd)	= *bmhd;

	ilbm->camg = modeid = getcamg(ilbm);
	ilbm->usermodeid = modeid;
	wide = (RowBytes(bmhd->w)) >= (RowBytes(bmhd->pageWidth)) ?
		bmhd->w : bmhd->pageWidth;
	high = MAX(bmhd->h, bmhd->pageHeight);
	maxdepth = maxdisplaydepth(modeid);
	deep = MIN(bmhd->nPlanes,maxdepth);


	/*
	 * Open the display
	 */
	if(!(opendisplay(ilbm,wide,high,deep,modeid)))
		{
		message(SI(MSG_ILBM_NODISPLAY));
		return(1);
		}
	return(0);
	}


/* freedisplay
 *
 * closes and deallocates display from getdisplay (not colors)
 * returns BOOL Success under V36 and above, always TRUE under <V36
 */
BOOL freedisplay(struct ILBMInfo *ilbm)
	{
	return(closedisplay(ilbm));
	}


/* maxdisplaydepth
 *
 * Returns maximum display depth for specified display mode id
 */
UWORD maxdisplaydepth(ULONG displayid)
	{
	extern struct Library *GfxBase;
	DisplayInfoHandle displayhandle;
	struct DimensionInfo dimensioninfo;
	UWORD maxdepth = MAXAMDEPTH;

	if(GfxBase->lib_Version >= 37)
	    {
	    if(displayhandle=FindDisplayInfo(displayid))
		{
		if(GetDisplayInfoData(displayhandle,
			(UBYTE *)&dimensioninfo,
			sizeof(struct DimensionInfo),
			DTAG_DIMS,NULL))
		    {
		    maxdepth=dimensioninfo.MaxDepth;
		    }
		}
	    }
	return(maxdepth);
	}
