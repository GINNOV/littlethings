//
//  Please excuse the graphics.  :-)
//
//  To compile:
//  gcc -o imagebut imagebut.c -lraauto -lauto
//
//  To make the compiled code smaller:
//  strip imagebut
//


#include <exec/exec.h>
#include <intuition/intuition.h>
#include <dos/dos.h>

#include <classes/window.h>

#include <images/bitmap.h>

#include <gadgets/layout.h>
#include <gadgets/button.h>

#include <proto/exec.h>
#include <proto/intuition.h>

#include <proto/window.h>
#include <proto/layout.h>
#include <proto/bitmap.h>

#include <reaction/reaction_macros.h>


Object *win;
struct Screen *screen;

enum
{
    OBJ_IBUT_1,
    OBJ_SEL,
    OBJ_UNSEL,
    OBJ_IBUT_2,
    OBJ_GHOST,
    OBJ_UNGHOST,
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
        WA_Title,              "Image buttons",
        WA_DragBar,            TRUE,
        WA_CloseGadget,        TRUE,
        WA_SizeGadget,         TRUE,
        WA_DepthGadget,        TRUE,
        WA_Activate,           TRUE,
        WINDOW_Position,       WPOS_CENTERSCREEN,
        WINDOW_Layout,         VLayoutObject,

            LAYOUT_AddChild,  LayoutObject,
                LAYOUT_VertAlignment,  LALIGN_CENTER,
                LAYOUT_HorizAlignment, LALIGN_CENTER,

                LAYOUT_AddChild,  OBJ(OBJ_IBUT_1) = ButtonObject,
                    BUTTON_BevelStyle,   BVS_NONE,
                    BUTTON_Transparent,  TRUE,
                    BUTTON_RenderImage,  OBJ(OBJ_SEL) = BitMapObject,
                        BITMAP_SourceFile,         "images/unsel.gif",
                        BITMAP_DisabledSourceFile, "images/ghosted.gif",
                        BITMAP_Screen,             screen,
                        BITMAP_Masking,            TRUE,
                    BitMapEnd,
                    BUTTON_SelectImage,  OBJ(OBJ_UNSEL) = BitMapObject,
                        BITMAP_SourceFile,  "images/sel.gif",
                        BITMAP_Screen,      screen,
                        BITMAP_Masking,     TRUE,
                    BitMapEnd,
                ButtonEnd,
                CHILD_WeightedWidth, 0,
                CHILD_WeightedHeight, 0,

            LayoutEnd,


            LAYOUT_AddChild,  LayoutObject,
                LAYOUT_HorizAlignment, LALIGN_CENTER,

                LAYOUT_AddChild,  OBJ(OBJ_IBUT_2) = ButtonObject,
                    GA_ID,               OBJ_IBUT_2,
                    GA_RelVerify,        TRUE,
                    BUTTON_BevelStyle,   BVS_NONE,
                    BUTTON_Transparent,  TRUE,
                    BUTTON_PushButton,   TRUE,
                    BUTTON_RenderImage,  OBJ(OBJ_GHOST) = BitMapObject,
                        BITMAP_SourceFile,   "images/ghost.gif",
                        BITMAP_Screen,       screen,
                        BITMAP_Masking,      TRUE,
                    BitMapEnd,
                    BUTTON_SelectImage,  OBJ(OBJ_UNGHOST) = BitMapObject,
                        BITMAP_SourceFile,  "images/unghost.gif",
                        BITMAP_Screen,      screen,
                        BITMAP_Masking,     TRUE,
                    BitMapEnd,
                ButtonEnd,
                CHILD_WeightedWidth, 0,

            LayoutEnd,
            CHILD_WeightedHeight, 0,

        End,   // VLayout
    WindowEnd;
}


int
main()
{
    struct Window *window;

    if (screen=IIntuition->LockPubScreen(NULL))
    {
        win = make_window();
        if (window = RA_OpenWindow(win))
        {
            uint32
                sigmask     = 0,
                siggot      = 0,
                result      = 0;
            uint16
                code        = 0,
                ghost       = 0;
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
                                case OBJ_IBUT_2:
                                    ghost = (ghost == 0);
                                    IIntuition->SetGadgetAttrs( GAD(OBJ_IBUT_1), window, NULL,
                                        GA_Disabled, ghost, TAG_END );
                                    break;
                            }
                            break;
                    }
                }
            }
        }
        if (win) IIntuition->DisposeObject(win);
        if (OBJ(OBJ_UNGHOST)) IIntuition->DisposeObject(OBJ(OBJ_UNGHOST));
        if (OBJ(OBJ_GHOST)) IIntuition->DisposeObject(OBJ(OBJ_GHOST));
        if (OBJ(OBJ_UNSEL)) IIntuition->DisposeObject(OBJ(OBJ_UNSEL));
        if (OBJ(OBJ_SEL)) IIntuition->DisposeObject(OBJ(OBJ_SEL));
        IIntuition->UnlockPubScreen(NULL,screen);
    }
}

