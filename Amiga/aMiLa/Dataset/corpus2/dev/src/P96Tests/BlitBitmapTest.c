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

char	ScreenTitle[] = "Picasso96 BlitBitmap Test";
LONG	Array[] = { 0, 0, 0 };
WORD	Pens[] = {~0};

main(void)
{
  ULONG	DisplayID;
  struct ScreenModeRequester *smr;
  int size = 5;
	
  if(smr = AllocAslRequest(ASL_ScreenModeRequest,NULL)) {
    if (AslRequestTags(smr,TAG_DONE)) {
      DisplayID = smr->sm_DisplayID;
      if(INVALID_ID != DisplayID) {
	struct Screen		*sc;

	if(sc=OpenScreenTags(NULL,
			     SA_DisplayID,DisplayID,
			     SA_Depth,smr->sm_DisplayDepth,
			     SA_Width,smr->sm_DisplayWidth,
			     SA_Height,smr->sm_DisplayHeight,
			     SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,TAG_DONE)){
	  
	  struct Window		*wd;
	  
	  if(wd=OpenWindowTags(NULL,WA_Left,0,
			       WA_Title,"Drawing Window",
			       WA_Width,smr->sm_DisplayWidth,
			       WA_Height,smr->sm_DisplayHeight,
			       WA_DragBar,TRUE,WA_DragBar,TRUE,WA_Activate,TRUE,WA_CloseGadget,TRUE,
			       WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,
			       WA_SmartRefresh,TRUE,
			       WA_CustomScreen,sc,TAG_DONE)){
	    int x    = smr->sm_DisplayWidth  >> 1;
	    int y    = smr->sm_DisplayHeight >> 1;
	    int size = 5;
	    int draw = 1;
	    struct RastPort	  *rp = wd->RPort;
	    struct IntuiMessage *msg;
	    
	    rp = wd->RPort;
	    
	    do {
	      if (draw) {
		SetRast(rp,0);
		RefreshWindowFrame(wd);
		SetAPen(rp,1);
		SetDrMd(rp,JAM2);
		rp->cp_x = x - size;
		rp->cp_y = y - size;
		Draw(rp,x + size,y - size);
		Draw(rp,x + size,y + size);
		Draw(rp,x - size,y + size);
		Draw(rp,x - size,y - size);
		draw = 0;
	      }
	      WaitPort(wd->UserPort);
	      msg = (struct IntuiMessage *)GetMsg(wd->UserPort);
	      if (msg->Class & IDCMP_CLOSEWINDOW)
		break;
	      if (msg->Class & IDCMP_RAWKEY) {
		int dx = 0;
		int dy = 0;
		switch(msg->Code) {
		case 0x21:
		  dx = -1;
		  break;
		case 0x11:
		  dx = -1;
		  dy = -1;
		  break;
		case 0x12:
		  dy = -1;
		  break;
		case 0x13:
		  dx = 1;
		  dy = -1;
		  break;
		case 0x23:
		  dx = 1;
		  break;
		case 0x34:
		  dx = 1;
		  dy = 1;
		  break;
		case 0x33:
		  dy = 1;
		  break;
		case 0x32:
		  dx = -1;
		  dy = 1;
		  break;
		case 0x4f:
		  if (size > 1) {
		    size--;
		    draw = 1;
		  }
		  break;
		case 0x4e:
		  if (size < 32) {
		    size++;
		    draw = 1;
		  }
		  break;
		}
		if (dx || dy) {
		  if (x + dx - size - 1 > 0 && x + dx + size + 1 < smr->sm_DisplayWidth &&
		      y + dy - size - 1 > 0 && y + dy + size + 1 < smr->sm_DisplayHeight) {
		    BltBitMap(rp->BitMap,x - size - 1     ,y - size - 1,
			      rp->BitMap,x - size - 1 + dx,y - size - 1 + dy,
			      1 + ((size + 1) << 1),1 + ((size + 1) << 1),0xc0,0xff,NULL);
		    x += dx;
		    y += dy;
		  }
		}
	      }
	      ReplyMsg((struct Message *)msg);
	    } while(TRUE);
	    
	    ReplyMsg((struct Message *)msg);
	    CloseWindow(wd);
	  }
	  CloseScreen(sc);
	}
      }
    }
    FreeAslRequest(smr);
  }
}
