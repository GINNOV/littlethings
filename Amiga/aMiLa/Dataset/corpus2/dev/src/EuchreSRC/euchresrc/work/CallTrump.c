///
/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : CallTrump.c
 ** Created on       : Monday, 18-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.19
 **
 ** Purpose
 ** -------
 **   Call trump routine returns trump suit
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 27-Sep-98   Rick Keller            changed 'UserLoner' to 'GottaLoner'
 **                                     for AI purposes
 ** 31-Aug-98   Rick Keller            added ShowWhoCalled to display calling
 **                                     team
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 04-Aug-98   Rick Keller            added RISKY playing style
 ** 28-Jul-98   Rick Keller            MODERATE handling for PickItUp()
 ** 16-Oct-97   Rick Keller            put PickTrump into its own file
 ** 13-Oct-97   Rick Keller            added loner handling for user
 ** 13-Oct-97   Rick Keller            fixed bug- now user picks up card if necessary
 ** 05-Oct-97   Rick Keller            fixed bug where user was not noted as calling trump
 ** 05-Oct-97   Rick Keller            fixed bug- player who called trump is now properly recorded
 ** 01-Oct-97   Rick Keller            added trump calling by computer
 ** 21-Sep-97   Rick Keller            SortHand() is now called from here instead of GamePlay()
 ** 21-Sep-97   Rick Keller            added computer picking up UpCard
 ** 29-Aug-97   Rick Keller            added EuchreMain window events handling to allow user to quit during input event
 ** 25-Aug-97   Rick Keller            instituted GameInfo structure
 ** 22-Aug-97   Rick Keller            fixed a ton of Enforcer hits caused by not setting xxxx.ng_TextAttr
 ** 22-Aug-97   Rick Keller            handled card exchange needed when UpCard is chosen
 ** 19-Aug-97   Rick Keller            user trump calling handled (I hope!)
 ** 18-Aug-97   Rick Keller            --- Initial release ---
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

extern struct Image pass;
extern struct Image clubcall;
extern struct Image diamondcall;
extern struct Image heartcall;
extern struct Image spadecall;
extern short Speed;


extern struct Cards *Deal(void);
extern void SortHand(struct GameInfo *);
extern void ShowCards(WORD, struct Cards *);
extern int HandleMouseButtons(void);
extern void HandleMenuEvents(struct IntuiMessage *);
extern WORD PickTrump(struct GameInfo *Round, WORD plyr, WORD round, struct Cards *UpCard, short style);
struct RoundHand FindGarbage(struct RoundHand cards[], WORD num_cards);

WORD UserPickTrump( short, struct Cards * );
WORD UserCallTrump( WORD suit );
WORD PickUpWinEvents(struct Window *, struct Cards *);
WORD CallWinEvents(struct Window *, WORD suit );
static void Discard(int, struct Cards *UpCard);
void ShowTrump(WORD);
void PickItUp(struct GameInfo *Round, struct Cards *UpCard, short style);
void ShowWhoCalled(WORD call_team, BOOL clear);

struct Window *PickUpWin = NULL;
struct Window *CallWin   = NULL;
struct Gadget *glist = NULL;
void *vi = NULL;
WORD GottaLoner;

