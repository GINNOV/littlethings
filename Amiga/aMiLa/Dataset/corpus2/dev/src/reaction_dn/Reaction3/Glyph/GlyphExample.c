//
//  To compile:
//  gcc -o GlyphExample GlyphExample.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip GlyphExample
//

#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>

#include <images/label.h>
#include <images/glyph.h>

#include <classes/window.h>

#include <gadgets/layout.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/label.h>
#include <proto/glyph.h>
#include <proto/bevel.h>

#include <reaction/reaction_macros.h>


Object *win;

struct MsgPort *AppPort;

enum
{
    OBJ_QUIT,
    OBJ_NUM
};

Object *Objects[OBJ_NUM];
#define OBJ(x) Objects[x]
#define GAD(x) (struct Gadget *)Objects[x]

#define Glyph(id) LAYOUT_AddImage, GlyphObject, GLYPH_Glyph, id, End, \
                  CHILD_MinWidth, 12, CHILD_MinHeight, 12


Object *
make_window(void)
{
    return WindowObject,
        WA_ScreenTitle,        "Reaction Example",
        WA_Title,              "Glyphs",
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
            LAYOUT_SpaceOuter,     TRUE,

            LAYOUT_AddChild,       VLayoutObject,
                GA_BackFill,            NULL,
                LAYOUT_SpaceOuter,      TRUE,
                LAYOUT_BevelStyle,     BVS_GROUP,
                LAYOUT_Label,          " Glyphs ",

                Glyph(GLYPH_DOWNARROW),
                Label("Down Arrow:"),

                Glyph(GLYPH_UPARROW),
                Label("Up Arrow:"),

                Glyph(GLYPH_LEFTARROW),
                Label("Left Arrow:"),

                Glyph(GLYPH_RIGHTARROW),
                Label("Right Arrow:"),

                Glyph(GLYPH_DROPDOWN),
                Label("Drop Down:"),

                Glyph(GLYPH_CHECKMARK),
                Label("Check Mark:"),

                Glyph(GLYPH_RADIOBUTTON),
                Label("Radio Button:"),

                Glyph(GLYPH_POPUP),
                Label("Pop Up:"),

                Glyph(GLYPH_POPFONT),
                Label("Pop Font:"),

                Glyph(GLYPH_POPFILE),
                Label("Pop File:"),

                Glyph(GLYPH_POPDRAWER),
                Label("Pop Drawer:"),

                Glyph(GLYPH_POPSCREENMODE),
                Label(" Pop Screen Mode:"),

                Glyph(GLYPH_POPTIME),
                Label("Pop Time:"),

                Glyph(GLYPH_RETURNARROW),
                Label("Return Arrow:"),

            End,   // VLayout

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

