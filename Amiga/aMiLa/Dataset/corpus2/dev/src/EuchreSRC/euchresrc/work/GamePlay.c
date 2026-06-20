/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : GamePlay.c
 ** Created on       : Monday, 25-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.27
 **
 ** Purpose
 ** -------
 **   main game loop
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 27-Sep-98   Rick Keller            added loner handling for all players
 ** 22-Sep-98   Rick Keller            added CheckMenu() function for better
 **                                     menu repsonsiveness
 ** 26-Aug-98   Rick Keller            cleared up display probs due to difft
 **                                     overscans (I hope!)
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 13-Aug-98   Rick Keller            added handling for EndEarly and 4 pt.
 **                                     loner
 ** 04-Aug-98   Rick Keller            cleaned out old score artifact
 ** 04-Aug-98   Rick Keller            removed window borders for Round result
 **                                     messages
 ** 04-Aug-98   Rick Keller            added flag for EvalTrick for use by AI
 ** 23-Jul-98   Rick Keller            added LeadStats and PlayedStats arrays
 **                                     for AI use
 ** 30-Jun-98   Rick Keller            removed Lead() and placed in file with
 **                                     Follow(), called Game_AI.c
 ** 23-Jun-98   Rick Keller            removed Follow() and placed in own file
 ** 21-Jun-98   Rick Keller            finished CONSERVATIVE playstyle
 **                                     implementation
 ** 11-Jun-98   Rick Keller            added config data interpretation to
 **                                     Follow()
 ** 10-Jun-98   Rick Keller            added config data interpretation to
 **                                     Lead()
 ** 09-Jun-98   Rick Keller            began config integration, values are
 **                                     read in but not used yet
 ** 13-Oct-97   Rick Keller            added user loner handling
 ** 05-Oct-97   Rick Keller            fixed problem when only cards left to
 **                                     play have same value
 ** 05-Oct-97   Rick Keller            debug now plays a game, score raised
 **                                     to 10
 ** 21-Sep-97   Rick Keller            moved SortHand() call from here to
 **                                     CallTrump
 ** 05-Sep-97   Rick Keller            un-commented initial AI
 ** 05-Sep-97   Rick Keller            fixed bug in EvalTrick which caused
 **                                     incorrect evaluation of tricks with
 **                                     more than 2 of led suit or trump played
 ** 04-Sep-97   Rick Keller            added winner congratulations
 ** 04-Sep-97   Rick Keller            game is now initiated from GamePlay
 **                                     instead of main
 ** 03-Sep-97   Rick Keller            added score handling
 ** 29-Aug-97   Rick Keller            added EuchreMain event handling
 ** 28-Aug-97   Rick Keller            added TookTrick() to show trick winner
 ** 28-Aug-97   Rick Keller            stripped a lot of stuff to get basic
 **                                     functions working
 ** 25-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/

#include <exec/types.h>
#include <intuition/intuition.h>

#include <time.h>
#include <string.h>
#include <stdlib.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

#include "gamesetup.h"
#include "settings.h"

#define WIN 10

extern LONG Player0Card[5][2];
extern LONG Player1Card[5][2];
extern LONG Player2Card[5][2];
extern LONG Player3Card[5][2];
extern LONG UpCardPos[4];
extern WORD GottaLoner;

extern int HandleMouseButtons(void);
extern struct Window *EuchreMain;
extern struct Cards *Deal(void);
extern void ShowCards(short, struct Cards *);
extern WORD CallTrump(struct GameInfo *, struct Cards *, short style[]);
extern void ShowTricks(short, short);
extern void ShowWinLose(short winner);
extern void Follow(struct GameInfo *,  WORD plyr, short order, short style);
extern void Lead(struct GameInfo *, WORD plyr, short style);
extern void ShowWhoCalled(WORD call_team, BOOL clear);
extern void HandleMenuEvents(struct IntuiMessage *msg);

struct Trick MyTrick[4];
struct GameInfo Round;

void ShowWinner(short winner, short howmuch, BOOL euchre);
void UserLead(struct GameInfo *);
void UserFollow(struct GameInfo *, short order);
short EvalTrick(struct GameInfo *, BOOL AI_use);
void CleanTable(void);
void TookTrick(short);
void ShowScore(short who_won, short myscore, BOOL clear);
void CheckMenu(void);

short pstyle[4];
short Speed;
short Loner;
BOOL End;

