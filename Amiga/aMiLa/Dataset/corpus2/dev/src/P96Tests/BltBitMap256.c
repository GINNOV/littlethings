#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#define	MASK		0x07
#define	DEPTH		8

UBYTE	Data[32*8] = {
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,0,0,1,1,1,1,2,2,2,2,0,0,3,3,3,3,0,0,1,1,1,1,2,2,2,2,0,0,3,3,
	3,3,0,0,2,2,2,2,1,1,1,1,0,0,3,3,3,3,0,0,2,2,2,2,1,1,1,1,0,0,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
	3,3,0,0,4,4,4,4,5,5,5,5,0,0,3,3,3,3,0,0,4,4,4,4,5,5,5,5,0,0,3,3,
	3,3,0,0,5,5,5,5,4,4,4,4,0,0,3,3,3,3,0,0,5,5,5,5,4,4,4,4,0,0,3,3,
	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
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

struct BitMap	bm =
{
	32,
	8,
	0,
	8,
	0xfed1,
	Data, Data, NULL, NULL, NULL, NULL, NULL, NULL
};

main(void)
{
	struct Screen		*sc;

	if(sc=OpenScreenTags(NULL,SA_Depth,DEPTH,SA_LikeWorkbench,TRUE,SA_Title,"BltBitMap Test (Chunky to Chunky)",SA_FullPalette,TRUE,TAG_DONE))
	{
		struct Window		*wd;

		if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS,WA_CustomScreen,sc,TAG_DONE))
		{
			struct RastPort	*rp = &(sc->RastPort);
			struct Message		*msg;
			int	y;

			BltBitMap(rp->BitMap,  0, 0, rp->BitMap, 16+0*32+8+4, 24-4, 4+4, 16*13+4, 0xf0, 0x07, NULL);
			BltBitMap(rp->BitMap,  0, 0, rp->BitMap, 16+1*32+8+8, 24-4, 8+4, 16*13+4, 0xf0, 0x07, NULL);
			BltBitMap(rp->BitMap,  0, 0, rp->BitMap, 16+2*32+8+16, 24-4, 16+4, 16*13+4, 0xf0, 0x07, NULL);

			for(y=0; y<16; y++){
				Move(rp, 16+32*4, 24+13*y+rp->Font->tf_Baseline);
				Text(rp, MintermDesc[y], 17);
			}

			for(y=0; y<16; y++){
				BltBitMap(&bm,  4, 0, rp->BitMap, 16+0*32+8, 24+13*y, 8, 8, (y<<4), MASK, NULL);
			}

			for(y=0; y<16; y++){
				BltBitMap(&bm,  0, 0, rp->BitMap, 16+1*32+8, 24+13*y, 16, 8, (y<<4), MASK, NULL);
			}

			for(y=0; y<16; y++){
				BltBitMap(&bm,  0, 0, rp->BitMap, 16+2*32+8, 24+13*y, 32, 8, (y<<4), MASK, NULL);
			}

			WaitPort(wd->UserPort);
			Forbid();
			while(msg = GetMsg(wd->UserPort)) ReplyMsg(msg);
			Permit();

			CloseWindow(wd);
		}
		CloseScreen(sc);
	}
}
