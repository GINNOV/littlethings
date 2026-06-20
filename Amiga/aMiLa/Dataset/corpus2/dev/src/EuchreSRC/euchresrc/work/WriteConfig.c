/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : WriteConfig.c
 ** Created on       : Monday, 10-Aug-98
 ** Created by       : Rick Keller
 ** Current revision : V 1.03
 **
 ** Purpose
 ** -------
 **   
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 18-Oct-98   Rick Keller            added screen mode preference choice
 ** 13-Aug-98   Rick Keller            RELEASE 1.0
 ** 11-Aug-98   Rick Keller            finished integrating
 ** 10-Aug-98   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/




#include <exec/types.h>
#include <exec/libraries.h>

#include <intuition/intuition.h>
#include <intuition/classes.h>
#include <intuition/classusr.h>
#include <intuition/imageclass.h>
#include <intuition/gadgetclass.h>

#include <libraries/asl.h>
#include <libraries/gadtools.h>

#include <graphics/displayinfo.h>
#include <graphics/gfxbase.h>

#include <clib/asl_protos.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>
#include <clib/utility_protos.h>

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "WriteConfig.h"
#include "settings.h"
#include "gamesetup.h"

extern struct Screen  *EuchreScreen;
extern ULONG  EuchreScreenMode;

extern APTR            VisualInfo = NULL;
struct Window         *settingsWnd = NULL;
struct Gadget         *settingsGList = NULL;
struct IntuiMessage    settingsMsg;
struct Gadget         *settingsGadgets[11];
UWORD                  settingsLeft = 166;
UWORD                  settingsTop = 79;
UWORD                  settingsWidth = 315;
UWORD                  settingsHeight = 297;
UBYTE                 *settingsWdt = (UBYTE *)"Euchre Settings";

struct Screen         *Scr = NULL;
UBYTE                 *PubScreenName = "Workbench";

UBYTE *Player10Labels[] =
{
    (UBYTE *)" ",//Cons
    (UBYTE *)" ",//Mod
    (UBYTE *)" ",//Risk
    NULL
};

UBYTE *Player20Labels[] =
{
    (UBYTE *)" ",//Cons
    (UBYTE *)" ",//Mod
    (UBYTE *)" ",//Risk
    NULL
};

UBYTE *Player30Labels[] =
{
    (UBYTE *)" ",//Cons
    (UBYTE *)" ",//Mod
    (UBYTE *)" ",//Risk
    NULL
};

UBYTE *LonerValue0Labels[] =
{
    (UBYTE *)"3 pts.",
    (UBYTE *)"4 pts.",
    NULL
};

UBYTE *EndEarly0Labels[] =
{
    (UBYTE *)"On",
    (UBYTE *)"Off",
    NULL
};

UBYTE *GameSpeed0Labels[] =
{
    (UBYTE *)"Slow",
    (UBYTE *)"Normal",
    (UBYTE *)"Fast",
    (UBYTE *)"Ridiculous",
    NULL
};

UWORD settingsGTypes[] =
{
    MX_KIND,
    MX_KIND,
    MX_KIND,
    MX_KIND,
    MX_KIND,
    MX_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND,
    BUTTON_KIND
};

struct NewGadget settingsNGad[] =
{
    101, 56, 17, 9, NULL, NULL, GD_Player1, PLACETEXT_LEFT, NULL, NULL,
    173, 56, 17, 9, NULL, NULL, GD_Player2, PLACETEXT_LEFT, NULL, NULL,
    255, 56, 17, 9, NULL, NULL, GD_Player3, PLACETEXT_LEFT, NULL, NULL,
    211, 136, 17, 9, NULL, NULL, GD_LonerValue, PLACETEXT_LEFT, NULL, NULL,
    211, 192, 17, 9, NULL, NULL, GD_EndEarly, PLACETEXT_LEFT, NULL, NULL,
    97, 137, 17, 9, NULL, NULL, GD_GameSpeed, PLACETEXT_LEFT, NULL, NULL,
    33, 264, 53, 13, (UBYTE *)"Save", NULL, GD_Save, PLACETEXT_IN, NULL, NULL,
    123, 264, 53, 13, (UBYTE *)"Use", NULL, GD_Use, PLACETEXT_IN, NULL, NULL,
    219, 264, 53, 13, (UBYTE *)"Cancel", NULL, GD_Cancel, PLACETEXT_IN, NULL, NULL,
    209, 232, 21, 11, (UBYTE *)"Set Screen Mode", NULL, GD_chg_scrn_mode, PLACETEXT_LEFT, NULL, NULL

};

