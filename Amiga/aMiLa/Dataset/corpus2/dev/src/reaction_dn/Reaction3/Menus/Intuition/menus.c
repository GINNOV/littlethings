//
//  To compile:
//  gcc -o menus menus.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip menus
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <libraries/gadtools.h>

#include <classes/window.h>
#include <gadgets/layout.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/window.h>
#include <proto/layout.h>

#include <reaction/reaction_macros.h>


Object *win;
struct Window *window;
struct MsgPort *AppPort;

enum
{
    OBJ_OUTPUT,
    OBJ_DISABLE,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

/*
    To get the Radio buttons working with each other, they
    have to be told which other ITEMs to exclude when clicked.

    As you can see from the array of NewMenu structs below,
    the nm_MutualExclude value will depend on where the Radio
    buttons appear in the menus.

    In "Radio 1", the 96 comes from adding the two Radio buttons
    below it together.  32 + 64 = 96
    "Radio 2" adds the one above it to the one below. 16 + 64 = 80
    "Radio 3" adds the two above it together.  16 + 32 = 48

    This also works with CheckBox ITEMs, the CheckBox of
    "Enable Radios" is linked to the "Disable Radios" CheckBox.
 */

struct NewMenu mynewmenu[] =
{
    { NM_TITLE, "Project ", 0, 0, 0, 0},
    { NM_ITEM, "New", 0, 0, 0, 0},
    { NM_ITEM, "Open", "O", 0, 0, 0},
    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},
    { NM_ITEM, "Save", "S", 0, 0, 0},
    { NM_ITEM, "Save as...", 0, 0, 0, 0},
    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},
    { NM_ITEM, "About...", "?", 0, 0, 0},
    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},
    { NM_ITEM, "Quit...", "Q", 0, 0, 0},

    { NM_TITLE, "Prefs ", 0, 0, 0, 0},
    { NM_ITEM, "Use Extras", 0, MENUTOGGLE | CHECKIT | CHECKED, 0, 0},    //  1
    { NM_ITEM, "Use SubMenus", 0, MENUTOGGLE | CHECKIT | CHECKED, 0, 0},  //  2
    { NM_ITEM, "Use Radios", 0, MENUTOGGLE | CHECKIT | CHECKED, 0, 0},    //  4
    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},                                  //  8
    { NM_ITEM, "Radio 1", 0, CHECKIT | CHECKED, 96, 0},                   //  16
    { NM_ITEM, "Radio 2", 0, CHECKIT, 80, 0},                             //  32
    { NM_ITEM, "Radio 3", 0, CHECKIT, 48, 0},                             //  64
    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},                                  //  128
    { NM_ITEM, "SubItems", 0, 0, 0, 0},                                   //  256

        { NM_SUB, "Enable Radios", 0, MENUTOGGLE | CHECKIT, 32, 0},             //  1
        { NM_SUB, NM_BARLABEL, 0, 0, 0, 0},                                     //  2
        { NM_SUB, "Radio 4", 0, NM_ITEMDISABLED | CHECKIT | CHECKED, 8, 0},     //  4
        { NM_SUB, "Radio 5", 0, NM_ITEMDISABLED | CHECKIT, 4, 0},               //  8
        { NM_SUB, NM_BARLABEL, 0, 0, 0, 0},                                     //  16
        { NM_SUB, "Disable Radios", 0, MENUTOGGLE | CHECKIT | CHECKED, 1, 0},   //  32

    { NM_ITEM, NM_BARLABEL, 0, 0, 0, 0},                                  //  512
    { NM_ITEM, "Save Prefs", 0, 0, 0, 0},                                 //  1024

    { NM_TITLE, "Extras ", 0, 0, 0, 0},
    { NM_ITEM, "Help", 0, 0, 0, 0},
    { NM_ITEM, "Arexx", 0, 0, 0, 0},

    {  NM_END, NULL, 0, 0, 0, 0}
};

enum
{
    PROJECT_MENU,
    PREFS_MENU,
    EXTRAS_MENU
};

BOOL console_enabled = FALSE;
BOOL processMenus(uint16 selection, BOOL done);


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Menus",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_InnerWidth,         150,
        WA_NewLookMenus,       TRUE,
        WINDOW_NewMenu,        mynewmenu,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,

            LAYOUT_AddChild,    OBJ(OBJ_OUTPUT) = ButtonObject,
                GA_ID,          OBJ_OUTPUT,
                GA_ReadOnly,    TRUE,
                GA_Text,        "Disabled",
            End, // Button
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,   Button("Disable / Enable console",OBJ_DISABLE),
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    End;  // WindowObject
}


