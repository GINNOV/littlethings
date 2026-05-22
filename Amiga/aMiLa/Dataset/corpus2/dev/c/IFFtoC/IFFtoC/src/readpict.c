/** ReadPict.c **************************************************************
 *
 * Read an ILBM raster image file.   				23-Jan-86.
 *
 * By Jerry Morrison, Steve Shaw, and Steve Hayes, Electronic Arts.
 * This software is in the public domain.
 *
 * USE THIS AS AN EXAMPLE PROGRAM FOR AN IFF READER.
 *
 * The IFF reader portion is essentially a recursive-descent parser.
 ****************************************************************************/

#define LOCAL	static

#include "iff/intuall.h"
#include "libraries/dos.h"
#include "libraries/dosextens.h"
#include "iff/ilbm.h"
#include "iff/readpict.h"

/* This example's max number of planes in a bitmap. Could use MaxAmDepth. */
#define EXDepth 5
#define maxColorReg (1<<EXDepth)
#define MIN(a,b) ((a)<(b)?(a):(b))

#define SafeFreeMem(p,q) {if(p)FreeMem(p,q);}

/* Define the size of a temporary buffer used in unscrambling the ILBM rows.*/
#define bufSz 512

/*------------ ILBM reader -----------------------------------------------*/
/* ILBMFrame is our "client frame" for reading FORMs ILBM in an IFF file.
 * We allocate one of these on the stack for every LIST or FORM encountered
 * in the file and use it to hold BMHD & CMAP properties. We also allocate
 * an initial one for the whole file.
 * We allocate a new GroupContext (and initialize it by OpenRIFF or
 * OpenRGroup) for every group (FORM, CAT, LIST, or PROP) encountered. It's
 * just a context for reading (nested) chunks.
 *
 * If we were to scan the entire example file outlined below:
 *    reading          proc(s)                new               new
 *
 * --whole file--   ReadPicture+ReadIFF   GroupContext        ILBMFrame
 * CAT              ReadICat                GroupContext
 *   LIST           GetLiILBM+ReadIList       GroupContext        ILBMFrame
 *     PROP ILBM    GetPrILBM                   GroupContext
 *       CMAP       GetCMAP
 *       BMHD       GetBMHD
 *     FORM ILBM    GetFoILBM                   GroupContext        ILBMFrame
 *       BODY       GetBODY
 *     FORM ILBM    GetFoILBM                   GroupContext        ILBMFrame
 *       BODY       GetBODY
 *   FORM ILBM      GetFoILBM                 GroupContext        ILBMFrame
 */

/* NOTE: For a small version of this program, set Fancy to 0.
 * That'll compile a program that reads a single FORM ILBM in a file, which
 * is what DeluxePaint produces. It'll skip all LISTs and PROPs in the input
 * file. It will, however, look inside a CAT for a FORM ILBM.
 * That's suitable for 90% of the uses.
 *
 * For a fancier version that handles LISTs and PROPs, set Fancy to 1.
 * That'll compile a program that dives into a LIST, if present, to read
 * the first FORM ILBM. E.g. a DeluxePrint library of images is a LIST of
 * FORMs ILBM.
 *
 * For an even fancier version, set Fancy to 2. That'll compile a program
 * that dives into non-ILBM FORMs, if present, looking for a nested FORM ILBM.
 * E.g. a DeluxeVideo C.S. animated object file is a FORM ANBM containing a
 * FORM ILBM for each image frame. */
#define Fancy  0

/* Global access to client-provided pointers.*/
LOCAL Allocator *gAllocator = NULL;
LOCAL struct BitMap *gBM = NULL;	/* client's bitmap.*/
LOCAL ILBMFrame *giFrame = NULL;	/* "client frame".*/

/** GetFoILBM() *************************************************************
 *
 * Called via ReadPicture to handle every FORM encountered in an IFF file.
 * Reads FORMs ILBM and skips all others.
 * Inside a FORM ILBM, it stops once it reads a BODY. It complains if it
 * finds no BODY or if it has no BMHD to decode the BODY.
 *
 * Once we find a BODY chunk, we'll allocate the BitMap and read the image.
 *
 ****************************************************************************/