ULONG settingsGTags[] =
{
    (GTMX_Labels), (ULONG)&Player10Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (GTMX_Labels), (ULONG)&Player20Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (GTMX_Labels), (ULONG)&Player30Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (GTMX_Labels), (ULONG)&LonerValue0Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (GTMX_Labels), (ULONG)&EndEarly0Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (GTMX_Labels), (ULONG)&GameSpeed0Labels[ 0 ], (GTMX_Spacing), 4, (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE),
    (TAG_DONE)

};



int SetupScreen( void )
{

    if (EuchreScreen != NULL)
    {       
        if ( ! ( VisualInfo = GetVisualInfo( EuchreScreen, TAG_DONE )))
            return( 2L );
    }
    else
    {
        if ( ! ( Scr = LockPubScreen( PubScreenName )))
            return( 1L );

        if ( ! ( VisualInfo = GetVisualInfo( Scr, TAG_DONE )))
            return( 2L );
    }

    return( 0L );
}

void CloseDownScreen( void )
{
    if ( VisualInfo )
    {
        FreeVisualInfo( VisualInfo );
        VisualInfo = NULL;
    }

    if (Scr)
    {
        UnlockPubScreen( NULL, Scr );
        Scr = NULL;
    }
}

void HandlesettingsIDCMP( void )
{
    extern short Speed;
    extern short Loner;
    extern BOOL End;
    extern short pstyle[4];

    short Speed_old = Speed;
    short Loner_old = Loner;
    BOOL End_old = End;
    short pstyle_old[4];
    ULONG EuchreScreenMode_old = EuchreScreenMode;

    struct IntuiMessage *imsg;
    struct Gadget *gad;

    BOOL terminated = FALSE;

    pstyle_old[PLAYER_1] = pstyle[PLAYER_1];
    pstyle_old[PLAYER_2] = pstyle[PLAYER_2];
    pstyle_old[PLAYER_3] = pstyle[PLAYER_3];

    while (!terminated)
    {
        Wait (1L<<settingsWnd->UserPort->mp_SigBit);

        while ((!terminated) && (imsg = GT_GetIMsg(settingsWnd->UserPort)))
        {

            switch ( imsg->Class )
            {

                case    IDCMP_GADGETDOWN:
                case    IDCMP_GADGETUP:
                    gad = (struct Gadget *)imsg->IAddress;

                    if (gad->GadgetID == GD_Cancel)
                    {
                        //Cancel settings change
                        terminated = TRUE;

                        pstyle[PLAYER_1] = pstyle_old[PLAYER_1];
                        pstyle[PLAYER_2] = pstyle_old[PLAYER_2];
                        pstyle[PLAYER_3] = pstyle_old[PLAYER_3];
                        Loner = Loner_old;
                        Speed = Speed_old;
                        End = End_old;
                        EuchreScreenMode = EuchreScreenMode_old;
                    }
                    else if (gad->GadgetID == GD_Player1)
                    {
                        //Adjust Player 1 Style
                        switch (imsg->Code)
                        {
                            case 0:
                                pstyle[PLAYER_1] = CONSERVATIVE;
                                break;
                            case 1:
                                pstyle[PLAYER_1] = MODERATE;
                                break;
                            case 2:
                                pstyle[PLAYER_1] = RISKY;
                                break;
                        }
                    }
                    else if (gad->GadgetID == GD_Player2)
                    {
                        //Adjust Player 2 Style
                        switch (imsg->Code)
                        {
                            case 0:
                                pstyle[PLAYER_2] = CONSERVATIVE;
                                break;
                            case 1:
                                pstyle[PLAYER_2] = MODERATE;
                                break;
                            case 2:
                                pstyle[PLAYER_2] = RISKY;
                                break;
                        }

                    }
                    else if (gad->GadgetID == GD_Player3)
                    {
                        //Adjust Player 3 style
                        switch (imsg->Code)
                        {
                            case 0:
                                pstyle[PLAYER_3] = CONSERVATIVE;
                                break;
                            case 1:
                                pstyle[PLAYER_3] = MODERATE;
                                break;
                            case 2:
                                pstyle[PLAYER_3] = RISKY;
                                break;
                        }

                    }
                    else if (gad->GadgetID == GD_LonerValue)
                    {
                        //Adjust Loner Value
                        switch ( imsg->Code )
                        {
                            case 0:
                                Loner = THREE_POINT;
                                break;
                            case 1:
                                Loner = FOUR_POINT;
                                break;
                        }
                    }
                    else if (gad->GadgetID == GD_EndEarly)
                    {
                        //Adjust End Early
                        switch (imsg->Code)
                        {
                            case 0:
                                End = TRUE;
                                break;
                            case 1:
                                End = FALSE;
                                break;
                        }
                    }
                    else if (gad->GadgetID == GD_GameSpeed)
                    {
                        //Adjust GameSpeed
                        switch ( imsg->Code )
                        {
                            case 0:
                                Speed = SLOW_SPEED;
                                break;
                            case 1:
                                Speed = NORMAL_SPEED;
                                break;
                            case 2:
                                Speed = FAST_SPEED;
                                break;
                            case 3:
                                Speed = RIDICULOUS_SPEED;
                                break;
                        }
                    }
                    else if (gad->GadgetID == GD_chg_scrn_mode)
                    {
                        ChangeScreenMode();
                    }

                    else if (gad->GadgetID == GD_Use)
                    {
                        //Use settings
                        terminated = TRUE;
                    }
                    else if (gad->GadgetID == GD_Save)
                    {
                        terminated = TRUE;
                        //Save settings
                        SaveSettings();
                    }
                    break;
                case IDCMP_REFRESHWINDOW:
                {
                        GT_BeginRefresh(settingsWnd);
                        GT_EndRefresh(settingsWnd, TRUE);
                        break;
                }
            }//switch (imsg->Class)
        GT_ReplyIMsg(imsg);

        }//inner while

    }//outer while
}

