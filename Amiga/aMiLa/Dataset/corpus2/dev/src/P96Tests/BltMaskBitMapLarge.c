#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#define WIDTH 0x3c
#define HEIGHT 0xaa
#define DEPTH 8

main(void)
{
  struct Screen		*sc;
  
  if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,DEPTH,SA_Title,
		       "BltBitMap Test (Chunky to Planar)",SA_FullPalette,TRUE,TAG_DONE)) {
    struct Window		*wd;

    if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEMOVE|IDCMP_VANILLAKEY|IDCMP_INTUITICKS,
			 WA_CustomScreen,sc,TAG_DONE)) {
      struct BitMap   *maskbm = AllocBitMap(WIDTH,HEIGHT,1,BMF_CLEAR,NULL);
      if (maskbm) {
	struct BitMap *mainbm = AllocBitMap(WIDTH,HEIGHT,DEPTH,BMF_CLEAR,sc->RastPort.BitMap);
	if (mainbm) {
	  struct RastPort tmprp;
	  struct IntuiMessage  *msg;

	  InitRastPort(&tmprp);
	  tmprp.BitMap = maskbm;

	  SetAPen(&tmprp,1);
	  DrawEllipse(&tmprp,WIDTH >> 1,HEIGHT >> 1,WIDTH >> 2,HEIGHT >> 2);

	  InitRastPort(&tmprp);
	  tmprp.BitMap = mainbm;

	  SetAPen(&tmprp,1);
	  DrawEllipse(&tmprp,WIDTH >> 1,HEIGHT >> 1,WIDTH >> 2,HEIGHT >> 2);
			  
	  do {
	    WaitPort(wd->UserPort);
	    msg = (struct IntuiMessage *)GetMsg(wd->UserPort);

	    if (msg->Class == IDCMP_INTUITICKS) {
	      BltMaskBitMapRastPort(mainbm,0,0,wd->RPort,wd->MouseX,wd->MouseY,WIDTH,HEIGHT,0xe0,maskbm->Planes[0]);
	      ReplyMsg((struct Message *)msg);
	    } else if (msg->Class == IDCMP_VANILLAKEY) {
	      ReplyMsg((struct Message *)msg);
	      Forbid();
	      while(msg = (struct IntuiMessage *)GetMsg(wd->UserPort)) ReplyMsg((struct Message *)msg);
	      Permit();
	      break;
	    }
	  } while(1);
	}
      }
      CloseWindow(wd);
    }
    CloseScreen(sc);
  }
}
