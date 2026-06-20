#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/gfx.h>
#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <stdlib.h>

main(void)
{
	struct Screen		*sc;

	if(sc=OpenScreenTags(NULL,SA_Depth,8,SA_LikeWorkbench,TRUE,SA_Title,"BltBitMap Test (Planar to Chunky)",SA_FullPalette,TRUE,TAG_DONE))
	{
		struct Window		*wd;

		if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS,WA_CustomScreen,sc,TAG_DONE))
		{
			struct RastPort	*rp = &(sc->RastPort);
			struct Message		*msg;
			struct BitMap   *bm = AllocBitMap(wd->Width,wd->Height,8,0,NULL);

			if (bm) {
			  ULONG words = wd->Height * ((wd->Width + 15) >> 4);
			  int i,min;
			  for(i = 0;i < 8;i++) {
			    ULONG  t = words;
			    UWORD *p = (UWORD *)(bm->Planes[i]);
			    do {
			      *p = rand() ^ (t * 13) ^ (i * 23);
			      p++;
			    } while(--t);
			  }

			  for(i = 1;i <= 8;i++) {
			    for(min = 0;min < 0x100;min += 0x10) {
			      BltBitMap(bm,0,0,rp->BitMap,0,0,wd->Width,wd->Height,min,
					(1 << i) - 1,NULL);
			    }
			  }
			  FreeBitMap(bm);
			}

			//WaitPort(wd->UserPort);
			Forbid();
			while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
			Permit();

			CloseWindow(wd);
		}
		CloseScreen(sc);
	}
}
