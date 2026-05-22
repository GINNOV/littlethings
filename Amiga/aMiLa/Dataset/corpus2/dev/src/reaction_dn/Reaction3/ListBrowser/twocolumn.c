//
//  To compile:
//  gcc -o twocolumn twocolumn.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip twocolumn
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <intuition/gui.h>
#include <dos/dos.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/listbrowser.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/label.h>
#include <proto/listbrowser.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;
struct List listbrowser_list;
struct ColumnInfo columninfo[] =
{
    { 80, " GUI Attributes", 0 },
    { 20, " BOOL", 0 },
    { -1, (STRPTR)~0, -1 }
};

enum
{
    OBJ_LISTBROWSER,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define NUMBOOLS 13

uint32 tagdatas[NUMBOOLS];

int32 tags[] =
{
    GUIA_ScreenDragging,
    GUIA_OffScreenDragging,
    GUIA_OffScreenSizing,
    GUIA_WindowPropLook,
    GUIA_WindowPropKnobColor,
    GUIA_WindowPropBorder,
    GUIA_PropKnobColor,
    GUIA_PropBorder,
    GUIA_MenuDropShadows,
    GUIA_MenuTransparency,
    GUIA_EvenRequesterButtons,
    GUIA_AutomaticEdgesContrast,
    GUIA_RealShading
};

STRPTR list_strings[] =
{
    " GUIA_ScreenDragging",
    " GUIA_OffScreenDragging",
    " GUIA_OffScreenSizing",
    " GUIA_WindowPropLook",
    " GUIA_WindowPropKnobColor",
    " GUIA_WindowPropBorder",
    " GUIA_PropKnobColor",
    " GUIA_PropBorder",
    " GUIA_MenuDropShadows",
    " GUIA_MenuTransparency",
    " GUIA_EvenRequesterButtons",
    " GUIA_AutomaticEdgesContrast ",
    " GUIA_RealShading",
    NULL
};

BOOL GetGuiData(void);
BOOL make_browserlist(struct List *, char **, uint32 *);
VOID free_browserlist(struct List *);


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Two Column Example",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_InnerWidth,         260,
        WA_InnerHeight,        300,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_SpaceOuter,     TRUE,
            LAYOUT_AddChild,    VLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " GUI Tags ",

                LAYOUT_AddChild, OBJ(OBJ_LISTBROWSER) = ListBrowserObject,
                    GA_ID,                     OBJ_LISTBROWSER,
                    GA_RelVerify,              TRUE,
                    LISTBROWSER_AutoFit,       TRUE,
                    LISTBROWSER_Labels,        &listbrowser_list,
                    LISTBROWSER_ColumnInfo,    &columninfo,
                    LISTBROWSER_ColumnTitles,  TRUE,
                End,  // ListBrowser

                LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
                CHILD_WeightedHeight,   0,

            End,   // VLayout
        End,   // VLayout
    End;  // WindowObject
}


int
main()
{
    struct Window *window;

    if (AppPort = IExec->CreateMsgPort())
    {
        if (!(GetGuiData())) goto out;
        if (make_browserlist(&listbrowser_list, list_strings, tagdatas))
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
            free_browserlist(&listbrowser_list);
        }
out:    IExec->DeleteMsgPort(AppPort);
    }
}


BOOL GetGuiData()
{
    struct Screen *screen = NULL;
    int i;

    if (screen = IIntuition->LockPubScreen(NULL))
    {
        struct DrawInfo *drinfo = NULL;
        if (drinfo = IIntuition->GetScreenDrawInfo(screen))
        {
            for (i=0; i<NUMBOOLS; i++)
            {
                IIntuition->GetGUIAttrs(NULL,drinfo,
                    tags[i], &tagdatas[i],
                    TAG_END);
            }
            IIntuition->FreeScreenDrawInfo(screen, drinfo);
        }
        else
        {
            printf("ERROR: Couldn't get DrawInfo\n");
            IIntuition->UnlockPubScreen(0, screen);
            return(FALSE);
        }
        IIntuition->UnlockPubScreen(0, screen);
        return(TRUE);
    }
    else
    {
        printf("ERROR: Couldn't lock public screen\n");
        return(FALSE);
    }
}


BOOL make_browserlist(struct List *list, char **tagstring, uint32 *bools)
{
    struct Node *node;
    uint16 num = 0;
    STRPTR truefalse[] = {" FALSE"," TRUE",NULL};

    IExec->NewList(list);
    while (*tagstring)
    {
        if (node = IListBrowser->AllocListBrowserNode(2,
            LBNA_Column, 0,
                LBNCA_Text, *tagstring,
            LBNA_Column, 1,
                LBNCA_Text, truefalse[bools[num]],
            TAG_DONE))
        {
            IExec->AddTail(list, node);
        }
        else
        {
            printf(" AllocListBrowserNode() failed\n");
            return(FALSE);
        }
        tagstring++;
        num ++;
    }
    return(TRUE);
}


VOID free_browserlist(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while (nextnode = node->ln_Succ)
    {
        IListBrowser->FreeListBrowserNode(node);
        node = nextnode;
    }
    IExec->NewList(list);
}


