#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <cybergraphics/cybergraphics.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/cybergraphics.h>

UBYTE	Data[32*8] = {
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,0,0,1,1,1,1,2,2,2,2,0,0,3,3,3,3,0,0,1,1,1,1,2,2,2,2,0,0,3,3,
	3,3,0,0,2,2,2,2,1,1,1,1,0,0,3,3,3,3,0,0,2,2,2,2,1,1,1,1,0,0,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,0,0,4,4,4,4,5,5,5,5,0,0,3,3,3,3,0,0,4,4,4,4,5,5,5,5,0,0,3,3,
	3,3,0,0,5,5,5,5,4,4,4,4,0,0,3,3,3,3,0,0,5,5,5,5,4,4,4,4,0,0,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
};

#define DEPTH 8

main(void)
{
  struct Screen  *sc;
  struct Library *CyberGfxBase;

  if (CyberGfxBase = OpenLibrary("cybergraphics.library",2)) {
    if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Width,640,SA_Height,240,SA_Depth,DEPTH,SA_Title,
			 "WritePixelArray Test",SA_FullPalette,TRUE,TAG_DONE)) {
      struct Window		*wd;
      
      if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS,WA_CustomScreen,
			   sc,TAG_DONE)) {
	struct RastPort	*rp = &(sc->RastPort);
	struct Message		*msg;

	WritePixelArray(Data,0,0,32,rp,16+32,24+13,32,8,
			RECTFMT_LUT8);


	WaitPort(wd->UserPort);
	Forbid();
	while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
	Permit();
	
	CloseWindow(wd);
      }
      CloseScreen(sc);
    }
    CloseLibrary(CyberGfxBase);
  }
}
