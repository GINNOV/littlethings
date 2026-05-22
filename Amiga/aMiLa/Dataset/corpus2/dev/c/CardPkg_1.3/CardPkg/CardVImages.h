/************************************************************

    TML's C Language Card Image Package  v1.1

    January, 1993
    Todd M. Lewis             (919) 776-7386
    2601 Piedmont Drive
    Sanford, NC  27330-9437
    USA
************************************************************/

#ifndef CARD_V_IMAGES_H
#define CARD_V_IMAGES_H 1
#include <exec/types.h>
#include "Cards.h"

#define CARD_V_WIDTH   38
#define CARD_V_HEIGHT  32
#define CARD_V_DEPTH    2

extern UWORD CardVBrush [];
extern UWORD CardVBrush1[];
extern UWORD CardVBrush2[];
 /*----- bitmap : w = 519, h = 125, d = 3 -------*/

extern BOOL ShowVCard( struct RastPort *rp, CardID_t Card, WORD dx, WORD dy );
   /*  rp had better point to a real RastPort.                   */
   /*  Card is an CardID_t .                                     */
   /*  dx and dy are the offsets of the upper left corner of the */
   /*     selected card in the RastPort.                         */
   /*  Returns FALSE if Card is out of range, TRUE otherwise.    */

/*
 *The way these things are set up, you can say:
 *
 *   ShowVCard( rp, CardID(SUIT_SPADES,2), 10, 20 );
 *
 * to display the 2 of Spades.
 *
 * The Jack  of Spades would be ShowVCard( rp, CardID(SUIT_SPADES,11),     dx, dy).
 * The Queen of Clubs  would be ShowVCard( rp, CardID(SUIT_CLUBS, 12),     dx, dy).
 * The King  of Hearts would be ShowVCard( rp, CardID(SUIT_HEARTS,13),     dx, dy).
 * The Joker           would be ShowVCard( rp, CardID(SUIT_SPECIAL,JOKER), dx, dy).
 */


#endif
