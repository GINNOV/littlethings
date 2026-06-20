///
/** $Revision Header *** Header built automatically - do not edit! ***********
 **
 ** © Copyright Bargain Basement Software
 **
 ** File             : main.c
 ** Created on       : Thursday, 07-Aug-97
 ** Created by       : Rick Keller
 ** Current revision : V 1.10
 **
 ** Purpose
 ** -------
 **   Startup, UI, and Intuition I/O routines
 **
 ** Date        Author                 Comment
 ** =========   ====================   ====================
 ** 18-Oct-98   Rick Keller            added screen mode preference
 ** 25-Aug-98   Rick Keller            changed font to XHelvetica
 ** 04-Jun-98   Rick Keller            zapped an enforcer hit in HandleMenuEvents
 ** 13-Oct-97   Rick Keller            added about requester
 ** 04-Sep-97   Rick Keller            moved game play initiation into GamePlay()
 ** 29-Aug-97   Rick Keller            changed "Help" mode to "debug" mode
 ** 29-Aug-97   Rick Keller            added HandleMenuEvents for better user interface
 ** 29-Aug-97   Rick Keller            added ExitFromAnywhere() to clean up and exit prog.
 ** 25-Aug-97   Rick Keller            instituted GameInfo struct
 ** 19-Aug-97   Rick Keller            added CallTrump call after ShowCards in NewGame menu option
 ** 07-Aug-97   Rick Keller            --- Initial release ---
 **
 ** $Revision Header *********************************************************/
///

//Includes

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <libraries/gadtools.h>
#include <libraries/dos.h>
#include <graphics/displayinfo.h>
#include <graphics/modeid.h>
#include <graphics/text.h>

#include <time.h>
#include <stdlib.h>

//Function Prototypes
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/intuition_protos.h>
#include <clib/gadtools_protos.h>
#include <clib/graphics_protos.h>

//My own includes
#include "visual.h"
#include "gamesetup.h"
#include "Euchre!_rev.h"  //version numbers
//Now some Defines.....

UBYTE version[] = VERSTAG;

int CXBRK(void);
int chkabort(void);

//Local Function Protos
void HandleMainEvents(void);
void ExitFromAnywhere(void);
void HandleMenuEvents(struct IntuiMessage *msg);
void About(void);
void Mode(void);

//external funcions
extern void GamePlay(void);
extern int OpensettingsWindow( void );
extern int ReadConfig(void);

//global structures
struct Screen *EuchreScreen;
struct Library *IntuitionBase;
struct Library *GadToolsBase;
struct Library *GfxBase;
struct Window *EuchreMain;
struct Menu *EuchreStrip;
struct Hand Player[4];
struct TextAttr helvetica = {"XHelvetica.font",11,0,0};
//global variables

LONG width;
LONG height;

ULONG EuchreScreenMode;

#ifdef BETA_VERSION
BOOL debug = FALSE;
#endif

