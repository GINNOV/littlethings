#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#define	WIDTH		2*32+8*32
#define	HEIGHT	32+32+64
#define	DEPTH		7
#define	ID			0x50019000

ULONG	__chip mask[] =
{
	0x00000001,
	0x00000002,
	0x00000004,
	0x00000008,
	0x00000010,
	0x00000020,
	0x00000040,
	0x00000080,
	0x00000100,
	0x00000200,
	0x00000400,
	0x00000800,
	0x00001000,
	0x00002000,
	0x00004000,
	0x00008000,
	0x00010000,
	0x00020000,
	0x00040000,
	0x00080000,
	0x00100000,
	0x00200000,
	0x00400000,
	0x00800000,
	0x01000000,
	0x02000000,
	0x04000000,
	0x08000000,
	0x10000000,
	0x20000000,
	0x40000000,
	0x80000000
};

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

			SetAPen(rp, 3);
			RectFill(rp, 32+0*32, 32, 63+7*32, 47);

			SetAPen(rp, 1);
			SetBPen(rp, 2);

			SetDrMd(rp, JAM1);
			BltPattern(rp, (PLANEPTR)mask, 32+0*32, 32, 63+0*32, 63, 4);
			SetDrMd(rp, JAM1|INVERSVID);
			BltPattern(rp, (PLANEPTR)mask, 32+1*32, 32, 63+1*32, 63, 4);
			SetDrMd(rp, JAM1|COMPLEMENT);
			BltPattern(rp, (PLANEPTR)mask, 32+2*32, 32, 63+2*32, 63, 4);
			SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
			BltPattern(rp, (PLANEPTR)mask, 32+3*32, 32, 63+3*32, 63, 4);
			SetDrMd(rp, JAM2);
			BltPattern(rp, (PLANEPTR)mask, 32+4*32, 32, 63+4*32, 63, 4);
			SetDrMd(rp, JAM2|INVERSVID);
			BltPattern(rp, (PLANEPTR)mask, 32+5*32, 32, 63+5*32, 63, 4);
			SetDrMd(rp, JAM2|COMPLEMENT);
			BltPattern(rp, (PLANEPTR)mask, 32+6*32, 32, 63+6*32, 63, 4);
			SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
			BltPattern(rp, (PLANEPTR)mask, 32+7*32, 32, 63+7*32, 63, 4);

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
