/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : Game_AI.c
 ** Created on       : Tuesday, 23-Jun-98
 ** Created by       : Rick Keller
 ** Current revision : V 1.12
 **
 ** Purpose
 ** -------
 **   AI routine to determine cards played when following a lead,
 **   based on playing style
 **   Also includes Lead() routine
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 26-Aug-98   Rick Keller            cleared up display probs due to difft
 **                                     overscans (I hope)
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 04-Aug-98   Rick Keller            added flag for EvalTrick AI use
 ** 04-Aug-98   Rick Keller            added RISKY playstyle
 ** 23-Jul-98   Rick Keller            initial  MODERATE Follow() settings
 ** 23-Jul-98   Rick Keller            intitial MODERATE Lead() settings
 ** 02-Jul-98   Rick Keller            added take it with lowest needed routine for Follow() CONS
 ** 02-Jul-98   Rick Keller            added power lead routine for Lead()  CONS
 ** 01-Jul-98   Rick Keller            totally restructured logic for CONSERVATIVE Follow()
 ** 30-Jun-98   Rick Keller            created ShowPlayedCards() and UpdateCardStatus()
 ** 30-Jun-98   Rick Keller            combined common routines into FindUnusedCards(),
 **                                           FindBestCard(), and FindGarbage
 ** 30-Jun-98   Rick Keller            pulled Lead() routine and renamed file to Game_AI.c
 ** 23-Jun-98   Rick Keller            pulled routine from GamePlay.c
 **
 ** $Revision Header *********************************************************/

#include <exec/types.h>
#include <intuition/intuition.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

#include "gamesetup.h"
#include "settings.h"

extern short EvalTrick(struct GameInfo *, BOOL AI_use);

WORD FindUnusedCards( WORD plyr, struct RoundHand unused[] );
struct RoundHand FindBestCard(struct RoundHand cards[], WORD num_cards);
struct RoundHand FindGarbage(struct RoundHand cards[], WORD num_cards);
WORD UpdateCardStatus(WORD plyr, struct RoundHand played, short order);
void ShowPlayedCard(struct Image *showcard, WORD plyr, WORD index);

extern WORD GottaLoner;

struct CardTrack PlayedStats[4];

/************************************************************************
*
*       Lead();
*       determines and displays card led by computer
*                                                                                                                                              *
*
************************************************************************/

