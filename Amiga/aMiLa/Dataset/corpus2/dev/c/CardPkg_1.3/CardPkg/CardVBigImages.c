/*** CardVBigImages.c ***/

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
#include "CardVBigImages.h"
#include "Cards.h"

#ifdef AZTEC_C
  #include <functions.h>
#endif
#ifdef __SASC
  #include <clib/graphics_protos.h>
#endif

/**********************************************************************
CardVBigBrush.c contains an array of UWORDs which holds the bitmap
data for a deck of playing cards layed out in eight columns.  In
all, 56 cards are defined in the following order:

  Spades Hearts  Clubs  Diamonds  Spades Hearts  Clubs  Diamonds
    A       A       A       A       2       2       2       2
    3       3       3       3       4       4       4       4
    5       5       5       5       6       6       6       6
    7       7       7       7       8       8       8       8
    9       9       9       9      10      10      10      10
    J       J       J       J       Q       Q       Q       Q
    K       K       K       K     JOKER   BLANK   BACK    BLACK

Each card is 48 bits wide and 64 bits high, the edges of the cards
do not overlap, so the total bitmap is 384(h)x512(v)x2 planes deep. In
addition, another bitplane is defined which has the same shape as the 2
mentioned above, but with all the pixels within the cards turned on. This
bitplane is used as a mask with BltMaskBitMapRastPort() to round off the
corners of the cards.

MAKE SURE THE CardVBigBrush DATA GET LOADED INTO CHIP RAM!  You may
have to edit CardVBigBrush.c to add the "__chip" keyword, or you
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

#include "CardVBigBrush.c"

struct  Image CardVBigBrushimage =
 {
   0,0,
   512 , 384 , 3 ,
   &CardVBigBrush[0],
   0x1f,0x00,
   NULL,
 };

extern struct GfxBase *GfxBase;

BOOL ShowVBigCard( struct RastPort *rp, CardID_t Card, WORD dx, WORD dy )
  {

    static struct BitMap bm;
    static BOOL   bmInit = FALSE;
    static UWORD *mask;
    WORD          SourceX, SourceY;
    WORD          suit, rank,x,y;

    if (!bmInit)
      {
        PLANEPTR tmp;
        InitBitMap( &bm, 2L, 512L, 384L);
        bm.Planes[0] = (PLANEPTR)&CardVBigBrush [ 0 ];
        bm.Planes[1] = (PLANEPTR)&CardVBigBrush1[ 0 ];
        mask         =           &CardVBigBrush2[ 0 ];

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
        RectFill(rp, dx, dy, dx+CARD_VBIG_WIDTH-1, dy+CARD_VBIG_HEIGHT-1 );
        SetWrMsk(rp, Mask );
        SetDrMd( rp, DrawMode );
        SetAPen( rp, FgPen );
        return TRUE;
      }

    if ( !(rank = CardRank( Card )) || !(suit = CardSuit( Card )) )
      return FALSE;

    if ( suit == SUIT_SPECIAL )
        {
          y = 6;
          x = 3 + rank;
        }
      else
        {
          x = (suit - 1) + (rank&1? 0 : 4 );
          y = (rank - 1) / 2;
        }

    SourceX = x * CARD_VBIG_WIDTH;
    SourceY = y * CARD_VBIG_HEIGHT;

    BltMaskBitMapRastPort(
       &bm,                                     /* Source BitMap */
       SourceX,                                 /* Source X      */
       SourceY,                                 /* Source Y      */
       rp,                                      /* destRastPort  */
       dx, dy,                                  /* destX, destY  */
       CARD_VBIG_WIDTH, CARD_VBIG_HEIGHT,       /* sizeX, sizeY  */
       0x00E0,                                  /* minterm       */
       (APTR)mask                               /* bltMask       */
       );

    return TRUE;
  }


