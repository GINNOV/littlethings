// imagebutton.c
// Public Domain by Matthias Rustler
// Use at your own risk

// A ReAction Button with 2 images

#include <stdio.h>
#include <stdlib.h>

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <intuition/classusr.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <clib/alib_protos.h>

struct IntuitionBase *IntuitionBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *ButtonBase;
struct Library *BitMapBase;
struct Screen  *screen;

char * vers="\0$VER: ImageButton 0.1 (2.3.2003)";

BOOL alllibrariesopen = FALSE;
Object *window, *layout;

void cleanexit(char *str);

int main(void)
{
    struct Window *intuiwin=NULL;
    ULONG windowsignal,receivedsignal,result,code;
    BOOL end;

    if ( ! (IntuitionBase= (struct IntuitionBase*)OpenLibrary("intuition.library",39)))
        cleanexit("Can't open intuition.library");

    if ( ! (WindowBase= OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (LayoutBase= OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    if ( ! (ButtonBase= OpenLibrary("gadgets/button.gadget",44)))
        cleanexit("Can't open button.gadget");

    if ( ! (BitMapBase= OpenLibrary("images/bitmap.image",44)))
        cleanexit("Can't open drawlist.image");

    alllibrariesopen = TRUE;

    if( ! (screen=LockPubScreen(NULL)))
        cleanexit("Can't lock pubscreen");

    window = WindowObject,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WA_Activate, TRUE,
        WA_Title, "Button Image Demo",
        WA_DragBar, TRUE,
        WA_CloseGadget, TRUE,
        WA_DepthGadget, TRUE,
        WA_SizeGadget, TRUE,
        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP,
        WINDOW_Layout, HLayoutObject,
            LAYOUT_DeferLayout, TRUE,
            LAYOUT_SpaceInner, TRUE,
            LAYOUT_SpaceOuter, TRUE,

            LAYOUT_AddChild, ButtonObject,
                BUTTON_RenderImage, BitMapObject,
                    BITMAP_SourceFile , "pic1.iff" ,
                    BITMAP_Screen,screen,
                BitMapEnd,
                BUTTON_SelectImage, BitMapObject,
                    BITMAP_SourceFile , "pic2.iff" ,
                    BITMAP_Screen,screen,
                BitMapEnd,
            ButtonEnd,
            CHILD_WeightedWidth, 0,
            CHILD_WeightedHeight, 0,
       LayoutEnd,
    WindowEnd;

    if ( ! (window))
        cleanexit("Can't create window");

    if ( ! (intuiwin = (struct Window *) DoMethod(window,WM_OPEN)))
        cleanexit("Can't open window");

    GetAttr(WINDOW_SigMask,window,&windowsignal);

    end = FALSE;
    while (!end)
    {
        receivedsignal = Wait(windowsignal);
        while ((result = DoMethod(window,WM_HANDLEINPUT,&code)) != WMHI_LASTMSG)
        {
            switch (result & WMHI_CLASSMASK)
            {
                case WMHI_CLOSEWINDOW:
                    end=TRUE;
                    break;
            }
        }
    }
    DoMethod(window,WM_CLOSE);
    cleanexit(NULL);
}

void cleanexit(char *str)
{
    if (str) printf("Error: %s\n",str);

    if (alllibrariesopen)
    {
        DisposeObject(window);
        UnlockPubScreen(NULL,screen);
    }

    CloseLibrary((struct Library*)IntuitionBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(ButtonBase);
    CloseLibrary(BitMapBase);
    exit(0);
}