void Lead(struct GameInfo *Round, WORD plyr, short style)
{
    extern short Speed;

    struct RoundHand unused[5];
    struct RoundHand played;
    struct RoundHand non_trump[5];

    WORD un = 0;
    WORD index= 0;
    WORD i,j;
    WORD num_trump = 0;
    BOOL gotone = FALSE;
    BOOL goodlead = FALSE;
    Delay((LONG)(4 * Speed));

    // use only those cards not already played

    un = FindUnusedCards(plyr, unused);
/************************************************************************
                     BEGIN LONER
************************************************************************/

    if (GottaLoner == plyr)
    {
        played = FindBestCard(unused, un);
    }

/************************************************************************
                     END LONER
************************************************************************/
    
/************************************************************************
                     BEGIN CONSERVATIVE
************************************************************************/
///
    //begin CONSERVATIVE always leads srong card

    else if ( style == CONSERVATIVE ) 
    {
        //if it's the first lead of the Round
        if (un == 5)
        {
            played.round_value = 0;

            for (i = 0; i < un; i++)
            {
                if (unused[i].round_value == L_BAUER)
                {
                    played = unused[i];
                    gotone = TRUE;
                }
            }
            if (gotone == FALSE)
            {
                for (i = 0; i < un; i++)
                {
                    if (unused[i].round_value == R_BAUER)
                    {
                        played = unused[i];
                        gotone = TRUE;
                    }
                }
            }
            if (gotone == FALSE)
            {
                for (i = 0; i < un; i++)
                {
                    if (unused[i].round_value == ACE)
                    {
                        played = unused[i];
                        gotone = TRUE;
                    }
                }
            }
            if (gotone == FALSE)
            {
                played = FindGarbage(unused, un);
            }
        }
        else
        {
            played = FindBestCard(unused, un);
        }

    }
///
/************************************************************************
                     END CONSERVATIVE
************************************************************************/

/************************************************************************
*                    BEGIN MODERATE
************************************************************************/
///

    if ( style == MODERATE ) //begin MODERATE always leads srong card
    {
        j = 0;
        played.round_value = 0;

        for (i = 0; i < un; i++)
        {
            if (unused[i].suit == Round->trump_suit)
            {
                num_trump++;
            }
            else
            {
                non_trump[j] = unused[i];
                j++;
            }
        }

        if (un == 5 )
        {
            if (num_trump >= 4)
            {
                played = FindBestCard(unused, un);
                if (played.round_value >= R_BAUER)
                {
                    goodlead = TRUE;
                }
                else if (j > 0)
                {
                    played = FindBestCard(non_trump, j);
                    if (played.round_value == ACE)
                    {
                        goodlead = TRUE;
                    }
                }
            }
            else
            {
                played = FindBestCard(non_trump,j);
                if (played.round_value == ACE)
                {
                    goodlead = TRUE;
                }
                else
                {
                    played = FindBestCard(unused, un);
                    if (played.round_value >= R_BAUER)
                    {
                        goodlead = TRUE;
                    }
                }
            }
            if (goodlead == FALSE)
            {
                played = FindGarbage(unused,un);
            }
        }
        else if (un == 4)
        {
            played = FindBestCard(unused, un);
            if (num_trump >0)
            {
                 if (played.round_value >=R_BAUER)
                {
                    goodlead = TRUE;
                }
                else if (PlayedStats[Round->trump_suit].cards_played > 0 && played.round_value > KING_TRUMP)
                {
                    goodlead = TRUE;
                }
            }

            if (goodlead == FALSE)
            {
                played = FindBestCard(non_trump, j);
                if (played.round_value >= KING)
                {
                    goodlead = TRUE;
                }
                else if (PlayedStats[played.suit].cards_played > 0 && played.round_value >= QUEEN)
                {
                    goodlead = TRUE;
                }
            }
            if (goodlead == FALSE)
            {
                played = FindGarbage(unused, un);
            }
        }
        else if(un == 3)
        {
            played = FindBestCard(unused,un);
            if (played.suit == Round->trump_suit)
            {
                goodlead = TRUE;
            }
            else if (played.round_value >= KING || (PlayedStats[played.suit].cards_played > 0 && played.round_value >=QUEEN) )
            {
                goodlead = TRUE;
            }

            if (goodlead == FALSE)
            {
                played = FindGarbage(unused, un);
            }
        }
        else if (un < 3)
        {
            played = FindBestCard(unused, un);
        }
    }

///
/************************************************************************
*                  END MODERATE
************************************************************************/

/************************************************************************
*                    BEGIN RISKY
************************************************************************/
///

    if ( style == RISKY ) //begin RISKY always leads srong card but never trump
    {
        j = 0;
        played.round_value = 0;

        for (i = 0; i < un; i++)
        {
            if (unused[i].suit == Round->trump_suit)
            {
                num_trump++;
            }
            else
            {
                non_trump[j] = unused[i];
                j++;
            }
        }

        if (un == 5 )
        {
            if (num_trump >= 4)
            {
                played = FindBestCard(unused, un);
                if (played.round_value >= R_BAUER)
                {
                    goodlead = TRUE;
                }
                else if (j > 0)
                {
                    played = FindBestCard(non_trump, j);
                    if (played.round_value == ACE)
                    {
                        goodlead = TRUE;
                    }
                }
            }
            else
            {
                played = FindBestCard(non_trump,j);
                if (played.round_value == ACE)
                {
                    goodlead = TRUE;
                }
                else
                {
                    played = FindGarbage(unused, un);
                }
            }
        }
        else if (un == 4)
        {
            played = FindBestCard(unused, un);
            if (num_trump >= 3)
            {
                 if (played.round_value >=R_BAUER)
                {
                    goodlead = TRUE;
                }
                else if (PlayedStats[Round->trump_suit].cards_played > 0 && played.round_value > KING_TRUMP)
                {
                    goodlead = TRUE;
                }
            }

            if (goodlead == FALSE)
            {
                played = FindBestCard(non_trump, j);
                if (played.round_value >= KING)
                {
                    goodlead = TRUE;
                }
                else if (PlayedStats[played.suit].cards_played > 0 && played.round_value >= QUEEN)
                {
                    goodlead = TRUE;
                }
            }
            if (goodlead == FALSE)
            {
                played = FindGarbage(unused, un);
            }
        }
        else if(un == 3)
        {

//              find best card
            played = FindBestCard(unused, un);
            goodlead = TRUE;
//              if it's trump, check if it is the highest trump not yet played
            if (played.suit == Round->trump_suit)
            {
                if ( PlayedStats[played.suit].lbower_played == FALSE && played.round_value != L_BAUER)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].rbower_played == FALSE && played.round_value < R_BAUER)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].ace_played == FALSE && played.round_value < ACE_TRUMP)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].king_played == FALSE && played.round_value < KING_TRUMP)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].queen_played == FALSE && played.round_value < QUEEN_TRUMP)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].ten_played == FALSE && played.round_value < TEN_TRUMP)
                {
                    goodlead = FALSE;
                }
                else if (PlayedStats[played.suit].nine_played == FALSE && played.round_value < NINE_TRUMP)
                {
                    goodlead = FALSE;
                }
            }
