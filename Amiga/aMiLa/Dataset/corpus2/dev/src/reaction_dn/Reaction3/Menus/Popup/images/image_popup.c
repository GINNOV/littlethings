//
//  To compile:
//  gcc -o image_popup image_popup.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip image_popup
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>

#include <classes/window.h>
#include <classes/popupmenu.h>
#include <gadgets/layout.h>
#include <images/bitmap.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/window.h>
#include <proto/popupmenu.h>
#include <proto/layout.h>
#include <proto/bitmap.h>

#include <reaction/reaction_macros.h>


#define myPMMENU()   IIntuition->NewObject( IPopupMenu->POPUPMENU_GetClass(), NULL,\
        PMA_AddItem, (ULONG) IIntuition->NewObject( IPopupMenu->POPUPMENU_GetItemClass(), NULL

struct Library  *PopupMenuBase = NULL;
struct PopupMenuIFace *IPopupMenu = NULL;

Object *win;
struct Window *window;
struct Hook MenuHandler;
struct MsgPort *AppPort;

Object *image_1,
       *image_2;

enum
{
    OBJ_OUTPUT,
    OBJ_DISABLE,
    OBJ_STICKY,
    OBJ_QUIT,
    OBJ_MENU,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

enum
{
    MENU_NEW = 1,
    MENU_OPEN,
    MENU_SAVE,
    MENU_SAVE_AS,
    MENU_SUB_1,
    MENU_SUB_2,
    MENU_QUIT
};

BOOL done            = FALSE;
BOOL console_enabled = FALSE;

// ***** prototypes *****

BOOL startup(void);
void shutdown(void);
uint32 MenuHandlerFunc( struct Hook *hook, Object *item, APTR reserved);


void makeMenu(void)
{
    image_1 = BitMapObject,
                  BITMAP_SourceFile,    "images/title.gif",
                  BITMAP_Screen,        window->WScreen,
                  BITMAP_Masking,       TRUE,
              End;

    image_2 = BitMapObject,
                  BITMAP_SourceFile,    "images/small.gif",
                  BITMAP_SelectSourceFile, "images/smallsel.gif",
                  BITMAP_Screen,        window->WScreen,
                  BITMAP_Masking,       TRUE,
              End;

//    OBJ(OBJ_MENU) = PMMENU("Menu Title "),
    OBJ(OBJ_MENU) = myPMMENU(), PMIA_Image, image_1, PMIA_ReadOnly, TRUE, End, PMBAR(),End,
                        PMA_MenuHandler, &MenuHandler,
                        PMITEM("New"),PMIA_ID,MENU_NEW, PMIA_Icon, image_2, End,
                        PMITEM("Open"),PMIA_ID,MENU_OPEN, PMIA_Icon, image_2, End,
                        PMBAR(),End,
                        PMITEM("Save"),PMIA_ID,MENU_SAVE, PMIA_Icon, image_2, End,
                        PMITEM("Save as"),PMIA_ID,MENU_SAVE_AS, PMIA_Icon, image_2, End,
                        PMBAR(),End,
                        PMITEM("Sub Menus"), PMIA_Icon, image_2,
                            PMSUBMENU("Sub Menu Title"),
                                PMITEM("sub 1"), PMIA_ID,MENU_SUB_1, PMIA_Icon, image_2, End,
                                PMITEM("sub 2"), PMIA_ID,MENU_SUB_2, PMIA_Icon, image_2, End,
                            End,
                        End,
                        PMBAR(),End,
                        PMITEM("Quit"),PMIA_ID,MENU_QUIT, PMIA_Icon, image_2, End,
                    End;
}

Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "PopupMenu",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_RMBTrap,            TRUE,
        WA_IDCMP,              IDCMP_MOUSEBUTTONS,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,

            LAYOUT_AddChild,    OBJ(OBJ_OUTPUT) = ButtonObject,
                GA_ID,          OBJ_OUTPUT,
                GA_ReadOnly,    TRUE,
                GA_Text,        "Disabled",
            ButtonEnd,
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,   Button("Disable / Enable console",OBJ_DISABLE),
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,   Button("Sticky menu",OBJ_STICKY),
            CHILD_WeightedHeight,   0,

            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    WindowEnd;
}


int main()
{
    if (startup() == FALSE)
    {
        printf("Failed to open a library\n");
        shutdown();
        return(RETURN_WARN);
    }

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
                code        = 0;

            MenuHandler.h_Entry=(HOOKFUNC)MenuHandlerFunc;

            makeMenu();

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
                        case WMHI_MOUSEBUTTONS:
                            if(code==MENUDOWN)
                            {
                                IIntuition->IDoMethod(OBJ(OBJ_MENU), PM_OPEN, window);
                            }
                            break;
                        case WMHI_GADGETUP:
                            switch (result & WMHI_GADGETMASK)
                            {
                                case OBJ_DISABLE:
                                    console_enabled = (console_enabled == 0);
                                    IIntuition->SetGadgetAttrs(GAD(OBJ_OUTPUT),window,NULL,
                                      GA_Text, console_enabled ? "enabled":"disabled", TAG_END);
                                    break;
                                case OBJ_STICKY:
                                    IIntuition->IDoMethod(OBJ(OBJ_MENU), PM_OPEN, window);
                                    break;
                                case OBJ_QUIT:
                                    done=TRUE;
                                    break;
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
        IIntuition->DisposeObject(OBJ(OBJ_MENU));
        IIntuition->DisposeObject(image_2);
        IIntuition->DisposeObject(image_1);
        IExec->DeleteMsgPort(AppPort);
    }
    shutdown();
}


uint32 MenuHandlerFunc( struct Hook *hook, Object *item, APTR reserved)
{
    int32 item_ID = 0;

    if (IIntuition->GetAttr(PMIA_ID, item, &item_ID))
    {
        switch (item_ID)
        {
            case MENU_NEW: if (console_enabled) printf("New\n");
                break;
            case MENU_OPEN: if (console_enabled) printf("Open\n");
                break;
            case MENU_SAVE: if (console_enabled) printf("Save\n");
                break;
            case MENU_SAVE_AS: if (console_enabled) printf("Save as\n");
                break;
            case MENU_SUB_1: if (console_enabled) printf("Sub 1\n");
                break;
            case MENU_SUB_2: if (console_enabled) printf("Sub 2\n");
                break;
            case MENU_QUIT: if (console_enabled) printf("Quit\n");
                done = TRUE;
                break;
        }
    }
    return 0;
}


BOOL startup(void)
{
    BOOL retval = FALSE;
    if (PopupMenuBase = IExec->OpenLibrary( "popupmenu.class", 0 ))
    {
        if (IPopupMenu = (struct PopupMenuIFace *) IExec->GetInterface( PopupMenuBase, "main", 1, NULL ))
        {
            retval = TRUE;
        }
     }
    return(retval);
}


void shutdown(void)
{
    if (IPopupMenu) IExec->DropInterface( (struct Interface *) IPopupMenu );
    if (PopupMenuBase) IExec->CloseLibrary( PopupMenuBase );
}



