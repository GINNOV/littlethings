//
//  To compile:
//  gcc -o Hierarchical Hierarchical.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip Hierarchical
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/listbrowser.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/listbrowser.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;
struct List listbrowser_list;
struct ColumnInfo columninfo[] =
{
    { 100, " Column Header", 0 },
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

STRPTR list_strings[] =
{
    "HASCHILDREN", "HIDDEN", "HIDDEN", "HASCHILDREN"," HIDDEN | HASCHILDREN",
     "HIDDEN", "HIDDEN", "HIDDEN | HASCHILDREN", "HIDDEN", "HIDDEN",
     "HASCHILDREN.", "HIDDEN | HASCHILDREN", "HIDDEN", "HIDDEN",
    "HIDDEN | HASCHILDREN", "HIDDEN | HASCHILDREN", "HIDDEN", "HIDDEN",
    "HIDDEN | HASCHILDREN", "HIDDEN", "HIDDEN", NULL
};

int32 generation[] =
{
    1, 2, 2, 1, 2, 3, 3, 2, 3, 3, 1, 2, 3, 3, 2, 3, 4, 4, 3, 4, 4
};

int32 flags[] =                    //  ListBrowser node flags.
{                                      //  Generation of nodes.
    LBFLG_HASCHILDREN,                 //  1
    LBFLG_HIDDEN,                      //  2
    LBFLG_HIDDEN,                      //  2
    LBFLG_HASCHILDREN,                 //  1
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  2
    LBFLG_HIDDEN,                      //  3
    LBFLG_HIDDEN,                      //  3
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  2
    LBFLG_HIDDEN,                      //  3
    LBFLG_HIDDEN,                      //  3
    LBFLG_HASCHILDREN,                 //  1
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  2
    LBFLG_HIDDEN,                      //  3
    LBFLG_HIDDEN,                      //  3
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  2
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  3
    LBFLG_HIDDEN,                      //  4
    LBFLG_HIDDEN,                      //  4
    LBFLG_HIDDEN | LBFLG_HASCHILDREN,  //  3
    LBFLG_HIDDEN,                      //  4
    LBFLG_HIDDEN                       //  4
};

uint16 hide_data[28] =
{
        //  Plane 0
        0x0000, 0xC000, 0xC000, 0xC002,
        0xC203, 0xC203, 0xC203, 0xC203,
        0x6203, 0x3203, 0x1A03, 0x0FFF,
        0x0FFF, 0x0600,
        //  Plane 1
        0x2000, 0x7000, 0x781C, 0x6CFE,
        0x77F6, 0x7FDE, 0x6F76, 0x77DE,
        0x3F72, 0x1FCE, 0x0FBE, 0x07FE,
        0x0600, 0x0000
};

struct Image hide_image =
{
    0,0, 16,14, 2, &hide_data[0], 0x3,0x0, NULL
};

uint16 show_data[28] =
{
        //  Plane 0
        0x0180, 0x07C0, 0x1FE0, 0x7F70,
        0xFF78, 0xBF7C, 0xDF7E, 0x6C7F,
        0x37FC, 0x1BF1, 0x0DC6, 0x0618,
        0x0260, 0x0180,
        //  Plane 1
        0x0000, 0x0180, 0x07C0, 0x1FE0,
        0x7F70, 0x3FF8, 0x5F7C, 0x2EFC,
        0x17F2, 0x0BCE, 0x0538, 0x02E0,
        0x0080, 0x0000
};

struct Image show_image =
{
    0,0, 16,14, 2, &show_data[0], 0x3,0x0, NULL
};

uint16 leaf_data[28] =
{
    //  Plane 0
    0xFF00,0x8180,0xA940,0x8120,0xA9F0,0x8030,0xAAB0,0x8030,
    0xAAB0,0x8030,0xAAB0,0x8030,0xFFF0,0x7FF0,
    //  Plane 1
    0x0000,0x7E00,0x5680,0x7EC0,0x5600,0x7FC0,0x5540,0x7FC0,
    0x5540,0x7FC0,0x5540,0x7FC0,0x0000,0x0000
};

struct Image leaf_image =
{
    0, 0,            //  LeftEdge, TopEdge
    12, 14, 2,       //  Width, Height, Depth
    leaf_data,       //  ImageData
    0x0003, 0x0000,  //  PlanePick, PlaneOnOff
    NULL             //  NextImage
};

BOOL make_browserlist(struct List *, char **, int32 *, int32 *);
VOID free_browserlist(struct List *);


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Hierarchical",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_InnerWidth,         230,
        WA_InnerHeight,        400,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_AddChild, OBJ(OBJ_LISTBROWSER) = ListBrowserObject,
                GA_ID,                     OBJ_LISTBROWSER,
                GA_RelVerify,              TRUE,
                LISTBROWSER_Hierarchical,  TRUE,
                LISTBROWSER_HideImage,     &hide_image,  // comment out to see default
                LISTBROWSER_ShowImage,     &show_image,  // comment out to see default
                LISTBROWSER_LeafImage,     &leaf_image,  // comment out to see default
                LISTBROWSER_Labels,        &listbrowser_list,
                LISTBROWSER_ColumnInfo,    &columninfo,
                LISTBROWSER_ColumnTitles,  TRUE,
        //        LISTBROWSER_ShowSelected,  TRUE,  // uncomment to leave selected
            End,  // ListBrowser
            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,
        End,   // VLayout
    End;  // WindowObject
}


BOOL make_browserlist(struct List *list, char **string, int32 *gen_list, int32 *flags)
{
    struct Node *node;
    int16 nodenumber = 0;

    IExec->NewList(list);
    while (*string)
    {
        if (node = IListBrowser->AllocListBrowserNode(1,
            LBNA_Generation, gen_list[nodenumber],
            LBNA_Flags, flags[nodenumber],
            LBNA_Column, 0,
                LBNCA_Text, *string,
            TAG_DONE))
        {
            IExec->AddTail(list, node);
        }
        else
        {
            printf(" AllocListBrowserNode() failed\n");
            return(FALSE);
        }
        string++;
        nodenumber++;
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


int main()
{
    struct Window *window;

    if (AppPort = IExec->CreateMsgPort())
    {
        if (make_browserlist(&listbrowser_list, list_strings, generation, flags))
        {
            win = make_window();
            if (window = RA_OpenWindow(win))
            {
                uint32
                    sigmask     = 0,
                    siggot      = 0,
                    result      = 0,
                    retval      = 0;
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
                                    case OBJ_LISTBROWSER:
                                        IIntuition->GetAttr(LISTBROWSER_Selected,OBJ(OBJ_LISTBROWSER),&retval);
                          //              printf("Entry %d clicked\n",retval);
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
            free_browserlist(&listbrowser_list);
        }
        IExec->DeleteMsgPort(AppPort);
    }
}