int OpensettingsWindow( void )
{
    struct NewGadget ng;
    struct Gadget    *g;
    UWORD            lc, tc;
    UWORD            offx, offy;
    UWORD  active;

    struct TextAttr *GadText;

    FILE *config;



    if (EuchreScreen != NULL)
    {
        SetupScreen();
        offx = EuchreScreen->WBorLeft;
        offy = EuchreScreen->WBorTop + EuchreScreen->RastPort.TxHeight + 1;
        GadText = EuchreScreen->Font;
    }

    else
    {
        SetupScreen();
        offx = Scr->WBorLeft;
        offy = Scr->WBorTop + Scr->RastPort.TxHeight + 1;
        GadText = Scr->Font;
    }


    if ( ! ( g = CreateContext( &settingsGList )))
        return( 1L );

    for( lc = 0, tc = 0; lc < settings_CNT; lc++ )
    {
        CopyMem((char * )&settingsNGad[ lc ], (char * )&ng, (long)sizeof( struct NewGadget ));

        ng.ng_VisualInfo = VisualInfo;
        ng.ng_TextAttr   = GadText;
        ng.ng_LeftEdge  += offx;
        ng.ng_TopEdge   += offy;

        settingsGadgets[ lc ] = g = CreateGadgetA((ULONG)settingsGTypes[ lc ], g, &ng, ( struct TagItem * )&settingsGTags[ tc ] );

        while( settingsGTags[ tc ] ) tc += 2;
        tc++;

        if ( NOT g )
            return( 2L );
     }

    if (EuchreScreen != NULL)
    {
        if ( ! ( settingsWnd = OpenWindowTags( NULL,
                                WA_Left,        settingsLeft,
                                WA_Top,         settingsTop,
                                WA_Width,       settingsWidth,
                                WA_Height,      settingsHeight + offy,
                                WA_IDCMP,       MXIDCMP|BUTTONIDCMP|IDCMP_REFRESHWINDOW,
                                WA_Flags,       WFLG_SMART_REFRESH,
                                WA_Gadgets,     settingsGList,
                                WA_Title,       settingsWdt,
                                WA_ScreenTitle, "Euchre! Settings",
                                WA_CustomScreen, EuchreScreen,
                                WA_Activate,    TRUE,
                                WA_DragBar,     TRUE,
                                TAG_DONE )))
        {
            return( 4L );
        }
    }
    else if (EuchreScreen == NULL)
    {
        if ( ! ( settingsWnd = OpenWindowTags( NULL,
                                WA_Left,        settingsLeft,
                                WA_Top,         settingsTop,
                                WA_Width,       settingsWidth,
                                WA_Height,      settingsHeight,
                                WA_IDCMP,       MXIDCMP|BUTTONIDCMP|IDCMP_REFRESHWINDOW,
                                WA_Flags,       WFLG_SMART_REFRESH,
                                WA_Gadgets,     settingsGList,
                                WA_Title,       settingsWdt,
                                WA_ScreenTitle, "Euchre! Settings",
                                WA_Activate,    TRUE,
                                WA_DragBar,     TRUE,
                                TAG_DONE )))
        {
            return( 4L );
        }
    }

    GT_RefreshWindow( settingsWnd, NULL );
    settingsRender();
    // see if the Euchre.config file exists
    if ((config = fopen("Euchre.config","r")) != NULL)
    {
        fclose(config);
        for (lc = 0; lc < 6 ; lc++) //6 is the number of MX gads
        {
            active = ReflectSettings(lc);
            GT_SetGadgetAttrs(settingsGadgets[lc], settingsWnd, NULL, GTMX_Active, active, TAG_END);
        }
    }

    if (settingsWnd != NULL)
    {
        HandlesettingsIDCMP();
        ClosesettingsWindow();

        if (EuchreScreen != NULL)
        {
            CloseDownScreen();
        }
    }

    return( 0L );
}

