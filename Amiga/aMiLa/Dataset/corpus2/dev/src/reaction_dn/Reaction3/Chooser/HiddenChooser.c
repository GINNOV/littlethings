//
//  To compile:
//  gcc -o HiddenChooser HiddenChooser.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip HiddenChooser
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <intuition/icclass.h>
#include <dos/dos.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/chooser.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/utility.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/chooser.h>
#include <proto/label.h>

#include <reaction/reaction_macros.h>


Object *win = NULL;

struct MsgPort *AppPort;
struct Hook idcmphook;

enum
{
    OBJ_SELECTED,
    OBJ_CHOOSE,
    OBJ_HIDDEN_CHOOSER,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

STRPTR hidden_strings[] =
{
    "Index",
    "Chapter One",
    "Chapter Two",
    "Chapter Three",
    NULL
};

uint16 page_data[28] =     //  for chooser image
{
    //  Plane 0
    0xFF00,0x8180,0xA940,0x8120,0xA9F0,0x8030,0xAAB0,0x8030,
    0xAAB0,0x8030,0xAAB0,0x8030,0xFFF0,0x7FF0,
    //  Plane 1
    0x0000,0x7E00,0x5680,0x7EC0,0x5600,0x7FC0,0x5540,0x7FC0,
    0x5540,0x7FC0,0x5540,0x7FC0,0x0000,0x0000
};

struct Image page_image =
{
    0, 0,             // LeftEdge, TopEdge
    13, 14, 2,        // Width, Height, Depth
    page_data,        // ImageData
    0x0003, 0x0000,   // PlanePick, PlaneOnOff
    NULL              // NextImage
};


void IDCMPFunc(struct Hook *hook,Object *wobj,struct IntuiMessage *Msg)
{
    struct Window *window = Msg->IDCMPWindow;
    uint32 active;

    if (Msg->Class == IDCMP_IDCMPUPDATE)
    {
        if (IUtility->GetTagData(GA_ID, 0, Msg->IAddress) == OBJ_HIDDEN_CHOOSER)
        {
            active = IUtility->GetTagData(CHOOSER_Active, -1, Msg->IAddress);
   //         printf("chooser picked = %d\n",active);
            IIntuition->SetGadgetAttrs( GAD(OBJ_SELECTED), window, NULL,
                GA_Text, hidden_strings[active], TAG_END);
        }
    }
}


Object *
make_window(void)
{
    //  The hidden chooser is not attached to the window
    //  object, and has to be disposed of separately.

    OBJ(OBJ_HIDDEN_CHOOSER) = ChooserObject,
        GA_ID,                  OBJ_HIDDEN_CHOOSER,
        GA_RelVerify,           TRUE,
        CHOOSER_LabelArray,     hidden_strings,
        CHOOSER_DropDown,       TRUE,
        CHOOSER_AutoFit,        TRUE,
        CHOOSER_Hidden,         TRUE,
        ICA_TARGET,             ICTARGET_IDCMP,
    End;  // Chooser

    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Hidden",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_InnerWidth,         160,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_IDCMPHook,      &idcmphook,
        WINDOW_IDCMPHookBits,  IDCMP_IDCMPUPDATE,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_SpaceOuter,  TRUE,
            LAYOUT_AddChild,   VLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       "Bookmarks",

                LAYOUT_AddChild, HLayoutObject,
                    LAYOUT_AddChild,    OBJ(OBJ_SELECTED) = ButtonObject,
                        GA_ID,          OBJ_SELECTED,
                        GA_ReadOnly,    TRUE,
                    End, // Button

                    LAYOUT_AddChild,    OBJ(OBJ_CHOOSE) = ButtonObject,
                        GA_ID,          OBJ_CHOOSE,
                        GA_RelVerify,   TRUE,
                        GA_Image,       &page_image,
                    End, // Button
                    CHILD_WeightedWidth, 0,
                End, // HLayout

                LAYOUT_AddChild,   VLayoutObject,
                    LAYOUT_SpaceOuter,      TRUE,
                    LAYOUT_VertAlignment,   LALIGN_CENTER,
                    LAYOUT_HorizAlignment,  LALIGN_CENTER,
                    LAYOUT_BevelStyle,      BVS_FIELD,
                    GA_BackFill,            NULL,
                    LAYOUT_AddImage, LabelObject,
                        LABEL_Text, "\n Once upon a time ..... ",
                        LABEL_Text, "\n\n\n The End.\n",
                    End,  // Label
                End, // VLayout

            End, // VLayout
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    End;  // WindowObject
}


int main()
{
    struct Window *window;

    RA_SetUpHook(idcmphook, IDCMPFunc, NULL);
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
                                case OBJ_CHOOSE:
                                    IIntuition->ActivateGadget(GAD(OBJ_HIDDEN_CHOOSER), window, NULL);
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
        if (win) IIntuition->DisposeObject(win);

            //  The hidden chooser isn't attached to anything,
            //  so we must dispose of it ourselves...

        IIntuition->DisposeObject(OBJ(OBJ_HIDDEN_CHOOSER));
        IExec->DeleteMsgPort(AppPort);
    }
}