void CallTrump(struct GameInfo *Round, struct Cards *UpCard, short style[])
///
{
    extern LONG UpCardPos[];
    extern LONG Player0Card[5][2];
    extern LONG Player1Card[5][2];
    extern LONG Player2Card[5][2];
    extern LONG Player3Card[5][2];
    extern struct Window *EuchreMain;

    Round->trump_suit = 4;

    switch (Round->dealer)   //pick it up or pass??
    {
        case 0:                    //user deals
            if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 1, UpCard, style[PLAYER_1] ) ) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                Discard(HandleMouseButtons(), UpCard);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 1, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                Discard(HandleMouseButtons(), UpCard);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 1, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                Discard(HandleMouseButtons(), UpCard);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = UserPickTrump(Round->dealer, UpCard)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else
                break;
        case 1:
            if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 1, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_1]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 1, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_1]);
                break;
            }
            else if ((Round->trump_suit = UserPickTrump(Round->dealer, UpCard)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_1]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 1, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_1]);
                break;
            }
            else
                break;
        case 2:
            if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 1, UpCard, style[PLAYER_3])) != 4 )
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_2]);
                break;
            }
            else if ((Round->trump_suit = UserPickTrump(Round->dealer, UpCard)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_2]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 1, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_2]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 1, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_2]);
                break;
            }
            else
                break;
        case 3:
            if ((Round->trump_suit = UserPickTrump(Round->dealer, UpCard)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_3]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 1, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_3]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 1, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_3]);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 1, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                PickItUp(Round,UpCard, style[PLAYER_3]);
                break;
            }
            else
                break;

    } //switch

    switch (Round->dealer)  //erase UpCard
    {
        case 0:
            EraseImage(EuchreMain->RPort, UpCard->CardImage, Player0Card[2][0], UpCardPos[0]);
            break;
        case 1:
            EraseImage(EuchreMain->RPort, UpCard->hCardImage, UpCardPos[1], Player1Card[2][1]);
            break;
        case 2:
            EraseImage(EuchreMain->RPort, UpCard->CardImage, Player2Card[2][0], UpCardPos[2]);
            break;
        case 3:
            EraseImage(EuchreMain->RPort, UpCard->hCardImage, UpCardPos[3], Player3Card[2][1]);
            break;
    }


    if (Round->trump_suit == 4)
    {
        Delay((LONG)(5 * Speed));
        switch (Round->dealer)
        {
            case 0:
            if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 2, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 2, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 2, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = UserCallTrump( UpCard->suit)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else
                break;
        case 1:
            if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 2, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 2, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = UserCallTrump( UpCard->suit)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 2, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else
                break;
        case 2:
            if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 2, UpCard, style[PLAYER_3])) != 4 )
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = UserCallTrump( UpCard->suit)) != 4 )
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 2, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 2, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else
                break;
        case 3:
            if ((Round->trump_suit = UserCallTrump( UpCard->suit)) != 4)
            {
                Round->who_called = 0;
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_1, 2, UpCard, style[PLAYER_1])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_2, 2, UpCard, style[PLAYER_2])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else if ((Round->trump_suit = PickTrump(Round, PLAYER_3, 2, UpCard, style[PLAYER_3])) != 4)
            {
                ShowWhoCalled(Round->who_called, FALSE);
                SortHand(Round);
                break;
            }
            else
                break;
        } //switch
    } //if                  */
    ShowTrump(Round->trump_suit);

    if (Round->trump_suit == 4)
    {
        if (Round->dealer < 3)
            Round->dealer++;
        else
            Round->dealer = 0;
        UpCard = Deal();
        ShowCards(Round->dealer, UpCard);
        CallTrump(Round, UpCard, style );
    }


} //end CallTrump()


///
/************************************************************************
*
*
*        UserPickTrump                                                               *
*        -handles users trump call takes round # (for pick/pass, named
*                                                 trump calls)
*        -takes UpCard to determine called suit if card is picked up
************************************************************************/
///
#define PICKUP (0)
#define PASS   (1)
#define ALONE_GAD  (7)