void ClosesettingsWindow( void )
{
    if ( settingsWnd )
    {
        CloseWindow( settingsWnd );
        settingsWnd = NULL;
    }

    if ( settingsGList )
    {
        FreeGadgets( settingsGList );
        settingsGList = NULL;
    }
}

void SaveSettings( void )
{
    FILE *config = NULL;
    extern short Speed;
    extern short Loner;
    extern BOOL End;
    extern short pstyle[4];


    if ( !config )
        (config = fopen("Euchre.config","w"));

    if (config)
    {
        fprintf(config,"%ld\n",EuchreScreenMode);

        if (pstyle[PLAYER_1] == CONSERVATIVE)
        {
            fprintf(config,"CONSERVATIVE\n");
        }
        else if (pstyle[PLAYER_1] == MODERATE)
        {
            fprintf(config,"MODERATE\n");
        }
        else if (pstyle[PLAYER_1] == RISKY)
        {
            fprintf(config,"RISKY\n");
        }

        if (pstyle[PLAYER_2] == CONSERVATIVE)
        {
            fprintf(config,"CONSERVATIVE\n");
        }
        else if (pstyle[PLAYER_2] == MODERATE)
        {
            fprintf(config,"MODERATE\n");
        }
        else if (pstyle[PLAYER_2] == RISKY)
        {
            fprintf(config,"RISKY\n");
        }

        if (pstyle[PLAYER_3] == CONSERVATIVE)
        {
            fprintf(config,"CONSERVATIVE\n");
        }
        else if (pstyle[PLAYER_3] == MODERATE)
        {
            fprintf(config,"MODERATE\n");
        }
        else if (pstyle[PLAYER_3] == RISKY)
        {
            fprintf(config,"RISKY\n");
        }

        if (Loner == THREE_POINT)
        {
            fprintf(config,"THREE\n");
        }
        else if (Loner == FOUR_POINT)
        {
            fprintf(config, "FOUR\n");
        }

        if (End == TRUE)
        {
            fprintf(config,"ENDEARLY\n");
        }
        else if (End == FALSE)
        {
            fprintf(config, "NOEARLY\n");
        }

        if (Speed == SLOW_SPEED)
        {
            fprintf(config, "SLOW\n");
        }

        else if (Speed == NORMAL_SPEED)
        {
            fprintf(config, "NORMAL\n");
        }
        else if (Speed == FAST_SPEED)
        {
            fprintf(config, "FAST\n");
        }
        else if (Speed == RIDICULOUS_SPEED)
        {
            fprintf(config,"RIDICULOUS\n");
        }

        if (config)
            fclose(config);
    }

}

