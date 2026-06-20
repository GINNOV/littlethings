// bitmap.c
// Public Domain by Matthias Rustler
// Use at your own risk

// It shows the use of a ReAction bitmap object with a self created bitmap

#include <stdio.h>
#include <stdlib.h>

#define  ALL_REACTION_CLASSES
#define  ALL_REACTION_MACROS

#include <reaction/reaction.h>
#include <intuition/classusr.h>
#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <clib/alib_protos.h>

char * vers="\0$VER: Bitmap 0.1 (24.5.2)";

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *LayersBase;
struct Library *WindowBase;
struct Library *LayoutBase;
struct Library *BitMapBase;

struct Screen *myscreen;
struct BitMap *bm;
struct Layer_Info *li;
struct Layer *lay;
struct ColorMap *cm;

Object *window,*layout,*bitmap;
ULONG pen;

BOOL alllibrariesopen = FALSE;

#define BMWIDTH 300
#define BMHEIGHT 200

void cleanexit(char *str);

int main(void)
{
    struct Window *intuiwin = NULL;
    struct RastPort *rport = NULL;
    UBYTE depth;
    ULONG windowsignal,receivedsignal,result,code;
    BOOL end;

    if ( ! (IntuitionBase = (struct IntuitionBase*)OpenLibrary("intuition.library",33)))
        cleanexit("Can't open intuition.library");

    if ( ! (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",39)))
        cleanexit("Can't open graphics.library");

    if ( ! (LayersBase = OpenLibrary("layers.library",39)))
        cleanexit("Can't open layers.library");

    if ( ! (WindowBase = OpenLibrary("window.class",44)))
        cleanexit("Can't open window.class");

    if ( ! (BitMapBase = OpenLibrary("images/bitmap.image",44)))
        cleanexit("Can't open bitmap.image");

    if ( ! (LayoutBase = OpenLibrary("gadgets/layout.gadget",44)))
        cleanexit("Can't open layout.gadget");

    alllibrariesopen = TRUE;

    if ( ! (myscreen = LockPubScreen(NULL)))
        cleanexit("Can't lock pubscreen");

    depth = myscreen->RastPort.BitMap->Depth;

    printf ("Depth %d\n",depth);

    if ( ! (bm = AllocBitMap(BMWIDTH , BMHEIGHT , depth, BMF_CLEAR , NULL)))
        cleanexit("Can't allocate bitmap");

    //We need a layer for automatic clipping
    if ( ! (li = NewLayerInfo()))
        cleanexit("Can't get newlayerinfo");

    if ( ! ( lay = CreateUpfrontLayer( li , bm , 0 , 0 , BMWIDTH-1 , BMHEIGHT-1 , LAYERSIMPLE , NULL)))
        cleanexit("Can't create layer");

    rport=lay->rp;

    cm = myscreen->ViewPort.ColorMap;

    if (-1 == (pen = ObtainBestPen(cm , 200<<24 , 50<<24 , 10<<24 , TAG_END)))
        cleanexit("Can't obtain pen");

    printf("Pen %d\n",pen);

    SetAPen(rport,pen);
    Move(rport,-50,100);
    Draw(rport,150,-50);
    Draw(rport,350,100);
    Draw(rport,150,250);
    Draw(rport,-50,100);

    window = WindowObject ,
        WINDOW_Position, WPOS_CENTERSCREEN ,
        WA_Activate, TRUE ,
        WA_Title, "ReAction Bitmap with own bitmap" ,
        WA_DragBar, TRUE ,
        WA_CloseGadget, TRUE ,
        WA_DepthGadget, TRUE ,
        WA_SizeGadget, TRUE ,
        WA_IDCMP, IDCMP_CLOSEWINDOW ,
        WINDOW_Layout, layout = VLayoutObject ,
            LAYOUT_DeferLayout, TRUE ,
            LAYOUT_SpaceInner, TRUE ,
            LAYOUT_SpaceOuter, TRUE ,
            LAYOUT_AddImage, bitmap = BitMapObject ,
                BITMAP_BitMap, bm ,
                BITMAP_Width, BMWIDTH ,
                BITMAP_Height, BMHEIGHT ,
            BitMapEnd ,
        LayoutEnd ,
    WindowEnd ;

    if ( ! (window))
        cleanexit("Can't create window object");

    if ( ! (intuiwin = (struct Window *) DoMethod(window , WM_OPEN)))
        cleanexit("Can't open window");

    SetAPen(rport,pen);
    Move(rport,-50,100);
    Draw(rport,350,100);

    //Update the Bitmap object after drawing
    RethinkLayout ((struct Gadget *)layout , intuiwin , NULL , TRUE);

    GetAttr(WINDOW_SigMask , window , &windowsignal);
    end = FALSE;
    while (!end)
    {
        receivedsignal = Wait(windowsignal);
        while ((result = DoMethod(window , WM_HANDLEINPUT , &code)) != WMHI_LASTMSG)
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

    //avoid calling library functions when the libraries couldn't be opened
    if (alllibrariesopen == TRUE)
    {
        ReleasePen(cm,pen);
        DisposeObject(window);
        if (lay) DeleteLayer(0,lay);
        if (li) DisposeLayerInfo(li);
        WaitBlit();  // Very important
        FreeBitMap(bm);
        UnlockPubScreen("",myscreen);
    }
    CloseLibrary( (struct Library *) IntuitionBase);
    CloseLibrary( (struct Library *) GfxBase);
    CloseLibrary(WindowBase);
    CloseLibrary(LayoutBase);
    CloseLibrary(BitMapBase);
    CloseLibrary(LayersBase);
    exit(0);
}

