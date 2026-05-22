#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/Picasso96.h>

char	ScreenTitle[] = "Picasso96 FillRect Test";
WORD	Pens[] = {~0};
ULONG ColorTable[] = { 16<<16|0,
	0x88888888, 0x88888888, 0x88888888,
	0x00000000, 0x00000000, 0x00000000,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xCCCCCCCC, 0x44444444, 0x44444444,
	0x44444444, 0xCCCCCCCC, 0x44444444,
	0x44444444, 0x44444444, 0xCCCCCCCC,
	0xFFFFFFFF, 0x00000000, 0x00000000,
	0x00000000, 0xFFFFFFFF, 0x00000000,
	0x00000000, 0x00000000, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0x00000000,
	0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
	0x00000000, 0xFFFFFFFF, 0xFFFFFFFF,
	0x44444444, 0xCCCCCCCC, 0xCCCCCCCC,
	0xCCCCCCCC, 0x44444444, 0xCCCCCCCC,
	0xCCCCCCCC, 0xCCCCCCCC, 0x44444444,
	0xCCCCCCCC, 0xCCCCCCCC, 0xCCCCCCCC,
};

void Render(struct RastPort *rp, WORD x, WORD y, UBYTE mask)
{
	rp->Mask = 0xff;

	SetDrMd(rp, JAM2);
	SetAPen(rp, 15);
	SetAfPt(rp, NULL, 0);
	RectFill(rp, x+0*32, y+8, x+31+7*32, y+24-1);

	SetAPen(rp, 1);
	SetBPen(rp, 2);

	rp->Mask = mask;

	SetDrMd(rp, JAM1);
	RectFill(rp, x+0*32, y, x+31+0*32, y+31);
	SetDrMd(rp, JAM1|INVERSVID);
	RectFill(rp, x+1*32, y, x+31+1*32, y+31);
	SetDrMd(rp, JAM1|COMPLEMENT);
	RectFill(rp, x+2*32, y, x+31+2*32, y+31);
	SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
	RectFill(rp, x+3*32, y, x+31+3*32, y+31);
	SetDrMd(rp, JAM2);
	RectFill(rp, x+4*32, y, x+31+4*32, y+31);
	SetDrMd(rp, JAM2|INVERSVID);
	RectFill(rp, x+5*32, y, x+31+5*32, y+31);
	SetDrMd(rp, JAM2|COMPLEMENT);
	RectFill(rp, x+6*32, y, x+31+6*32, y+31);
	SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
	RectFill(rp, x+7*32, y, x+31+7*32, y+31);

	rp->Mask = 0xff;
}

main(void)
{
	ULONG	DisplayID;

	if(INVALID_ID != (DisplayID = p96RequestModeIDTags(TAG_DONE))){
		struct Screen	*sc;

		if(sc=OpenScreenTags(NULL,
									SA_AutoScroll,TRUE,SA_DisplayID,DisplayID,SA_Depth,4,SA_Width,640,SA_Height,480,SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,SA_Colors32,ColorTable,TAG_DONE)){
			struct BitMap	*bm, *bmC;

			/* width of bitmap doesn't allow it to be put on the board */ 

//			if(bmC = p96AllocBitMap(640,32+6*40+24,4,BMF_CLEAR|BMF_USERPRIVATE,sc->RastPort.BitMap,0)){
			if(bmC = p96AllocBitMap(640,32+6*40+24,4,BMF_CLEAR|BMF_USERPRIVATE,sc->RastPort.BitMap,p96GetModeIDAttr(DisplayID,P96IDA_RGBFORMAT))){

				if(bm = AllocBitMap(640,32+6*40+24,4,BMF_CLEAR,NULL)){
					struct Window	*wd;

					if(wd=OpenWindowTags(NULL,WA_Left,0,WA_Width,14*32,WA_Height,10*32,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_Activate,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,WA_CustomScreen,sc,WA_Title,(ULONG)ScreenTitle,TAG_DONE)){
						struct Message		*msg;
						struct RastPort	*rp, prp, prpC;

						rp = wd->RPort;
						prp = *rp;
						prpC = *rp;

						prp.Layer = NULL;
						prpC.Layer = NULL;
						prp.BitMap = bm;
						prpC.BitMap = bmC;

						Render(&prp, 2*32+15, 5*40+24, 0xff);
						BltBitMapRastPort(bm, 2*32+15, 5*40+24, rp, 2*32+15, 3*40+24, 8*32, 32, 0xc0);
						Render(&prpC, 2*32+15, 5*40+24, 0xff);
						BltBitMapRastPort(bmC, 2*32+15, 5*40+24, rp, 2*32+15, 4*40+24, 8*32, 32, 0xc0);
						Render(rp, 2*32+15, 5*40+24, 0xff);

						Render(&prp, 2*32+15, 2*40+24, 0x07);
						BltBitMapRastPort(bm, 2*32+15, 2*40+24, rp, 2*32+15, 0*40+24, 8*32, 32, 0xc0);
						Render(&prpC, 2*32+15, 2*40+24, 0x07);
						BltBitMapRastPort(bmC, 2*32+15, 2*40+24, rp, 2*32+15, 1*40+24, 8*32, 32, 0xc0);
						Render(rp, 2*32+15, 2*40+24, 0x07);


						SetDrMd(rp, JAM1);
						SetAPen(rp, 1);
						SetBPen(rp, 0);

						Move(rp,12,2*40+3);
						Text(rp,"Mask $7",7);
						Move(rp,12,5*40+3);
						Text(rp,"No Mask",7);

						Move(rp,12+3*32,25*8+75);
						Text(rp,"INV",3);
						Move(rp,12+5*32,25*8+75);
						Text(rp,"INV",3);
						Move(rp,12+7*32,25*8+75);
						Text(rp,"INV",3);
						Move(rp,12+9*32,25*8+75);
						Text(rp,"INV",3);

						Move(rp,28+4*32,25*8+85);
						Text(rp,"COMP",4);
						Move(rp,28+8*32,25*8+85);
						Text(rp,"COMP",4);

						Move(rp,4*32,25*8+94);
						Text(rp,"JAM1",4);
						Move(rp,8*32,25*8+94);
						Text(rp,"JAM2",4);

						Move(rp,10*32+24,1*40+3);
						Text(rp,"RAM Planar",10);

						Move(rp,10*32+24,2*40+3);
						Text(rp,"RAM Chunky",10);

						Move(rp,10*32+24,3*40+3);
						Text(rp,"Card driver",11);

						Move(rp,10*32+24,4*40+3);
						Text(rp,"RAM Planar",10);

						Move(rp,10*32+24,5*40+3);
						Text(rp,"RAM Chunky",10);

						Move(rp,10*32+24,6*40+3);
						Text(rp,"Card driver",11);

						WaitPort(wd->UserPort);
						
						Forbid();
						while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
						Permit();

						CloseWindow(wd);
					}
					FreeBitMap(bm);
				}
				FreeBitMap(bmC);
			}
			CloseScreen(sc);
		}
	}
}