LOCAL BYTE bodyBuffer[bufSz];
IFFP GetFoILBM(parent)  GroupContext *parent;  {
   /*compilerBug register*/ IFFP iffp;
   GroupContext formContext;
   ILBMFrame ilbmFrame;		/* only used for non-clientFrame fields.*/
   register int i;
   LONG plsize;	/* Plane size in bytes. */
   int nPlanes; /* number of planes in our display image */

    /* Handle a non-ILBM FORM. */
    if (parent->subtype != ID_ILBM) {
#if Fancy >= 2
	/* Open a non-ILBM FORM and recursively scan it for ILBMs.*/
	iffp = OpenRGroup(parent, &formContext);
	CheckIFFP();
	do {
	    iffp = GetF1ChunkHdr(&formContext);
	    } while (iffp >= IFF_OKAY);
	if (iffp == END_MARK)
	    iffp = IFF_OKAY;	/* then continue scanning the file */
	CloseRGroup(&formContext);
	return(iffp);
#else
        return(IFF_OKAY); /* Just skip this FORM and keep scanning the file.*/
#endif
	}

   ilbmFrame = *(ILBMFrame *)parent->clientFrame;
   iffp = OpenRGroup(parent, &formContext);
   CheckIFFP();

   do switch (iffp = GetFChunkHdr(&formContext)) {
      case ID_BMHD: {
	ilbmFrame.foundBMHD = TRUE;
	iffp = GetBMHD(&formContext, &ilbmFrame.bmHdr);
	break; }
      case ID_CMAP: {
	ilbmFrame.nColorRegs = maxColorReg;  /* we have room for this many */
	iffp = GetCMAP(
	   &formContext, (WORD *)&ilbmFrame.colorMap[0], &ilbmFrame.nColorRegs);
			/* was &ilbmFrame.colorMap, (fixed) robp. */
	break; }
      case ID_BODY: {
         if (!ilbmFrame.foundBMHD)  return(BAD_FORM);	/* No BMHD chunk! */

	 nPlanes = MIN(ilbmFrame.bmHdr.nPlanes, EXDepth);
	 InitBitMap(
	    gBM,
	    nPlanes,
	    ilbmFrame.bmHdr.w,
	    ilbmFrame.bmHdr.h);
	 plsize = RowBytes(ilbmFrame.bmHdr.w) * ilbmFrame.bmHdr.h;
	 /* Allocate all planes contiguously.  Not really necessary,
	  * but it avoids writing code to back-out if only enough memory
	  * for some of the planes.
	  * WARNING: Don't change this without changing the code that
	  * Frees these planes.
	  */
	 if (gBM->Planes[0] =
		(PLANEPTR)(*gAllocator)(nPlanes * plsize))
	    {
	    for (i = 1; i < nPlanes; i++)
		gBM->Planes[i] = (PLANEPTR) gBM->Planes[0] + plsize*i;
	    iffp = GetBODY(
		&formContext,
		gBM,
		NULL,
		&ilbmFrame.bmHdr,
		bodyBuffer,
		bufSz);
	    if (iffp == IFF_OKAY) iffp = IFF_DONE;	/* Eureka */
	    *giFrame = ilbmFrame;  /* Copy fields to client's frame.*/
	    }
	 else 
	    iffp = CLIENT_ERROR;	/* not enough RAM for the bitmap */
         break; }
      case END_MARK: { iffp = BAD_FORM; break; } /* No BODY chunk! */
      } while (iffp >= IFF_OKAY);  /* loop if valid ID of ignored chunk or a
			  * subroutine returned IFF_OKAY (no errors).*/

   if (iffp != IFF_DONE)  return(iffp);

   /* If we get this far, there were no errors. */
   CloseRGroup(&formContext);
   return(iffp);
   }

/** Notes on extending GetFoILBM ********************************************
 *
 * To read more kinds of chunks, just add clauses to the switch statement.
 * To read more kinds of property chunks (GRAB, CAMG, etc.) add clauses to
 * the switch statement in GetPrILBM, too.
 *
 * To read a FORM type that contains a variable number of data chunks--e.g.
 * a FORM FTXT with any number of CHRS chunks--replace the ID_BODY case with
 * an ID_CHRS case that doesn't set iffp = IFF_DONE, and make the END_MARK
 * case do whatever cleanup you need.
 *
 ****************************************************************************/