void GamePlay(void)
{
    extern struct Trick MyTrick[4];
    extern short Speed;
    extern short Loner;
    extern short pstyle[4];

    struct Cards *UpCard;
    short  Score[2] = {0,0};
    int    tricks_won[2] = {0,0};
    short  trick_no;
    short  leader;
    short  order;
    short i;

    srand(time(NULL));
    Round.dealer = (rand() >> 8) % 4;

    ShowScore(0,10, TRUE);
    ShowScore(1,10, TRUE);

    ShowScore(INITIAL_SETUP,0, FALSE);

    while (Score[0] < WIN && Score[1] < WIN)
    {
        CheckMenu();
        CleanTable();
        UpCard = Deal();
        CheckMenu();
        ShowCards(Round.dealer, UpCard);
        ShowWhoCalled(1, TRUE);
        GottaLoner = INITIAL_SETUP;
        CallTrump(&Round, UpCard, pstyle);

        CheckMenu();

        tricks_won[0] = 0;
        tricks_won[1] = 0;

        if (Round.dealer == 3)
            leader = 0;
        else
            leader = Round.dealer + 1;

        for (trick_no = 0; trick_no < 5; trick_no++) //main loop of tricks
        {

            // initialize trick struct
            for (i = 0; i < 4; i++)
            {
                MyTrick[i].suit = INITIAL_SETUP;
            }

            order = 0;

            /* If there is a loner called, then make sure the partner
               of the loner dude doesn't lead
               following will be handled in the next switch stmt
                                                                    */


            if (GottaLoner != INITIAL_SETUP)
            {
                switch (GottaLoner)
                {
                    case PLAYER_0:
                        if (leader == PLAYER_2)
                            leader = PLAYER_3;
                        break;
                    case PLAYER_1:
                        if (leader == PLAYER_3)
                            leader = PLAYER_0;
                        break;
                    case PLAYER_2:
                        if (leader == PLAYER_0)
                            leader = PLAYER_1;
                        break;
                    case PLAYER_3:
                        if (leader == PLAYER_1)
                            leader = PLAYER_2;
                        break;
                }
            }


            switch (leader)
            {
                case 0:                         //USER LEADS
                    UserLead(&Round);
                    order++;

                    CheckMenu();

                    if (GottaLoner != PLAYER_3)
                    {
                        Follow(&Round,PLAYER_1, order, pstyle[PLAYER_1]);
                        order++;
                    }

                    if (GottaLoner != PLAYER_0)
                    {
                        Follow(&Round, PLAYER_2, order,pstyle[PLAYER_2]);
                        order++;
                    }

                    CheckMenu();

                    if (GottaLoner != PLAYER_1)
                    {
                        Follow(&Round, PLAYER_3, order, pstyle[PLAYER_3]);
                    }
                    break;
                case 1:

                    CheckMenu();

                    Lead(&Round, PLAYER_1, pstyle[PLAYER_1]);
                    order++;

                    if (GottaLoner != PLAYER_0)
                    {
                        Follow(&Round, PLAYER_2, order, pstyle[PLAYER_2]);
                        order++;
                    }

                    CheckMenu();

                    if (GottaLoner != PLAYER_1)
                    {
                        Follow(&Round, PLAYER_3, order, pstyle[PLAYER_3]);
                        order++;
                    }

                    if (GottaLoner != PLAYER_2)
                    {
                        UserFollow(&Round, order);
                    }

                    CheckMenu();
                    break;
                case 2:
                    CheckMenu();

                    Lead(&Round, PLAYER_2, pstyle[PLAYER_2]);
                    order++;

                    if (GottaLoner != PLAYER_1)
                    {
                        Follow(&Round, PLAYER_3, order, pstyle[PLAYER_3]);
                        order++;
                    }

                    if (GottaLoner != PLAYER_2)
                    {
                        UserFollow(&Round,order);
                        order++;
                    }
                    CheckMenu();

                    if (GottaLoner != PLAYER_3)
                    {
                        Follow(&Round, PLAYER_1, order, pstyle[PLAYER_1]);
                    }
                    break;
                case 3:
                    CheckMenu();

                    Lead(&Round, PLAYER_3, pstyle[PLAYER_3]);
                    order++;

                    if (GottaLoner != PLAYER_2)
                    {
                        UserFollow(&Round, order);
                        order++;
                    }

                    CheckMenu();

                    if (GottaLoner != PLAYER_3)
                    {
                        Follow(&Round, PLAYER_1, order, pstyle[PLAYER_1]);
                        order++;
                    }

                    if (GottaLoner != PLAYER_0)
                        Follow(&Round, PLAYER_2, order, pstyle[PLAYER_2]);
                    break;
            }//switch

            CheckMenu();

            leader = EvalTrick(&Round, FALSE);
            if (leader == PLAYER_0 || leader == PLAYER_2)
            {
                tricks_won[0]++;
                ShowTricks(leader, tricks_won[0]);
            }
            else
            {
                tricks_won[1]++;
                ShowTricks(leader, tricks_won[1]);
            }

            CleanTable();

            //check to see if we should end early
            if (End == TRUE && trick_no == 3)
            {
                if ((tricks_won[0] == 3 && tricks_won[1] == 1) ||
                    (tricks_won[0] == 1 && tricks_won[1] == 3) )
                    break;
            }
            //if you get euchred in 3 tricks and End Early is on, the hand is done!
            if (End == TRUE && trick_no == 2)
            {
                if (((Round.who_called == PLAYER_0 || Round.who_called == PLAYER_2) && tricks_won[1] == 3) ||
                   ((Round.who_called == PLAYER_1  || Round.who_called == PLAYER_3) && tricks_won[0] == 3)   )
                    break;
            }
            CheckMenu();


        } // for trick_no

        CheckMenu();

        ShowWhoCalled(Round.who_called, TRUE);

        if (Round.who_called == PLAYER_0 || Round.who_called == PLAYER_2) //team 0 called and won
        {
            if (tricks_won[0] == 3 || tricks_won[0] == 4) //got a point
            {
                Score[0]++;
                ShowWinner(0,1, FALSE);
                ShowScore(0,Score[0], FALSE);
            }
            else if ((GottaLoner != PLAYER_0 && GottaLoner != PLAYER_2) && tricks_won[0] == 5) //got em all
            {
                Score[0] += 2;
                ShowWinner(0,2, FALSE);
                ShowScore(0,Score[0], FALSE);

            }
            else if ((GottaLoner == PLAYER_0 || GottaLoner == PLAYER_2)&& tricks_won[0] == 5) //got em all
            {
                if (Loner == THREE_POINT)
                {
                    Score[0] += 3;
                    ShowWinner(0,3, FALSE);
                    ShowScore(0,Score[0],FALSE);
                }
                else
                {
                    Score[0] += 4;
                    ShowWinner(0,3, FALSE);    //use 3 so that ShowWinner will know a loner was won
                    ShowScore(0,Score[0],FALSE);
                }

            }
            else if (tricks_won[0] < 3)
            {
                Score[1] += 2; //you got Euchred!
                ShowWinner(1,2, TRUE);
                ShowScore(1,Score[1],FALSE);
            }
        }


        else if (tricks_won[1] == 3 || tricks_won[1] == 4)
        {
            Score[1]++;
            ShowWinner(1,1, FALSE);
            ShowScore(1,Score[1],FALSE);

        }
        else if (tricks_won[1] == 5 && (GottaLoner != PLAYER_1 && GottaLoner != PLAYER_3))
        {
            Score[1] += 2;
            ShowWinner(1,2, FALSE);
            ShowScore(1,Score[1],FALSE);
        }

        else if (tricks_won[1] == 5 && (GottaLoner == PLAYER_1 || GottaLoner == PLAYER_3))
        {
            if (Loner == THREE_POINT)
            {
                Score[1] += 3;
                ShowWinner(1,3, FALSE);
                ShowScore(1,Score[1],FALSE);
            }
            else
            {
                Score[1] += 4;
                ShowWinner(1,3, FALSE);    //use 3 so that ShowWinner will know a loner was won
                ShowScore(1,Score[1],FALSE);
            }
        }
        else if (tricks_won[1] < 3)
        {
            Score[0] += 2;
            ShowWinner(0,2, TRUE);
            ShowScore(0,Score[0],FALSE);
        }

        if (Round.dealer < 3)
            Round.dealer++;
        else
            Round.dealer = 0;

    }

    CheckMenu();

    CleanTable();

    if (Score[0] >= WIN)
        ShowWinLose(0);
    else
        ShowWinLose(1);



} // end GamePlay()
///

