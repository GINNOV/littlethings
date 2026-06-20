/************************************************************

    TML's C Language Card Image Package  v1.1
    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include "CardVImages.h"
#include "Cards.h"

#ifdef AZTEC_C
  #include <functions.h>
#endif
#ifdef __SASC
  #include <clib/graphics_protos.h>
#endif

/**********************************************************************
CardVBrush.c contains an array of UWORDs which contains the
bitmap data for a deck of playing cards layed out in four rows.
In all 56 cards are defined in the following order:

     SpadeA..SpadeK,     Joker,
     DiamondA..DiamondK, Back,
     ClubA..ClubK,       Blank,
     HeartA..HeartK,     Black

Each card is 38 bits wide and 32 bits high, but the edges of the
cards overlap by one bit (pixel), so the total bitmap is
519(h)x125(v)x2 planes deep.  In addition, another bitplane is
defined which has the same shape as the 2 mentioned above, but
with all the pixels within the cards turned on. This bitplane is
used as a mask with BltMaskBitMapRastPort() to round off the
corners of the cards when they are copied.

MAKE SURE THE CardVBrush DATA GET LOADED INTO CHIP RAM!  You may
have to edit CardVBrush.c to add the "__chip" keyword, or you
may have to use a link option, or run the ATOM facility on the
final executable to make it load into chip ram.

The cards were designed with the following pen colors:

  pen | red  green blue
  ----+----------------
    0 |   0     4    12   (Blue)
    1 |   0     0     0   (Black)
    2 |  14    12    10   (Creamy White)
    3 |  15     8     0   (Rusty Red)

**********************************************************************/

#include "CardVBrush.c"

struct  Image CardVBrushimage =
 {
   0,0,
   519 , 125 , 3 ,
   &CardVBrush[0],
   0x1f,0x00,
   NULL,
 };

extern struct GfxBase *GfxBase;

BOOL ShowVCard( struct RastPort *rp, CardID_t Card, WORD dx, WORD dy )
  {
    static struct BitMap bm;
    static BOOL  bmInit = FALSE;
    static UWORD *mask;
    WORD suit, rank,x,y;

    if (!bmInit)
      {
        PLANEPTR tmp;
        InitBitMap( &bm, 2L, 519L, 125L);
        bm.Planes[0] = (PLANEPTR)&CardVBrush [ 0 ];
        bm.Planes[1] = (PLANEPTR)&CardVBrush1[ 0 ];
        mask         =           &CardVBrush2[ 0 ];

        /** Black and White are reversed prior to v35, so swap planes. **/
        if ( CardColorSwapping && GfxBase->LibNode.lib_Version < 35 )
          {
            tmp = bm.Planes[0];
                  bm.Planes[0] = bm.Planes[1];
                                 bm.Planes[1] = tmp;
          }
        bmInit = 1;
      }

    if ( Card == CARD_NONE ) /* Erase the card */
      {
        BYTE FgPen, DrawMode;
        UBYTE Mask;
        FgPen    = rp->FgPen;
        DrawMode = rp->DrawMode;
        Mask     = rp->Mask;
        SetAPen( rp, 0 );
        SetDrMd( rp, JAM1 );
        SetWrMsk(rp, 0xff );
        RectFill(rp, dx, dy, dx+CARD_V_WIDTH-1, dy+CARD_V_HEIGHT-1 );
        SetWrMsk(rp, Mask );
        SetDrMd( rp, DrawMode );
        SetAPen( rp, FgPen );
        return TRUE;
      }

    if ( !(rank = CardRank( Card )) || !(suit = CardSuit( Card )) )
      return FALSE;

    if ( suit == SUIT_SPECIAL )
        {
          x = 13;
          y = rank - 1;
        }
      else
        {
          x = rank - 1;
          y = suit - 1;
        }

    BltMaskBitMapRastPort(
       &bm,                                     /* Source BitMap */
       x * (CARD_V_WIDTH -  1L),                /* Source X      */
       y * (CARD_V_HEIGHT - 1L),                /* Source Y      */
       rp,                                      /* destRastPort  */
       dx, dy,                                  /* destX, destY  */
       CARD_V_WIDTH, CARD_V_HEIGHT,             /* sizeX, sizeY  */
       0x00E0,                                  /* minterm       */
       (APTR)mask                               /* bltMask       */
       );

    return TRUE;
    }