WORD UserPickTrump( WORD dlr, struct Cards *UpCard)
{
    struct NewGadget PickUp, Pass, Alone;
    struct Gadget *pgad;
    WORD trump;
    extern struct Screen *EuchreScreen;
    extern LONG width, height;

    struct TextAttr *GadText = EuchreScreen->Font;
    UBYTE *pick = "Pick it Up";
    UBYTE *pass = "Pass";
    UBYTE *loner = "Alone";

    LONG PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;

    GottaLoner = INITIAL_SETUP;
    //pick/pass window 74x57
    // pick up card?


    if ((vi = GetVisualInfo(EuchreScreen,TAG_END)) != NULL)
    {
            //gadet structures for PickUpWin

        PickUp.ng_TextAttr   = GadText;
        PickUp.ng_VisualInfo = vi;
        PickUp.ng_LeftEdge   = 15;
        PickUp.ng_TopEdge    = 20;
        PickUp.ng_Width      = 70;
        PickUp.ng_Height     = 19;
        PickUp.ng_GadgetText = pick;
        PickUp.ng_GadgetID   = PICKUP;
        PickUp.ng_Flags      = 0;

        Pass.ng_TextAttr     = GadText;
        Pass.ng_VisualInfo   = vi;
        Pass.ng_LeftEdge     = 120;
        Pass.ng_TopEdge      = 20;
        Pass.ng_Width        = 60;
        Pass.ng_Height       = 19;
        Pass.ng_GadgetText   = pass;
        Pass.ng_GadgetID     = PASS;
        Pass.ng_Flags        = 0;

        Alone.ng_TextAttr     = GadText;
        Alone.ng_VisualInfo   = vi;
        Alone.ng_LeftEdge     = 84;
        Alone.ng_TopEdge      = 45;
        Alone.ng_Width        = 26;
        Alone.ng_Height       = 11;
        Alone.ng_GadgetText   = loner;
        Alone.ng_GadgetID     = ALONE_GAD;
        Alone.ng_Flags        = PLACETEXT_BELOW;
///
        pgad = CreateContext(&glist);

        pgad = CreateGadget(BUTTON_KIND, pgad, &PickUp, TAG_END);
        pgad = CreateGadget(BUTTON_KIND, pgad, &Pass, TAG_END);
        pgad = CreateGadget(CHECKBOX_KIND, pgad, &Alone, TAG_DONE);


        PickUpWin = OpenWindowTags(NULL,
                                WA_Left,            ((PlayWidth/2)-97),
                                WA_Top,             ((height/2) - 27),
                                WA_Width,           195,
                                WA_Height,          75,
                                WA_Gadgets,         glist,
                                WA_CustomScreen,    EuchreScreen,
                                WA_Activate,        TRUE,
                                WA_IDCMP,           BUTTONIDCMP | IDCMP_REFRESHWINDOW,
                                WA_SimpleRefresh,   TRUE,
                                TAG_DONE);

        GT_RefreshWindow(PickUpWin, NULL);
        if (PickUpWin != NULL)
        {
            trump = PickUpWinEvents(PickUpWin, UpCard);
            CloseWindow(PickUpWin);
            FreeGadgets(glist);
            FreeVisualInfo(vi);

            PickUpWin = NULL;
            glist = NULL;
            vi = NULL;

            if (dlr == 0 && trump != 4)
                Discard(HandleMouseButtons(), UpCard);

            return trump;

        }
    }//if vi=....

}//end UserPickTrump()
///
/************************************************************************
*
*   PickUpWinEvents()
*   handles IDCMP events for PickUpWindow
*
*
*
************************************************************************/
///
WORD PickUpWinEvents(struct Window *PickUpWin, struct Cards *UpCard)
{
    extern struct Window *EuchreMain;
    struct IntuiMessage *imsg;
    struct Gadget *gad;
    BOOL terminated = FALSE;
    ULONG signals;
    while (!terminated)
    {

        signals = Wait(1L << PickUpWin->UserPort->mp_SigBit);

        while ((!terminated) && (imsg = GT_GetIMsg(PickUpWin->UserPort)))
        {
            switch (imsg->Class)
            {
                case IDCMP_GADGETUP:
                    gad = (struct Gadget *)imsg->IAddress;
                    if (gad->GadgetID == PICKUP)
                    {
                        terminated = TRUE;
                        return UpCard->suit;
                    }
                    if (gad->GadgetID == PASS)
                    {
                        GottaLoner = INITIAL_SETUP;
                        terminated = TRUE;
                        return 4;
                    }
                    if (gad->GadgetID == ALONE_GAD)
                    {
                        if (GottaLoner == INITIAL_SETUP)
                            GottaLoner = PLAYER_0;

                        else if (GottaLoner == PLAYER_0)
                            GottaLoner = INITIAL_SETUP;
                    }
                    break;
                case IDCMP_REFRESHWINDOW:
                    {
                        GT_BeginRefresh(EuchreMain);
                        GT_EndRefresh(EuchreMain, TRUE);
                        break;
                    }
            }  //switch
        GT_ReplyIMsg(imsg);
        } //while
    } //while !terminated
}//end PickUpWinEvents()
///
/************************************************************************
*
*      ShowTrump()
*      function to disply trump called
*
*
*
************************************************************************/
///
void ShowTrump(WORD trump)
{
    extern struct Window *EuchreMain;
    extern LONG width, height;

    LONG CallX = width - 78;

    switch (trump)
    {
        case 0:
            DrawImage(EuchreMain->RPort, &spadecall, CallX, height/3);
            break;
        case 1:
            DrawImage(EuchreMain->RPort, &clubcall, CallX, height/3);
            break;
        case 2:
            DrawImage(EuchreMain->RPort, &heartcall, CallX, height/3);
            break;
        case 3:
            DrawImage(EuchreMain->RPort, &diamondcall, CallX, height/3);
            break;
    }
}//end ShowTrump
///
/************************************************************************
*
*
*   UserCallTrump()
*      user calls trump from remaining suits
*
*
************************************************************************/
///
#define SPADES_GAD   (2)
#define CLUBS_GAD    (3)
#define HEARTS_GAD   (4)
#define DIAMONDS_GAD (5)
#define PASS_GAD     (6)
#define ALONE_GAD    (7)
WORD UserCallTrump( WORD suit )
{
    extern struct Screen *EuchreScreen;
    extern LONG width, height;

    struct NewGadget spades, hearts, diamonds, clubs, pass, alone;
    struct Gadget *pgad;
    struct TextAttr *GadText = EuchreScreen->Font;

    WORD trump;

    UBYTE *sp = "Spades";
    UBYTE *hts = "Hearts";
    UBYTE *dmnds = "Diamonds";
    UBYTE *clbs = "Clubs";
    UBYTE *ps = "Pass";
    UBYTE *loner = "Alone";

    LONG PlayWidth = 2 + (2 * CARD_LENGTH) + (5 * CARD_WIDTH) + 24;


    GottaLoner = INITIAL_SETUP;

    if ((vi = GetVisualInfo(EuchreScreen,TAG_END)) != NULL)
    {
            //gadet structures for PickUpWin

        spades.ng_TextAttr   = GadText;
        spades.ng_VisualInfo = vi;
        spades.ng_LeftEdge   = 25;
        spades.ng_TopEdge    = 9;
        spades.ng_Width      = 60;
        spades.ng_Height     = 19;
        spades.ng_GadgetText = sp;
        spades.ng_GadgetID   = SPADES_GAD;
        spades.ng_Flags      = 0;

        clubs.ng_TextAttr     = GadText;
        clubs.ng_VisualInfo   = vi;
        clubs.ng_LeftEdge     = 110;
        clubs.ng_TopEdge      = 9;
        clubs.ng_Width        = 60;
        clubs.ng_Height       = 19;
        clubs.ng_GadgetText   = clbs;
        clubs.ng_GadgetID     = CLUBS_GAD;
        clubs.ng_Flags        = 0;

        hearts.ng_TextAttr   = GadText;
        hearts.ng_VisualInfo = vi;
        hearts.ng_LeftEdge   = 25;
        hearts.ng_TopEdge    = 35;
        hearts.ng_Width      = 60;
        hearts.ng_Height     = 19;
        hearts.ng_GadgetText = hts;
        hearts.ng_GadgetID   = HEARTS_GAD;
        hearts.ng_Flags      = 0;

        diamonds.ng_TextAttr     = GadText;
        diamonds.ng_VisualInfo   = vi;
        diamonds.ng_LeftEdge     = 110;
        diamonds.ng_TopEdge      = 35;
        diamonds.ng_Width        = 60;
        diamonds.ng_Height       = 19;
        diamonds.ng_GadgetText   = dmnds;
        diamonds.ng_GadgetID     = DIAMONDS_GAD;
        diamonds.ng_Flags        = 0;

        pass.ng_TextAttr     = GadText;
        pass.ng_VisualInfo   = vi;
        pass.ng_LeftEdge     = 110;
        pass.ng_TopEdge      = 60;
        pass.ng_Width        = 60;
        pass.ng_Height       = 19;
        pass.ng_GadgetText   = ps;
        pass.ng_GadgetID     = PASS_GAD;
        pass.ng_Flags        = 0;
///
        alone.ng_TextAttr     = GadText;
        alone.ng_VisualInfo   = vi;
        alone.ng_LeftEdge     = 43;
        alone.ng_TopEdge      = 60;
        alone.ng_GadgetText   = loner;
        alone.ng_GadgetID     = ALONE_GAD;
        alone.ng_Flags        = PLACETEXT_BELOW;

        pgad = CreateContext(&glist);

        if (suit != SPADES)
            pgad = CreateGadget(BUTTON_KIND, pgad, &spades, TAG_END);
        else
            pgad = CreateGadget(BUTTON_KIND, pgad, &spades, GA_Disabled, TRUE, TAG_END);

        if (suit != CLUBS)
            pgad = CreateGadget(BUTTON_KIND, pgad, &clubs, TAG_END);
        else
            pgad = CreateGadget(BUTTON_KIND, pgad, &clubs, GA_Disabled, TRUE,TAG_END);

        if (suit != HEARTS)
            pgad = CreateGadget(BUTTON_KIND, pgad, &hearts, TAG_END);
        else
            pgad = CreateGadget(BUTTON_KIND, pgad, &hearts, GA_Disabled, TRUE,TAG_END);

        if (suit != DIAMONDS)
            pgad = CreateGadget(BUTTON_KIND, pgad, &diamonds, TAG_END);
        else
            pgad = CreateGadget(BUTTON_KIND, pgad, &diamonds, GA_Disabled, TRUE,TAG_END);

        pgad = CreateGadget(BUTTON_KIND, pgad, &pass, TAG_DONE);
        pgad = CreateGadget(CHECKBOX_KIND, pgad, &alone, TAG_DONE);

        CallWin = OpenWindowTags(NULL,
                                WA_Left,            ((PlayWidth/2) - 97),
                                WA_Top,             ((height/2) - 27),
                                WA_Width,           195,
                                WA_Height,          90,
                                WA_Gadgets,         glist,
                                WA_CustomScreen,    EuchreScreen,
                                WA_Activate,        TRUE,
                                WA_IDCMP,           BUTTONIDCMP | IDCMP_REFRESHWINDOW,
                                WA_SimpleRefresh,   TRUE,
                                TAG_DONE);

        GT_RefreshWindow(CallWin, NULL);
        if (CallWin != NULL)
        {
            trump = CallWinEvents(CallWin, suit);
            CloseWindow(CallWin);
            FreeGadgets(glist);
            FreeVisualInfo(vi);
            CallWin = NULL;
            glist = NULL;
            vi = NULL;
            return trump;

        }
    }//if vi=....

}//end UserCallTrump()
///
/************************************************************************
*
*  CallWinEvents()
*      processes events for CallWin in UserCallTrump()
*
*
*
************************************************************************/
///
WORD CallWinEvents(struct Window *CallWin, WORD suit)
{
    struct IntuiMessage *imsg;
    struct Gadget *gad;
    BOOL terminated = FALSE;

    while (!terminated)
    {
        Wait(1L << CallWin->UserPort->mp_SigBit);

        while ((!terminated) && (imsg = GT_GetIMsg(CallWin->UserPort)))
        {
            switch (imsg->Class)
            {
                case IDCMP_GADGETUP:
                    gad = (struct Gadget *)imsg->IAddress;
                    if (gad->GadgetID == SPADES_GAD)
                    {
                        terminated = TRUE;
                        return SPADES;
                    }
                    if (gad->GadgetID == CLUBS_GAD)
                    {
                        terminated = TRUE;
                        return CLUBS;
                    }
                    if (gad->GadgetID == HEARTS_GAD)
                    {
                        terminated = TRUE;
                        return HEARTS;
                    }
                    if (gad->GadgetID == DIAMONDS_GAD)
                    {
                        terminated = TRUE;
                        return DIAMONDS;
                    }
                    if (gad->GadgetID == PASS_GAD)
                    {
                        GottaLoner = INITIAL_SETUP;
                        terminated = TRUE;
                        return 4;
                    }
                    if (gad->GadgetID == ALONE_GAD)
                    {
                        if (GottaLoner == PLAYER_0)
                            GottaLoner = INITIAL_SETUP;

                        else if (GottaLoner == INITIAL_SETUP)
                            GottaLoner = PLAYER_0;
                    }
                    break;
                case IDCMP_REFRESHWINDOW:
                    {
                        GT_BeginRefresh(EuchreMain);
                        GT_EndRefresh(EuchreMain, TRUE);
                        break;
                    }
            }  //switch
        GT_ReplyIMsg(imsg);
        } //while
    } //while !terminated
}//end PickUpWinEvents()
///
/************************************************************************
*
* Discard() - if user is dealer and has to pick up UpCard,
*           this routine will show the change in hand to reflect
*           the addition of the UpCard
*
*
************************************************************************/
static void Discard(int disc, struct Cards *UpCard)
{
    extern struct Hand Player[4];
    extern struct Window *EuchreMain;
    extern LONG Player0Cards[5][2];

    DrawImage(EuchreMain->RPort, UpCard->CardImage, Player0Card[disc][0], Player0Card[disc][1]);

    Player[0].MyHand[disc] = *UpCard;
}