/************************************************************************
*
*
*   EvalTrick determines who wins the trick
*
*
*
************************************************************************/
///
short EvalTrick(struct GameInfo *Round, BOOL AI_use)
{
    extern struct Trick MyTrick[4];
    BOOL gottrump = FALSE;
    short i,j, k;
    short bigind = 0;
    WORD bigcard;
    struct Trick trump[4];
    struct Trick temp[4];

    //how many people played trump?
    for (i = 0, k = 0; i < 4; i++)
    {
        //if used by AI to determine if a partner has it, check
        //to make sure MyTrick[i].suit != INITIAL_SETUP
        if (MyTrick[i].suit == INITIAL_SETUP)
        {
            break;
        }

        else if (MyTrick[i].suit == Round->trump_suit)
        {
            gottrump = TRUE;
            trump[k] = MyTrick[i];
            k++;
        }
    }
    //if any, highest trump wins!
    if (gottrump)
    {
        if ( k == 1 )
        {
            if (AI_use != TRUE)
            {
                TookTrick(trump[0].played_by);
            }
            return trump[0].played_by;

        }
        else
        {
            i = 0;
            bigcard = -1;

            do
            {
                if (trump[i].card_value > bigcard && trump[i].card_value > trump[i+1].card_value)
                {
                    bigind = i;
                    bigcard = trump[i].card_value;
                }
                else if (trump[i+1].card_value > bigcard && trump[i+1].card_value > trump[i].card_value)
                {
                    bigind = i+1;
                    bigcard = trump[i].card_value;
                }
            i++;

            } while (i < k-1 );

            if (AI_use != TRUE)
            {
                TookTrick(trump[bigind].played_by);
            }
            return trump[bigind].played_by;
        }

    } // end if
    //if none, what suit was led?
    //what was the highest card led and who played it?
    else
    {
        for (i = 0, j = 0; i < 4; i++)
        {
            //if used by AI to determine if a partner has it, check that
            //the MyTrick[i].suit != INITIAL_SETUP
            if (MyTrick[i].suit == INITIAL_SETUP)
            {
                break;
            }

            // take all the cards of the led suit
            else if (MyTrick[i].suit == MyTrick[0].suit)
            {
                temp[j] = MyTrick[i];
                j++;
            }
        }

        if (j == 1)
        {
            if (AI_use != TRUE)
            {
                TookTrick(temp[0].played_by);
            }
            return temp[0].played_by;
        }

        else
        {
            i =0;
            bigcard = -1;
            do
            {
                if (temp[i].card_value > bigcard && temp[i].card_value > temp[i+1].card_value)
                {
                    bigind = i;
                    bigcard = temp[i].card_value;
                }
                else if (temp[i+1].card_value > bigcard && temp[i+1].card_value > temp[i].card_value)
                {
                    bigind = i+1;
                    bigcard = temp[i].card_value;
                }
            i++;
            }while (i < j-1);
        }
        if (AI_use != TRUE)
        {
            TookTrick(temp[bigind].played_by);
        }
        return temp[bigind].played_by;

    }//end else
} // end EvalTrick()

