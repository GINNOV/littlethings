#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include	<stdio.h>

#define	DEPTH	7
#define	ID	HIRESLACEKEY
#define SCANW   13
#define SCANH   13
#define	WIDTH	2*32+(8+2)*3*SCANW
#define	HEIGHT	32+(8+2)*SCANH

char buffer[20];

main(void)
{
	struct Window		*wd;
	struct RastPort		*rp;
	struct RastPort          tmprp;
	struct IntuiMessage	*imsg;
	struct Message		*msg;
	BOOL	quit = FALSE;
	ULONG bytesperrow = (((SCANW + 15) >> 4) << 4);
	UBYTE array[(((SCANW + 15) >> 4) << 4) * SCANH];
	UBYTE buffer[SCANW * 3];

	if(wd=OpenWindowTags(NULL,WA_Width,WIDTH,WA_Height,HEIGHT,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_MOUSEBUTTONS,TAG_DONE))
	{
		rp = wd->RPort;
		tmprp = *rp;
		tmprp.Layer = NULL;
		tmprp.BitMap = AllocBitMap(SCANW,1,rp->BitMap->Depth,BMF_CLEAR,rp->BitMap);

		if (tmprp.BitMap) {
		  while(!quit){
		    WaitPort(wd->UserPort);
		    if(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
		      if(imsg->Class & IDCMP_CLOSEWINDOW) quit = TRUE;
		      if(imsg->Class & IDCMP_MOUSEBUTTONS){
			LONG	x,y;

			ReadPixelArray8(rp, imsg->MouseX, imsg->MouseY,
					imsg->MouseX + SCANW - 1,imsg->MouseY + SCANH - 1,
					array,&tmprp);

			for(y = 0;y < SCANH;y++) {
			  for(x = 0;x < SCANW;x++) {
			    UBYTE digit = array[bytesperrow * y + x];
			    UBYTE hi    = digit >> 4;
			    UBYTE lo    = digit & 0x0f;
			    buffer[x * 3]     = (hi >= 0x0a)?(hi + 'a' - 0x0a):(hi + '0');
			    buffer[x * 3 + 1] = (lo >= 0x0a)?(lo + 'a' - 0x0a):(lo + '0');
			    buffer[x * 3 + 2] = ' ';
			  }
			  Move(rp, 20, 30 + y * rp->TxHeight);
			  Text(rp, buffer, x * 3);
			}
		      }
		      ReplyMsg((struct Message *)imsg);
		    }
		  }
		  FreeBitMap(tmprp.BitMap);
		}
		Forbid();
		while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
		Permit();

		CloseWindow(wd);
	}
}
