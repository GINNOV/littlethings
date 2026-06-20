// clicktab.c
// Public Domain by Matthias Rustler
// Use at your own risk

#include <stdio.h>
#include <stdlib.h>

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <intuition/classusr.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <clib/alib_protos.h>

char * vers="\0$VER: Clicktab 0.1 (3.3.2003)";

struct IntuitionBase *IntuitionBase;
struct Library *WindowBase;
struct Library *LayoutBase; // PageObject is part of LayoutObject
struct Library *ClickTabBase;
struct Library *LabelBase;

BOOL alllibrariesopen = FALSE;
Object *window, *layout, *clicktab, *page;

void cleanexit(char *str);

STRPTR tabnames[] = {"One","Two","Tree",0};
// NULL terminated list of tab names, must exist as long as the clicktab exists

int main(void)
{
    char *str;
    struct Window *intuiwin=NULL;
    ULONG windowsignal,receivedsignal,result,code;
    BOOL end;

    if ( ! (IntuitionBase= (struct IntuitionBase*)OpenLibrary("intuition.library",39)))
        cleanexit("Can't open intuition.library");

    if ( ! (WindowBase= OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (LayoutBase= OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    if ( ! (ClickTabBase= OpenLibrary("gadgets/clicktab.gadget",44)))
        cleanexit("Can't open clicktab.gadget");

    if ( ! (LabelBase= OpenLibrary("images/label.image",44)))
        cleanexit("Can't open label.image");

    alllibrariesopen = TRUE;

    window = WindowObject,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WA_Activate, TRUE,
        WA_Title, "Clicktab.gadget demo",
        WA_DragBar, TRUE,
        WA_CloseGadget, TRUE,
        WA_DepthGadget, TRUE,
        WA_SizeGadget, TRUE,
        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP,
        WINDOW_Layout, VLayoutObject,
            LAYOUT_DeferLayout, TRUE,
            LAYOUT_SpaceInner, TRUE,
            LAYOUT_SpaceOuter, TRUE,
            LAYOUT_AddChild, clicktab = ClickTabObject,
                GA_Text,tabnames,

                CLICKTAB_PageGroup, page = PageObject,
                    PAGE_Add, LayoutObject,
                        LAYOUT_AddImage, LabelObject,
                            LABEL_Text, "Page 1",
                        LabelEnd,
                        CHILD_WeightedWidth, 0,
                        CHILD_WeightedHeight, 0,
                    LayoutEnd,

                    PAGE_Add, LayoutObject,
                        LAYOUT_AddImage, LabelObject,
                            LABEL_Text, "Page 2",
                        LabelEnd,
                        CHILD_WeightedWidth, 0,
                        CHILD_WeightedHeight, 0,
                    LayoutEnd,

                    PAGE_Add, LayoutObject,
                        LAYOUT_AddImage, LabelObject,
                            LABEL_Text, "Page 3",
                        LabelEnd,
                    LayoutEnd,
                PageEnd,
            End,
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
                case WMHI_GADGETUP:
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
    }

    CloseLibrary((struct Library*)IntuitionBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(ClickTabBase);
    CloseLibrary(LabelBase);
    exit(0);
}