APTR my_VisualInfo;
int main(void)
{
    struct Rectangle rect;
    extern LONG width,height;
    ULONG screen_modeID;
    EuchreScreen = NULL;

    IntuitionBase = OpenLibrary("intuition.library", 37);
    GfxBase = OpenLibrary("graphics.library", 37);
    GadToolsBase = OpenLibrary("gadtools.library",37);

    if (GadToolsBase && IntuitionBase && GfxBase)
        ReadConfig();

    else
        ExitFromAnywhere();

    if (GfxBase != NULL)
    {
        if (ModeNotAvailable(EuchreScreenMode) != NULL)
        {
            Mode();
            OpensettingsWindow();
        }
    }


    if (NULL != IntuitionBase)
    {
        if (GadToolsBase != NULL)
        {
            if (NULL != (EuchreScreen = OpenScreenTags(NULL,
                                        SA_Depth,       4,
                                        SA_Colors,      EuchreColors,
                                        SA_Pens,        (ULONG)pens,
                                        SA_Title,       VERS" by "AUTHOR", "DATE,
                                        SA_Overscan,    OSCAN_TEXT,
                                        SA_DisplayID,   EuchreScreenMode,      //Read from ReadConfig                                     SA_Depth,       4,
                                        SA_Font,        &helvetica,
                                        TAG_DONE)))

            {
                //get height and width
                if (GfxBase != NULL)
                {
                    screen_modeID = GetVPModeID(&EuchreScreen->ViewPort);
                    if (QueryOverscan(screen_modeID, &rect, OSCAN_TEXT))
                    {
                        width  = rect.MaxX - rect.MinX +1;
                        height = rect.MaxY - rect.MinY +1;

                        if (NULL != (EuchreMain = OpenWindowTags(NULL,
                                                //size and position
                                                WA_Left,           0,
                                                WA_Top,            0,
                                                WA_Width,          width,
                                                WA_Height,         height,
                                                WA_CustomScreen,   EuchreScreen,
                                                    //gadgets

                                                    //misc
                                                WA_SmartRefresh,   TRUE,
                                                WA_Borderless,     TRUE,
                                                WA_Backdrop,       TRUE,
                                                WA_Activate,       TRUE,
                                                WA_IDCMP,          IDCMP_MENUPICK | IDCMP_MOUSEBUTTONS | IDCMP_REFRESHWINDOW,
                                                TAG_DONE)))
                        {
                            if (NULL != (my_VisualInfo = GetVisualInfo(EuchreMain->WScreen, TAG_END)))
                            {
                                if (NULL != (EuchreStrip = CreateMenus(EuchreMenu, TAG_END)))
                                {
                                    if (LayoutMenus(EuchreStrip, my_VisualInfo, TAG_END))
                                    {
                                        if (SetMenuStrip(EuchreMain,EuchreStrip))
                                        {
                                            HandleMainEvents();

                                            ClearMenuStrip(EuchreMain);
                                        }// if SetMenuStrip
                                        FreeMenus(EuchreStrip);
                                    }// if LayoutMenus
                                } //if CreateMenus
                                FreeVisualInfo(my_VisualInfo);
                            }// if GetVisualInfo
                            CloseWindow(EuchreMain);
                        } //if EuchreMain = OpenWindowTags
                    } // if QueryOverscan
                CloseLibrary(GfxBase);
                } //if GFXBase= OpenLibrary
            CloseScreen(EuchreScreen);
            } // if EuchreScreen = OpenScreenTags
        } //if GadToolsBase != NULL
        CloseLibrary(GadToolsBase);
    } //if NULL != IntuitionBase

    CloseLibrary(IntuitionBase);
    return 0;
} //end main()
/************************************************************************
*                                                                       *
*           HandleMainEvents                                            *                                                                                  *
*           handle events Intuition Events                              *
*           from main window                                            *
*                                                                       *
************************************************************************/
void HandleMainEvents(void)
{
    struct IntuiMessage *msg;
    short done;
    done = FALSE;

    while (done == FALSE)
    {
        Wait(1L << EuchreMain->UserPort->mp_SigBit);

        while ((done == FALSE) && (NULL != (msg = (struct IntuiMessage *)GetMsg(EuchreMain->UserPort))))
        {
            switch (msg->Class)
            {
                case IDCMP_REFRESHWINDOW:

                    BeginRefresh(EuchreMain);
                    EndRefresh(EuchreMain, TRUE);
                    break;

                case IDCMP_MENUPICK:
                    HandleMenuEvents(msg);
                    break;

                //next case here!
            } //end switch
        ReplyMsg((struct Message *)msg);
        } //end 2nd while
    } //end first while

} // end HandleMainEvents



