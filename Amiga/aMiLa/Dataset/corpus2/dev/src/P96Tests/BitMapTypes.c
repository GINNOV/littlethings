#include <proto/dos.h>
#include <proto/exec.h>
#include "proto/rtg.h"
#include "rtgBase.h"
#include "libraries/picasso96.h"
#include <graphics/gfx.h>


LONG main(void)
{
  struct RTGBase *RTGBase = (struct RTGBase *)OpenLibrary("rtg.library",40);

  if (RTGBase) {
    struct BoardInfo *bi = RTGBase->Boards[0];
    struct BitMap *bm    = rtgAllocBitMapTags(bi,320,200,
					      ABMA_Visible,TRUE,
					      ABMA_Displayable,TRUE,
					      ABMA_RGBFormat,RGBFB_A8R8G8B8,
					      TAG_DONE);
    if (bm) {
      Printf("ARGB bitmap address: 0x%08lx -> 0x%08lx\n",bm->Planes[0],
	     bi->CalculateMemory(bi,bm->Planes[0],RGBFB_A8R8G8B8));
      rtgFreeBitMapTags(bi,bm,TAG_DONE);
    }
    bm    = rtgAllocBitMapTags(bi,320,200,
			       ABMA_Visible,TRUE,
			       ABMA_Displayable,TRUE,
			       ABMA_RGBFormat,RGBFB_B8G8R8A8,
			       TAG_DONE);
    if (bm) {
      Printf("BGRA bitmap address: 0x%08lx -> 0x%08lx\n",bm->Planes[0],
	     bi->CalculateMemory(bi,bm->Planes[0],RGBFB_B8G8R8A8));
      rtgFreeBitMapTags(bi,bm,TAG_DONE);
    }

    
    CloseLibrary((struct Library *)RTGBase);
  }

  return 0;
}
