/************************************************************

    TML's C Language Card Image Package  v1.1
    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/

#ifndef CARD_H_IMAGES_H
#define CARD_H_IMAGES_H 1
#include <exec/types.h>

#include "Cards.h"

#define CARD_H_WIDTH   64
#define CARD_H_HEIGHT  18
#define CARD_H_DEPTH    2

extern UWORD CardHBrush [];
extern UWORD CardHBrush1[];
extern UWORD CardHBrush2[];
/*----- bitmap : w = 512, h = 126, d = 3 ------ words = 8064 ---*/

extern BOOL ShowHCard( struct RastPort *rp, CardID_t Card, WORD dx, WORD dy );
   /*  rp had better point to a real RastPort.                   */
   /*  Card is an CardID_t .                                     */
   /*  dx and dy are the offsets of the upper left corner of the */
   /*     selected card in the RastPort.                         */
   /*  Returns FALSE if Card is out of range, TRUE otherwise.    */


/*
 *The way these things are set up, you can say:
 *
 *   ShowHCard( rp, CardID(SUIT_SPADES,2), 10, 20 );
 *
 * to display the 2 of Spades.
 *
 * The Jack  of Spades would be ShowHCard( rp, CardID(SUIT_SPADES,11),     dx, dy).
 * The Queen of Clubs  would be ShowHCard( rp, CardID(SUIT_CLUBS, 12),     dx, dy).
 * The King  of Hearts would be ShowHCard( rp, CardID(SUIT_HEARTS,13),     dx, dy).
 * The Joker           would be ShowHCard( rp, CardID(SUIT_SPECIAL,JOKER), dx, dy).
 */
#endif
