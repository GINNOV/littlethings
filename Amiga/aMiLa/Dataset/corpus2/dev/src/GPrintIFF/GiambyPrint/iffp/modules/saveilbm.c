/* saveilbm.c 04/92  C. Scheppner CBM
 *
 * High-level ILBM save routines
 *
 * 37.10 07/92 - use scr->RastPort.BitMap instead of &scr->BitMap
 *			for future compatibility
 * 39.5 11/92 - raised BODYBUF size from 4096 to 5004 (should allow saving
 *              of bitmaps up to pixel width of 16384)
 */
#define INTUI_V36_NAMES_ONLY

#include "iffp/ilbm.h"
#include "iffp/ilbmapp.h"

extern struct Library *GfxBase;

/* screensave.c
 *
 * Given an ILBMInfo with a  currently available (not in use)
 *   ParseInfo->iff IFFHandle, a screen pointer, filename, and
 *   optional chunklist, will save screen as an ILBM
 * The struct Chunk *chunklist1 and 2 are for chunks you wish written
 * out other than BMHD, CMAP, and CAMG (they will be screened out
 * because they are computed and written separately).
 *
 * Note -  screensave passes NULL for transparent color and mask
 *
 * Returns 0 for success or an IFFERR (libraries/iffparse.h)
 */
LONG screensave(struct ILBMInfo *ilbm,
			struct Screen *scr,
			struct Chunk *chunklist1, struct Chunk *chunklist2,
			UBYTE *filename)
    {
    extern struct Library *GfxBase;
    Color32 *colortable32;
    UWORD *colortable, count;
    ULONG modeid;
    LONG error;
    int k;

    if(GfxBase->lib_Version >= 36)
	modeid=GetVPModeID(&scr->ViewPort);
    else
	modeid = scr->ViewPort.Modes & OLDCAMGMASK;

    count = scr->ViewPort.ColorMap->Count;

    error = IFFERR_NOMEM;

    if(GfxBase->lib_Version >= 39)
	{
    	if(colortable32 = (Color32 *)AllocMem(sizeof(Color32) * count, MEMF_CLEAR))
	    {
	    GetRGB32(scr->ViewPort.ColorMap,0L,count,(ULONG *)colortable32);
    	    error = saveilbm(ilbm, scr->RastPort.BitMap, modeid,
		scr->Width, scr->Height, scr->Width, scr->Height,
		colortable32, count, 32,
		mskNone, 0,
		chunklist1, chunklist2, filename);
	    FreeMem(colortable32,sizeof(Color32) * count);
	    }
	}
    else
	{
    	if(colortable = (UWORD *)AllocMem(count << 1, MEMF_CLEAR))
	    {
	    for(k=0; k<count; k++)
		colortable[k]=GetRGB4(scr->ViewPort.ColorMap,k);

    	    error = saveilbm(ilbm, scr->RastPort.BitMap, modeid,
		scr->Width, scr->Height, scr->Width, scr->Height,
		colortable, count, 4,
		mskNone, 0,
		chunklist1, chunklist2, filename);
	    FreeMem(colortable,count << 1);
	    }
	}
    return(error);
    }


/* saveilbm
 *
 * Given an ILBMInfo with a currently available (not-in-use)
 *   ParseInfo->iff IFFHandle, a BitMap ptr,
 *   modeid, widths/heights, colortable, ncolors, bitspergun,
 *   masking, transparent color, optional chunklists, and filename,
 *   will save the bitmap as an ILBM.
 *
 *  if bitspergun=4,  colortable is words, each with nibbles 0RGB
 *  if bitspergun=8,  colortable is byte guns of RGBRGB etc. (like a CMAP)
 *  if bitspergun=32, colortable is ULONG guns of RGBRGB etc.
 *     Only the high eight bits of each gun will be written to CMAP.
 *     Four bit guns n will be saved as nn
 *
 * The struct Chunk *chunklist is for chunks you wish written
 * other than BMHD, CMAP, and CAMG (they will be screened out)
 * because they are calculated and written separately
 *
 * Returns 0 for success, or an IFFERR
 */