/************************************************************************
*
*   CleanTable()
*
*           erases played cards from screen after a trick
*
*
************************************************************************/

void CleanTable(void)
{
    extern struct Image horiz_cardback;
    extern struct Image cardback;

    LONG PlayWidth;

    PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;

    EraseImage(EuchreMain->RPort, &cardback, Player0Card[2][0], (2*CARD_LENGTH) + 16);
    EraseImage(EuchreMain->RPort, &horiz_cardback, ((PlayWidth - CARD_WIDTH)/2) - (CARD_LENGTH +4), Player1Card[2][1]);
    EraseImage(EuchreMain->RPort, &cardback, Player2Card[2][0], (UpCardPos[2]));
    EraseImage(EuchreMain->RPort, &horiz_cardback, ((PlayWidth + CARD_WIDTH)/2)+4, Player3Card[2][1]);
}

/************************************************************************
*
* ShowWinner()
*        display winner of round and tell points
*
*
*
************************************************************************/

void ShowWinner(short winner, short howmuch, BOOL euchre)
{
    extern struct Image clubcall;
    extern struct Screen *EuchreScreen;
    extern LONG width, height;
    extern short Speed;
    extern short Loner;

    struct Window *ShowWinnerWin;
    struct DrawInfo *drawinfo;
    struct IntuiText MyIText;
    struct TextAttr myTextAttr;

    ULONG myTEXTPEN;
    ULONG myBACKGROUNDPEN;

    LONG PlayWidth;
    PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;


    if (drawinfo = GetScreenDrawInfo(EuchreScreen))
    {
        myTEXTPEN= drawinfo->dri_Pens[TEXTPEN];
        myBACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

        myTextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        myTextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        myTextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        myTextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        if (ShowWinnerWin = OpenWindowTags(NULL,
                                           WA_Left,         ((PlayWidth/2)-100),
                                           WA_Top,          ((height/2) - 25),
                                           WA_Width,        200,
                                           WA_Height,       50,
                                           WA_CustomScreen, EuchreScreen,
                                           WA_Borderless,   TRUE,
                                           WA_Activate,     TRUE,
                                           TAG_DONE) )
        {
            MyIText.FrontPen = myTEXTPEN;
            MyIText.BackPen  = myBACKGROUNDPEN;
            MyIText.DrawMode = JAM2;
            MyIText.LeftEdge = 0;
            MyIText.TopEdge  = 0;
            MyIText.ITextFont=&myTextAttr;
            MyIText.NextText = NULL;

            switch (winner)
            {
                case 0:
                case 2:
                    if (howmuch == 1)
                    {
                        MyIText.IText = "We got it!  1 pt.";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,62,20);
                    }
                    else if (howmuch == 2 && euchre == FALSE)
                    {
                        MyIText.IText = "Got 'em all!  2pts.";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,52,20);
                    }
                    else if (howmuch == 2 && euchre == TRUE)
                    {
                        MyIText.IText = "We Euchred 'em!  2 pts!";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,50,19);
                    }
                    else if (howmuch == 3)
                    {
                        if (Loner == THREE_POINT)
                        {
                            MyIText.IText = "Got the loner!  3 pts!";
                            PrintIText(ShowWinnerWin->RPort, &MyIText, 50, 19);
                        }
                        else
                        {
                            MyIText.IText = "Got the loner!  4 pts!";
                            PrintIText(ShowWinnerWin->RPort, &MyIText, 50, 19);
                        }

                    }
                    break;
                case 1:
                case 3:
                    if (howmuch == 1)
                    {
                        MyIText.IText = "They got it! 1  pt.";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,40,25);
                    }
                    else if (howmuch == 3)
                    {
                        if (Loner == THREE_POINT)
                        {
                            MyIText.IText = "Got the loner!  3 pts!";
                            PrintIText(ShowWinnerWin->RPort, &MyIText, 50, 19);
                        }
                        else
                        {
                            MyIText.IText = "Got the loner!  4 pts!";
                            PrintIText(ShowWinnerWin->RPort, &MyIText, 50, 19);
                        }
                    }
                    else if (euchre == FALSE)
                    {
                        MyIText.IText = "They got 'em all!  2pts.";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,40,25);
                    }
                    else if (euchre == TRUE)
                    {
                        MyIText.IText = "We got Euchred!  2 pts!";
                        PrintIText(ShowWinnerWin->RPort,&MyIText,50,19);
                    }
                    break;
            }//end switch
            Delay((LONG)(10 * Speed));
        CloseWindow(ShowWinnerWin);
        }
    FreeScreenDrawInfo(EuchreScreen, drawinfo);
    }//end if
    EraseImage(EuchreMain->RPort,&clubcall,(width - 78),height/3);
}//end ShowWinner

