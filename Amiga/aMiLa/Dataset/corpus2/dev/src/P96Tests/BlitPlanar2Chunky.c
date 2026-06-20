#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/Picasso96.h>

#include	<stdio.h>
#include	<string.h>

char	ScreenTitle[] = "Picasso96 BlitPlanar2Chunky Test";
WORD	Pens[] = {~0};

UWORD	__chip Plane[2*8] = {
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xffff, 0xffff
};

//UWORD	__chip Plane1[2*8] = {
UWORD Plane1[2*8] = {
	0xffff, 0xffff,
	0xcf03, 0xcf03,
	0xc0f3, 0xc0f3,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xc0f3, 0xc0f3,
	0xcf03, 0xcf03,
	0xffff, 0xffff,
};

UWORD	__chip Plane2[2*8] = {
	0xffff, 0xffff,
	0xc0f3, 0xc0f3,
	0xcf03, 0xcf03,
	0xffff, 0xffff,
	0xffff, 0xffff,
	0xc003, 0xc003,
	0xc003, 0xc003,
	0xffff, 0xffff,
};

UWORD	__chip Plane3[2*8] = {
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0ff0, 0x0ff0,
	0x0ff0, 0x0ff0,
	0x0000, 0x0000,
};

UWORD	__chip Plane4[2*8] = {
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
	0x0000, 0x0000,
};

char	*MintermDesc[16] = {
	"FALSE      (0x00)",
	"NOR        (0x10)",
	"ONLYDST    (0x20)",
	"NOTSRC     (0x30)",
	"ONLYSRC    (0x40)",
	"NOTDST     (0x50)",
	"EOR        (0x60)",
	"NAND       (0x70)",
	"AND        (0x80)",
	"NEOR       (0x90)",
	"DST        (0xa0)",
	"NOTONLYSRC (0xb0)",
	"SRC        (0xc0)",
	"NOTONLYDST (0xd0)",
	"OR         (0xe0)",
	"TRUE       (0xf0)"
};

struct BitMap	tbm =
{
	4,
	4,
	0,
	4,
	0,
	(PLANEPTR)Plane1, (PLANEPTR)Plane2, (PLANEPTR)Plane3, (PLANEPTR)Plane4, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55
//	(PLANEPTR)Plane, (PLANEPTR)Plane, (PLANEPTR)Plane, (PLANEPTR)Plane, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55, (PLANEPTR)0xaa55aa55
};


#define	MASK	0x3f

