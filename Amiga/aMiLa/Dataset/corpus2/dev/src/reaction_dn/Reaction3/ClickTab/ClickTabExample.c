//
//  To compile:
//  gcc -o ClickTabExample ClickTabExample.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip ClickTabExample
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/clicktab.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/space.h>
#include <proto/clicktab.h>
#include <proto/label.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    // *** page 1 ***
    OBJ_BUT_1,
    OBJ_BUT_2,

    // *** page 2 ***
    OBJ_BUT_3,
    OBJ_BUT_4,

    // *** page 3a ***
    OBJ_BUT_5,
    OBJ_BUT_6,

    // *** page 3b ***
    OBJ_BUT_7,
    OBJ_BUT_8,

    // *** other ***
    OBJ_CLICKTAB_1,
    OBJ_CLICKTAB_2,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

STRPTR PageLabels_1[] = {"Tab 1", "Tab 1", "Tab 1", NULL};

STRPTR PageLabels_2[] = {"Tab 3a", "Tab 3b", NULL};

#define SPACE LAYOUT_AddChild, SpaceObject, End

Object *
make_window(void)
{
    Object
            *page1 = NULL,
            *page2 = NULL,
            *page3 = NULL,
            *page3a = NULL,
            *page3b = NULL;

        //  Some CHILD_WeightedHeight tags have been left
        //  out to demonstrate the effects of the tag.

    page1 = VLayoutObject,
                LAYOUT_BevelStyle,    BVS_GROUP,
                LAYOUT_Label,         "Page One",
                LAYOUT_AddChild,      Button("Button One",OBJ_BUT_1),
                CHILD_WeightedHeight, 0,
                LAYOUT_AddChild,      Button("Button Two",OBJ_BUT_2),
                CHILD_WeightedHeight, 0,
            End;  // VLayout

    page2 = VLayoutObject,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       "Page Two",
                LAYOUT_AddChild,    Button("Button Three",OBJ_BUT_3),
                LAYOUT_AddChild,    Button("Button Four",OBJ_BUT_4),
            End;  // VLayout

    page3a = VLayoutObject,
                 LAYOUT_AddChild,  HLayoutObject,
                     LAYOUT_AddChild,    Button("Button Five",OBJ_BUT_5),
                     LAYOUT_AddChild,    Button("Button Six",OBJ_BUT_6),
                 End,  // HLayout
                 CHILD_WeightedHeight, 0,
             End;  // VLayout

    page3b = VLayoutObject,
                 LAYOUT_AddChild, HLayoutObject,
                     LAYOUT_AddChild,    Button("Button Seven",OBJ_BUT_7),
                     SPACE,
                     LAYOUT_AddChild,    Button("Button Eight",OBJ_BUT_8),
                 End, // HLayout
             End;  // VLayout

    page3 = OBJ(OBJ_CLICKTAB_2) = ClickTabObject,
                GA_Text,             PageLabels_2,
                CLICKTAB_Current,    0,
                CLICKTAB_PageGroup,  PageObject,
                    PAGE_Add,        page3a,
                    PAGE_Add,        page3b,
                PageEnd,
            ClickTabEnd;

    OBJ(OBJ_CLICKTAB_1) = ClickTabObject,
        GA_Text,            PageLabels_1,
        CLICKTAB_Current,   0,
        CLICKTAB_PageGroup, PageObject,
            PAGE_Add,       page1,
            PAGE_Add,       page2,
            PAGE_Add,       page3,
        PageEnd,
    ClickTabEnd;

    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "ClickTab Example",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,

            LAYOUT_AddChild,       OBJ(OBJ_CLICKTAB_1),

            LAYOUT_AddChild,       Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,  0,

        End,   // VLayout
    WindowEnd;
}


int
main()
{
    struct Window *window;

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
            BOOL
                done        = FALSE;

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

