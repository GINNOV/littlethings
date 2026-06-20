
///
/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : Deal.c
 ** Created on       : Thursday, 07-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.04
 **
 ** Purpose
 ** -------
 **   Deal routine
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 08-Aug-97   Rick Keller            added shadowed card images
 ** 08-Aug-97   Rick Keller            changed rand() usage
 ** 07-Aug-97   Rick Keller          moved srand() inside of 1st for stmt
 ** 07-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
///

#include <exec/types.h>
#include <stdlib.h>
#include <time.h>

#include "gamesetup.h"
#include "spades.h"
#include "hearts.h"
#include "diamonds.h"
#include "clubs.h"

static struct Cards Deck[] =
    {
        { SPADES,   NINE,   NINE_TRUMP,   NOT_BAUER, FALSE, &Spades9,       &hSpades9},
        { SPADES,   TEN,    TEN_TRUMP,    NOT_BAUER, FALSE, &Spades10,      &hSpades10},
        { SPADES,   JACK,   L_BAUER,      R_BAUER,   FALSE, &JackSpades,    &hJackSpades},
        { SPADES,   QUEEN,  QUEEN_TRUMP,  NOT_BAUER, FALSE, &QueenSpades,   &hQueenSpades},
        { SPADES,   KING,   KING_TRUMP,   NOT_BAUER, FALSE, &KingSpades,    &hKingSpades},
        { SPADES,   ACE,    ACE_TRUMP,    NOT_BAUER, FALSE, &AceSpades,     &hAceSpades},

        { CLUBS,    NINE,   NINE_TRUMP,   NOT_BAUER, FALSE, &Clubs9,        &hClubs9},
        { CLUBS,    TEN,    TEN_TRUMP,    NOT_BAUER, FALSE, &Clubs10,       &hClubs10},
        { CLUBS,    JACK,   L_BAUER,      R_BAUER,   FALSE, &JackClubs,     &hJackClubs},
        { CLUBS,    QUEEN,  QUEEN_TRUMP,  NOT_BAUER, FALSE, &QueenClubs,    &hQueenClubs},
        { CLUBS,    KING,   KING_TRUMP,   NOT_BAUER, FALSE, &KingClubs,     &hKingClubs},
        { CLUBS,    ACE,    ACE_TRUMP,    NOT_BAUER, FALSE, &AceClubs,      &hAceClubs},

        { HEARTS,   NINE,   NINE_TRUMP,   NOT_BAUER, FALSE, &Hearts9,       &hHearts9},
        { HEARTS,   TEN,    TEN_TRUMP,    NOT_BAUER, FALSE, &Hearts10,      &hHearts10},
        { HEARTS,   JACK,   L_BAUER,      R_BAUER,   FALSE, &JackHearts,    &hJackHearts},
        { HEARTS,   QUEEN,  QUEEN_TRUMP,  NOT_BAUER, FALSE, &QueenHearts,   &hQueenHearts},
        { HEARTS,   KING,   KING_TRUMP,   NOT_BAUER, FALSE, &KingHearts,    &hKingHearts},
        { HEARTS,   ACE,    ACE_TRUMP,    NOT_BAUER, FALSE, &AceHearts,     &hAceHearts},

        { DIAMONDS, NINE,   NINE_TRUMP,   NOT_BAUER, FALSE, &Diamonds9,     &hDiamonds9},
        { DIAMONDS, TEN,    TEN_TRUMP,    NOT_BAUER, FALSE, &Diamonds10,    &hDiamonds10},
        { DIAMONDS, JACK,   L_BAUER,      R_BAUER,   FALSE, &JackDiamonds,  &hJackDiamonds},
        { DIAMONDS, QUEEN,  QUEEN_TRUMP,  NOT_BAUER, FALSE, &QueenDiamonds, &hQueenDiamonds},
        { DIAMONDS, KING,   KING_TRUMP,   NOT_BAUER, FALSE, &KingDiamonds,  &hKingDiamonds},
        { DIAMONDS, ACE,    ACE_TRUMP,    NOT_BAUER, FALSE, &AceDiamonds,   &hAceDiamonds},

    };//struct init


struct Cards *Deal(void)
{
    extern struct Hand Player[4];
    WORD plyr_num,card_num;
    LONG dealt;
    WORD init;

    for (init = 0; init < 24; init++)
        Deck[init].used = FALSE;

    for (plyr_num = 0; plyr_num < 4; plyr_num++)
    {
        srand(time(NULL));
        for (card_num = 0; card_num < 5; card_num++)
        {
            do
            {
              dealt = (rand() >> 8) % 24;
            } while (Deck[dealt].used == TRUE);
            //Loop ends when a card not yet dealt is picked
            //set 'used' flag in Deck structure and assign the card to the player
            Deck[dealt].used = TRUE;
            Player[plyr_num].MyHand[card_num] = Deck[dealt];
            Player[plyr_num].MyHand[card_num].used = FALSE;
           //card hasn't been played from hand yet!  ^^^^^

        }//inner for
    }//outer for
    do
    {
        dealt = (rand() >> 8) % 24;
    } while (Deck[dealt].used == TRUE);
    return &Deck[dealt];
}//end Deal()
