#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <libraries/asl.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/Picasso96.h>
#include <proto/asl.h>

#include	<stdio.h>
#include	<string.h>

#define	PatSize	3
UWORD __chip Muster[(1L<<PatSize)]= { 0x8000, 0xc828, 0xe454, 0xfaaa, 0xfd55, 0xffaa, 0xffd4, 0xfff8 };

#define	WIDTH	4*32+8*32
#define	HEIGHT	32+32+64+32
#define	DEPTH	8

char	ScreenTitle[] = "Picasso96 AreaFill Test";
char	Template[] = "Width=W/N,Height=H/N,Depth=D/N";
LONG	Array[] = { 0, 0, 0 };
WORD	Pens[] = {~0};

Point inner[] = {
	{ 20-50 , 20-30},
	{ 100-50, 30-30},
	{ 30-50 , 80-30},
};

#define NUMVECTORS (sizeof(inner)/sizeof(Point))

WORD buffer[(((NUMVECTORS/2+1)*5)+1) & ~1];

main(void)
{
	ULONG	DisplayID;
	void *TmpBuf;
	struct TmpRas tmpras;
	struct ScreenModeRequester *smr;
	
	memset(buffer, 0, sizeof(buffer));

	if(smr = AllocAslRequest(ASL_ScreenModeRequest,NULL)) {
	  if (AslRequestTags(smr,TAG_DONE)) {
	    DisplayID = smr->sm_DisplayID;
	    if(INVALID_ID != DisplayID) {
	      struct Screen		*sc;

	      if(TmpBuf = AllocRaster(WIDTH, HEIGHT)){
		InitTmpRas(&tmpras, TmpBuf, ((WIDTH+7)/8) * HEIGHT);
		
		if(sc=OpenScreenTags(NULL,
				     SA_DisplayID,DisplayID,
				     SA_Depth,smr->sm_DisplayDepth,
				     SA_Width,smr->sm_DisplayWidth,
				     SA_Height,smr->sm_DisplayHeight,
				     SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,TAG_DONE)){
		  
		  struct Window		*wd;
		  struct Window         *wd2;
		  
		  if(wd=OpenWindowTags(NULL,WA_Left,0,
				       WA_Title,"Drawing Window",
				       WA_Width,smr->sm_DisplayWidth >> 1,
				       WA_Height,smr->sm_DisplayHeight >> 1,
				       WA_DragBar,TRUE,WA_DragBar,TRUE,WA_Activate,TRUE,WA_CloseGadget,TRUE,
				       WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_MOUSEBUTTONS,
				       WA_SmartRefresh,TRUE,
				       WA_CustomScreen,sc,TAG_DONE)){
		    if(wd2 = OpenWindowTags(NULL,
					    WA_Left,smr->sm_DisplayWidth >> 1,
					    WA_Title,"Blocking Window",
					    WA_Width,smr->sm_DisplayWidth >> 1,
					    WA_Height,smr->sm_DisplayHeight >> 1,
					    WA_DragBar,TRUE,WA_DragBar,TRUE,WA_Activate,TRUE,WA_CloseGadget,TRUE,
					    WA_CustomScreen,sc,TAG_DONE)){
		      struct RastPort	*rp, prp;
		      struct IntuiMessage *msg;
		      Point p;
		      int i, j, res;
		      struct AreaInfo area, *ai;
		      
		      rp = wd->RPort;
		      prp = *rp;
		      
		      ai = &area;
		      
		      rp->AreaInfo = ai;
		      rp->TmpRas   = &tmpras;
		      rp->AreaPtrn = Muster;
		      rp->AreaPtSz = PatSize;
		      
		      SetAPen(rp,1);
		      SetDrMd(rp,JAM2);
		      do {
			WaitPort(wd->UserPort);
			msg = (struct IntuiMessage *)GetMsg(wd->UserPort);
			if (msg->Class & IDCMP_CLOSEWINDOW)
			  break;
			if (msg->Class & IDCMP_MOUSEBUTTONS) {
			  LONG dx = msg->MouseX;
			  LONG dy = msg->MouseY;
			  
			  j = sizeof(inner)/sizeof(p);
			  InitArea(ai, buffer, NUMVECTORS+1);
			  AreaMove(rp, inner[j-1].x + dx, inner[j-1].y + dy);
			  for(i = 0; i<j; i++){
			    res = AreaDraw(rp, inner[i].x + dx, inner[i].y + dy);
			  }
			  AreaEnd(rp);
			}
			ReplyMsg((struct Message *)msg);
		      } while(TRUE);
		      
		      ReplyMsg((struct Message *)msg);
		      CloseWindow(wd2);
		    }
		    CloseWindow(wd);
		  }
		  CloseScreen(sc);
		}
		FreeRaster(TmpBuf, WIDTH, HEIGHT);
	      }
	    }
	  }
	  FreeAslRequest(smr);
	}
}