void settingsRender( void )
{
    UWORD           offx, offy;
    struct TextAttr GadText;
    struct DrawInfo *drawinfo;

    ULONG myTEXTPEN;
    ULONG myBACKGROUNDPEN;

    struct IntuiText settingsIText[10];

    if (EuchreScreen)
        drawinfo = GetScreenDrawInfo(EuchreScreen);

    else
        drawinfo = GetScreenDrawInfo(Scr);

    myTEXTPEN = drawinfo->dri_Pens[TEXTPEN];
    myBACKGROUNDPEN = drawinfo->dri_Pens[BACKGROUNDPEN];

    GadText.ta_Name = drawinfo->dri_Font->tf_Message.mn_Node.ln_Name;
    GadText.ta_YSize = drawinfo->dri_Font->tf_YSize;
    GadText.ta_Style = drawinfo->dri_Font->tf_Style;
    GadText.ta_Flags = drawinfo->dri_Font->tf_Flags;

    settingsIText[0].FrontPen = myTEXTPEN;
    settingsIText[0].BackPen  = myBACKGROUNDPEN;
    settingsIText[0].DrawMode = JAM2;
    settingsIText[0].LeftEdge = 113;
    settingsIText[0].TopEdge  = 10;
    settingsIText[0].ITextFont= &GadText;
    settingsIText[0].NextText = &settingsIText[1];
    settingsIText[0].IText    = (UBYTE *)"Playing Styles";

    settingsIText[1].FrontPen = myTEXTPEN;
    settingsIText[1].BackPen  = myBACKGROUNDPEN;
    settingsIText[1].DrawMode = JAM2;
    settingsIText[1].LeftEdge = 73;
    settingsIText[1].TopEdge  = 34;
    settingsIText[1].ITextFont= &GadText;
    settingsIText[1].NextText = &settingsIText[2];
    settingsIText[1].IText    = (UBYTE *)"Player 1";

    settingsIText[2].FrontPen = myTEXTPEN;
    settingsIText[2].BackPen  = myBACKGROUNDPEN;
    settingsIText[2].DrawMode = JAM2;
    settingsIText[2].LeftEdge = 157;
    settingsIText[2].TopEdge  = 34;
    settingsIText[2].ITextFont= &GadText;
    settingsIText[2].NextText = &settingsIText[3];
    settingsIText[2].IText    = (UBYTE *)"Player 2";

    settingsIText[3].FrontPen = myTEXTPEN;
    settingsIText[3].BackPen  = myBACKGROUNDPEN;
    settingsIText[3].DrawMode = JAM2;
    settingsIText[3].LeftEdge = 237;
    settingsIText[3].TopEdge  = 34;
    settingsIText[3].ITextFont= &GadText;
    settingsIText[3].NextText = &settingsIText[4];
    settingsIText[3].IText    = (UBYTE *)"Player 3";

    settingsIText[4].FrontPen = myTEXTPEN;
    settingsIText[4].BackPen  = myBACKGROUNDPEN;
    settingsIText[4].DrawMode = JAM2;
    settingsIText[4].LeftEdge = 3;
    settingsIText[4].TopEdge  = 58;
    settingsIText[4].ITextFont= &GadText;
    settingsIText[4].NextText = &settingsIText[5];
    settingsIText[4].IText    = (UBYTE *)"Conservative";

    settingsIText[5].FrontPen = myTEXTPEN;
    settingsIText[5].BackPen  = myBACKGROUNDPEN;
    settingsIText[5].DrawMode = JAM2;
    settingsIText[5].LeftEdge = 3;
    settingsIText[5].TopEdge  = 70;
    settingsIText[5].ITextFont= &GadText;
    settingsIText[5].NextText = &settingsIText[6];
    settingsIText[5].IText    = (UBYTE *)"Moderate";

    settingsIText[6].FrontPen = myTEXTPEN;
    settingsIText[6].BackPen  = myBACKGROUNDPEN;
    settingsIText[6].DrawMode = JAM2;
    settingsIText[6].LeftEdge = 3;
    settingsIText[6].TopEdge  = 82;
    settingsIText[6].ITextFont= &GadText;
    settingsIText[6].NextText = &settingsIText[7];
    settingsIText[6].IText    = (UBYTE *)"Risky";

    settingsIText[7].FrontPen = myTEXTPEN;
    settingsIText[7].BackPen  = myBACKGROUNDPEN;
    settingsIText[7].DrawMode = JAM2;
    settingsIText[7].LeftEdge = 33;
    settingsIText[7].TopEdge  = 122;
    settingsIText[7].ITextFont= &GadText;
    settingsIText[7].NextText = &settingsIText[8];
    settingsIText[7].IText    = (UBYTE *)"Game Speed";

    settingsIText[8].FrontPen = myTEXTPEN;
    settingsIText[8].BackPen  = myBACKGROUNDPEN;
    settingsIText[8].DrawMode = JAM2;
    settingsIText[8].LeftEdge = 181;
    settingsIText[8].TopEdge  = 122;
    settingsIText[8].ITextFont= &GadText;
    settingsIText[8].NextText = &settingsIText[9];
    settingsIText[8].IText    = (UBYTE *)"Loner Value";

    settingsIText[9].FrontPen = myTEXTPEN;
    settingsIText[9].BackPen  = myBACKGROUNDPEN;
    settingsIText[9].DrawMode = JAM2;
    settingsIText[9].LeftEdge = 185;
    settingsIText[9].TopEdge  = 178;
    settingsIText[9].ITextFont= &GadText;
    settingsIText[9].NextText = NULL;
    settingsIText[9].IText    = (UBYTE *)"End Early";

    offx = settingsWnd->BorderLeft;
    offy = settingsWnd->BorderTop;

    PrintIText( settingsWnd->RPort, settingsIText, offx, offy );
}

