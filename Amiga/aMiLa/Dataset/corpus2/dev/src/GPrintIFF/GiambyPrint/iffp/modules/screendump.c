/*
 * screendump.c    - routine to dump rastport (iffparse not required)
 *
 */
#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <intuition/screens.h>
#include <devices/printer.h>

#ifndef NO_PROTOS
#include <clib/exec_protos.h>
#include <clib/alib_protos.h>
#endif


/* screendump
 * 
 * Passed a screen pointer, source x, source y, width, height,
 *   destcols and io_Special flags, will print part or all of a screen.
 *
 * If 0 is passed for BOTH destcols and special, screendump()
 *   assumes you want IT to compute suitable values.
 * In this case:
 *   1. If srcx and srcy are 0, and srcw and srch are same as
 *      screen width and height, screendump will set destcols=0,
 *      and special = SPECIAL_FULLCOLS|SPECIAL_ASPECT
 *	for a full width aspected dump.
 *
 *   2. If srcx or srcy are nonzero, or srcw or srch are different
 *      from screen width or height, screendump will print a
 *      fractional size dump relative to the size whole screendump
 *      would have been.
 *
 * Returns 0 for success or printer io_Error (devices/printer.h)
 */

int screendump(struct Screen *scr,
		UWORD srcx, UWORD srcy, UWORD srcw, UWORD srch,
		LONG destcols, UWORD iospecial)
    {
    struct IODRPReq *iodrp;
    struct MsgPort  *printerPort;
    struct ViewPort *vp;
    ULONG tmpl;
    int error = PDERR_BADDIMENSION;

    if(!scr)	return(error);

    if((!destcols)&&(!iospecial))
	{
	/* Then we compute what they should be */
	if((!srcx)&&(!srcy)&&(srcw==scr->Width)&&(srch==scr->Height))
	    {
	    iospecial = SPECIAL_FULLCOLS|SPECIAL_ASPECT;
	    }
	else
	    {
	    iospecial = SPECIAL_FRACCOLS|SPECIAL_ASPECT;
	    tmpl = srcw;
	    tmpl = tmpl << 16;
	    destcols = (tmpl / scr->Width) << 16;
	    }
	}

    if(printerPort = CreatePort(0,0))
	{
	if(iodrp=
	   (struct IODRPReq *)CreateExtIO(printerPort,sizeof(struct IODRPReq)))
	    {
	    if(!(error=OpenDevice("printer.device",0,(struct IORequest *) iodrp,0)))
		{
            	vp = &scr->ViewPort;
            	iodrp->io_Command = PRD_DUMPRPORT;
            	iodrp->io_RastPort = &scr->RastPort;
            	iodrp->io_ColorMap = vp->ColorMap;
            	iodrp->io_Modes = (ULONG)vp->Modes;
 	    	iodrp->io_SrcX = srcx;
	    	iodrp->io_SrcY = srcy;
            	iodrp->io_SrcWidth = srcw;
            	iodrp->io_SrcHeight = srch;
	    	iodrp->io_DestCols = destcols;
	/*  	iodrp->io_DestRows = 0; cleared by allocation */
            	iodrp->io_Special = iospecial;

            	error = DoIO((struct IORequest *) iodrp);

            	CloseDevice((struct IORequest *) iodrp);
            	}
	    DeleteExtIO((struct IORequest *) iodrp);
  	    }
      	DeletePort(printerPort);
      	}
    return(error);
    }
