#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/clip.h>
#include <graphics/scale.h>
#include <exec/alerts.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include <stdio.h>
#include <math.h>

#define	WIDTH		(8+1)*40
#define	HEIGHT	(8+1)*10
#define	DEPTH		4

#define	ID			0x50021000		/* CLUT */
//#define	ID			0x50021100		/* HiColor */
//#define	ID			0x55011200		/* TrueColor */
//#define	ID			0x55021300		/* TrueAlpha */
void KPrintF(char *, ...);

#define BSAF_XSCALE 1
#define BSAF_YSCALE 2

main(void)
{
	struct Screen		*sc;
	struct Window		*wd;
	struct RastPort	*rp;
	struct Message		*msg;

	if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,DEPTH,TAG_DONE)) {

	  if(wd=OpenWindowTags(NULL,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW,WA_CustomScreen,sc,TAG_DONE)) {
	    struct BitScaleArgs	bsa;
	    ULONG	dstWidth, dstHeight;
	    struct BitMap *srcmap = AllocBitMap(sc->Width,sc->Height,8,0,NULL);

	    if (srcmap) {
	    
	      rp = &(sc->RastPort);
	      
	      Delay(50);
	      
	      SetDrMd(rp, JAM1);
	      SetAPen(rp, 1);
	      SetBPen(rp, 0);
	      
	      Move(rp,32,32+8);
	      Text(rp,"Test",4);
	      Move(rp,24,32+8+20);
	      Text(rp,"BitMapScale",11);

	      /*
	      ** Make a planar copy of the screen
	      */
	      BltBitMap(rp->BitMap,0,0,srcmap,0,0,sc->Width,sc->Height,0xc0,0xff,NULL);
	      
	      bsa.bsa_SrcX = 0;
	      bsa.bsa_SrcY = 0;
	      bsa.bsa_SrcWidth = 120;
	      bsa.bsa_SrcHeight = 80;
	      bsa.bsa_SrcBitMap = srcmap;
	      bsa.bsa_DestBitMap = rp->BitMap;
	      bsa.bsa_Flags = 0;
	      
	      bsa.bsa_DestX = 120;
	      bsa.bsa_XSrcFactor = 4;
	      bsa.bsa_XDestFactor = 3;
	      bsa.bsa_DestY = 80;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 3;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale down/down: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 140;
	      bsa.bsa_YSrcFactor = 1;
	      bsa.bsa_YDestFactor = 1;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale down/no: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 220;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 5;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale down/up: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestX = 210;
	      bsa.bsa_XSrcFactor = 1;
	      bsa.bsa_XDestFactor = 1;
	      bsa.bsa_DestY = 80;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 3;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale no/down: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 140;
	      bsa.bsa_YSrcFactor = 1;
	      bsa.bsa_YDestFactor = 1;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale no/no: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 220;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 5;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale no/up: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestX = 330;
	      bsa.bsa_XSrcFactor = 4;
	      bsa.bsa_XDestFactor = 5;
	      bsa.bsa_DestY = 80;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 3;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale up/down: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 140;
	      bsa.bsa_YSrcFactor = 1;
	      bsa.bsa_YDestFactor = 1;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale up/no: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      bsa.bsa_DestY = 220;
	      bsa.bsa_YSrcFactor = 4;
	      bsa.bsa_YDestFactor = 5;
	      BitMapScale(&bsa);
	      
	      dstWidth = ScalerDiv(bsa.bsa_SrcWidth, bsa.bsa_XDestFactor, bsa.bsa_XSrcFactor);
	      dstHeight = ScalerDiv(bsa.bsa_SrcHeight, bsa.bsa_YDestFactor, bsa.bsa_YSrcFactor);
	      
	      printf("Scale up/up: %ld x %ld (%ld x %ld)\n", bsa.bsa_DestWidth, bsa.bsa_DestHeight, dstWidth, dstHeight);
	      
	      WaitPort(wd->UserPort);
	      
	      Forbid();
	      while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
	      Permit();

	      FreeBitMap(srcmap);
	    }
	    
	    CloseWindow(wd);
	  }
	  CloseScreen(sc);
	}
}