/************************************************************************
*
*       PickItUp()- handles computer dealer picking up UpCard
*
*
*
*
************************************************************************/

void PickItUp(struct GameInfo *Round, struct Cards *UpCard, short style)
{
    extern struct RoundHand players_hand[4][5];

    #ifdef BETA_VERSION
    extern BOOL debug;
    #endif

    extern LONG Player1Card[5][2];
    extern LONG Player2Card[5][2];
    extern LONG Player3Card[5][2];

    extern struct Window *EuchreMain;

    WORD i,drop;
    WORD k = 0;
    WORD suits[] = {0,0,0,0};
    WORD lowsuit = 0;
    WORD lowval =0;

    struct RoundHand temp[5];
    struct RoundHand dropped;

    //look only at non-trump cards to discard
    for (i = 0; i < 5; i++)
    {
        if (players_hand[Round->dealer][i].suit != UpCard->suit)
        {
            temp[k] = players_hand[Round->dealer][i];
            k++;
        }
    }
    //if there is only 1 non-trump card, discard it and replace with UpCard
    if (k == 1)
    {
        for (i = 0; i < 5; i++)
        {
            if (players_hand[Round->dealer][i].suit != UpCard->suit)
            {
                drop = i;
                players_hand[Round->dealer][drop].suit = UpCard->suit;
                players_hand[Round->dealer][drop].round_value = UpCard->trumpvalue;
                players_hand[Round->dealer][drop].used = FALSE;

                if (Round->dealer == 2)
                    players_hand[Round->dealer][drop].showcard = UpCard->CardImage;
                else
                    players_hand[Round->dealer][drop].showcard = UpCard->hCardImage;
            }
        }

    }

    //if the dealer holds 5 trump, discard the lowest one

    else if (k == 0)
    {

        dropped = FindGarbage(players_hand[Round->dealer], 5);

        for (i =0; i < 5; i++)
        {
            if (players_hand[Round->dealer][i].suit == dropped.suit && players_hand[Round->dealer][i].round_value == dropped.round_value)
            {
                drop = i;
                players_hand[Round->dealer][i].suit = UpCard->suit;
                players_hand[Round->dealer][i].round_value = UpCard->trumpvalue;
                players_hand[Round->dealer][i].used = FALSE;

                if (Round->dealer == 2)
                    players_hand[Round->dealer][i].showcard = UpCard->CardImage;
                else
                    players_hand[Round->dealer][i].showcard = UpCard->hCardImage;
            }
        }

    }

    //if there is more than one non-trump card, discard the lowest value card
    else if (k > 1)
    {

        if (style == CONSERVATIVE)
        {
            dropped = FindGarbage(temp, k);

        }
        //begin MODERATE/RISKY
        else if( (style == MODERATE) || (style == RISKY) )
        {
            //find number of suits and num of cards in each suit

            for (i = 0; i < 5; i++)
            {
                switch (players_hand[Round->dealer][i].suit)
                {
                    case 0:
                        suits[0]++;
                        break;
                    case 1:
                        suits[1]++;
                        break;
                    case 2:
                        suits[2]++;
                        break;
                    case 3:
                        suits[3]++;
                        break;
                }
            }
            //give all suits with no cards a high number so they aren't considered
            //in the card selection routines
            for (i = 0; i < 4; i++)
            {
                if (suits[i] == 0)
                {
                    suits[i] = 6;
                }
                //artificially inflate number of cards in trump suit so it won't
                //be considered in selection routine
                if (i == Round->trump_suit)
                {
                    suits[i] = 6;
                }
            }
            //find suit with least num of cards
            i = 0;
            lowval =  6;
            lowsuit = Round->trump_suit;

            do
            {
                if (suits[i] < lowval && suits[i] < suits[i+1])
                {
                    lowsuit = i;
                    lowval  = suits[i];
                }
                else if (suits[i+1] < lowval && suits[i+1] < suits[i] && suits[i] > 0 && suits[i+1] > 0)
                {
                    lowsuit = i+1;
                    lowval = suits[i];
                }
                i++;
            } while (i < 2);

            //put cards from that suit in the temp[] array
            for (i = 0, drop = 0; i < 5; i++)
            {
                if (players_hand[Round->dealer][i].suit == lowsuit)
                {
                    temp[drop] = players_hand[Round->dealer][i];
                    drop++;
                }
            }
            //use FindGarbage to determine the lowest card of that suit
            dropped = FindGarbage(temp, drop);

        }//end MODERATE/RISKY


    }
    //find the dropped card in players hand so the screen may be updated
    for (i =0; i < 5; i++)
    {
        if (players_hand[Round->dealer][i].suit == dropped.suit && players_hand[Round->dealer][i].round_value == dropped.round_value)
        {
            drop = i;
            players_hand[Round->dealer][drop].suit = UpCard->suit;
            players_hand[Round->dealer][drop].round_value = UpCard->trumpvalue;
            players_hand[Round->dealer][drop].used = FALSE;

            if (Round->dealer == 2)
                players_hand[Round->dealer][drop].showcard = UpCard->CardImage;
            else
                players_hand[Round->dealer][drop].showcard = UpCard->hCardImage;
        }
    }

#ifdef BETA_VERSION
    //if DUBUG is on, show the change on the screen

    if (debug)
    {
        switch (Round->dealer)
        {
            case 1:
                DrawImage(EuchreMain->RPort, players_hand[1][drop].showcard, Player1Card[drop][0], Player1Card[drop][1]);
                break;
            case 2:
                DrawImage(EuchreMain->RPort, players_hand[2][drop].showcard, Player2Card[drop][0], Player2Card[drop][1]);
                break;
            case 3:
                DrawImage(EuchreMain->RPort, players_hand[3][drop].showcard, Player3Card[drop][0], Player3Card[drop][1]);
                break;
        }
    } //All done!
#endif
}
/************************************************************************
*
*               ShowWhoCalled()
*
*                 displays calling team in status bar
*
*
*
************************************************************************/

