#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/Picasso96.h>

char	ScreenTitle[] = "Picasso96 BlitPattern Test";
WORD	Pens[] = {~0};

main(void)
{
	ULONG	DisplayID;

	if(INVALID_ID != (DisplayID = p96RequestModeIDTags(TAG_DONE))){
		struct Screen	*sc;

		if(sc=OpenScreenTags(NULL,
									SA_DisplayID,DisplayID,SA_Depth,8,SA_Width,640,SA_Height,480,SA_Pens,Pens,SA_FullPalette,TRUE,SA_Title,(ULONG)ScreenTitle,TAG_DONE)){
			struct BitMap	*bm1, *bm2;

			/* width of bitmap doesn't allow it to be put on the board */ 

			if(bm1 = AllocBitMap(4100,32+3*40+24,8,BMF_CLEAR,sc->RastPort.BitMap)){
				LONG lock =  p96LockBitMap(sc->RastPort.BitMap, NULL, 0);
				if(bm2 = AllocBitMap(4100,32+3*40+24,8,BMF_CLEAR,bm1)){
					FreeBitMap(bm2);
				}
				p96UnlockBitMap(sc->RastPort.BitMap, lock);
				FreeBitMap(bm1);
			}
			CloseScreen(sc);
		}
	}
}