UWORD ReflectSettings(int gad_num)
{
    extern short pstyle[4];
    extern short Loner;
    extern short End;
    extern short Speed;

    if (gad_num < 3)
    {
        if (pstyle[gad_num + 1] == MODERATE)
            return (UWORD)1;

        else if (pstyle[gad_num + 1] == RISKY)
            return (UWORD)2;

        else
        {
            pstyle[gad_num + 1] = CONSERVATIVE;
            return (UWORD)0;
        }

    }

    else if (gad_num == 3)
    {
        if (Loner == FOUR_POINT)
            return (UWORD)1;

        else
        {
            Loner = THREE_POINT;
            return (UWORD)0;
        }


    }

    else if (gad_num == 4)
    {
        if (End == FALSE)
            return (UWORD)1;

        else
        {
            End = TRUE;
            return (UWORD) 0;
        }
    }

    else if (gad_num == 5)
    {
        if (Speed == SLOW_SPEED)
            return (UWORD) 0;

        else if(Speed == FAST_SPEED)
            return (UWORD) 2;

        else if (Speed == RIDICULOUS_SPEED)
            return (UWORD) 3;

        else
        {
            Speed = NORMAL_SPEED;
            return (UWORD) 1;
        }
    }   

    else
        return (UWORD) 10;

}

void ChangeScreenMode(void)
{

    struct Library *AslBase = NULL;
    struct ScreenModeRequester *Settings_ScreenMode_Req;

    if (AslBase = OpenLibrary("asl.library", 38L))
    {
        if (EuchreScreen != NULL)
        {

            if (Settings_ScreenMode_Req = (struct ScreenModeRequester *)
                AllocAslRequestTags(ASL_ScreenModeRequest,
                                    ASLSM_Screen,           EuchreScreen,
                                    ASLSM_TitleText,        (ULONG)"Euchre Screen Mode",
                                    ASLSM_InitialHeight,    MODE_REQ_HEIGHT,
                                    ASLSM_InitialWidth,     MODE_REQ_WIDTH,
                                    ASLSM_InitialLeftEdge,  MODE_REQ_LEFT_EDGE,
                                    ASLSM_InitialTopEdge,   MODE_REQ_TOP_EDGE,
                                    ASLSM_PositiveText,     (ULONG)"Ok",
                                    ASLSM_NegativeText,     (ULONG)"Cancel",
                                    ASLSM_MinDepth,         3,
                                    TAG_DONE))
            {
                if (AslRequest(Settings_ScreenMode_Req, NULL))
                {
                    EuchreScreenMode = Settings_ScreenMode_Req->sm_DisplayID;
                }
                FreeAslRequest(Settings_ScreenMode_Req);
            }
        }

        else
        {
            if (Settings_ScreenMode_Req = (struct ScreenModeRequester *)
                AllocAslRequestTags(ASL_ScreenModeRequest,
                                    ASLSM_TitleText,        (ULONG)"Euchre Screen Mode",
                                    ASLSM_InitialHeight,    MODE_REQ_HEIGHT,
                                    ASLSM_InitialWidth,     MODE_REQ_WIDTH,
                                    ASLSM_InitialLeftEdge,  MODE_REQ_LEFT_EDGE,
                                    ASLSM_InitialTopEdge,   MODE_REQ_TOP_EDGE,
                                    ASLSM_PositiveText,     (ULONG)"Ok",
                                    ASLSM_NegativeText,     (ULONG)"Cancel",
                                    ASLSM_MinDepth,         3,
                                    TAG_DONE))


            {
                if (AslRequest(Settings_ScreenMode_Req, NULL))
                {
                    EuchreScreenMode = Settings_ScreenMode_Req->sm_DisplayID;
                }
                FreeAslRequest(Settings_ScreenMode_Req);
            }
        }

        CloseLibrary(AslBase);
    }

    else
    {
        ExitFromAnywhere();
    }
}
