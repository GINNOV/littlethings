//
//  To compile:
//  gcc -o IntegerExample IntegerExample.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip IntegerExample
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <images/label.h>
#include <intuition/icclass.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/fuelgauge.h>
#include <gadgets/integer.h>
#include <gadgets/slider.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/fuelgauge.h>
#include <proto/integer.h>
#include <proto/slider.h>
#include <proto/label.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    OBJ_INTEGER_1,
    OBJ_SLIDER,
    OBJ_INTEGER_2,
    OBJ_FUELGAUGE,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

struct TagItem slider_to_int_1[] =
{
    SLIDER_Level, INTEGER_Number, TAG_END
};

struct TagItem int_to_fuel[] =
{
    INTEGER_Number, FUELGAUGE_Level, TAG_END
};


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Integer Example",
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
            LAYOUT_SpaceOuter,   TRUE,
            LAYOUT_AddChild,    HLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,

                LAYOUT_AddChild,    VLayoutObject,
                    LAYOUT_SpaceOuter,  TRUE,
                    LAYOUT_BevelStyle,  BVS_GROUP,
                    LAYOUT_Label,       " Connected Integers ",

                    LAYOUT_AddChild,     OBJ(OBJ_INTEGER_1) = IntegerObject,
                        GA_ID,             OBJ_INTEGER_1,
                        GA_RelVerify,      TRUE,
                        GA_TabCycle,       TRUE,
                        INTEGER_Arrows,    FALSE,
                        INTEGER_MaxChars,  3,
                        INTEGER_Minimum,   0,
                        INTEGER_Maximum,   100,
                        INTEGER_Number,    50,
                    End,  // Integer
                    Label(" Integer 1 "),

                    LAYOUT_AddChild, OBJ(OBJ_SLIDER) = SliderObject,
                        GA_ID,               OBJ_SLIDER,
                        SLIDER_Max,          100,
                        SLIDER_Level,        50,
                        SLIDER_Orientation,  SLIDER_HORIZONTAL,
                        SLIDER_Ticks,        20,
                        SLIDER_ShortTicks,   TRUE,
                        ICA_TARGET,          OBJ(OBJ_INTEGER_1),
                        ICA_MAP,             slider_to_int_1,
                    End,  // Slider

                    LAYOUT_AddChild,     OBJ(OBJ_INTEGER_2) = IntegerObject,
                        GA_ID,             OBJ_INTEGER_2,
                        GA_RelVerify,      TRUE,
                        GA_TabCycle,       TRUE,
                        INTEGER_MaxChars,  3,
                        INTEGER_Minimum,   0,
                        INTEGER_Maximum,   100,
                        INTEGER_Number,    35,
                        INTEGER_SkipVal,   5,
                    End,  // Integer
                    Label(" Integer 2 "),

                End,  // VLayout

                LAYOUT_AddChild,  OBJ(OBJ_FUELGAUGE) = FuelGaugeObject,
                    GA_ID,            OBJ_FUELGAUGE,
                    FUELGAUGE_Orientation, FGORIENT_VERT,
                    FUELGAUGE_Ticks, FALSE, // TRUE,
                    FUELGAUGE_Level,  35,
                    FUELGAUGE_Max,    100,
                End,  // FuelGauge
                CHILD_WeightedWidth,   0,

            End,  // HLayout

            LAYOUT_AddChild,   Button("_Quit",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,  // VLayout
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

            // These attributes have to be set after opening the window,
            // because the fuelgauge was created after the integer.

            IIntuition->SetGadgetAttrs(GAD(OBJ_INTEGER_2),window, NULL,
                ICA_TARGET,         OBJ(OBJ_FUELGAUGE),
                ICA_MAP,            int_to_fuel,
                TAG_DONE);

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

