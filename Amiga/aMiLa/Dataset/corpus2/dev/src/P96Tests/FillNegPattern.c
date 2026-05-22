#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

UWORD Muster[5][2]=
{
	{0x0000,0x0000},
	{0x000f,0x000f},
	{0x00f0,0x00f0},
	{0x0f00,0x0f00},
	{0xf000,0xf000}
};

#define	WIDTH		2*32+8*32
#define	HEIGHT	32+32+64
#define	DEPTH		5
#define	ID			0x50018000
main(void)
{
	struct Screen		*sc;
	struct Window		*wd;
	struct RastPort	*rp;
	struct Message		*msg;

	if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_DisplayID,ID,SA_Depth,DEPTH,SA_FullPalette,TRUE,TAG_DONE))
	{
		if(wd=OpenWindowTags(NULL,WA_Width,WIDTH,WA_Height,HEIGHT,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW,WA_CustomScreen,sc,TAG_DONE))
		{
			rp = wd->RPort;

//			SetAPen(rp, 3);
//			RectFill(rp, 32+0*32, 32, 63+7*32, 47);

//			SetAPen(rp, 0xaa);
//			SetBPen(rp,	0x55);

			SetAPen(rp, 255);
			SetBPen(rp,	0);

			SetAfPt(rp, &Muster[0][0], -1);

			SetDrMd(rp, JAM1);
			RectFill(rp, 32+0*32, 32, 63+0*32, 63);
			SetDrMd(rp, JAM1|INVERSVID);
			RectFill(rp, 32+1*32, 32, 63+1*32, 63);
			SetDrMd(rp, JAM1|COMPLEMENT);
			RectFill(rp, 32+2*32, 32, 63+2*32, 63);
			SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
			RectFill(rp, 32+3*32, 32, 63+3*32, 63);
			SetDrMd(rp, JAM2);
			RectFill(rp, 32+4*32, 32, 63+4*32, 63);
			SetDrMd(rp, JAM2|INVERSVID);
			RectFill(rp, 32+5*32, 32, 63+5*32, 63);
			SetDrMd(rp, JAM2|COMPLEMENT);
			RectFill(rp, 32+6*32, 32, 63+6*32, 63);
			SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
			RectFill(rp, 32+7*32, 32, 63+7*32, 63);

			SetDrMd(rp, JAM1);
			SetAPen(rp, 1);
			SetBPen(rp, 0);

			Move(rp,32+1*32,73);
			Text(rp,"INV",3);
			Move(rp,32+3*32,73);
			Text(rp,"INV",3);
			Move(rp,32+5*32,73);
			Text(rp,"INV",3);
			Move(rp,32+7*32,73);
			Text(rp,"INV",3);

			Move(rp,32+2*32,83);
			Text(rp,"COMP",4);
			Move(rp,32+3*32,83);
			Text(rp,"COMP",4);
			Move(rp,32+6*32,83);
			Text(rp,"COMP",4);
			Move(rp,32+7*32,83);
			Text(rp,"COMP",4);

			Move(rp,24+2*32,92);
			Text(rp,"JAM1",4);
			Move(rp,24+6*32,92);
			Text(rp,"JAM2",4);

			WaitPort(wd->UserPort);
			
			Forbid();
			while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
			Permit();

			CloseWindow(wd);
		}
		CloseScreen(sc);
	}
}
