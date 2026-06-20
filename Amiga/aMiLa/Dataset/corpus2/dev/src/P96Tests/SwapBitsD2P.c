#include <exec/memory.h>
#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/clip.h>
#include <graphics/scale.h>
#include <exec/alerts.h>
#define NEWCLIPRECTS_1_1 1
#include <graphics/clip.h>
#include <boardinfo.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/layers.h>
#include <proto/rtg.h>

#include <stdio.h>
#include <math.h>

#define	WIDTH	(8+1)*40
#define	HEIGHT	(8+1)*10
#define	DEPTH	4

main(void)
{
  struct Screen		*sc;
  struct Window		*wd;
  struct RastPort	*rp;
  struct Message	*msg;
  struct Library        *RTGBase;
  struct ClipRect       *cr;
  struct BitMap         *bm;

  if (RTGBase = OpenLibrary("rtg.library",42)) {
    
    if (cr = AllocMem(sizeof(struct ClipRect),MEMF_PUBLIC|MEMF_CLEAR)) {
      
      if (sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,DEPTH,TAG_DONE)) {

	if (wd=OpenWindowTags(NULL,WA_DragBar,TRUE,WA_CloseGadget,TRUE,
			      WA_IDCMP,IDCMP_CLOSEWINDOW,WA_CustomScreen,sc,TAG_DONE)) {

	  if (bm = rtgAllocBitMapTags(NULL,WIDTH,HEIGHT,
				      ABMA_RGBFormat,RGBFB_R5G5B5PC,
				      ABMA_Clear,TRUE,
				      ABMA_Friend,sc->RastPort.BitMap,
				      ABMA_ColorMap,sc->ViewPort.ColorMap,
				      TAG_DONE)) {
	    cr->bounds.MinX = 32;
	    cr->bounds.MinY = 32;
	    cr->bounds.MaxX = cr->bounds.MinX + WIDTH  - 1;
	    cr->bounds.MaxY = cr->bounds.MinY + HEIGHT - 1;
	    cr->BitMap      = bm;
	    
	    rp              = &(sc->RastPort);

	    SetDrMd(rp, JAM1);
	    SetAPen(rp, 1);
	    SetBPen(rp, 0);
	    
	    Move(rp,32,32+8);
	    Text(rp,"Test",4);
	    Move(rp,24,32+8+20);
	    Text(rp,"BitMapScale",11);

	    Delay(50L);

	    SwapBitsRastPortClipRect(rp,cr);

	    WaitPort(wd->UserPort);
			
	    Forbid();
	    while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
	    Permit();

	    SwapBitsRastPortClipRect(rp,cr);
	    Delay(50L);

	    rtgFreeBitMapTags(NULL,bm,TAG_DONE);
	  }
	  CloseWindow(wd);
	}
	CloseScreen(sc);
      }
      FreeMem(cr,sizeof(struct ClipRect));
    }
    CloseLibrary(RTGBase);
  }
}
