// drawlist.c
// Public Domain by Matthias Rustler
// Use at your own risk

// Shows the use of a DrawList Image

// The Drawlist image has some 'features' and the autodoc has errors and is incomplete.
// 
// RefWidth, RefHeight
// ===================
// Standard value for RefWidth and RefHeigt is 50. This means, if your graphics is 50x50
// then you don't need RefWidth and RefHeight. If your image is 70x70 and you chose 140 for
// RefWidth and RefHeight your image is half as big as the button.
// 
// Directives
// ==========
// 
// {DLST_LINE , x1 , y1 , x2 , y2 , pen} - draws a line
// {DLST_RECT , x1 , y1 , x2 , y2 , pen} - draws a filled rect
// {DLST_FILL , x , y , 0 , 0 , pen}     - flood fill
// 
// {DLST_LINEPAT , pat , 0 , 0 , 0 , 0}
// 16 bit line pattern for DLST_LINE. Use 65535 to reset to a full line
// 
// {DLST_FILLPAT , 0 , 0 , 0 , 0 , 0}
// I couldn't change the pattern, no matter which parameter I used. I could only switch on the pattern.
// DLST_FILLPAT influences DLST_RECT, DLST_FILL and DLST_AFILL.
// 
// {DLST_LINESIZE , width , 0 , 0 , 0 , 0}
// Line width for DLST_LINE. The width doesn't change when scaling the image.
// 
// The area directives are for polygon shapes. Use DLST_AMOVE to move the cursor without drawing,
// DLST_ADRAW to draw a line from cursor to new position. DLST_AFILL draws the shape with the given pen.
// {DLST_AMOVE , x , y , 0 , 0 , 0}
// {DLST_ADRAW , x , y , 0 , 0 , 0}
// {DLST_AFILL , 0 , 0 , 0 , 0 , pen}
// 
// {DLST_ELLIPSE , x , y , rx , ry , pen}
// {DLST_CIRCLE , x , y , r , 0 , pen}
// This both directives didn't work right for me. They weren't scaled correctly when I have changed the
// button size.
//
// {DLST_END , 0 , 0 , 0 , 0 , 0}        - end the directive list.

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
struct Library *GfxBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *ButtonBase;
struct Library *DrawListBase;

char * vers="\0$VER: Drawlist 0.2 (13.3.2003)";

BOOL alllibrariesopen = FALSE;
Object *window, *layout;

struct DrawList dlist[] = {
    {DLST_LINEPAT , 4095 , 0 , 0 , 0 , 0 } ,
    {DLST_LINESIZE , 3 , 0 , 0 , 0 , 0 } ,
    {DLST_RECT , 15 , 25 , 35 , 40 , 2 } ,
    {DLST_AMOVE, 15 , 25 , 0 , 0 , 0} ,
    {DLST_ADRAW , 35, 25 , 0 , 0 , 0} ,
    {DLST_ADRAW , 25, 10 , 0 , 0 , 0} ,
    {DLST_AFILL , 0 , 0 , 0 , 0 , 3} ,
    {DLST_LINE , 15 , 25 , 35 , 40 , 1 } ,
    {DLST_LINEPAT , 65535 , 0 , 0 , 0 , 0 } ,  // resetting line pattern
    {DLST_LINE , 15 , 40 , 35 , 25 , 1 } ,
    {DLST_FILL, 5 , 5 , 0 , 0 , 4},
    {DLST_END  , 0 , 0 , 0  , 0  , 0 }  //don't forget this one
};

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

    if ( ! (DrawListBase= OpenLibrary("images/drawlist.image",44)))
        cleanexit("Can't open drawlist.image");

    alllibrariesopen = TRUE;

    window = WindowObject,
        WINDOW_Position, WPOS_CENTERSCREEN,
        WA_Activate, TRUE,
        WA_Title, "Drawlist Demo",
        WA_DragBar, TRUE,
        WA_CloseGadget, TRUE,
        WA_DepthGadget, TRUE,
        WA_SizeGadget, TRUE,
        WA_Width, 250,
        WA_Height, 200,
        WA_IDCMP, IDCMP_CLOSEWINDOW|IDCMP_GADGETUP,
        WINDOW_Layout, HLayoutObject,
            LAYOUT_DeferLayout, TRUE,
            LAYOUT_SpaceInner, TRUE,
            LAYOUT_SpaceOuter, TRUE,

            LAYOUT_AddChild, ButtonObject,
                GA_Image, DrawListObject,
                    DRAWLIST_Directives , dlist ,
                DrawListEnd,
            ButtonEnd,
            CHILD_WeightedWidth, 0,
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, ButtonObject,
                GA_Image, DrawListObject,
                    DRAWLIST_Directives , dlist ,
                    DRAWLIST_RefHeight , 100,
                    DRAWLIST_RefWidth , 100,
                DrawListEnd,
            ButtonEnd,
            CHILD_WeightedWidth, 0,
            CHILD_WeightedHeight, 0,

            LAYOUT_AddChild, ButtonObject,
                GA_Image, DrawListObject,
                    DRAWLIST_Directives , dlist ,
                DrawListEnd,
            ButtonEnd,

            LAYOUT_AddChild, ButtonObject,
                GA_Image, DrawListObject,
                    DRAWLIST_Directives , dlist ,
                    DRAWLIST_RefHeight , 100,
                    DRAWLIST_RefWidth , 100,
                DrawListEnd,
            ButtonEnd,
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
    }

    CloseLibrary((struct Library*)IntuitionBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(ButtonBase);
    CloseLibrary(DrawListBase);
    exit(0);
}

