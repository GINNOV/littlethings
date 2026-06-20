///
/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : ShowCards.c
 ** Created on       : Thursday, 07-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.10
 **
 ** Purpose
 ** -------
 **   Display cards after they are dealt
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 26-Aug-98   Rick Keller            cleared up display error due to difft
                                        overscans (I hope!)
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 04-Jun-98   Rick Keller            moved image data into a header for clarity
 ** 05-Sep-97   Rick Keller            ShowTricks called after ClearTable() now
 ** 29-Aug-97   Rick Keller            changed ShowCardsHelp() to ShowCardsDebug()
 ** 29-Aug-97   Rick Keller            added ShowTricks() to indicate how many tricks each side took
 ** 29-Aug-97   Rick Keller            added pass and suitcall gfx code
 ** 08-Aug-97   Rick Keller            added shadowed cardbacks
 ** 07-Aug-97   Rick Keller            moved UpCard in front of dealer
 ** 07-Aug-97   Rick Keller            --- Initial version ---
 **
 ** $Revision Header *********************************************************/
///
#include <exec/types.h>
#include <intuition/intuition.h>
#include <string.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/dos_protos.h>

#include "gamesetup.h"
#include "GameImages.h"

///

// a few global variables....

LONG Player0Card[5][2];
LONG Player1Card[5][2];
LONG Player2Card[5][2];
LONG Player3Card[5][2];
LONG UpCardPos[4];


void ShowTricks(short who_won, short howmany);
// some static functions....

static void ClearTable(void);

#ifdef BETA_VERSION
static void ShowCardsDebug(WORD);
#endif

static void ShowCardsNormal(WORD);

/************************************************************************
*
*   ShowCards() shows results of Deal()
*
*
*
*
************************************************************************/

void ShowCards(WORD dealer, struct Cards *UpCard)
{
    extern short Speed;
    extern struct Hand Player[];
    extern struct Window *EuchreMain;
    extern LONG width, height;
    int i;

    #ifdef BETA_VERSION
    extern BOOL debug;
    #endif

    for (i = 0; i < 5; i ++)
    {
        Player0Card[i][0] = (CARD_LENGTH + 6) + (i * CARD_WIDTH) + (i * 4);
        Player0Card[i][1] = height - (CARD_LENGTH + 4);
        Player1Card[i][0] = 2;
        Player1Card[i][1] = (((4 * CARD_LENGTH + 10) - (5 * CARD_WIDTH +8)) / 2) + ( i * CARD_WIDTH + i * 2);
        Player2Card[i][0] = (CARD_LENGTH + 6) + (i * CARD_WIDTH) + (i * 4);
        Player2Card[i][1] = 12;
        Player3Card[i][0] = 2 + CARD_LENGTH + (5 * CARD_WIDTH) + 24;
        Player3Card[i][1] = (((4 * CARD_LENGTH + 10) - (5 * CARD_WIDTH +8)) / 2) + ( i * CARD_WIDTH + i * 2);
    }

    UpCardPos[0] = Player0Card[2][1] - (CARD_LENGTH + 2);  //player 0 dealt
    UpCardPos[1] = Player1Card[2][0] + CARD_LENGTH + 2;  //player 1 dealt
    UpCardPos[2] = Player2Card[2][1] + CARD_LENGTH + 2;  //player 2 dealt
    UpCardPos[3] = Player3Card[2][0] - (CARD_LENGTH + 2);  //player 3 dealt

    ClearTable();
    ShowTricks(4,0);

    #ifdef BETA_VERSION
    if (debug == TRUE)
        ShowCardsDebug(dealer);
                                                   //shown face up
    else
        ShowCardsNormal(dealer);                  //cards shown normal
    #endif

    #ifndef BETA_VERSION
    ShowCardsNormal(dealer);
    #endif

    Delay((LONG)(1.5 * Speed));

    switch (dealer)
    {
        case 0:
            DrawImage(EuchreMain->RPort, UpCard->CardImage, Player0Card[2][0], UpCardPos[0]);
            break;
        case 1:
            DrawImage(EuchreMain->RPort, UpCard->hCardImage, UpCardPos[1], Player1Card[2][1]);
            break;
        case 2:
            DrawImage(EuchreMain->RPort, UpCard->CardImage, Player2Card[2][0], UpCardPos[2]);
            break;
        case 3:
            DrawImage(EuchreMain->RPort, UpCard->hCardImage, UpCardPos[3], Player3Card[2][1]);
            break;
    }
    Delay((LONG)(3 *Speed));

} //  end ShowCards()

/************************************************************************
*
* ClearTable()
*       clears all image locations on screen to prepare for
*       displaying new deal
*
*
************************************************************************/
static void ClearTable(void)
{
    extern short Speed;
    extern struct Window *EuchreMain;
    int i;

    for (i = 0; i < 5; i++)
    {
        EraseImage(EuchreMain->RPort, &cardback, Player0Card[i][0], Player0Card[i][1]);
        EraseImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
        EraseImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
        EraseImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
    }

    EraseImage(EuchreMain->RPort, &cardback, Player0Card[2][0], UpCardPos[0]);
    EraseImage(EuchreMain->RPort, &horiz_cardback, UpCardPos[1], Player1Card[2][1]);
    EraseImage(EuchreMain->RPort, &cardback, Player2Card[2][0], UpCardPos[2]);
    EraseImage(EuchreMain->RPort, &horiz_cardback, UpCardPos[3], Player3Card[2][1]);

    EraseImage(EuchreMain->RPort, &spadecall, 0,0);

    Delay((LONG)(1.5*Speed));
} //end ClearTable()

