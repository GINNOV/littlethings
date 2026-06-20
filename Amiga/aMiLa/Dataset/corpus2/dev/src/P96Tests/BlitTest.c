#include <intuition/screens.h>
#include <graphics/rastport.h>

#include <proto/graphics.h>
#include <proto/intuition.h>

struct BitMap  tbm =
{
   4,
   4,
   0,
   1,
   0,
   NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
};


main(void)
{
   struct Screen *sc;
   struct RastPort *rp;
   
   if(sc = LockPubScreen(NULL)){
      rp = &sc->RastPort;
      BltBitMap(&tbm,  0, 0, rp->BitMap, 20, 20, 50, 50, 0xc0, 0xff, NULL);
      UnlockPubScreen(NULL, sc);
   }
}