/************************************************************************
*
*  UserLead()
*       handles users lead
*
*
*
************************************************************************/

void UserLead(struct GameInfo *Round)
{
    extern short Speed;
    int picked;
    extern struct Trick MyTrick[4];
    extern struct RoundHand players_hand[4][5];

    while ( players_hand[0][(picked=HandleMouseButtons())].used == TRUE )
    {
        picked = HandleMouseButtons();
    }
    //mark card as played
    players_hand[0][picked].used = TRUE;

    //update MyTrick

    MyTrick[0].card_value = players_hand[0][picked].round_value;
    MyTrick[0].played_by = 0;
    MyTrick[0].suit  = players_hand[0][picked].suit;

    //show the card
    DrawImage(EuchreMain->RPort, players_hand[0][picked].showcard, Player0Card[2][0], (2*CARD_LENGTH) + 16);
    EraseImage(EuchreMain->RPort, players_hand[0][picked].showcard, Player0Card[picked][0], Player0Card[picked][1]);

    Delay((LONG)(4 * Speed));
}

/************************************************************************
*
*
*   UserFollow()
*        handles user follow and ensures player follow suit
*
*
************************************************************************/

void UserFollow(struct GameInfo *Round, short order)
{
    extern short Speed;
    int picked;
    int i;
    BOOL DoIGotta = FALSE;

    extern struct Trick MyTrick[4];
    extern struct Screen *EuchreScreen;
    extern struct RoundHand players_hand[4][5];

    // do I gotta follow?
    for ( i = 0; i < 5; i++)
        if (players_hand[0][i].suit == MyTrick[0].suit && players_hand[0][i].used == FALSE)
            DoIGotta = TRUE;

    if (DoIGotta)
    {
        while (players_hand[0][(picked=HandleMouseButtons())].suit != MyTrick[0].suit || players_hand[0][picked].used ==TRUE)
        {
            DisplayBeep(EuchreScreen);
        }
    }
    else
    {
        while (players_hand[0][(picked=HandleMouseButtons())].used ==TRUE)
        {
            continue;
        }
    }

    //mark card as played in hand
    players_hand[0][picked].used = TRUE;

    //update MyTrick
    MyTrick[order].card_value = players_hand[0][picked].round_value;
    MyTrick[order].played_by = 0;
    MyTrick[order].suit = players_hand[0][picked].suit;

    DrawImage(EuchreMain->RPort, players_hand[0][picked].showcard, Player0Card[2][0], (2*CARD_LENGTH) + 16);
    EraseImage(EuchreMain->RPort, players_hand[0][picked].showcard, Player0Card[picked][0], Player0Card[picked][1]);

    Delay((LONG)(4 * Speed));
}