#ifdef BETA_VERSION
/************************************************************************
*
*
* ShowCardsDebug()- displays computer players cards face up for
*                  and debugging purposes
*
*
************************************************************************/
static void ShowCardsDebug(WORD dealer)
{
    extern short Speed;
    extern struct Hand Player[4];
    extern struct Window *EuchreMain;
    int i;
    switch (dealer) //show cards clockwise from dealers left
    {
        case 0:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));


            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);

            break;
        case 1:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);

            break;

        case 2:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            break;

        case 3:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[1].MyHand[i].hCardImage, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[2].MyHand[i].CardImage, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[3].MyHand[i].hCardImage, Player3Card[i][0], Player3Card[i][1]);
            break;
    }//end switch

}//end ShowCardsDebug()
#endif
/************************************************************************
*
*  ShowCardsNormal() - shows cards face down for normal gameplay
*
*
*
*
************************************************************************/
static void ShowCardsNormal(WORD dealer)
{
    extern short Speed;
    extern struct Hand Player[4];
    extern struct Window *EuchreMain;
    int i;

    switch (dealer) //show cards clockwise from dealers left
    {
        case 0:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));


            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            break;
        case 1:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            break;
        case 2:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            break;
        case 3:
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 3; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 0; i < 2; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);

            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, Player[0].MyHand[i].CardImage, Player0Card[i][0], Player0Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player1Card[i][0], Player1Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 2; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &cardback, Player2Card[i][0], Player2Card[i][1]);
            Delay((LONG)(1.5*Speed));
            for (i = 1; i < 5; i ++)
                DrawImage(EuchreMain->RPort, &horiz_cardback, Player3Card[i][0], Player3Card[i][1]);
            break;
    }// end switch
} // end ShowCardsNormal()
/************************************************************************
*
*   ShowTricks()                                                                    *
*           shows how many tricks each side has taken
*
*
*
************************************************************************/
void ShowTricks(short who_won, short howmany)
{
    extern struct Window *EuchreMain;
    extern struct Screen *EuchreScreen;
    extern LONG width, height;

    struct DrawInfo *drawinfo;
    struct IntuiText TricksTaken;
    struct IntuiText Us;
    struct IntuiText Them;
    struct IntuiText Num;
    struct TextAttr myTextAttr;

    BYTE trickstaken[3];
    int nuttin;
    ULONG myTEXTPEN;
    ULONG myBACKGROUNDPEN;

    if (drawinfo = GetScreenDrawInfo(EuchreScreen))
    {
        myTEXTPEN= drawinfo->dri_Pens[TEXTPEN];
        myBACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

        myTextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        myTextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        myTextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        myTextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        TricksTaken.FrontPen = myTEXTPEN;
        TricksTaken.BackPen  = myBACKGROUNDPEN;
        TricksTaken.DrawMode = JAM2;
        TricksTaken.LeftEdge = 0;
        TricksTaken.TopEdge  = 0;
        TricksTaken.ITextFont=&myTextAttr;
        TricksTaken.NextText = NULL;
        TricksTaken.IText    = "Tricks Taken";

        Us.FrontPen = myTEXTPEN;
        Us.BackPen  = myBACKGROUNDPEN;
        Us.DrawMode = JAM2;
        Us.LeftEdge = 0;
        Us.TopEdge  = 0;
        Us.ITextFont=&myTextAttr;
        Us.NextText = NULL;
        Us.IText    = "Us";


        Them.FrontPen = myTEXTPEN;
        Them.BackPen  = myBACKGROUNDPEN;
        Them.DrawMode = JAM2;
        Them.LeftEdge = 0;
        Them.TopEdge  = 0;
        Them.ITextFont=&myTextAttr;
        Them.NextText = NULL;
        Them.IText    = "Them";

        Num.FrontPen = myTEXTPEN;
        Num.BackPen  = myBACKGROUNDPEN;
        Num.DrawMode = JAM2;
        Num.LeftEdge = 0;
        Num.TopEdge  = 0;
        Num.ITextFont=&myTextAttr;
        Num.NextText = NULL;
        Num.IText    ="0";

        if (who_won == 4)
        {
            PrintIText(EuchreMain->RPort, &TricksTaken, width - 80, 20);
            PrintIText(EuchreMain->RPort, &Us, width - 80, 35);
            PrintIText(EuchreMain->RPort, &Them, width - 80,50);

            PrintIText(EuchreMain->RPort, &Num, width - 30, 35);
            PrintIText(EuchreMain->RPort, &Num, width - 30, 50);
        }
        else
        {
            switch (who_won)
            {
                case 0:
                case 2:
                        nuttin = stci_d(trickstaken, howmany);
                        Num.IText = trickstaken;
                        PrintIText(EuchreMain->RPort,&Num, width - 30, 35);
                    break;
                case 1:
                case 3:
                        nuttin = stci_d(trickstaken, howmany);
                        Num.IText = trickstaken;
                        PrintIText(EuchreMain->RPort,&Num, width - 30, 50);
                    break;
            }//end switch

        }
        FreeScreenDrawInfo(EuchreScreen, drawinfo);
    }//end if
}//end ShowTricks



