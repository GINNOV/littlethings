#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#define	WIDTH		2*32+8*32
#define	HEIGHT	32+32+64+16
#define	DEPTH		8

#define	MASK		0x07

UWORD Muster[8]= { 0xffff, 0xffff, 0xffff, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000 };

ULONG	__chip mask[32] =
{
	0x00000000,
	0x0000000f,
	0x0000001e,
	0x0000003c,
	0x00000078,
	0x000000f0,
	0x000001e0,
	0x000003c0,
	0x00000780,
	0x00000f00,
	0x00001e00,
	0x00003c00,
	0x00007800,
	0x0000f000,
	0x0001e000,
	0x0003c000,
	0x00078000,
	0x000f0000,
	0x001e0000,
	0x003c0000,
	0x00780000,
	0x00f00000,
	0x01e00000,
	0x03c00000,
	0x07800000,
	0x0f000000,
	0x1e000000,
	0x3c000000,
	0x78000000,
	0xf0000000,
	0x00000000
};

main(void)
{
	struct Screen		*sc;
	struct Window		*wd;
	struct RastPort	*rp, prp;
	struct BitMap		*bm;
	struct Message		*msg;

	if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,DEPTH,SA_FullPalette,TRUE,TAG_DONE))
	{
		if(wd=OpenWindowTags(NULL,WA_Left,0,WA_Width,WIDTH,WA_Height,HEIGHT,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_IDCMP,IDCMP_CLOSEWINDOW,WA_CustomScreen,sc,TAG_DONE))
		{
			if(bm = AllocBitMap(8*32,32,DEPTH,BMF_CLEAR,NULL)){
				rp = wd->RPort;

				prp = *rp;

				prp.Layer = NULL;
				prp.BitMap = bm;

				SetAPen(&prp, 3);
				RectFill(&prp, 0*32, 8, 8*32-1, 24-1);

				SetAPen(&prp, 1);
				SetBPen(&prp, 2);

				SetAfPt(&prp, Muster, 3);

				prp.Mask = MASK;

				SetDrMd(&prp, JAM1);
				BltPattern(&prp, (PLANEPTR)mask, 0*32, 0, 31+0*32, 31, 4);
				SetDrMd(&prp, JAM1|INVERSVID);
				BltPattern(&prp, (PLANEPTR)mask, 1*32, 0, 31+1*32, 31, 4);
				SetDrMd(&prp, JAM1|COMPLEMENT);
				BltPattern(&prp, (PLANEPTR)mask, 2*32, 0, 31+2*32, 31, 4);
				SetDrMd(&prp, JAM1|INVERSVID|COMPLEMENT);
				BltPattern(&prp, (PLANEPTR)mask, 3*32, 0, 31+3*32, 31, 4);
				SetDrMd(&prp, JAM2);
				BltPattern(&prp, (PLANEPTR)mask, 4*32, 0, 31+4*32, 31, 4);
				SetDrMd(&prp, JAM2|INVERSVID);
				BltPattern(&prp, (PLANEPTR)mask, 5*32, 0, 31+5*32, 31, 4);
				SetDrMd(&prp, JAM2|COMPLEMENT);
				BltPattern(&prp, (PLANEPTR)mask, 6*32, 0, 31+6*32, 31, 4);
				SetDrMd(&prp, JAM2|INVERSVID|COMPLEMENT);
				BltPattern(&prp, (PLANEPTR)mask, 7*32, 0, 31+7*32, 31, 4);

				prp.Mask = 0xff;

				BltBitMapRastPort(bm, 0, 0, rp, 32, 24, 8*32, 32, 0xc0);

				SetAPen(rp, 3);
				RectFill(rp, 32+0*32, 64+8, 63+7*32, 63+24);

				SetAPen(rp, 1);
				SetBPen(rp, 2);

				SetAfPt(rp, Muster, 3);

				rp->Mask = MASK;

				SetDrMd(rp, JAM1);
				BltPattern(rp, (PLANEPTR)mask, 32+0*32, 32+32, 63+0*32, 63+32, 4);
				SetDrMd(rp, JAM1|INVERSVID);
				BltPattern(rp, (PLANEPTR)mask, 32+1*32, 32+32, 63+1*32, 63+32, 4);
				SetDrMd(rp, JAM1|COMPLEMENT);
				BltPattern(rp, (PLANEPTR)mask, 32+2*32, 32+32, 63+2*32, 63+32, 4);
				SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
				BltPattern(rp, (PLANEPTR)mask, 32+3*32, 32+32, 63+3*32, 63+32, 4);
				SetDrMd(rp, JAM2);
				BltPattern(rp, (PLANEPTR)mask, 32+4*32, 32+32, 63+4*32, 63+32, 4);
				SetDrMd(rp, JAM2|INVERSVID);
				BltPattern(rp, (PLANEPTR)mask, 32+5*32, 32+32, 63+5*32, 63+32, 4);
				SetDrMd(rp, JAM2|COMPLEMENT);
				BltPattern(rp, (PLANEPTR)mask, 32+6*32, 32+32, 63+6*32, 63+32, 4);
				SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
				BltPattern(rp, (PLANEPTR)mask, 32+7*32, 32+32, 63+7*32, 63+32, 4);

				rp->Mask = 0xff;

				SetDrMd(rp, JAM1);
				SetAPen(rp, 1);
				SetBPen(rp, 0);

				Move(rp,32+1*32,32+73);
				Text(rp,"INV",3);
				Move(rp,32+3*32,32+73);
				Text(rp,"INV",3);
				Move(rp,32+5*32,32+73);
				Text(rp,"INV",3);
				Move(rp,32+7*32,32+73);
				Text(rp,"INV",3);

				Move(rp,32+2*32,32+83);
				Text(rp,"COMP",4);
				Move(rp,32+3*32,32+83);
				Text(rp,"COMP",4);
				Move(rp,32+6*32,32+83);
				Text(rp,"COMP",4);
				Move(rp,32+7*32,32+83);
				Text(rp,"COMP",4);

				Move(rp,24+2*32,32+92);
				Text(rp,"JAM1",4);
				Move(rp,24+6*32,32+92);
				Text(rp,"JAM2",4);

				WaitPort(wd->UserPort);
				
				Forbid();
				while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
				Permit();

				FreeBitMap(bm);
			}
			CloseWindow(wd);
		}
		CloseScreen(sc);
	}
}
