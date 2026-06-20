#include <intuition/screens.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <exec/memory.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <string.h>

#define	MASK		0x07
#define	DEPTH		4

/*
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
*/

main(void)
{
  struct Screen		*sc;

  if(sc=OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,SA_Depth,DEPTH,SA_Title,"BltBitMap Test (Chunky to Planar)",SA_FullPalette,TRUE,TAG_DONE)) {
    struct Window		*wd;

    if(wd=OpenWindowTags(NULL,WA_Backdrop,TRUE,WA_Borderless,TRUE,WA_IDCMP,IDCMP_MOUSEBUTTONS,WA_CustomScreen,sc,TAG_DONE)) {
      struct RastPort	*rp = &(sc->RastPort);
      struct Message	*msg;
      ULONG msize  = (((2 * wd->Width + 15) >> 4) * wd->Height) << 2;
      UBYTE *mask = AllocMem(msize,MEMF_PUBLIC);
      if (mask) {
	int w,h;
	memset(mask,0xff,msize);
	for(h = 1;h < wd->Height;h+=13) {
	  for(w = 1;w < wd->Width;w+=17) {
	    ULONG dsize = w * h;
	    struct BitMap *bm = AllocBitMap(w,h,8,0,rp->BitMap);
	    if (bm) {
	      int x,y;
	      struct RastPort rm;
	      InitRastPort(&rm);
	      rm.BitMap = bm;
	      
	      for(y = 0;y < wd->Height;y+=h) {
		for(x = 0;x < wd->Width;x+=w) {
		  SetAPen(&rm,x ^ y);
		  RectFill(&rm,0,0,w-1,h-1);
		  if (x > w && y > h) {
		    BltMaskBitMapRastPort(rp->BitMap,x-w,y-h,rp,x,y,w,h,0xe0,mask);
		  } else {
		    BltMaskBitMapRastPort(bm,0,0,rp,x,y,w,h,0xe0,mask);
		  }
		}
	      }
	      FreeBitMap(bm);
	    }
	  }
	}
	FreeMem(mask,msize);
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
