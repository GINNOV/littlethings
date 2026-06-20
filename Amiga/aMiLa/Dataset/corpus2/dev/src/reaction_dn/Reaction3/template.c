//
//  To compile:
//  gcc -o template template.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip template
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <intuition/icclass.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#define ALL_REACTION_CLASSES
#define ALL_REACTION_MACROS
#include <reaction/reaction.h>

#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    OBJ_QUIT = 1,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Example",
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

            LAYOUT_AddChild,   Button("* * * _Quit * * *",OBJ_QUIT),
            CHILD_WeightedHeight,   0,

        End,   // VLayout
    WindowEnd;
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

