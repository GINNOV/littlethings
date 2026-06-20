#include <libraries/picasso96.h>
#include <intuition/screens.h>
#include <graphics/rastport.h>

#include <proto/graphics.h>
#include <proto/dos.h>
#include <proto/intuition.h>

extern __asm void BlitPlane(
	register __a0 struct RenderInfo *sri,
	register __a1 struct RenderInfo *dri,
	register __d0 WORD SrcX,
	register __d1 WORD SrcY,
	register __d2 WORD DstX,
	register __d3 WORD DstY,
	register __d4 WORD SizeX,
	register __d5 WORD SizeY,
	register __d6 UBYTE MinTerm);

main(void)
{
   struct Screen *sc;
   
   if(sc = LockPubScreen(NULL)){
		struct RenderInfo	sri, dri;
	   struct BitMap *bm;
		int	i, j;
		bm = sc->RastPort.BitMap;

		sri.BytesPerRow = bm->BytesPerRow;
		dri.BytesPerRow = bm->BytesPerRow;

		BltBitMap(sc->RastPort.BitMap, 1, 0, sc->RastPort.BitMap, 2, 0, 254, 200, 0xc0, 0xff, NULL);
		BltBitMap(sc->RastPort.BitMap, 0, 0, sc->RastPort.BitMap, 1, 0, 1, 200, 0xc0, 0xff, NULL);

/*
		for(j=0; j<3*64; j+=3){
			for(i=0; i<bm->Depth; i++){
				sri.Memory = bm->Planes[i];
				dri.Memory = bm->Planes[i];

				BlitPlane(&sri, &dri, 128+j, 200, 128+j+3, 200, 200, 200, 0xc);
			}

			Delay(5);
		}
*/
		UnlockPubScreen(NULL, sc);
	}
}
