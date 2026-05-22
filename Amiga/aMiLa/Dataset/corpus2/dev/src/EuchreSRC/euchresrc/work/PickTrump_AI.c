/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : PickTrump.c
 ** Created on       : Thursday, 16-Oct-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.06
 **
 ** Purpose
 ** -------
 **   trump call AI based on playing style setting
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 09-Oct-98   Rick Keller            add loner handling for computer guys
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 04-Aug-98   Rick Keller            added RISKY playing style
 ** 22-Jul-98   Rick Keller            added MODERATE playing style
 ** 20-Jun-98   Rick Keller            finished call settings for CONSERVATIVE playing style
 ** 11-Jun-98   Rick Keller            added use of Config settings
 ** 16-Oct-97   Rick Keller            pulled routine from CallTrump.c
 **
 ** $Revision Header *********************************************************/
///
#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/gadtools.h>
#include <intuition/gadgetclass.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/dos_protos.h>

#include "gamesetup.h"
#include "settings.h"

extern void ShowTrump(WORD);
extern void CheckMenu( void );
extern struct Hand Player[];

extern WORD GottaLoner;

void DisplayCall(WORD call, WORD plyr, BOOL loner);
void BuryBower(struct Cards *UpCard );

WORD PickTrump(struct GameInfo *Round, WORD plyr, WORD round, struct Cards *UpCard, short style)
{
    extern struct CardTrack PlayedStats[4];

    short i, j, bigval, bigind;
    short hand_value[4]={0,0,0,0};

    short gotsuit[4] ={0,0,0,0} ;

    WORD call = 4;
    BOOL gotbower = FALSE;
    BOOL gotace = FALSE;
    BOOL bowerburied = FALSE;
    BOOL loner = FALSE;
///
    CheckMenu();
    if (round == 1) //pick up?
    {

        for (i = 0; i < 4; i++) //for each suit, do the following
        {                           // finds value of hand
            if (UpCard->suit == i)
            {
                for ( j = 0; j < 5; j++)
                {
                    gotsuit[Player[plyr].MyHand[j].suit]++;

                    if (Player[plyr].MyHand[j].suit == i)
                    {
                        hand_value[0] += Player[plyr].MyHand[j].trumpvalue;
                        if (Player[plyr].MyHand[j].trumpvalue == L_BAUER)
                            gotbower = TRUE;
                    }

                    else if ( i == SPADES && Player[plyr].MyHand[j].suit == CLUBS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        hand_value[0] += R_BAUER;
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[SPADES]++;
                    }

                    else if ( i == CLUBS && Player[plyr].MyHand[j].suit == SPADES && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        hand_value[0] += R_BAUER;
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[CLUBS]++;
                    }

                    else if ( i == HEARTS && Player[plyr].MyHand[j].suit == DIAMONDS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        hand_value[0] += R_BAUER;
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[HEARTS]++;
                    }

                    else if ( i == DIAMONDS && Player[plyr].MyHand[j].suit == HEARTS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        hand_value[0] += R_BAUER;
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[DIAMONDS]++;
                    }

                    if (Player[plyr].MyHand[j].value == ACE)
                    {
                        gotace = TRUE;
                    }
                }
            }
        }

        //if dealer is considering picking up, make sure that the number of
        //trumps in hand is accounted for after picking up

        if (Round->dealer == plyr)
        {
            hand_value[0] += UpCard->trumpvalue;
            gotsuit[call]++;
        }


        if (style == CONSERVATIVE) //criteria for CONSERVATIVE player
        {

            if (hand_value[0] > 25)
            {
                call =  UpCard->suit;
                Round->who_called = plyr;
            }

            //CONSERVATIVE loner call

            if (hand_value[0] > 37)
            {
                if (gotbower == TRUE)
                {
                    if (gotsuit[call] >= 4)
                    {
                        GottaLoner = plyr;
                        loner = TRUE;
                    }

                    //make sure there's not crap in the hand....
                    for (i = 0; i < 5; i++)
                    {
                        if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value < KING)
                        {
                            GottaLoner = INITIAL_SETUP;
                            loner = FALSE;
                        }
                    } 

                }
            }

        } //end CONSERVATIVE

        //begin MODERATE
        else if (style == MODERATE)
        {
            if ( (Round->dealer == 0 && plyr == 2) ||
                      (Round->dealer == 1 && plyr == 3) ||
                      (Round->dealer == 3 && plyr == 1)   )
            {
                hand_value[0] += UpCard->trumpvalue/2;
            }


            if (gotbower == TRUE && gotace == TRUE && Player[plyr].NumSuits <= 2)
            {
                if (hand_value[0] > 20)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }
            else if ( (gotbower == FALSE && gotace == TRUE) || (gotbower ==TRUE && gotace == FALSE) )
            {
                if (hand_value[0] > 22)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }
            else
            {
                if (hand_value[0] > 25)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }

            // MODERATE loner call

            if (hand_value[0] > 33 && gotsuit[call] >= 3)
            {
                if (gotbower == TRUE)
                {
                    for (i=0; i < 5; i++)
                    {
                        if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value == ACE)
                        {
                            GottaLoner = plyr;
                            loner = TRUE;
                        }
                    }
                }
            }

        }//END MODERATE

        //begin RISKY
        else if (style == RISKY)
        {
            if ( (Round->dealer == 0 && plyr == 2) ||
                      (Round->dealer == 1 && plyr == 3) ||
                      (Round->dealer == 3 && plyr == 1)   )
            {
                hand_value[0] +=  (UpCard->trumpvalue) * .85;
            }


            if (gotbower == TRUE && gotace == TRUE && gotsuit[call] >= 3)
            {
                if (hand_value[0] > 20)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }
            else if ( gotace == TRUE || gotbower ==TRUE )
            {
                if (hand_value[0] > 21)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }
            else
            {
                if (hand_value[0] > 24)
                {
                    Round->who_called = plyr;
                    call = UpCard->suit;
                }
            }

            //RISKY loner call
            if (hand_value[0] > 30 && gotbower == TRUE)
            {
                if (gotsuit[call] >= 3)
                {
                    GottaLoner = plyr;
                    loner = TRUE;
                }

                //make sure there's not crap in the hand....
                for (i = 0; i < 5; i++)
                {
                    if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value < KING)
                    {
                        GottaLoner = INITIAL_SETUP;
                        loner = FALSE;
                    }
                }

            }

        }//END RISKY

    }
    //call trump suit from remaining suits
