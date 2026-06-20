//
//  To compile:
//  gcc -o StringExample StringExample.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip StringExample
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>
#include <images/label.h>

#include <classes/window.h>

#include <gadgets/layout.h>
#include <gadgets/string.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/label.h>
#include <proto/string.h>

#include <reaction/reaction_macros.h>
#include <clib/layout_protos.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    OBJ_TOPLAYOUT,
    OBJ_STRING_1,
    OBJ_STRING_2,
    OBJ_STRING_3,
    OBJ_STRING_4,
    OBJ_STRING_5,
    OBJ_STRING_6,
    OBJ_STRING_7,
    OBJ_STRING_8,
    OBJ_STRING_9,
    OBJ_STRING_10,
    OBJ_PRINT_OUT,
    OBJ_OUTPUT,
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define STRMAX 30

int8
    buffer_1[STRMAX],
    buffer_2[STRMAX],
    buffer_3[STRMAX],
    buffer_4[STRMAX],
    buffer_5[STRMAX],
    buffer_6[STRMAX],
    buffer_7[STRMAX],
    buffer_8[STRMAX],
    buffer_9[STRMAX],
    buffer_10[STRMAX];


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "String Editing Hooks",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_IconifyGadget,  TRUE,
        WINDOW_IconTitle,      "Iconified",
        WINDOW_AppPort,        AppPort,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         OBJ(OBJ_TOPLAYOUT) = VLayoutObject,
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild,    VLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " Input ",

                LAYOUT_AddChild,   OBJ(OBJ_STRING_1) = StringObject,
                    GA_ID,               OBJ_STRING_1,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_Buffer,      buffer_1,
                End,  // String
                Label(" CUSTOM "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_2) = StringObject,
                    GA_ID,               OBJ_STRING_2,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_PASSWORD,
                    STRINGA_Buffer,      buffer_2,
                End,  // String
                Label(" PASSWORD "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_3) = StringObject,
                    GA_ID,               OBJ_STRING_3,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_IPADDRESS,
                    STRINGA_Buffer,      buffer_3,
                End,  // String
                Label(" IPADDRESS "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_4) = StringObject,
                    GA_ID,               OBJ_STRING_4,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_FLOAT,
                    STRINGA_Buffer,      buffer_4,
                End,  // String
                Label(" FLOAT "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_5) = StringObject,
                    GA_ID,               OBJ_STRING_5,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_HEXADECIMAL,
                    STRINGA_Buffer,      buffer_5,
                End,  // String
                Label(" HEXADECIMAL "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_6) = StringObject,
                    GA_ID,               OBJ_STRING_6,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_TELEPHONE,
                    STRINGA_Buffer,      buffer_6,
                End,  // String
                Label(" TELEPHONE "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_7) = StringObject,
                    GA_ID,               OBJ_STRING_7,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_POSTALCODE,
                    STRINGA_Buffer,      buffer_7,
                End,  // String
                Label(" POSTALCODE "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_8) = StringObject,
                    GA_ID,               OBJ_STRING_8,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_AMOUNT,
                    STRINGA_Buffer,      buffer_8,
                End,  // String
                Label(" AMOUNT "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_9) = StringObject,
                    GA_ID,               OBJ_STRING_9,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_UPPERCASE,
                    STRINGA_Buffer,      buffer_9,
                End,  // String
                Label(" UPPERCASE "),

                LAYOUT_AddChild,   OBJ(OBJ_STRING_10) = StringObject,
                    GA_ID,               OBJ_STRING_10,
                    GA_RelVerify,        TRUE,
                    GA_TabCycle,         TRUE,
                    STRINGA_MinVisible,  10,
                    STRINGA_MaxChars,    STRMAX,
                    STRINGA_HookType,    SHK_HOTKEY,
                    STRINGA_Buffer,      buffer_10,
                End,  // String
                Label(" HOTKEY "),

            End,   // VLayout

            LAYOUT_AddChild,    HLayoutObject,
                LAYOUT_SpaceOuter,  TRUE,
                LAYOUT_BevelStyle,  BVS_GROUP,
                LAYOUT_Label,       " Output ",

                LAYOUT_AddChild,   Button("_Password",OBJ_PRINT_OUT),
                CHILD_WeightedHeight,   0,

                LAYOUT_AddChild,    OBJ(OBJ_OUTPUT) = ButtonObject,
                    GA_ID,          OBJ_OUTPUT,
                    GA_ReadOnly,    TRUE,
                End, // Button
                CHILD_WeightedHeight,   0,

            End,   // HLayout

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
        strcpy(buffer_1, "(default)");
        strcpy(buffer_2, "Password");

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

                //  Place curser in the first string gadget
   //         ILayout->ActivateLayoutGadget(GAD(OBJ_TOPLAYOUT),
   //             window,NULL,(uint32)OBJ(OBJ_STRING_1));

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
                                case OBJ_PRINT_OUT:
                                    IIntuition->SetGadgetAttrs(GAD(OBJ_OUTPUT),window,NULL,
                                        GA_Text, buffer_2, TAG_END);
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
        IExec->DeleteMsgPort(AppPort);
    }
}