int main()
{
    if (AppPort = IExec->CreateMsgPort())
    {
        win = make_window();
        if (window = RA_OpenWindow(win))
        {
            uint32
                sigmask     = 0,
                siggot      = 0,
                result      = 0;
            uint16
                code        = 0,
                selection;
            BOOL
                done        = FALSE;

            struct Menu *menuStrip;
            struct MenuItem *item;

            IIntuition->GetAttr(WINDOW_SigMask, win, &sigmask);
            while (!done)
            {
                siggot = IExec->Wait(sigmask | SIGBREAKF_CTRL_C);
                if (siggot & SIGBREAKF_CTRL_C) done = TRUE;
                while ((result = RA_HandleInput(win, &code)))
                {
                    switch(result & WMHI_CLASSMASK)
                    {
                        case WMHI_CLOSEWINDOW:
                            done = TRUE;
                            break;
                        case WMHI_GADGETUP:
                            switch (result & WMHI_GADGETMASK)
                            {
                                case OBJ_QUIT:
                                    done=TRUE;
                                    break;
                                case OBJ_DISABLE:
                                    console_enabled = (console_enabled == 0);
                                    if (console_enabled)
                                        {
                                        IIntuition->SetGadgetAttrs(GAD(OBJ_OUTPUT),window,NULL,
                                                                   GA_Text, "Enabled", TAG_END);
                                        }
                                    else
                                        {
                                        IIntuition->SetGadgetAttrs(GAD(OBJ_OUTPUT),window,NULL,
                                                                   GA_Text, "Disabled", TAG_END);
                                        }
                                    break;
                            }
                            break;
                        case WMHI_MENUPICK:
                            menuStrip = window->MenuStrip;
                            selection = code;
                            while ((selection != MENUNULL) && (done == FALSE))
                            {
                                item = IIntuition->ItemAddress(menuStrip, selection);
                                done = processMenus(selection, done);
                                selection = item->NextSelect;
                            }
                            break;
                        case WMHI_ICONIFY:
                            if (RA_Iconify(win)) window = NULL;
                            break;
                        case WMHI_UNICONIFY:
                            window = RA_OpenWindow(win);
                            break;
                    }
                }
            }
        }
        IIntuition->DisposeObject(win);
        IExec->DeleteMsgPort(AppPort);
    }
}


BOOL processMenus(uint16 selection, BOOL done)
{
    static BOOL extras_enabled = TRUE;
    static BOOL submenus_enabled = TRUE;
    static BOOL radios_enabled = TRUE;

    uint16 menuNum, itemNum, subNum;

    menuNum = MENUNUM(selection);
    itemNum = ITEMNUM(selection);
    subNum = SUBNUM(selection);

    switch (menuNum)
    {
        case PROJECT_MENU:
            switch (itemNum)
            {
                case 0: if (console_enabled) printf("New\n");
                    break;
                case 1: if (console_enabled) printf("Open\n");
                    break;
                    // Bar = 2
                case 3: if (console_enabled) printf("Save\n");
                    break;
                case 4: if (console_enabled) printf("Save as\n");
                    break;
                    // Bar = 5
                case 6: if (console_enabled) printf("About\n");
                    break;
                    // Bar = 7
                case 8: if (console_enabled) printf("Quit\n");
                    done = TRUE;
                    break;
            }
            break;
        case PREFS_MENU:
            switch (itemNum)
            {
                case 0: if (console_enabled) printf("Use Extras\n");
                    extras_enabled = (extras_enabled == 0);
                    if (extras_enabled)
                    {
                        IIntuition->OnMenu( window, FULLMENUNUM( EXTRAS_MENU, NOITEM, NOSUB));
                    }
                    else
                    {
                        IIntuition->OffMenu( window, FULLMENUNUM( EXTRAS_MENU, NOITEM, NOSUB));
                    }
                    if (console_enabled) printf("*** Extras menu %s ***\n",
                                    extras_enabled ? "enabled":"disabled");
                    break;
                case 1: if (console_enabled) printf("Use SubMenus\n");
                    submenus_enabled = (submenus_enabled == 0);
                    if (submenus_enabled)
                    {
                        IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 8, NOSUB));
                    }
                    else
                    {
                        IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 8, NOSUB));
                    }
                    if (console_enabled) printf("*** SubMenu %s ***\n",
                              submenus_enabled ? "enabled":"disabled");
                    break;
                case 2: if (console_enabled) printf("Use Radios\n");
                    radios_enabled = (radios_enabled == 0);
                    if (radios_enabled)
                    {
                        IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 4, NOSUB));
                        IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 5, NOSUB));
                        IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 6, NOSUB));
                    }
                    else
                    {
                        IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 4, NOSUB));
                        IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 5, NOSUB));
                        IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 6, NOSUB));
                    }
                    if (console_enabled) printf("*** Radio items %s ***\n",
                                    radios_enabled ? "enabled":"disabled");
                    break;
                    // Bar = 3
                case 4: if (console_enabled) printf("Radio 1\n");
                    break;
                case 5: if (console_enabled) printf("Radio 2\n");
                    break;
                case 6: if (console_enabled) printf("Radio 3\n");
                    break;
                    // Bar = 7
                case 8:                  //  SubItems
                    switch (subNum)
                    {
                        case 0: if (console_enabled) printf("Enable Radios 4 and 5\n");
                            IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 8, 2));
                            IIntuition->OnMenu( window, FULLMENUNUM( PREFS_MENU, 8, 3));
                            break;
                            // Bar = 1
                        case 2: if (console_enabled) printf("Radio 4\n");
                            break;
                        case 3: if (console_enabled) printf("Radio 5\n");
                            break;
                            // Bar = 4
                        case 5: if (console_enabled) printf("Disable Radios 4 and 5\n");
                            IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 8, 2));
                            IIntuition->OffMenu( window, FULLMENUNUM( PREFS_MENU, 8, 3));
                            break;
                    }
                    break;
                    // Bar = 9
                case 10: if (console_enabled) printf("Save Prefs\n");
                    break;
            }
            break;
        case EXTRAS_MENU: // 2:
            switch (itemNum)
            {
                case 0: if (console_enabled) printf("Help\n");
                    break;
                case 1: if (console_enabled) printf("Arexx\n");
                    break;
            }
            break;
    }
    return(done);
}


