#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/Picasso96.h>

char	ScreenTitle[] = "Picasso96 DrawLine Test";
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
	int amp = 8;
	int i;

	rp->Mask = 0xff;

	SetDrMd(rp, JAM2);
	SetAPen(rp, 15);
	RectFill(rp, x+0*32, y+4, x+31+7*32, y+12-1);

	SetAPen(rp, 1);
	SetBPen(rp, 2);

	rp->Mask = mask;
	rp->LinePtrn = 0x3838;

	SetDrMd(rp, JAM1);
	Move(rp, x+0*32, y+8-amp);
	Draw(rp, x+8+0*32, y+8+amp);
	Draw(rp, x+31+0*32, y+8-amp);

	SetDrMd(rp, JAM1|INVERSVID);
	Move(rp, x+1*32, y+8-amp);
	Draw(rp, x+8+1*32, y+8+amp);
	Draw(rp, x+31+1*32, y+8-amp);

	SetDrMd(rp, JAM1|COMPLEMENT);
	Move(rp, x+2*32, y+8-amp);
	Draw(rp, x+8+2*32, y+8+amp);
	Draw(rp, x+31+2*32, y+8-amp);

	SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
	Move(rp, x+3*32, y+8-amp);
	Draw(rp, x+8+3*32, y+8+amp);
	Draw(rp, x+31+3*32, y+8-amp);

	SetDrMd(rp, JAM2);
	Move(rp, x+4*32, y+8-amp);
	Draw(rp, x+8+4*32, y+8+amp);
	Draw(rp, x+31+4*32, y+8-amp);

	SetDrMd(rp, JAM2|INVERSVID);
	Move(rp, x+5*32, y+8-amp);
	Draw(rp, x+8+5*32, y+8+amp);
	Draw(rp, x+31+5*32, y+8-amp);

	SetDrMd(rp, JAM2|COMPLEMENT);
	Move(rp, x+6*32, y+8-amp);
	Draw(rp, x+8+6*32, y+8+amp);
	Draw(rp, x+31+6*32, y+8-amp);

	SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
	Move(rp, x+7*32, y+8-amp);
	Draw(rp, x+8+7*32, y+8+amp);
	Draw(rp, x+31+7*32, y+8-amp);

	SetDrMd(rp, JAM1);

	SetAPen(rp, 1);
	for(i=0; i<16; i++){
		rp->LinePtrn = (0xBCBCBCBC<<i)>>16;
		Move(rp, i+x+8*32, y+i);
		Draw(rp, i+x+8*32, y+16+i);
	}

	SetAPen(rp, 2);
	for(i=0; i<16; i++){
		rp->LinePtrn = (0xBCBCBCBC<<(15-i))>>16;
		Move(rp, i+x+8*32+16, y+16+i);
		Draw(rp, i+x+8*32+16, y+i);
	}

	SetAPen(rp, 1);
	for(i=0; i<16; i++){
		rp->LinePtrn = (0xBCBCBCBC<<i)>>16;
		Move(rp, x+9*32+i, y+i);
		Draw(rp, x+9*32+16+i, y+i);
	}

	SetAPen(rp, 2);
	for(i=0; i<16; i++){
		rp->LinePtrn = (0xBCBCBCBC<<(15-i))>>16;
		Move(rp, x+9*32+16+i, 16+y+i);
		Draw(rp, x+9*32+i, 16+y+i);
	}

	rp->LinePtrn = 0xBCBC;

	SetAPen(rp, 1);

	Move(rp, x+10*32+3, y+3);
	Draw(rp, x+10*32+8, y+8);
	Draw(rp, x+10*32+8+16, y+8);
	Draw(rp, x+10*32+8+16, y+8+16);
	Draw(rp, x+10*32+8, y+8+16);
	Draw(rp, x+10*32+8, y+8);


	rp->Mask = 0xff;
}

