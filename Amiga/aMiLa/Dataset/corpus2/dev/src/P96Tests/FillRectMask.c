#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

main(void)
{
  struct Screen		*sc;
  
  if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,8,SA_Title,"RectFill mask test",SA_FullPalette,TRUE,TAG_DONE))
	{
	  struct Window		*wd;
	  
	  if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS,WA_CustomScreen,sc,TAG_DONE))
	    {
	      struct RastPort	*rp = &(sc->RastPort);
	      struct Message		*msg;

	      SetAPen(rp,0xff);
	      
	      rp->Mask = 0x01;
	      RectFill(rp,10,10,200,100);

	      rp->Mask = 0x02;
	      RectFill(rp,30,30,230,130);

	      WaitPort(wd->UserPort);
	      Forbid();
	      while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
	      Permit();
	      
	      CloseWindow(wd);
	    }
	  CloseScreen(sc);
	}
}
