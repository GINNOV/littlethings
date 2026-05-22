/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : SortHand.c
 ** Created on       : Monday, 25-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.03
 **
 ** Purpose
 ** -------
 **   sorts players hand for easier AI use
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 25-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
#include <exec/types.h>
#include <intuition/intuition.h>
#include "gamesetup.h"

extern struct Hand Player[4];
struct RoundHand players_hand[4][5];
extern WORD GottaLoner;

void SortHand(struct GameInfo *Round)
{
    short i,j;

    for (i = 0; i < 4; i ++)
        for (j = 0; j < 5; j ++)
        {
                players_hand[i][j].used = FALSE;
                if (Player[i].MyHand[j].suit == Round->trump_suit)
                {
                    players_hand[i][j].suit = Round->trump_suit;
                    players_hand[i][j].round_value = Player[i].MyHand[j].trumpvalue;
                }
                else if( ( (Player[i].MyHand[j].suit == DIAMONDS && Round->trump_suit == HEARTS) ||
                           (Player[i].MyHand[j].suit == HEARTS && Round->trump_suit == DIAMONDS) ||
                           (Player[i].MyHand[j].suit == CLUBS && Round->trump_suit == SPADES)    ||
                           (Player[i].MyHand[j].suit == SPADES && Round->trump_suit == CLUBS)   )&&
                            Player[i].MyHand[j].Rbauer == R_BAUER)
                {
                    players_hand[i][j].suit = Round->trump_suit;
                    players_hand[i][j].round_value = R_BAUER;
                }
                else
                {
                    players_hand[i][j].suit = Player[i].MyHand[j].suit;
                    players_hand[i][j].round_value = Player[i].MyHand[j].value;
                }

                if (i == 0 || i == 2)
                    players_hand[i][j].showcard = Player[i].MyHand[j].CardImage;
                else
                    players_hand[i][j].showcard = Player[i].MyHand[j].hCardImage;
        }

}

