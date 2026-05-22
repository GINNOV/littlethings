//
//  To compile:
//  gcc -o SoundCheckBox SoundCheckBox.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip SoundCheckBox
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <libraries/gadtools.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/checkbox.h>
#include <gadgets/button.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/checkbox.h>
#include <proto/label.h>
#include <proto/space.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    OBJ_CHECKBOX1,
    OBJ_CHECKBOX2,
    OBJ_CHECKBOX3,
    OBJ_CHECKBOX4,
    OBJ_CHECKBOX5,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define SPACE LAYOUT_AddChild, SpaceObject, End


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "CheckBox Example",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WA_InnerHeight,        230,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,
            LAYOUT_SpaceOuter,   TRUE,

            LAYOUT_AddChild, HLayoutObject,
                LAYOUT_AddChild, OBJ(OBJ_CHECKBOX2) = CheckBoxObject,
                    GA_ID,         OBJ_CHECKBOX2,
                    GA_RelVerify,  TRUE,
                    GA_Text,       "Left Speaker",
                    CHECKBOX_TextPlace,  PLACETEXT_LEFT,
                End,  // CheckBox
                CHILD_NominalSize, TRUE,

                LAYOUT_AddChild, ButtonObject,
                    GA_ID,  OBJ_CHECKBOX1,
                    GA_Text,       "TV",
                End,  // Button
                CHILD_WeightedHeight,   0,
                CHILD_WeightedWidth,   0,

                LAYOUT_AddChild, OBJ(OBJ_CHECKBOX3) = CheckBoxObject,
                    GA_ID,               OBJ_CHECKBOX2,
                    GA_RelVerify,        TRUE,
                    GA_Text,             "Right Speaker",
                End,  // CheckBox
            End,   // HLayout

            SPACE,

            LAYOUT_AddChild, HLayoutObject,
                LAYOUT_AddChild, OBJ(OBJ_CHECKBOX4) = CheckBoxObject,
                    GA_ID,         OBJ_CHECKBOX4,
                    GA_RelVerify,  TRUE,
                    GA_Text,       "Left Rear Speaker",
                End,  // CheckBox
                CHILD_NominalSize, TRUE,

                LAYOUT_AddChild, OBJ(OBJ_CHECKBOX5) = CheckBoxObject,
                    GA_ID,               OBJ_CHECKBOX5,
                    GA_RelVerify,        TRUE,
                    GA_Text,             "Right Rear Speaker",
                    CHECKBOX_TextPlace,  PLACETEXT_LEFT,
                End,  // CheckBox
            End,   // HLayout

            LAYOUT_AddChild, VLayoutObject,
                LAYOUT_SpaceOuter,      TRUE,
                LAYOUT_VertAlignment,   LALIGN_CENTER,
                LAYOUT_HorizAlignment,  LALIGN_CENTER,
                LAYOUT_BevelStyle,      BVS_FIELD,
                GA_BackFill,            NULL,

                LAYOUT_AddImage, LabelObject,
                    LABEL_Text,  "\nLabels can be left or\n",
                    LABEL_Text,  "right of the checkbox.\n\n",
                    LABEL_Text,  "The text is also clickable.\n",
                End,  // Label
            End,   // VLayout

            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    End;  // WindowObject
}


int main()
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