/** GetPrILBM() *************************************************************
 *
 * Called via ReadPicture to handle every PROP encountered in an IFF file.
 * Reads PROPs ILBM and skips all others.
 *
 ****************************************************************************/
#if Fancy
IFFP GetPrILBM(parent)  GroupContext *parent;  {
   /*compilerBug register*/ IFFP iffp;
   GroupContext propContext;
   ILBMFrame *ilbmFrame = (ILBMFrame *)parent->clientFrame;

   if (parent->subtype != ID_ILBM)
      return(IFF_OKAY);	/* just continue scaning the file */

   iffp = OpenRGroup(parent, &propContext);
   CheckIFFP();

   do switch (iffp = GetPChunkHdr(&propContext)) {
      case ID_BMHD: {
	ilbmFrame->foundBMHD = TRUE;
	iffp = GetBMHD(&propContext, &ilbmFrame->bmHdr);
	break; }
      case ID_CMAP: {
	ilbmFrame->nColorRegs = maxColorReg; /* we have room for this many */
	iffp = GetCMAP(
	  &propContext, (WORD *)&ilbmFrame->colorMap, &ilbmFrame->nColorRegs);
	break; }
      } while (iffp >= IFF_OKAY);  /* loop if valid ID of ignored chunk or a
			  * subroutine returned IFF_OKAY (no errors).*/

   CloseRGroup(&propContext);
   return(iffp == END_MARK ? IFF_OKAY : iffp);
   }
#endif

/** GetLiILBM() *************************************************************
 *
 * Called via ReadPicture to handle every LIST encountered in an IFF file.
 *
 ****************************************************************************/
#if Fancy
IFFP GetLiILBM(parent)  GroupContext *parent;  {
    ILBMFrame newFrame;	/* allocate a new Frame */

    newFrame = *(ILBMFrame *)parent->clientFrame;  /* copy parent frame */

    return( ReadIList(parent, (ClientFrame *)&newFrame) );
    }
#endif

/** ReadPicture() **********************************************************/
IFFP ReadPicture(file, bm, iFrame, allocator)
   LONG file;
   struct BitMap *bm;
   ILBMFrame *iFrame;	/* Top level "client frame".*/

	/* **** ERROR IN SOURCE CODE, WAS jFrame, now iFrame */
	/* fixed */

   Allocator *allocator;
   {
   IFFP iffp = IFF_OKAY;

#if Fancy
   iFrame->clientFrame.getList = GetLiILBM;
   iFrame->clientFrame.getProp = GetPrILBM;
#else
   iFrame->clientFrame.getList = SkipGroup;
   iFrame->clientFrame.getProp = SkipGroup;
#endif
   iFrame->clientFrame.getForm = GetFoILBM;
   iFrame->clientFrame.getCat  = ReadICat ;

   /* Initialize the top-level client frame's property settings to the
    * program-wide defaults. This example just records that we haven't read
    * any BMHD property or CMAP color registers yet. For the color map, that
    * means the default is to leave the machine's color registers alone.
    * If you want to read a property like GRAB, init it here to (0, 0). */
   iFrame->foundBMHD  = FALSE;
   iFrame->nColorRegs = 0;

   gAllocator = allocator;
   gBM = bm;
   giFrame = iFrame;
  /* Store a pointer to the client's frame in a global variable so that
   * GetFoILBM can update client's frame when done.  Why do we have so
   * many frames & frame pointers floating around causing confusion?
   * Because IFF supports PROPs which apply to all FORMs in a LIST,
   * unless a given FORM overrides some property.  
   * When you write code to read several FORMs,
   * it is ssential to maintain a frame at each level of the syntax
   * so that the properties for the LIST don't get overwritten by any
   * properties specified by individual FORMs.
   * We decided it was best to put that complexity into this one-FORM example,
   * so that those who need it later will have a useful starting place.
   */

   iffp = ReadIFF(file, (ClientFrame *)iFrame);
   return(iffp);
   }