///
    else if (round == 2)
    {
        

        for (i = 0; i < 4; i++) //for each suit, do the following
        {
            if (UpCard->suit != i)
            {
                for ( j = 0; j < 5; j++)
                {
                    gotsuit[Player[plyr].MyHand[j].suit]++;

                    if (Player[plyr].MyHand[j].suit == i)
                        hand_value[i] += Player[plyr].MyHand[j].trumpvalue;

                    else if ( i == SPADES && Player[plyr].MyHand[j].suit == CLUBS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[SPADES]++;
                        hand_value[i] += R_BAUER;
                    }
                    else if ( i == CLUBS && Player[plyr].MyHand[j].suit == SPADES && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[CLUBS]++;
                        hand_value[i] += R_BAUER;
                    }
                    else if ( i == HEARTS && Player[plyr].MyHand[j].suit == DIAMONDS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[HEARTS]++;
                        hand_value[i] += R_BAUER;
                    }
                    else if ( i == DIAMONDS && Player[plyr].MyHand[j].suit == HEARTS && Player[plyr].MyHand[j].Rbauer == R_BAUER)
                    {
                        gotbower = TRUE;
                        gotsuit[Player[plyr].MyHand[j].suit]--;
                        gotsuit[DIAMONDS]++;
                        hand_value[i] += R_BAUER;
                    }

                }
            }
        }

        //find the best trump suit for the hand

        i = 0;
        bigval = 0;
        bigind = 0;
        do
        {

            if (hand_value[i] > bigval && hand_value[i] > hand_value[i+1])
            {
                bigind = i;
                bigval = hand_value[i];
            }
            else if (hand_value[i+1] > bigval && hand_value[i+1] > hand_value[i])
            {
                bigind = i+1;
                bigval = hand_value[i+1];
            }
            i++;
        } while (i < 3);

        //if the UpCard was a Jack, note the fact a bower was buried
        if (UpCard->value == JACK)
        {
            if ((UpCard->suit == SPADES   && bigind == CLUBS)   ||
                (UpCard->suit == CLUBS    && bigind == SPADES)  ||
                (UpCard->suit == HEARTS   && bigind == DIAMONDS)||
                (UpCard->suit == DIAMONDS && bigind == HEARTS)    )
            {
                bowerburied = TRUE;
            }
        }

        //CONSERVATIVE playing style
        if (style == CONSERVATIVE) 
        {
            if (hand_value[bigind] > 25)
            {
                call = bigind;
                Round->who_called = plyr;
            }

            //if a bower was upcard and got buried, comp color can be called with lower val
            if (bowerburied == TRUE)
            {
                if (hand_value[bigind] > 24)
                {
                    call = bigind;
                    Round->who_called = plyr;
                    BuryBower(UpCard);
                }
                if (gotbower == TRUE)
                {
                    if (hand_value[bigind] > 22)
                    {
                        call = bigind;
                        Round->who_called = plyr;
                        BuryBower(UpCard);
                    }
                }
            }
            //CONSERVATIVE loner call

            if (hand_value[0] >39)
            {
                if (gotbower == TRUE)
                {
                    if (gotsuit[call] >= 4)
                    {
                        GottaLoner = plyr;
                        loner= TRUE;

                        //make sure there's not crap in the hand....
                        for (i = 0; i < 5; i++)
                        {
                            if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value < KING)
                            {
                                GottaLoner = INITIAL_SETUP;
                                loner = FALSE;
                            }
                        }

                    }
                }
            }
        }
        // end CONSERVATIVE

        //begin MODERATE
        else if (style == MODERATE)
        {
            if (gotbower == TRUE && gotace == TRUE && Player[plyr].NumSuits <= 2)
            {
                if ( (hand_value[bigind] > 21) || ((hand_value[bigind] > 20) && (bowerburied == TRUE)) )
                {
                    Round->who_called = plyr;
                    BuryBower(UpCard);
                    call = bigind;
                }
            }
            else if ( (gotbower == FALSE && gotace == TRUE) || (gotbower == TRUE && gotace == FALSE) )
            {
                if ( (hand_value[bigind] > 25) || ((hand_value[bigind] > 24) && (bowerburied == TRUE)) )
                {
                    BuryBower(UpCard);
                    Round->who_called = plyr;
                    call = bigind;
                }
            }
            else if ( (hand_value[bigind] > 26)  || ((hand_value[bigind] > 25) && (bowerburied == TRUE)) )
            {
                    Round->who_called = plyr;
                    BuryBower(UpCard);
                    call = bigind;
            }

            // MODERATE loner call

            if (hand_value[0] > 36 && gotsuit[call] >= 3)
            {
                if (gotbower == TRUE)
                {
                    for (i=0; i < 5; i++)
                    {
                        if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value == ACE)
                        {
                            GottaLoner = plyr;
                            loner =TRUE;
                        }
                    }
                }

            }
        }//end MODERATE

        //begin RISKY
        else if (style == RISKY)
        {
            if (gotbower == TRUE && gotace == TRUE && gotsuit[call] >= 3)
            {
                if ( (hand_value[bigind] > 21) || ((hand_value[bigind] > 19) && (bowerburied == TRUE)) )
                {
                    Round->who_called = plyr;
                    BuryBower(UpCard);
                    call = bigind;
                }
            }
            else if ( gotace == TRUE || gotbower == TRUE )
            {
                if ( (hand_value[bigind] > 24) || ((hand_value[bigind] > 23) && (bowerburied == TRUE)) )
                {
                    BuryBower(UpCard);
                    Round->who_called = plyr;
                    call = bigind;
                }
            }
            else if ( (hand_value[bigind] > 25)  || ((hand_value[bigind] > 24) && (bowerburied == TRUE)) )
            {
                    BuryBower(UpCard);
                    Round->who_called = plyr;
                    call = bigind;
            }

            //RISKY loner call
            if (hand_value[0] > 33 && (gotbower == TRUE || bowerburied == TRUE) )
            {
                if (gotsuit[call] >= 3)
                {
                    GottaLoner = plyr;
                    loner = TRUE;

                    //make sure there's not crap in the hand....
                    for (i = 0; i < 5; i++)
                    {
                        if (Player[plyr].MyHand[i].suit != call && Player[plyr].MyHand[i].value < KING)
                        {
                            GottaLoner = INITIAL_SETUP;
                            loner = FALSE;
                        }
                    }
                }
            }



        }//end RISKY

    }
    //show called suit
    CheckMenu();
    DisplayCall(call,plyr, loner);

    //initialize PlayedStats for this hand; 4 is used because it denotes player passing
    //instead of calling a suit

    if (call != 4)
    {
        for (i = 0; i < 4; i++)
        {
            PlayedStats[i].cards_played = 0;
            PlayedStats[i].nine_played  = FALSE;
            PlayedStats[i].ten_played  = FALSE;
            PlayedStats[i].jack_played  = FALSE;
            PlayedStats[i].queen_played  = FALSE;
            PlayedStats[i].king_played  = FALSE;
            PlayedStats[i].ace_played  = FALSE;
            PlayedStats[i].lbower_played  = FALSE;
            PlayedStats[i].rbower_played  = FALSE;
        }
    }

    return call;

}// end PickTrump()
/************************************************************************
*
*   DisplayCall()
*       displays trump call
*
*
*
************************************************************************/
void DisplayCall(WORD call, WORD plyr, BOOL loner)
{

    extern short Speed;

    extern struct Image Pass;
    extern struct Image clubcall;
    extern struct Image diamondcall;
    extern struct Image heartcall;
    extern struct Image spadecall;
    extern struct Image Alone;

    extern struct Image horiz_cardback;
    extern struct Image cardback;
    extern struct Hand Player[];
    extern struct Window *EuchreMain;
    extern struct Screen *EuchreScreen;

    extern LONG Player0Card[5][2];
    extern LONG Player1Card[5][2];
    extern LONG Player2Card[5][2];
    extern LONG Player3Card[5][2];

    #ifdef BETA_VERSION
    extern BOOL debug;
    #endif

    extern LONG width, height;

    WORD showX, showY;

    LONG PlayWidth;

    PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;


    switch (plyr)
    {
        case 1:
        {
            showX = Player1Card[2][0] + (CARD_LENGTH - CALL_WIDTH)/2;
            showY = Player1Card[2][1] + (CARD_WIDTH - CALL_LENGTH)/2;
            break;
        }
        case 2:
        {
            showX = (PlayWidth / 2) - (CALL_WIDTH / 2);
            showY = Player2Card[2][1] + ((CARD_LENGTH - CALL_LENGTH)/2);
            break;
        }
        case 3:
        {
            showX = Player3Card[2][0] + (CARD_LENGTH - CALL_WIDTH)/2;
            showY = Player3Card[2][1] + (CARD_WIDTH - CALL_LENGTH)/2;
            break;
        }
    }
    switch (call)
    {
        case SPADES:
            DrawImage(EuchreMain->RPort,&spadecall,showX, showY);
            break;
        case CLUBS:
            DrawImage(EuchreMain->RPort,&clubcall,showX, showY);
            break;
        case HEARTS:
            DrawImage(EuchreMain->RPort,&heartcall,showX, showY);
            break;
        case DIAMONDS:
            DrawImage(EuchreMain->RPort,&diamondcall,showX, showY);
            break;
        case 4:    //PASS
            DrawImage(EuchreMain->RPort,&Pass,showX, showY);
            break;
    }
    Delay((LONG)(5 * Speed));

    if (loner)
    {
        DrawImage(EuchreMain->RPort, &Alone, showX, showY);
        Delay((LONG)(5 * Speed));
    }
    EraseImage(EuchreMain->RPort, &Pass,showX, showY);

    //restore image of card after trump call is shown
    switch (plyr)
    {

        #ifdef BETA_VERSION
        case 1:
        {
            if (debug == FALSE)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[2][0], Player1Card[2][1]);
            else
                DrawImage(EuchreMain->RPort, Player[1].MyHand[2].hCardImage, Player1Card[2][0], Player1Card[2][1]);
            break;
        }
        case 2:
        {
            if (debug == FALSE)
            {
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[1][0], Player2Card[1][1]);
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[2][0], Player2Card[2][1]);
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[3][0], Player2Card[3][1]);
            }

            else
            {
                DrawImage(EuchreMain->RPort, Player[2].MyHand[1].CardImage, Player2Card[1][0], Player2Card[1][1]);
                DrawImage(EuchreMain->RPort, Player[2].MyHand[2].CardImage, Player2Card[2][0], Player2Card[2][1]);
                DrawImage(EuchreMain->RPort, Player[2].MyHand[3].CardImage, Player2Card[3][0], Player2Card[3][1]);
            }
            break;

        }
        case 3:
        {
            if (debug == FALSE)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[2][0], Player3Card[2][1]);
            else
                DrawImage(EuchreMain->RPort, Player[3].MyHand[2].hCardImage, Player3Card[2][0], Player3Card[2][1]);
            break;
        }

        #endif

        #ifndef BETA_VERSION

        case 1:
        {
            DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[2][0], Player1Card[2][1]);
            break;
        }
        case 2:
        {
            DrawImage(EuchreMain->RPort, &cardback, Player2Card[1][0], Player2Card[2][1]);
            DrawImage(EuchreMain->RPort, &cardback, Player2Card[2][0], Player2Card[2][1]);
            DrawImage(EuchreMain->RPort, &cardback, Player2Card[3][0], Player2Card[3][1]);
            break;

        }
        case 3:
        {
            DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[2][0], Player3Card[2][1]);
            break;
        }
        #endif
    }
}

void BuryBower(struct Cards *UpCard)
{
    extern struct CardTrack PlayedStats[4];

    PlayedStats[UpCard->suit].cards_played++;

    switch (UpCard->suit)
    {
        case SPADES:
            PlayedStats[CLUBS].rbower_played = TRUE;
            break;

        case CLUBS:
            PlayedStats[SPADES].rbower_played = TRUE;
            break;

        case DIAMONDS:
            PlayedStats[HEARTS].rbower_played = TRUE;
            break;

        case HEARTS:
            PlayedStats[DIAMONDS].rbower_played = TRUE;
            break;
    }
}