void ExitFromAnywhere(void)
{
    extern struct Window *PickUpWin;
    extern struct Window *CallWin;
    extern struct Gadget *glist;
    extern void *vi;


    if (PickUpWin)
        CloseWindow(PickUpWin);

    if (CallWin)
        CloseWindow(CallWin);

    if (glist)
        FreeGadgets(glist);

    if (vi)
        FreeVisualInfo(vi);

    if (EuchreStrip)
    {
        ClearMenuStrip(EuchreMain);
        FreeMenus(EuchreStrip);
    }

    if (my_VisualInfo)
        FreeVisualInfo(my_VisualInfo);

    if (EuchreMain)
        CloseWindow(EuchreMain);

    if (GfxBase)
        CloseLibrary(GfxBase);

    if (EuchreScreen)
        CloseScreen(EuchreScreen);

    if (GadToolsBase)
        CloseLibrary(GadToolsBase);


    if (IntuitionBase)
        CloseLibrary(IntuitionBase);

    exit(0);
}

void HandleMenuEvents(struct IntuiMessage *msg)
{
    extern struct Menu *EuchreStrip;
    extern struct Window *PickUpWin;
    extern struct Window *CallWin;
    extern struct Gadget *glist;
    extern void *vi;

    UWORD menuNumber;
    UWORD menuNum;
    UWORD itemNum;
    struct MenuItem *item;

    menuNumber = msg->Code;
    item = ItemAddress(EuchreStrip, menuNumber);
    menuNum = MENUNUM(menuNumber);
    itemNum = ITEMNUM(menuNumber);

#ifdef BETA_VERSION
    if ((menuNum == 0) && (itemNum == 0)) //Project/New Game
    {
         //if a game is still in session, must veryif new game
         //close any previously opened windows before starting new game
        if (PickUpWin)
            CloseWindow(PickUpWin);

        if (CallWin)
            CloseWindow(CallWin);

        if (glist)
            FreeGadgets(glist);

        if (vi)
            FreeVisualInfo(vi);

        GamePlay();

    }

    if ((menuNum == 0) && (itemNum == 3)) //Project/About
    {
        About();

    }

    if ((menuNum == 0) && (itemNum == 1)) //Settings Program
    {
        OpensettingsWindow();

    }


    if ((menuNum == 0) && (itemNum == 5)) //Settings/debug Mode
    {

        if (debug == FALSE)
            debug = TRUE;
        else
            debug = FALSE;
    }

    if ((menuNum == 0) && (itemNum == 7)) //Project/Quit
    {
        ExitFromAnywhere();
    }
#endif

#ifndef BETA_VERSION
    if ((menuNum == 0) && (itemNum == 0)) //Project/New Game
    {
         //if a game is still in session, must veryif new game
         //close any previously opened windows before starting new game
        if (PickUpWin)
            CloseWindow(PickUpWin);

        if (CallWin)
            CloseWindow(CallWin);

        if (glist)
            FreeGadgets(glist);

        if (vi)
            FreeVisualInfo(vi);

        GamePlay();

    }

    if ((menuNum == 0) && (itemNum == 3)) //Project/About
    {
        About();

    }

    if ((menuNum == 0) && (itemNum == 1)) //Settings Program
    {
        OpensettingsWindow();

    }

    if ((menuNum == 0) && (itemNum == 5)) //Project/Quit
    {
        ExitFromAnywhere();
    }

#endif

}

void About(void)
{
    struct EasyStruct AboutReq =
    {
        sizeof(struct EasyStruct),
        0,
        "About Euchre!",
         VERS" by "AUTHOR", "DATE"\n",
        "Ok",
    };

    LONG answer;

    answer = EasyRequest(EuchreMain, &AboutReq, NULL);

    switch (answer)
    {
        case 0:
            ;
            break;
        default:
            ;
            break;
    }

} //end About()

void Mode(void)
{
    struct EasyStruct ModeReq =
    {
        sizeof (struct EasyStruct),
        0,
        "Bad Screen Mode",
        "Please set your desired screen mode",
        "Ok",
    };

    LONG confirm;

    confirm = EasyRequest(EuchreMain, &ModeReq, NULL);

    switch (confirm)
    {
        case (0):
            ;
            break;
        default:
            ;
            break;
    }
}
