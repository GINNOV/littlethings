//
//  The first chooser is made from an array of strings,
//  The second chooser is built with an Exec List.
//
//  To compile:
//  gcc -o ChooserExample ChooserExample.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip ChooserExample
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/chooser.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/chooser.h>
#include <proto/label.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;
struct List chooserlist;

enum
{
    OBJ_CHOOSER_1,
    OBJ_CHOOSER_2,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

STRPTR chooser1[] =
{
    "8mm",
    "10mm",
    "12mm",
    "15mm",
    "22mm",
    "28mm",
    NULL
};

STRPTR chooserstrings[] =
{
    "Custom Fitting",
    "_",
    "End Feed",
    "Solder Ring",
    "Compression",
    "Push Fit",
    "Chewing Gum",
    NULL
};

BOOL make_chooser_list(struct List *, char **);
VOID free_chooser_list(struct List *list);


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Chooser Example",
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
            LAYOUT_SpaceOuter,  TRUE,
            LAYOUT_AddChild,    VLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       "Size & Connection Type",

                LAYOUT_AddChild,       OBJ(OBJ_CHOOSER_1) = ChooserObject,
                    GA_ID,               OBJ_CHOOSER_1,
                    GA_RelVerify,        TRUE,
                    CHOOSER_LabelArray,  chooser1,  // array of strings
                    CHOOSER_Selected,    0,
                End,  // Chooser
                CHILD_NominalSize, TRUE,
                Label(" _External Size:"),

                LAYOUT_AddChild,       OBJ(OBJ_CHOOSER_2) = ChooserObject,
                    GA_ID,               OBJ_CHOOSER_2,
                    GA_RelVerify,        TRUE,
                    CHOOSER_Labels,      &chooserlist,    // Exec list
                    CHOOSER_Selected,    2,
                End,  // Chooser
                CHILD_NominalSize, TRUE,
                Label(" _Connect With:"),

            End,   // VLayout
            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    End;  // WindowObject
}


int main()
{
    struct Window *window;
    BOOL ChooserOK = FALSE;

    ChooserOK = make_chooser_list( &chooserlist, chooserstrings );

    if ((AppPort = IExec->CreateMsgPort()) && (ChooserOK))
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
                                case OBJ_CHOOSER_1:
                   //                 printf("Selected: %d\n",code);
                                    break;
                                case OBJ_CHOOSER_2:
                   //                 printf("Selected: %d\n",code);
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
    }
    if (AppPort) IExec->DeleteMsgPort(AppPort);
    if (ChooserOK) free_chooser_list(&chooserlist);
}



BOOL make_chooser_list(struct List *list, char **strings)
{
    struct Node *node;

    IExec->NewList(list);

    while(*strings)
    {
        if(**strings == '_')
            {
            node = IChooser->AllocChooserNode(CNA_Separator, TRUE, TAG_DONE);
            }
        else
            node = IChooser->AllocChooserNode(CNA_Text, *strings, TAG_DONE);

        if(node)
            {
            IExec->AddTail(list, node);
            }
        else
            {
            printf("AllocChooserButtonNode() failed\n");
            return(FALSE);
            }

        strings++;
    }
    return(TRUE);
}


void free_chooser_list(struct List *list)
{
    struct Node *node, *nextnode;

    node = list->lh_Head;
    while(nextnode = node->ln_Succ)
        {
        IChooser->FreeChooserNode(node);
        node = nextnode;
        }
    IExec->NewList(list);
}

