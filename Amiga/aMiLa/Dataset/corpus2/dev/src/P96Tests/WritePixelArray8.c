#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <libraries/picasso96.h>
#include <exec/memory.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#define DEPTH 8
#define WIDTH 640
#define HEIGHT 256

main(void)
{
  struct Library *GfxBase;
  struct BitMap *bm;
  struct RastPort rp;
  UBYTE *array;
  int i;

  if (GfxBase = OpenLibrary("graphics.library",45)) {
    array = AllocMem(WIDTH * HEIGHT,MEMF_PUBLIC);
    if (array) {
      bm = AllocBitMap(WIDTH,HEIGHT,DEPTH,0,NULL);
      if (bm) {
	InitRastPort(&rp);
	rp.BitMap = bm;

	/*
	** Fill the array with something
	*/
	for(i = 0;i < WIDTH*HEIGHT;i++) {
	  array[i] = i;
	}

	for(i = 0;i < 1000;i++) {
	  WritePixelArray8(&rp,0,0,WIDTH-1,HEIGHT-1,array,NULL);
	}

	FreeBitMap(bm);
      }
      FreeMem(array,WIDTH*HEIGHT);
    }
    CloseLibrary(GfxBase);
  }
}