void ShowWhoCalled(WORD call_team, BOOL clear)
{
    extern struct Screen *EuchreScreen;
    extern LONG width, height;

    struct DrawInfo *drawinfo;

    struct IntuiText WhoCalled_IText;
    struct TextAttr  WhoCalled_TextAttr;

    struct IntuiText CallStat_IText;
    struct TextAttr  CallStat_TextAttr;

    ULONG Call_TEXTPEN;
    ULONG Call_BACKGROUNDPEN;

    if (drawinfo = GetScreenDrawInfo(EuchreScreen))
    {
        Call_TEXTPEN= drawinfo->dri_Pens[TEXTPEN];
        Call_BACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

        WhoCalled_TextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        WhoCalled_TextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        WhoCalled_TextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        WhoCalled_TextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        WhoCalled_IText.FrontPen = Call_TEXTPEN;
        WhoCalled_IText.BackPen  = Call_BACKGROUNDPEN;
        WhoCalled_IText.DrawMode = JAM2;
        WhoCalled_IText.LeftEdge = 0;
        WhoCalled_IText.TopEdge  = 0;
        WhoCalled_IText.ITextFont=&WhoCalled_TextAttr;
        WhoCalled_IText.NextText = NULL;

        CallStat_TextAttr.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
        CallStat_TextAttr.ta_YSize = drawinfo->dri_Font->tf_YSize;
        CallStat_TextAttr.ta_Style = drawinfo->dri_Font->tf_Style;
        CallStat_TextAttr.ta_Flags = drawinfo->dri_Font->tf_Flags;

        CallStat_IText.FrontPen = Call_TEXTPEN;
        CallStat_IText.BackPen  = Call_BACKGROUNDPEN;
        CallStat_IText.DrawMode = JAM2;
        CallStat_IText.LeftEdge = 0;
        CallStat_IText.TopEdge  = 0;
        CallStat_IText.ITextFont=&WhoCalled_TextAttr;
        CallStat_IText.NextText = NULL;
        CallStat_IText.IText    = "Who Called: ";

        PrintIText(EuchreMain->RPort, &CallStat_IText, (width-78), (height - (2 *(height/5))));

        if (clear == TRUE)
        {
            WhoCalled_IText.FrontPen = Call_BACKGROUNDPEN;
        }
        else
        {
            WhoCalled_IText.FrontPen = Call_TEXTPEN;
        }


        if (call_team == 0 || call_team == 2)
        {
            WhoCalled_IText.IText = "Us";
            PrintIText(EuchreMain->RPort, &WhoCalled_IText, (width-55),(height -(2* (height/5)) + 15 ));
        }

        else
        {
            WhoCalled_IText.IText = "Them";
            PrintIText(EuchreMain->RPort, &WhoCalled_IText, (width-65),(height - (2*(height/5))+15));
        }

        FreeScreenDrawInfo(EuchreScreen, drawinfo);
    }//end if
}//end ShowWhoCalled



