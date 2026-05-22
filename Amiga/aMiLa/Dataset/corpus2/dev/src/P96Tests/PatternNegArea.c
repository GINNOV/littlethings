#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/picasso96.h>

#define	WIDTH		2*32+8*32
#define	HEIGHT	32+32+64+16
#define	DEPTH		8

#define	MASK		0xff

UWORD __chip Muster2[8][2<<2]=
{
	0x00ff,0x00ff,0x00ff,0x00ff,
	0xffff,0xffff,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000
};

UWORD __chip Muster[8][2<<2]=
{
	0x00ff,0x00f0,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000,
	0x0000,0x0000,0x0000,0x0000
};

UWORD __chip Muster3[8][2<<4]=
{
	0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,0x5555,
	0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,0x3333,
	0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,0x0F0F,
	0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,0x00FF,
	0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,0x0000,0xFFFF,
	0x0000,0x0000,0xFFFF,0xFFFF,0x0000,0x0000,0xFFFF,0xFFFF,0x0000,0x0000,0xFFFF,0xFFFF,0x0000,0x0000,0xFFFF,0xFFFF,
	0x0000,0x0000,0x0000,0x0000,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0x0000,0x0000,0x0000,0x0000,0xFFFF,0xFFFF,0xFFFF,0xFFFF,
	0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF,0xFFFF
};


#define	MSIZE		((BYTE)(sizeof(Muster)/sizeof(UWORD)/8/2))

static const char template[]="APEN=A/N,BPEN=B/N";
UWORD pens[]={(UWORD)(~0)};
//UWORD pens[]={0,128,32,255,130,196,64,0,170,40,180,0,(UWORD)(~0)};

main(void)
{
	struct Screen		*sc;
	struct Window		*wd;
	struct RastPort	*rp, prp;
	struct BitMap		*bm;
	struct Message		*msg;
	struct RDArgs		*rda;
	
	LONG *array[2];
	
	UBYTE APen=0, BPen=0;
	
	if(rda=ReadArgs((STRPTR)template,(LONG *)array,NULL)){
		if(array[0])	APen=*(array[0]);
		if(array[1])	BPen=*(array[1]);
		FreeArgs(rda);
	}

	if(sc=p96OpenScreenTags(P96SA_RGBFormat,RGBFB_CLUT,
									P96SA_Width,800,
									P96SA_Height,600,
									SA_FullPalette,TRUE,
									SA_Pens,pens,
									TAG_DONE)){
		int	n;
		SetRast(&sc->RastPort,128);
		for(n=0; n<256; n++) SetRGB32(&(sc->ViewPort), n, n<<24, n<<24, n<<24);

		if(wd=OpenWindowTags(NULL,	WA_Left,0,WA_Width,WIDTH,WA_Height,HEIGHT,
											WA_DragBar,TRUE,WA_Activate,TRUE,WA_CloseGadget,TRUE,
											WA_IDCMP,IDCMP_CLOSEWINDOW|IDCMP_RAWKEY|IDCMP_MOUSEBUTTONS,WA_CustomScreen,sc,TAG_DONE)){
			if(bm = AllocBitMap(8*32,32,DEPTH,BMF_CLEAR,NULL)){
				rp = wd->RPort;

				prp = *rp;

				prp.Layer = NULL;
				prp.BitMap = bm;

				SetAPen(&prp, 3);
				RectFill(&prp, 0*32, 8, 8*32-1, 24-1);

				SetAPen(&prp, APen);
				SetBPen(&prp, BPen);

				SetAfPt(&prp, &Muster[0][0], -MSIZE);

				prp.Mask = MASK;

				SetDrMd(&prp, JAM1);
				RectFill(&prp, 0*32, 0, 31+0*32, 31);
				SetDrMd(&prp, JAM1|INVERSVID);
				RectFill(&prp, 1*32, 0, 31+1*32, 31);
				SetDrMd(&prp, JAM1|COMPLEMENT);
				RectFill(&prp, 2*32, 0, 31+2*32, 31);
				SetDrMd(&prp, JAM1|INVERSVID|COMPLEMENT);
				RectFill(&prp, 3*32, 0, 31+3*32, 31);
				SetDrMd(&prp, JAM2);
				RectFill(&prp, 4*32, 0, 31+4*32, 31);
				SetDrMd(&prp, JAM2|INVERSVID);
				RectFill(&prp, 5*32, 0, 31+5*32, 31);
				SetDrMd(&prp, JAM2|COMPLEMENT);
				RectFill(&prp, 6*32, 0, 31+6*32, 31);
				SetDrMd(&prp, JAM2|INVERSVID|COMPLEMENT);
				RectFill(&prp, 7*32, 0, 31+7*32, 31);

				prp.Mask = 0xff;

				BltBitMapRastPort(bm, 0, 0, rp, 32, 24, 8*32, 32, 0xc0);

				SetAPen(rp, 3);
				RectFill(rp, 32+0*32, 64+8, 63+7*32, 63+24);

				SetAPen(rp, 1);
				SetBPen(rp, 2);

				SetAfPt(rp, &Muster[0][0], -MSIZE);

				rp->Mask = MASK;

				SetDrMd(rp, JAM1);
				RectFill(rp, 32+0*32, 32+32, 63+0*32, 32+63);
				SetDrMd(rp, JAM1|INVERSVID);
				RectFill(rp, 32+1*32, 32+32, 63+1*32, 32+63);
				SetDrMd(rp, JAM1|COMPLEMENT);
				RectFill(rp, 32+2*32, 32+32, 63+2*32, 32+63);
				SetDrMd(rp, JAM1|INVERSVID|COMPLEMENT);
				RectFill(rp, 32+3*32, 32+32, 63+3*32, 32+63);
				SetDrMd(rp, JAM2);
				RectFill(rp, 32+4*32, 32+32, 63+4*32, 32+63);
				SetDrMd(rp, JAM2|INVERSVID);
				RectFill(rp, 32+5*32, 32+32, 63+5*32, 32+63);
				SetDrMd(rp, JAM2|COMPLEMENT);
				RectFill(rp, 32+6*32, 32+32, 63+6*32, 32+63);
				SetDrMd(rp, JAM2|INVERSVID|COMPLEMENT);
				RectFill(rp, 32+7*32, 32+32, 63+7*32, 32+63);

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
		p96CloseScreen(sc);
	}
}
