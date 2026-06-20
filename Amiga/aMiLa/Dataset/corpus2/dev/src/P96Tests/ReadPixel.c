#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include	<stdio.h>

#define	WIDTH		2*32+8*32
#define	HEIGHT	32+32+64
#define	DEPTH		7
#define	ID			0x50018000

char buffer[20];

main(void)
{
	struct Window			*wd;
	struct RastPort		*rp;
	struct IntuiMessage	*imsg;
	struct Message			*msg;
	BOOL	quit = FALSE;

	if(wd=OpenWindowTags(NULL,WA_Width,WIDTH,WA_Height,HEIGHT,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_MOUSEBUTTONS,TAG_DONE))
	{
		rp = wd->RPort;

		while(!quit){
			WaitPort(wd->UserPort);
			if(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
				if(imsg->Class & IDCMP_CLOSEWINDOW) quit = TRUE;
				if(imsg->Class & IDCMP_MOUSEBUTTONS){
					LONG	pixel;
					pixel = ReadPixel(rp, imsg->MouseX, imsg->MouseY);
					sprintf(buffer,"Color %4ld",pixel);
					Move(rp, 20, 30);
					Text(rp, buffer, 10); 
				}
				ReplyMsg((struct Message *)imsg);
			}
		}
		
		Forbid();
		while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
		Permit();

		CloseWindow(wd);
	}
}