//              if not and I called trump
//              play it if it is an Ace or better
            if ( goodlead == FALSE && Round->who_called == plyr && played.round_value >= ACE_TRUMP)
            {
                goodlead = TRUE;
            }
            else if (goodlead == FALSE)
            {
//              else play best non trump card if any
                for ( i = 0, j = 0; i < un; i++)
                {
                    if (unused[i].suit != Round->trump_suit)
                    {
                        non_trump[j] = unused[i];
                        j++;
                    }
                }
                if ( j > 0 )
                {
                    played = FindBestCard(non_trump, j);
                }
            }
        }
        else if (un < 3)
        {
            played = FindBestCard(unused, un);
        }

    }

///
/************************************************************************
*                  END RISKY
************************************************************************/

    // mark the card as used in the players hand and update the MyTrick struct
    index = UpdateCardStatus(plyr, played, 0);   //0 is used here because the
                                                 //value is stored in MyTrick[0]
    ShowPlayedCard(played.showcard, plyr, index);//as the first card in the trick

}   //end Lead ()

/************************************************************************
*
*
*         Follow()
*
*         determines computer follow card using play style
*
************************************************************************/

void Follow(struct GameInfo *Round, WORD plyr, short order, short style)
{
    extern struct Trick MyTrick[4];
    extern struct RoundHand players_hand[4][5];
    int i,k;
    int followcards,trumpcards,gc;
    WORD un = 0;
    WORD index=0;

    BOOL gottafollow = FALSE;
    BOOL gottrump = FALSE;
    BOOL takeit = TRUE;
    BOOL partnerhasit = FALSE;
    BOOL trumped = FALSE;

    short whogot = INITIAL_SETUP;

    struct RoundHand unused[5];
    struct RoundHand temp[5];
    struct RoundHand trump[5];
    struct RoundHand played, bestcard;
    struct RoundHand goodcards[5];

     //only use cards not already played, store # of cards in un
    un = FindUnusedCards(plyr, unused);

        //do i gottafollow--store value in 'gottafollow'
    for (i = 0, followcards=0; i < un; i++)
    {
        if (MyTrick[0].suit == unused[i].suit)  //use MyTrick[0].suit to see what suit was led by first player
        {
            gottafollow = TRUE;
            temp[followcards] = unused[i];
            followcards++;
        }
    }
    //handle single card issues in FindBestCard() and FindGarbage() !!!!
    
    //if i don't gottafollow
    if (gottafollow == FALSE)
    {
        //do I have trump? -- only if trump wasn't led!
        if (MyTrick[0].suit != Round->trump_suit)
        for (i = 0,trumpcards = 0; i < un; i++)
        {
            if (unused[i].suit == Round->trump_suit)
            {
                gottrump = TRUE;
                trump[trumpcards] = unused[i];
                trumpcards++;
            }
        }
    }

/************************************************************************
                     BEGIN CONSERVATIVE
************************************************************************/
///
    if (style == CONSERVATIVE)
    {
        //if i'm last
        //see if my partner has it, store value in 'partnerhasit'
        if (order == 3)
        {
            whogot = EvalTrick(Round, TRUE);
            if ( (plyr == 1 && whogot == 3) ||
                 (plyr == 3 && whogot == 1) ||
                 (plyr == 2 && whogot == 0)   )
               {
                    partnerhasit = TRUE;
               }
        }

        //if I gottafollow
        if (gottafollow == TRUE)
        {
            //if i'm last
            if (order == 3)
            {
                //does my partner have it?
                if (partnerhasit == TRUE)
                {
                    //if yes, throw garbage
                    played = FindGarbage(temp, followcards);
                }
                //if no,
                else
                {
                    //has it been trumped?
                    for (k=0; k < order; k++)
                    {
                        if (MyTrick[k].suit == Round->trump_suit && MyTrick[0].suit != Round->trump_suit)
                        {
                            trumped = TRUE;
                        }
                    }

                    //if yes
                    if (trumped == TRUE)
                    {
                        //throw garbage
                        played = FindGarbage(temp, followcards);
                    }

                    //if no
                    else
                    {
                        //find best card
                        bestcard = FindBestCard(temp, followcards);
                        //now, can I take it?
                        for (k = 0; k < order; k++)
                        {
                            if ( (MyTrick[k].card_value > bestcard.round_value) && (MyTrick[k].suit == MyTrick[0].suit) )
                            {
                                takeit = FALSE;
                            }
                        }

                        //if yes, take it with lowest card necessary
                        if (takeit == TRUE)
                        {
                            //for each card in the temp struct,
                            for (i = 0, gc = 0; i < followcards; i++)
                            {
                                for (k = 0; k < order; k++)
                                {
                                    //find the highest card in the Trick
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        //if my card is better than that one,
                                        if (temp[i].round_value > MyTrick[k].card_value)
                                        {
                                            //put it in the goodcards struct
                                            goodcards[gc] = temp[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            //take the trick with the lowest card possible,
                            //find it with FindGarbage()
                            played = FindGarbage(goodcards, gc);

                        }

                        //if no, throw garbage
                        else
                        {
                            played = FindGarbage(temp, followcards);
                        }
                    }
                }
            }
            //else, if i'm not last,
            else
            {
                //has it been trumped? only if you're not first to follow!
                if (order > 1)
                {
                    for (k=0; k < order; k++)
                    {
                        if (MyTrick[k].suit == Round->trump_suit && MyTrick[0].suit != Round->trump_suit)
                        {
                            trumped = TRUE;
                        }
                    }
                }

                //if yes, throw garbage
                if (trumped == TRUE)
                {
                    played = FindGarbage(temp,followcards);
                }
                //if no
                else
                {
                        //find best card
                        bestcard = FindBestCard(temp, followcards);
                        //now, can I take it?
                        for (k = 0; k < order; k++)
                        {
                            if ( (MyTrick[k].card_value > bestcard.round_value) && (MyTrick[k].suit == MyTrick[0].suit) )
                            {
                                takeit = FALSE;
                            }
                        }

                        //if yes, take it
                        if (takeit == TRUE)
                        {
                            played = bestcard;
                        }

                        //if no, throw garbage
                        else
                        {
                            played = FindGarbage(temp, followcards);
                        }
                }
            }
        }
        //else if I don't gottafollow
        else
        {
            //if i gottrump
            if (gottrump == TRUE)
            {
                //if i'm last
                if (order == 3)
                {
                    //does my partner have it?
                    if (partnerhasit == TRUE)
                    {
                        //if yes, throw garbage
                        played = FindGarbage(unused, un);
                    }
                    //if no
                    else
                    {
                        //can i take it, get best card
                        bestcard = FindBestCard(trump, trumpcards);

                        //see if i can take it
                        for (k = 0; k < order; k++)
                        {
                            if (MyTrick[k].card_value > bestcard.round_value)
                            {
                                takeit = FALSE;
                            }
                        }

                        //if yes take with lowest card necessary
                        if (takeit == TRUE)
                        {
                            //for each card in the trump struct,
                            for (i = 0, gc = 0; i < trumpcards; i++)
                            {
                                for (k = 0; k < order; k++)
                                {
                                    //find the highest card in the Trick
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        //if my card is better than that one,
                                        if (trump[i].round_value > MyTrick[k].card_value)
                                        {
                                            //put it in the goodcards struct
                                            goodcards[gc] = trump[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            //take the trick with the lowest card possible,
                            //find it with FindGarbage()
                            played = FindGarbage(goodcards, gc);

                        }
                        //if no
                        else
                        {
                            //throw garbage
                            played = FindGarbage(unused, un);
                        }
                    }
                }
                //if i'm not last
                else
                {
                    //can i take it
                    bestcard = FindBestCard(trump, trumpcards);

                    //see if i can take it
                    for (k = 0; k < order; k++)
                    {
                        if (MyTrick[k].card_value > bestcard.round_value)
                        {
                            takeit = FALSE;
                        }
                    }

                    //if yes
                    if (takeit == TRUE)
                    {
                        //take it
                        played = bestcard;
                    }
                    //if no
                    else
                    {
                        //throw garbage
                        played = FindGarbage(unused, un);
                    }
                }
            }
            //else if i don't gottrump
            else
            {
                //throw garbage
                played = FindGarbage(unused, un);
            }
        }
    }
///
/************************************************************************
                     END CONSERVATIVE
************************************************************************/

/************************************************************************
*                    BEGIN MODERATE
************************************************************************/
///
    else if (style == MODERATE)
    {

        //if i'm third or fourth
        if (order >= 2)
        {
            //see if my partner has it, store value in 'partnerhasit'
            whogot = EvalTrick(Round,TRUE);
            if ( (plyr == 1 && whogot == 3) ||
                 (plyr == 3 && whogot == 1) ||
                 (plyr == 2 && whogot == 0)   )
            {
                partnerhasit = TRUE;

            //if i'm third and my partnerhasit, see if he's threw an
            //Ace....if not, set partnerhasit to FALSE
                if (order == 2)
                {
                    if (MyTrick[0].card_value < ACE)
                    {
                        partnerhasit = FALSE;
                    }
                }
            }
        }

        //if I gottafollow
        if (gottafollow == TRUE)
        {
            //if i'm third or fourth
            if (order >= 2)
            {
                //does my partner have it?
                if (partnerhasit == TRUE)
                {
                    //if yes, throw garbage
                    played = FindGarbage(temp,followcards);
                }
                //if no,
                else
                {
                    //has it been trumped?
                    for (k = 0; k < order; k ++)
                    {
                        if (MyTrick[k].suit == Round->trump_suit && MyTrick[0].suit != Round->trump_suit)
                        {
                            trumped = TRUE;
                        }
                    }
                    //if yes
                    if (trumped == TRUE)
                    {
                        //throw garbage
                        played = FindGarbage(temp, followcards);
                    }
                    //if no,
                    else
                    {
                        //find best card
                        bestcard = FindBestCard(temp, followcards);
                        //now, can I take it?
                        for(k=0; k < order; k++)
                        {
                            if(MyTrick[k].card_value > bestcard.round_value && MyTrick[k].suit == MyTrick[0].suit)
                            {
                                takeit = FALSE;
                            }
                        }
                        //if yes, take it with lowest card necessary
                        if (takeit == TRUE)
                        {
                            //for each card in the temp struct,
                            for (i=0, gc =0; i < followcards; i++)
                            {
                                for(k=0; k < order; k++)
                                {
                                    //find the higest card in the Trick
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        //if my card is better than that one,
                                        if (temp[i].round_value > MyTrick[k].card_value)
                                        {
                                            //put it in the goodcards struct
                                            goodcards[gc] = temp[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            //take trick with lowest card poss, using FindGarbage
                            played = FindGarbage(goodcards, gc);
                        }
                        //if no, throw garbage
                        else
                        {
                            played = FindGarbage(temp,followcards);
                        }
                    }

                }
            }
            //else, if i'm not 3rd or 4th
            else
            {

                //find best card
                bestcard = FindBestCard(temp, followcards);
                //can I take it if so, take it
                if (bestcard.round_value > MyTrick[0].card_value)
                {
                    played = bestcard;
                }
                //if not, throw garbage
                else
                {
                    played = FindGarbage(temp, followcards);
                }
            }
        }
        //else if I don't gottafollow
        else
        {
            //if i gottrump
            if (gottrump == TRUE)
            {
                //if i'm 3rd or 4th
                if (order >= 2)
                {
                    //does my partner have it?
                    if (partnerhasit == TRUE)
                    {
                       //yes, throw garbage
                       played = FindGarbage(unused, un);
                    }
                    //if no
                    else
                    {
                        //can i take it
                        bestcard = FindBestCard(trump, trumpcards);
                        for (k=0; k< order; k++)
                        {
                            if (MyTrick[k].card_value > bestcard.round_value)
                            {
                                takeit = FALSE;
                            }
                        }
                        //if yes
                        if (takeit == TRUE)
                        {
                            //take it with lowest card needed
                            for (i=0, gc =0; i < trumpcards; i++)
                            {
                                for (k=0; k< order; k++)
                                {
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        if (trump[i].round_value > MyTrick[k].card_value)
                                        {
                                            goodcards[gc] = trump[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            played = FindGarbage(goodcards, gc);
                        }

                        //if no
                        else
                        {
                            //throw garbage
                            played = FindGarbage(unused, un);
                        }
                    }
                }
                //if i'm 2nd
                else
                {
                    //can i take it
                    bestcard = FindBestCard(trump, trumpcards);
                    for (k=0; k< order; k++)
                    {
                        if (MyTrick[k].card_value > bestcard.round_value)
                        {
                            takeit = FALSE;
                        }
                    }
                    //if yes
                    if (takeit == TRUE)
                    {
                        whogot = EvalTrick(Round,TRUE);
                        //take it with lowest card needed
                        for (i=0, gc =0; i < trumpcards; i++)
                        {
                            for (k=0; k< order; k++)
                            {
                                if (MyTrick[k].played_by == whogot)
                                {
                                    if (trump[i].round_value > MyTrick[k].card_value)
                                    {
                                        goodcards[gc] = trump[i];
                                        gc++;
                                    }
                                }
                            }
                        }
                        played = FindGarbage(goodcards, gc);
                    }

                    //if no
                    else
                    {
                        //throw garbage
                        played = FindGarbage(unused, un);
                    }
                }
            }
            //else if i don't gottrump
            else
            {
                played = FindGarbage(unused, un);
            }
        }
    }
///
/************************************************************************
*                    END MODERATE
************************************************************************/

/************************************************************************
*                    BEGIN RISKY
************************************************************************/
///
    else if (style == RISKY)
    {

        //if i'm third or fourth
        if (order >= 2)
        {
            //see if my partner has it, store value in 'partnerhasit'
            whogot = EvalTrick(Round,TRUE);
            if ( (plyr == 1 && whogot == 3) ||
                 (plyr == 3 && whogot == 1) ||
                 (plyr == 2 && whogot == 0)   )
            {
                partnerhasit = TRUE;

            //if i'm third and my partnerhasit, see if he's threw an
            //Ace....if not, set partnerhasit to FALSE
                if (order == 2)
                {
                    if (MyTrick[0].card_value < QUEEN)
                    {
                        partnerhasit = FALSE;
                    }
                }
            }
        }

        //if I gottafollow
        if (gottafollow == TRUE)
        {
            //if i'm third or fourth
            if (order >= 2)
            {
                //does my partner have it?
                if (partnerhasit == TRUE)
                {
                    //if yes, throw garbage
                    played = FindGarbage(temp,followcards);
                }
                //if no,
                else
                {
                    //has it been trumped?
                    for (k = 0; k < order; k ++)
                    {
                        if (MyTrick[k].suit == Round->trump_suit && MyTrick[0].suit != Round->trump_suit)
                        {
                            trumped = TRUE;
                        }
                    }
                    //if yes
                    if (trumped == TRUE)
                    {
                        //throw garbage
                        played = FindGarbage(temp, followcards);
                    }
                    //if no,
                    else
                    {
                        //find best card
                        bestcard = FindBestCard(temp, followcards);
                        //now, can I take it?
                        for(k=0; k < order; k++)
                        {
                            if(MyTrick[k].card_value > bestcard.round_value && MyTrick[k].suit == MyTrick[0].suit)
                            {
                                takeit = FALSE;
                            }
                        }
                        //if yes, take it with lowest card necessary
                        if (takeit == TRUE)
                        {
                            //for each card in the temp struct,
                            for (i=0, gc =0; i < followcards; i++)
                            {
                                for(k=0; k < order; k++)
                                {
                                    //find the higest card in the Trick
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        //if my card is better than that one,
                                        if (temp[i].round_value > MyTrick[k].card_value)
                                        {
                                            //put it in the goodcards struct
                                            goodcards[gc] = temp[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            //take trick with lowest card poss, using FindGarbage
                            played = FindGarbage(goodcards, gc);
                        }
                        //if no, throw garbage
                        else
                        {
                            played = FindGarbage(temp,followcards);
                        }
                    }

                }
            }
            //else, if i'm not 3rd or 4th
            else
            {

                //find best card
                bestcard = FindBestCard(temp, followcards);
                //can I take it if so, take it
                if (bestcard.round_value > MyTrick[0].card_value)
                {
                    played = bestcard;
                }
                //if not, throw garbage
                else
                {
                    played = FindGarbage(temp, followcards);
                }
            }
        }
        //else if I don't gottafollow
        else
        {
            //if i gottrump
            if (gottrump == TRUE)
            {
                //if i'm 3rd or 4th
                if (order >= 2)
                {
                    //does my partner have it?
                    if (partnerhasit == TRUE)
                    {
                       //yes, throw garbage
                       played = FindGarbage(unused, un);
                    }
                    //if no
                    else
                    {
                        //can i take it
                        bestcard = FindBestCard(trump, trumpcards);
                        for (k=0; k< order; k++)
                        {
                            if (MyTrick[k].card_value > bestcard.round_value)
                            {
                                takeit = FALSE;
                            }
                        }
                        //if yes
                        if (takeit == TRUE)
                        {
                            //take it with lowest card needed
                            for (i=0, gc =0; i < trumpcards; i++)
                            {
                                for (k=0; k< order; k++)
                                {
                                    if (MyTrick[k].played_by == whogot)
                                    {
                                        if (trump[i].round_value > MyTrick[k].card_value)
                                        {
                                            goodcards[gc] = trump[i];
                                            gc++;
                                        }
                                    }
                                }
                            }
                            played = FindGarbage(goodcards, gc);
                        }

                        //if no
                        else
                        {
                            //throw garbage
                            played = FindGarbage(unused, un);
                        }
                    }
                }
                //if i'm 2nd
                else
                {
                    //can i take it
                    bestcard = FindBestCard(trump, trumpcards);
                    for (k=0; k< order; k++)
                    {
                        if (MyTrick[k].card_value > bestcard.round_value)
                        {
                            takeit = FALSE;
                        }
                    }
                    //if yes
                    if (takeit == TRUE)
                    {
                        whogot = EvalTrick(Round, TRUE);
                        //take it with lowest card needed
                        for (i=0, gc =0; i < trumpcards; i++)
                        {
                            for (k=0; k< order; k++)
                            {
                                if (MyTrick[k].played_by == whogot)
                                {
                                    if (trump[i].round_value > MyTrick[k].card_value)
                                    {
                                        goodcards[gc] = trump[i];
                                        gc++;
                                    }
                                }
                            }
                        }
                        played = FindGarbage(goodcards, gc);
                    }

                    //if no
                    else
                    {
                        //throw garbage
                        played = FindGarbage(unused, un);
                    }
                }
            }
            //else if i don't gottrump
            else
            {
                played = FindGarbage(unused, un);
            }
        }
    }
///
/************************************************************************
*                    END RISKY
************************************************************************/


    // mark the card as used in the players hand and Trick struct
    index = UpdateCardStatus(plyr, played, order);
    ShowPlayedCard(played.showcard, plyr, index);
}//end Follow()

/************************************************************************
*
*       FindUnusedCards()
*
*           finds all cards flagged used==FALSE and puts them in the
*           unused array
*
*           return value is the number of unused cards in the hand
*
************************************************************************/

WORD FindUnusedCards( WORD plyr, struct RoundHand unused[] )
{
    extern struct RoundHand players_hand[4][5];

    WORD i;
    WORD un;

    for (i = 0, un = 0; i < 5; i++)
    {
        if(players_hand[plyr][i].used == FALSE)
        {
            unused[un] = players_hand[plyr][i];
            un++;
        }
    }

    return un;
}

/************************************************************************
*
*
*   FindBestCard()
*         finds and returns the best card in the players hand
*         Lead()--best card overall
*         Follow()--best card for suit in question
*
*         return value is that card
*
************************************************************************/

struct RoundHand FindBestCard(struct RoundHand cards[], WORD num_cards)
{
    WORD i,bigcard;
    WORD bigind = 0;

    //if only 1 card available, play it
    if (num_cards == 1)
    {
        return cards[0];
    }

    else
    {
        i = 0;
        bigcard = 0;

        do
        {
            if (cards[i].round_value > bigcard && cards[i].round_value > cards[i+1].round_value)
            {
                bigind = i;
                bigcard = cards[i].round_value;
            }
            else if (cards[i+1].round_value > bigcard && cards[i+1].round_value > cards[i].round_value)
            {
                bigind = i+1;
                bigcard = cards[i+1].round_value;
            }
            i++;
        } while (i < num_cards-1);
    }

    return cards[bigind];
}

/************************************************************************
*
*   FindGarbage()
*         finds and returns the worst card in the players hand
*
*         return value is that card
*
************************************************************************/
struct RoundHand FindGarbage(struct RoundHand cards[], WORD num_cards)
{
    WORD i;
    WORD lowind = 0;
    WORD lowcard;

    //if only 1 card available, play it!!
    if (num_cards == 1)
    {
        return cards[0];
    }

    else
    {
        i = 0;
        lowcard = 12;

        do
        {
            if (cards[i].round_value < lowcard && cards[i].round_value < cards[i+1].round_value)
            {
                lowind = i;
                lowcard = cards[i].round_value;
            }
            else if (cards[i+1].round_value < lowcard && cards[i+1].round_value < cards[i].round_value)
            {
                lowind = i+1;
                lowcard = cards[i+1].round_value;
            }
            i++;
        } while (i < num_cards-1);
    }

    return cards[lowind];
}
/************************************************************************
*
*       UpdateCardStatus()
*
*               adds played card to Trick struct and marks card
*               as played in players hand
*
*               return value is index of card played
*
************************************************************************/
WORD UpdateCardStatus(WORD plyr, struct RoundHand played, short order)
{

    WORD played_index, s;

    extern struct Trick MyTrick[4];
    extern struct RoundHand players_hand[4][5];
    for (played_index = 0; played_index < 5; played_index++)
    {
        if (played.suit == players_hand[plyr][played_index].suit && played.round_value == players_hand[plyr][played_index].round_value)
        {
            players_hand[plyr][played_index].used = TRUE;
            break;
        }
    }
    //update the MyTrick struct
    MyTrick[order].card_value = played.round_value;
    MyTrick[order].played_by = plyr;
    MyTrick[order].suit = played.suit;

    //updates PlayedStats

    for (s = 0; s < 4; s++)
    {
        if (played.suit == s)
        {
            PlayedStats[s].cards_played++;
            switch (played.round_value)
            {
                case NINE:
                case NINE_TRUMP:
                    PlayedStats[s].nine_played = TRUE;
                    break;

                case TEN:
                case TEN_TRUMP:
                    PlayedStats[s].ten_played = TRUE;
                    break;

                case JACK:
                    PlayedStats[s].jack_played = TRUE;
                    break;

                case QUEEN:
                case QUEEN_TRUMP:
                    PlayedStats[s].queen_played = TRUE;
                    break;

                case KING:
                case KING_TRUMP:
                    PlayedStats[s].king_played = TRUE;
                    break;
                case ACE:
                case ACE_TRUMP:
                    PlayedStats[s].ace_played = TRUE;
                    break;

                case L_BAUER:
                    PlayedStats[s].lbower_played = TRUE;
                    break;

                case R_BAUER:
                    PlayedStats[s].rbower_played = TRUE;
                    break;
            }
        }
    }

    return played_index;
}
/************************************************************************
*
*       ShowPlayedCard()
*
*          displays on screen the card played from Lead() or Follow()
*
*
************************************************************************/
void ShowPlayedCard(struct Image *showcard, WORD plyr, WORD index)
{
    extern short Speed;
    extern struct Window *EuchreMain;
    extern LONG Player0Card[5][2];
    extern LONG Player1Card[5][2];
    extern LONG Player2Card[5][2];
    extern LONG Player3Card[5][2];
    extern LONG UpCardPos[4];

    LONG PlayWidth;
    LONG plyr1X, plyr3X;

    PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;

    switch (plyr)
    {
        case 1:
            plyr1X = ((PlayWidth - CARD_WIDTH)/2) - (CARD_LENGTH + 4);
            DrawImage(EuchreMain->RPort, showcard, plyr1X, Player1Card[2][1]);
            EraseImage(EuchreMain->RPort, showcard, Player1Card[index][0], Player1Card[index][1]);
            break;
        case 2:
            DrawImage(EuchreMain->RPort, showcard, Player2Card[2][0], (UpCardPos[2]));
            EraseImage(EuchreMain->RPort, showcard, Player2Card[index][0], Player2Card[index][1]);
            break;
        case 3:
            plyr3X = ((PlayWidth + CARD_WIDTH)/2) + 4;
            DrawImage(EuchreMain->RPort, showcard, plyr3X, Player3Card[2][1]);
            EraseImage(EuchreMain->RPort, showcard, Player3Card[index][0], Player3Card[index][1]);
            break;
    }
    Delay((LONG)(4 * Speed));
}