main(void)
{
	ULONG	DisplayID;

	if(INVALID_ID != (DisplayID = p96RequestModeIDTags(TAG_DONE)))
	{
		struct Screen	*sc;

		if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_AutoScroll,TRUE,SA_DisplayID,DisplayID,SA_Depth,4,SA_Width,640,SA_Height,480,SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,SA_Colors32,ColorTable,TAG_DONE))
		{
			struct BitMap	*bm, *bmC;

			/* width of bitmap doesn't allow it to be put on the board */ 

			if(bmC = p96AllocBitMap(4100,32+6*40+24,4,BMF_CLEAR|BMF_USERPRIVATE,sc->RastPort.BitMap,p96GetModeIDAttr(DisplayID,P96IDA_RGBFORMAT))){

				if(bm = AllocBitMap(640,32+6*40+24,4,BMF_CLEAR,NULL)){
					struct Window	*wd;

					wd=OpenWindowTags(NULL,WA_Left,0,WA_Width,17*32,WA_Height,10*32,WA_DragBar,TRUE,WA_CloseGadget,TRUE,WA_RMBTrap,TRUE,WA_Activate,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS|IDCMP_CLOSEWINDOW|IDCMP_RAWKEY,WA_CustomScreen,sc,WA_Title,(ULONG)ScreenTitle,TAG_DONE);
					if(wd){
						struct Message		*msg;
						struct RastPort	*rp, prp, prpC;
						BOOL terminate = FALSE;

						rp = wd->RPort;
						prp = *rp;
						prpC = *rp;

						prp.Layer = NULL;
						prpC.Layer = NULL;
						prp.BitMap = bm;
						prpC.BitMap = bmC;

						Render(&prp, 2*32+15, 5*40+24, 0xff);
						BltBitMapRastPort(bm, 2*32+15, 5*40+24, rp, 2*32+15, 3*40+24, 11*32, 32, 0xc0);
						Render(&prpC, 2*32+15, 5*40+24, 0xff);
						BltBitMapRastPort(bmC, 2*32+15, 5*40+24, rp, 2*32+15, 4*40+24, 11*32, 32, 0xc0);
						Render(rp, 2*32+15, 5*40+24, 0xff);

						Render(&prp, 2*32+15, 2*40+24, 0x07);
						BltBitMapRastPort(bm, 2*32+15, 2*40+24, rp, 2*32+15, 0*40+24, 11*32, 32, 0xc0);
						Render(&prpC, 2*32+15, 2*40+24, 0x07);
						BltBitMapRastPort(bmC, 2*32+15, 2*40+24, rp, 2*32+15, 1*40+24, 11*32, 32, 0xc0);
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

						Move(rp,16+10*32,25*8+75);
						Text(rp,"Dn",2);
						Move(rp,32+10*32,25*8+75);
						Text(rp,"Up",2);

						Move(rp,24+11*32,25*8+75);
						Text(rp,"-->",3);
						Move(rp,24+11*32,25*8+85);
						Text(rp,"<--",3);

						Move(rp,13*32+24,1*40+3);
						Text(rp,"RAM Planar",10);

						Move(rp,13*32+24,2*40+3);
						Text(rp,"RAM Chunky",10);

						Move(rp,13*32+24,3*40+3);
						Text(rp,"Card driver",11);

						Move(rp,13*32+24,4*40+3);
						Text(rp,"RAM Planar",10);

						Move(rp,13*32+24,5*40+3);
						Text(rp,"RAM Chunky",10);

						Move(rp,13*32+24,6*40+3);
						Text(rp,"Card driver",11);

						Move(rp,8,25*8+112);
						Text(rp,"Use mouse to draw lines!",24);

						rp->LinePtrn = 0xBCBC;

						do{
							struct IntuiMessage *imsg, im;
							WaitPort(wd->UserPort);
							while(imsg = (struct IntuiMessage *)GetMsg(wd->UserPort)){
								im = *imsg;
								ReplyMsg((struct Message *)imsg);
								
								switch(im.Class){
								case	IDCMP_MOUSEBUTTONS:
									switch(im.Code){
									case SELECTDOWN:
									case MENUDOWN:
										Move(rp, im.MouseX, im.MouseY);
										break;
									case SELECTUP:
										SetAPen(rp, 1);
										Draw(rp, im.MouseX, im.MouseY);
										break;
									case MENUUP:
										SetAPen(rp, 2);
										Draw(rp, im.MouseX, im.MouseY);
										break;
									}
									break;
								case	IDCMP_RAWKEY:
									switch(im.Code){
									case 0x45:
										terminate = TRUE;
										break;
									}
									break;
								case	IDCMP_CLOSEWINDOW:
									terminate = TRUE;
									break;
								}
							}
						}while(!terminate);
						
						Forbid();
						while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
						Permit();

						CloseWindow(wd);
					}
					FreeBitMap(bm);
				}
				FreeBitMap(bmC);
			}
			if(sc != NULL) CloseScreen(sc);
		}
	}
}