main(void)
{
	ULONG	DisplayID;

	if(INVALID_ID != (DisplayID = p96RequestModeIDTags(P96MA_FormatsAllowed, RGBFF_CLUT, TAG_DONE))){
		struct Screen		*sc;

		if(sc=OpenScreenTags(NULL,
									SA_DisplayID,DisplayID,SA_Depth,8,SA_Width,640,SA_Height,480,SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,TAG_DONE)){
			struct BitMap	*bm, *cbm;

			/* width of bitmap doesn't allow it to be put on the board */ 

			if(bm = AllocBitMap(4*32,13*16+8,8,BMF_CLEAR,NULL)){
				if(cbm = p96AllocBitMap(4*32,13*16+8,8,BMF_CLEAR|BMF_USERPRIVATE,sc->RastPort.BitMap,RGBFB_CLUT)){
					struct Window		*wd;

					if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_Activate,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS|IDCMP_RAWKEY,WA_CustomScreen,sc,TAG_DONE)){
						struct RastPort	*rp = &(sc->RastPort);
						struct Message		*msg;
						int	y;
						BOOL	running = TRUE;

						BltBitMap(bm,  0, 0, bm, 0*32+8+4, 0, 4+4, 16*13+4, 0x00, 0xff, NULL);
						BltBitMap(bm,  0, 0, bm, 0*32+8+4, 0, 4+4, 16*13+4, 0xf0, 0xaa, NULL);
						BltBitMap(bm,  0, 0, bm, 1*32+8+8, 0, 8+4, 16*13+4, 0x00, 0xff, NULL);
						BltBitMap(bm,  0, 0, bm, 1*32+8+8, 0, 8+4, 16*13+4, 0xf0, 0xaa, NULL);
						BltBitMap(bm,  0, 0, bm, 2*32+8+16, 0, 16+4, 16*13+4, 0x00, 0xff, NULL);
						BltBitMap(bm,  0, 0, bm, 2*32+8+16, 0, 16+4, 16*13+4, 0xf0, 0xaa, NULL);

						BltBitMap(bm, 0, 0, rp->BitMap, 16, 20, 4*32, 13*16+8, 0xc0, 0xff, NULL);
						BltBitMap(bm, 0, 0, cbm,         0,  0, 4*32, 13*16+8, 0xc0, 0xff, NULL);

						for(y=0; y<16; y++){
							BltBitMap(&tbm,  4, 0, rp->BitMap, 16+0*32+8, 24+13*y, 8, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  4, 0, bm,            0*32+8,  4+13*y, 8, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  4, 0, cbm,           0*32+8,  4+13*y, 8, 8, (y<<4), MASK, NULL);
						}

						for(y=0; y<16; y++){
							BltBitMap(&tbm,  0, 0, rp->BitMap, 16+1*32+8, 24+13*y, 16, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  0, 0, bm,            1*32+8,  4+13*y, 16, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  0, 0, cbm,           1*32+8,  4+13*y, 16, 8, (y<<4), MASK, NULL);
						}

						for(y=0; y<16; y++){
							BltBitMap(&tbm,  0, 0, rp->BitMap, 16+2*32+8, 24+13*y, 32, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  0, 0, bm,            2*32+8,  4+13*y, 32, 8, (y<<4), MASK, NULL);
							BltBitMap(&tbm,  0, 0, cbm,           2*32+8,  4+13*y, 32, 8, (y<<4), MASK, NULL);
						}

						BltBitMap(cbm, 0, 0, rp->BitMap, 16+32*4, 20, 4*32, 13*16+8, 0xc0, 0xff, NULL);
						BltBitMap(bm,  0, 0, rp->BitMap, 16+32*8, 20, 4*32, 13*16+8, 0xc0, 0xff, NULL);

						SetDrMd(rp, JAM1);
						SetAPen(rp, 1);
						SetBPen(rp, 0);

						for(y=0; y<16; y++){
							Move(rp, 32+32*12, 24+13*y+rp->Font->tf_Baseline);
							Text(rp, MintermDesc[y], 17);
						}

						Move(rp, 32*1, 24+13*17+rp->Font->tf_Baseline);
						Text(rp,"Card driver",11);

						Move(rp, 32*5, 24+13*17+rp->Font->tf_Baseline);
						Text(rp,"RAM Chunky",10);

						Move(rp, 32*9, 24+13*17+rp->Font->tf_Baseline);
						Text(rp,"RAM Planar",10);

						SetDrMd(rp, JAM2);

						do{
							char tmp[40];
							WaitPort(wd->UserPort);
							while(msg = GetMsg(wd->UserPort)){
								struct IntuiMessage *imsg;
								
								imsg = (struct IntuiMessage *)msg;
								
								switch(imsg->Class){
								case	IDCMP_MOUSEBUTTONS:
									sprintf(tmp,"X:%4ld  Y:%4ld  Pen: 0x%02lx",imsg->MouseX,imsg->MouseY,ReadPixel(rp,imsg->MouseX,imsg->MouseY));
									Move(rp, 32*11, 24+13*17+rp->Font->tf_Baseline);
									Text(rp, tmp, strlen(tmp));
									break;
								case	IDCMP_RAWKEY:
									running = FALSE;
									break;
								}
								ReplyMsg(msg);
							}
						}while(running);

						Forbid();
						while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
						Permit();

						CloseWindow(wd);
					}
					FreeBitMap(cbm);
				}
				FreeBitMap(bm);
			}
			CloseScreen(sc);
		}
	}
}