/************************************************************************
*
*   TookTrick
*      shows who wins each trick
*
*
*
************************************************************************/
void TookTrick(short plyr)
{
    extern struct Screen *EuchreScreen;
    extern LONG width, height;
    extern short Speed;

    extern LONG Player0Card[5][2];
    extern LONG Player1Card[5][2];
    extern LONG Player2Card[5][2];
    extern LONG Player3Card[5][2];

    struct Window *MineWin;
    struct DrawInfo *drawinfo;
    struct IntuiText Mine;
    struct TextAttr mineTextAttr;

    LONG left, top;

    ULONG myTEXTPEN;
    ULONG myBACKGROUNDPEN;

    LONG PlayWidth;

    PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;


    switch (plyr)
    {
        case 0:
            left = ((PlayWidth/2) - 35);
            top  = Player0Card[2][1] + (CARD_LENGTH - 30)/2;
            break;
        case 1:
            left = Player1Card[2][0] + (CARD_LENGTH - 70)/2;
            top  = Player1Card[2][1] + (CARD_WIDTH - 30)/2;
            break;
        case 2:
            left = (PlayWidth / 2) - 35;
            top  = Player2Card[2][1] + ((CARD_LENGTH - 30)/2);
            break;
        case 3:
            left = Player3Card[2][0] + (CARD_LENGTH - 70)/2;
            top  = Player3Card[2][1] + (CARD_WIDTH - 30)/2;
            break;
    }


    if (drawinfo = GetScreenDrawInfo(EuchreScreen))
    {
        myTEXTPEN= drawinfo->dri_Pens[TEXTPEN];
        myBACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

        mineTextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        mineTextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        mineTextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        mineTextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        if (MineWin = OpenWindowTags(NULL,
                                  WA_Left,         left,
                                  WA_Top,          top,
                                  WA_Width,        70,
                                  WA_Height,       30,
                                  WA_CustomScreen, EuchreScreen,
                                  WA_Activate,     TRUE,
                                  TAG_DONE) )
        {
            Mine.FrontPen = myTEXTPEN;
            Mine.BackPen  = myBACKGROUNDPEN;
            Mine.DrawMode = JAM2;
            Mine.LeftEdge = 0;
            Mine.TopEdge  = 0;
            Mine.ITextFont=&mineTextAttr;
            Mine.NextText = NULL;
            Mine.IText = "Mine!";

            PrintIText(MineWin->RPort,&Mine,20,10);

            Delay((LONG)(7 * Speed));
            CloseWindow(MineWin);
        }
    FreeScreenDrawInfo(EuchreScreen, drawinfo);
    }//end if
} //end TookTrick
/************************************************************************
*
*
*   ShowScore()- displays score on screen
*
*
************************************************************************/
void ShowScore(short who_won, short myscore, BOOL clear)
{
    extern struct Window *EuchreMain;
    extern struct Screen *EuchreScreen;
    extern LONG width, height;

    struct DrawInfo *drawinfo;
    struct IntuiText GameScore;
    struct IntuiText UsScore;
    struct IntuiText ThemScore;
    struct IntuiText Num;
    struct TextAttr myTextAttr;

    BYTE gamescore[3];
    int nuttin;
    ULONG myTEXTPEN;
    ULONG myBACKGROUNDPEN;

    if (myscore > WIN)
        myscore = WIN;

    if (drawinfo = GetScreenDrawInfo(EuchreScreen))
    {
        myTEXTPEN= drawinfo->dri_Pens[TEXTPEN];
        myBACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

        myTextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        myTextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        myTextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        myTextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        GameScore.FrontPen = myTEXTPEN;
        GameScore.BackPen  = myBACKGROUNDPEN;
        GameScore.DrawMode = JAM2;
        GameScore.LeftEdge = 0;
        GameScore.TopEdge  = 0;
        GameScore.ITextFont=&myTextAttr;
        GameScore.NextText = NULL;
        GameScore.IText    = "Score";

        UsScore.FrontPen = myTEXTPEN;
        UsScore.BackPen  = myBACKGROUNDPEN;
        UsScore.DrawMode = JAM2;
        UsScore.LeftEdge = 0;
        UsScore.TopEdge  = 0;
        UsScore.ITextFont=&myTextAttr;
        UsScore.NextText = NULL;
        UsScore.IText    = "Us";


        ThemScore.FrontPen = myTEXTPEN;
        ThemScore.BackPen  = myBACKGROUNDPEN;
        ThemScore.DrawMode = JAM2;
        ThemScore.LeftEdge = 0;
        ThemScore.TopEdge  = 0;
        ThemScore.ITextFont=&myTextAttr;
        ThemScore.NextText = NULL;
        ThemScore.IText    = "Them";

        if (clear == TRUE)
        {
            Num.FrontPen = myBACKGROUNDPEN;
        }
        else
        {
            Num.FrontPen = myTEXTPEN;
        }
        Num.BackPen  = myBACKGROUNDPEN;
        Num.DrawMode = JAM2;
        Num.LeftEdge = 0;
        Num.TopEdge  = 0;
        Num.ITextFont=&myTextAttr;
        Num.NextText = NULL;
        Num.IText    ="0";

        if (who_won == INITIAL_SETUP)
        {
            PrintIText(EuchreMain->RPort, &GameScore, width - 70, height - 50);
            PrintIText(EuchreMain->RPort, &UsScore, width - 80, height - 35);
            PrintIText(EuchreMain->RPort, &ThemScore, width - 80, height - 20);

            PrintIText(EuchreMain->RPort, &Num, width - 30, height - 35);
            PrintIText(EuchreMain->RPort, &Num, width - 30, height - 20);
        }
        else
        {
            switch (who_won)
            {
                case 0:
                        nuttin = stci_d(gamescore, myscore);
                        Num.IText = gamescore;
                        PrintIText(EuchreMain->RPort,&Num, width - 30, height - 35);
                    break;
                case 1:
                        nuttin = stci_d(gamescore, myscore);
                        Num.IText = gamescore;
                        PrintIText(EuchreMain->RPort,&Num, width - 30, height - 20);
                    break;
            }//end switch

        }
        FreeScreenDrawInfo(EuchreScreen, drawinfo);
    }//end if
}//end ShowTricks

/************************************************************************
*
*       CheckMenu()
*           checks to see if user has made any MENUPICKS,
*           also clears errant mouse clicks
*
************************************************************************/

void CheckMenu(void)
{
    struct IntuiMessage *checkmenu;
    while (NULL != (checkmenu = (struct IntuiMessage *)GetMsg(EuchreMain->UserPort)))
    {
        switch (checkmenu->Class)
        {
            case IDCMP_MENUPICK:
                HandleMenuEvents(checkmenu);
                break;
            default:
                break;
        }
        ReplyMsg((struct Message *)checkmenu);
    }
}