LONG saveilbm(struct ILBMInfo *ilbm,
		struct BitMap *bitmap, ULONG modeid,
		WORD width, WORD height, WORD pagewidth, WORD pageheight,
		APTR colortable, UWORD ncolors, UWORD bitspergun,
		WORD masking, WORD transparentColor,
		struct Chunk *chunklist1, struct Chunk *chunklist2,
		UBYTE *filename)
{
struct IFFHandle *iff;
struct Chunk *chunk;
ULONG chunkID;
UBYTE *bodybuf;
LONG size, error = 0L;
#define BODYBUFSZ	5004

    iff = ilbm->ParseInfo.iff;

    if(!(modeid & 0xFFFF0000))	modeid &= OLDCAMGMASK;

    if(!(bodybuf = AllocMem(BODYBUFSZ,MEMF_PUBLIC)))
	{
	message(SI(MSG_IFFP_NOMEM));
	return(IFFERR_NOMEM);
	}

    if(!(error = openifile((struct ParseInfo *) ilbm, filename, IFFF_WRITE)))
	{
	D(bug("Opened %s for write\n",filename));

	error = PushChunk(iff, ID_ILBM, ID_FORM, IFFSIZE_UNKNOWN);

	D(bug("After PushChunk FORM ILBM - error = %ld\n", error));

        initbmhd(&ilbm->Bmhd, bitmap, masking, cmpByteRun1, transparentColor,
            		width, height, pagewidth, pageheight, modeid);

	D(bug("Error before putbmhd = %ld\n",error));

	CkErr(putbmhd(iff,&ilbm->Bmhd));	

	if(colortable)	CkErr(putcmap(iff,colortable,ncolors,bitspergun));


	if(ilbm->IFFPFlags & IFFPF_NOMONITOR) modeid &= (~MONITOR_ID_MASK);
	ilbm->camg = modeid;
	D(bug("before putcamg - error = %ld\n",error));
	CkErr(putcamg(iff,&modeid));

	D(bug("Past putBMHD, CMAP, CAMG - error = %ld\n",error));

	/* Write out chunklists 1 & 2 (if any), except for
	 * any BMHD, CMAP, or CAMG (computed/written separately)
	 */
	for(chunk = chunklist1; chunk; chunk = chunk->ch_Next)
	    {
	    D(bug("chunklist1 - have a %.4s\n",&chunk->ch_ID));
	    chunkID = chunk->ch_ID;
	    if((chunkID != ID_BMHD)&&(chunkID != ID_CMAP)&&(chunkID != ID_CAMG))
		{
		size = chunk->ch_Size==IFFSIZE_UNKNOWN ?
			strlen(chunk->ch_Data) : chunk->ch_Size;
		D(bug("Putting %.4s\n",&chunk->ch_ID));
		CkErr(PutCk(iff, chunkID, size, chunk->ch_Data));
		}
	    }

	for(chunk = chunklist2; chunk; chunk = chunk->ch_Next)
	    {
	    chunkID = chunk->ch_ID;
	    D(bug("chunklist2 - have a %.4s\n",&chunk->ch_ID));
	    if((chunkID != ID_BMHD)&&(chunkID != ID_CMAP)&&(chunkID != ID_CAMG))
		{
		size = chunk->ch_Size==IFFSIZE_UNKNOWN ?
			strlen(chunk->ch_Data) : chunk->ch_Size;
		D(bug("Putting %.4s\n",&chunk->ch_ID));
		CkErr(PutCk(iff, chunkID, size, chunk->ch_Data));
		}
	    }

	/* Write out the BODY
	 */
	CkErr(putbody(iff, bitmap, NULL, &ilbm->Bmhd, bodybuf, BODYBUFSZ));

	D(bug("Past putbody - error = %ld\n",error));


	CkErr(PopChunk(iff));	/* close out the FORM */
	closeifile((struct ParseInfo *) ilbm);	/* and the file */
	}

    FreeMem(bodybuf,BODYBUFSZ);

    return(error);
}

