/*
    File: ball.c

    Description: This is a short demo code that shows how we could
                 handle OS3.x features to use fast blitter operation
                 that are compatible with graphics boards. Images,
                 3 balls, red, green and blue, will be remaped to the
                 current colortable useing ObtainBestPen().
                 Also the images will be converted to a friend format of
                 the window they are drawn into. This means it _could_
                 also be in chunky mode then, e.g. if used on a SD64 with
                 an EGS driver, this images are chunky with a memory area
                 located on the gfx board ! (I do not know if other board
                 driver do support allocating display memory).
                 All images are drawn transparent, check out masking and
                 miniterms. This demo should run in all colormodes, though
                 I haven't tryed true color cyber modes yet - do not know
                 if we get 24 bit images then (but I think we will).

                 There is still one problem, the biggest one games coders
                 will say. It does not double buffer. This is not possible
                 with the method I use herein. So, yes, there is a problem
                 with real smooth image movements...

                 I just wanted to show, that you can use OS3 to use effecient
                 methods of image handling, without worring of the destination
                 bitmap format ! This code generates the optimal bitmap format
                 for the images by itself - see the BMF_FRIEND flag !
                 This is important for me, since I want to write my own emulation.
                 
                 I know, this code is not the best you can get. There is some
                 space to make it better. One could try to use custom (public:)
                 screens, double buffering, background images etc. If you like
                 go ahead and try what's possible.

                 I hope you enjoy it :)

    Author: Jürgen Schober
            Muchargasse 35/1/4
            A-8010 Graz
            e-mail: jschober@campusart.com

    Date: 23.11.1996 (96/23/11)

*/

// we use a public screen

#define PUBLIC_SCREEN

#include <stdio.h>
#include <stdlib.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>
#include <clib/cybergraphics_protos.h>

#include <pragmas/exec_pragmas.h>
#include <pragmas/intuition_pragmas.h>
#include <pragmas/graphics_pragmas.h>
#include <pragmas/cybergraphics_pragmas.h>

#include <exec/types.h>
#include <intuition/intuition.h>
#include <intuition/intuitionbase.h>
#include <cybergraphics/cybergraphics.h>

#include <graphics/gfx.h>

// my images 
// they where drawn using a 24 bit package, dithered to 256 colors and
// saved to c source by PPaint 6.4 (and modified by me)

#include "GreenBall.h"
#include "BallMaske.h"
#include "Spectrum.h"

#define BG_WIDTH 640
#define BG_HEIGHT 512
#define BG_DEPTH 8
#define BG_PLANESIZE 40960
#define BG_PLANEWORDSIZE 20480

extern ULONG ScrollGroundPaletteRGB32[];
extern UWORD ScrollGroundData[];

// Convert it:

#ifndef __SASC
    #define __asm
#endif

extern void __asm CopyPlane2Chunky(register __a2 APTR planes,register __a3 APTR chunky,
                                   register __d6 WORD depth,register __d7 long BMSize);

struct Library *GfxBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct Window *win = NULL;
struct Screen *screen = NULL;
struct ColorMap *cm = NULL;
struct RastPort *rp = NULL;

struct BitMap *GreenBall = NULL,*MaskBall = NULL ;
struct BitMap *SuperBackGround = NULL;
int x, y, gx, gy;
int dx,dy, dgx, dgy;
int x_old, y_old, gx_old, gy_old;

UBYTE bgpens[256],ballpens[256],pen;
long background;
int cycle = 0;

int BitMapDepth;    // for TrueColor Modes
BOOL IsGfxBoard = FALSE;
BOOL verbose = FALSE;


#define PLANESIZE    BG_PLANESIZE
#define IMAGE_WIDTH  BG_WIDTH
#define IMAGE_HEIGHT BG_HEIGHT
#define IMAGE_DEPTH  BG_DEPTH   // 8 planes

#define VISIBLE_WIDTH 320
#define VISIBLE_HEIGHT 256

// ----------------------------------------------------------------------
// Basic Exit Code
// ----------------------------------------------------------------------
void CleanUp()
{
    int i;

    // ------------------------------------------------------------------
    // Free the pens again
    // ------------------------------------------------------------------

    if (cm)
    {
        for (i = 0; i < 256 ; i++)
        {
           ReleasePen(cm,bgpens[i]);
           ReleasePen(cm,ballpens[i]);
        }
    }

    // ------------------------------------------------------------------
    // now we want to free the bitmaps again
    // ------------------------------------------------------------------

    WaitBlit();

    if (GreenBall) FreeBitMap(GreenBall);
    if (MaskBall)  FreeBitMap(MaskBall);


    if (win)    CloseWindow(win);
#ifdef PUBLIC_SCREEN
    if (screen) UnlockPubScreen(NULL,screen);
#else
    if (screen) CloseScreen(screen);
#endif

    // ------------------------------------------------------------------
    // and don't forget to close the libraries !
    // ------------------------------------------------------------------

    if (GfxBase) CloseLibrary(GfxBase);
    if (IntuitionBase) CloseLibrary((struct Library*)IntuitionBase);

    exit(0);
}

// ----------------------------------------------------------------------
// As We have Shared Pens, We have to allocate Them Here
// ----------------------------------------------------------------------
void AllocateColors()
{
    int i,idx;

    // ------------------------------------------------------------------
    // Init the Background Color
    // ------------------------------------------------------------------

    if (!cm) CleanUp();

    if (verbose) { printf("Obtaining pens...\n\tPen "); fflush(stdout); }

    // ------------------------------------------------------------------
    // here I try to get as many colors of my table in the windows colormap
    // ------------------------------------------------------------------

    idx = 0;
    for (i = 0; i < 256; i++)
    {
        bgpens[i] = ObtainBestPen(cm,
                                ScrollGroundPaletteRGB32[idx++],
                                ScrollGroundPaletteRGB32[idx++],
                                ScrollGroundPaletteRGB32[idx++],
                                OBP_Precision,PRECISION_EXACT,
                                TAG_DONE);

        if (verbose) { printf("%d = %d ",i,bgpens[i]); fflush(stdout); }

    }

    // ------------------------------------------------------------------
    // after I have my image colors I also need some for my ball
    // ------------------------------------------------------------------

    idx = 0;
    for (i = 0; i < 256; i++)
    {
        ballpens[i] = ObtainBestPen(cm,
                                BallPaletteRGB32[idx++],
                                BallPaletteRGB32[idx++],
                                BallPaletteRGB32[idx++],
                                OBP_Precision,PRECISION_EXACT,
                                TAG_DONE);

        if (verbose) { printf("%d = %d ",i,bgpens[i]); fflush(stdout); }

    }
    if (verbose) { puts("done."); fflush(stdout); }

}

// ----------------------------------------------------------------------
// Images have to be brought into a usable format
// ----------------------------------------------------------------------
void CreateBackGround(struct BitMap *bm)
{
    int i;
    ULONG pixels;
    UBYTE *buffer;
    UBYTE *ChunkyData;
    UBYTE *Planes[8];
    struct RastPort tmpRastPort,tmpRastPort2;


    // ------------------------------------------------------------------
    // This is some support code if we run on a TrueColor Cyber Screen
    // in this case the Color Cycling has to be done in a different way
    // ------------------------------------------------------------------

    struct Library *CyberGfxBase; 

    if (CyberGfxBase = OpenLibrary("cybergraphics.library",40))
    {
        if (GetCyberMapAttr(rp->BitMap,CYBRMATTR_ISCYBERGFX))
        {
            BitMapDepth = GetCyberMapAttr(rp->BitMap,CYBRMATTR_DEPTH);
        }
        CloseLibrary(CyberGfxBase);
    }

    // ------------------------------------------------------------------
    // I support v39 now, so I need another RastPort for the WritePixelArray8()
    // ------------------------------------------------------------------

    CopyMem(rp,&tmpRastPort2,sizeof(struct RastPort));
    tmpRastPort2.Layer = NULL;
    tmpRastPort2.BitMap = AllocBitMap(BG_WIDTH,1,BG_DEPTH,0,NULL);

    // ------------------------------------------------------------------
    // I also need my images in an array for the next loop, see there
    // ------------------------------------------------------------------

    // ------------------------------------------------------------------
    // we need a chunky buffer, we need it only once because of the same size
    // this chunky buffer is needed because I want to remap the images to 
    // the available colors. This is really easy if you have 8 bit chunky sources
    // ------------------------------------------------------------------

    if (!(ChunkyData = AllocVec(BG_WIDTH * BG_HEIGHT, 0))) 
    {
        CleanUp();
    }
    
    // ------------------------------------------------------------------
    // this loop converts my 3 plane sources to chunky images and
    // remaps them to the colors allocated above
    // ------------------------------------------------------------------

    if (verbose) { printf("Converting plane to chunky ..."); fflush(stdout); }

    // -------------------------------------------------------------------
    // my own convert routine wants the planes in an array of planepointers
    // -------------------------------------------------------------------

    Planes[0] = (PLANEPTR)&ScrollGroundData[0*BG_PLANEWORDSIZE];
    Planes[1] = (PLANEPTR)&ScrollGroundData[1*BG_PLANEWORDSIZE];
    Planes[2] = (PLANEPTR)&ScrollGroundData[2*BG_PLANEWORDSIZE];
    Planes[3] = (PLANEPTR)&ScrollGroundData[3*BG_PLANEWORDSIZE];
    Planes[4] = (PLANEPTR)&ScrollGroundData[4*BG_PLANEWORDSIZE];
    Planes[5] = (PLANEPTR)&ScrollGroundData[5*BG_PLANEWORDSIZE];
    Planes[6] = (PLANEPTR)&ScrollGroundData[6*BG_PLANEWORDSIZE];
    Planes[7] = (PLANEPTR)&ScrollGroundData[7*BG_PLANEWORDSIZE];
    
    // ------------------------------------------------------------------
    // I use my own chunky converter.
    // well, this thing is really old, but does it's job...
    // It converts DEPTH planes with PLANESIZE and Planes[DEPTH] into
    // an UBYTE *ChunkyBuffer. - it does no selective (x/y) conversion.
    // ------------------------------------------------------------------

    buffer = ChunkyData;
    CopyPlane2Chunky(&Planes,buffer,BG_DEPTH, BG_PLANESIZE);

    if (verbose) { puts("done."); fflush(stdout);    }
    if (verbose) { printf("remapping image.."); fflush(stdout); }

    // ------------------------------------------------------------------
    // Now we remap <pixels> to the new colors
    // where we loose the original chunky data - we don't need them, see below
    // ------------------------------------------------------------------

    pixels = BG_WIDTH * BG_HEIGHT;
    while (pixels--)
    {
        pen = (ChunkyData[pixels]);
        ChunkyData[pixels] = bgpens[pen];
    }
    if (verbose) { puts("done"); fflush(stdout); }

    // ------------------------------------------------------------------
    // here we convert the remaped chunky image to a friend bitmap of the window
    // we use a temporary rastport here where we install the previous allocated
    // ball bitmaps. We use WriteChunkyPixels() here, so it will be converted
    // to the correct format ! This could also be a chunky format !
    // if we are on a gfxboard, this is just a plain copy, if we are on ECS/AGA,
    // it converts it to plane sources
    // ------------------------------------------------------------------

    CopyMem(rp,&tmpRastPort,sizeof(struct RastPort));
    tmpRastPort.Layer = NULL;
    tmpRastPort.BitMap = bm;

    // ------------------------------------------------------------------
    // I really hate this WritePixelArray8() so I try to use the WriteChunkyPixels() if possible
    // ------------------------------------------------------------------

    if (GfxBase->lib_Version >= 40)
        WriteChunkyPixels(&tmpRastPort,0,0,BG_WIDTH-1,BG_HEIGHT-1,ChunkyData,BG_WIDTH);
    else
        WritePixelArray8(&tmpRastPort,0,0,BG_WIDTH-1,BG_HEIGHT-1,ChunkyData,&tmpRastPort2);

    // ------------------------------------------------------------------
    // WARNING! This is available to OS 3.1 (v40) only, so this would be more
    // complicating on v39 system (OS2 is not supported , see ObtainPen())
    // -> check out the WritePixelLine8()/WritePixelArray8() functions
    // ^^^^^ you see, previously, I didn't even want to support v39 :)
    // ------------------------------------------------------------------
    
    
    // ------------------------------------------------------------------
    // we don't need the chunky puffer any more, so dispose it
    // ------------------------------------------------------------------

    if (ChunkyData)  FreeVec(ChunkyData);

    // ------------------------------------------------------------------
    // I also don't need the tmpRastPort anymore, so I have to free another bitmap
    // ------------------------------------------------------------------

    WaitBlit();
    FreeBitMap(tmpRastPort2.BitMap);

}

// ----------------------------------------------------------------------
// Images have to be brought into a usable format
// ----------------------------------------------------------------------

void CreateBall(struct BitMap *DisplayMap)
{
    int i;
    ULONG pixels;
    UBYTE *buffer;
    UBYTE *ChunkyData;
    UBYTE *Planes[8];
    struct BitMap *MaskBuffer = NULL;
    struct RastPort tmpRastPort,tmpRastPort2;
    PLANEPTR BackupPlanes[8];


    // ------------------------------------------------------------------
    // the Mask is a window friend and it is BMF_DISPLAYABLE, this means
    // that if available board memory is used  - so you get full
    // blitter access - check out the EGS SD64 :)
    // ------------------------------------------------------------------

    MaskBall = AllocBitMap(MASK_WIDTH,MASK_HEIGHT,MASK_DEPTH,BMF_MINPLANES|BMF_DISPLAYABLE,DisplayMap);
    if (!MaskBall)
    { 
        CleanUp();
    }

    // ------------------------------------------------------------------
    // but I have to convert it first - WITHOUT MAPPING !!
    // BMF_MINPLANES tells the OS not to allocate memory for the planes
    // WARNING ! Do _NOT_ use 
    //
    //      struct BitMap bm; 
    //
    //      bm.Planes[i] = &xyz;
    // 
    //      !!!!!!!!!!!!!!!!!
    // ------------------------------------------------------------------

    if ((MaskBuffer = AllocBitMap(MASK_WIDTH,MASK_HEIGHT,MASK_DEPTH,0,NULL)) == NULL)
    {
        CleanUp();
    }
    
    // ------------------------------------------------------------------
    // looks if BMF_MINPLANES does not what I want, so I backup the 
    // planepointers...
    // basically, I thought that BMF_MINPLANES does not allocate space
    // for the planes, but only the structure. Now it seems, that it also allocates
    // the planes, which are freed again by FreeBitMap()... so ..hm, this is not
    // really legal...but I have to patch them a bit :) I only need it temporary.
    // ------------------------------------------------------------------

    CopyMemQuick(&MaskBuffer->Planes[0],BackupPlanes,8*sizeof(PLANEPTR));

    // ------------------------------------------------------------------
    // now I connect my planepointers to this bitmap
    // the source array is WORD aligned, therefore I have PLANESIZE/2 here !
    // ------------------------------------------------------------------

    MaskBuffer->Planes[0] = (PLANEPTR)&BallMaskeData[0*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[1] = (PLANEPTR)&BallMaskeData[1*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[2] = (PLANEPTR)&BallMaskeData[2*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[3] = (PLANEPTR)&BallMaskeData[3*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[4] = (PLANEPTR)&BallMaskeData[4*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[5] = (PLANEPTR)&BallMaskeData[5*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[6] = (PLANEPTR)&BallMaskeData[6*GREEN_PLANEWORDSIZE];
    MaskBuffer->Planes[7] = (PLANEPTR)&BallMaskeData[7*GREEN_PLANEWORDSIZE];

    // ------------------------------------------------------------------
    // now convert the bitmap into a window friend format
    // ------------------------------------------------------------------

    WaitBlit();
    BltBitMap(MaskBuffer,0,0,MaskBall,0,0,MASK_WIDTH,MASK_HEIGHT,0xC0,0xff,0);

    // ------------------------------------------------------------------
    // wait for the blitter
    // ------------------------------------------------------------------

    WaitBlit();

    // ------------------------------------------------------------------
    // and free the buffer again
    // ...and install the old planes again, so I can call FreeBitMap()
    // ------------------------------------------------------------------

    CopyMemQuick(BackupPlanes,&MaskBuffer->Planes[0],8*sizeof(PLANEPTR));
    FreeBitMap(MaskBuffer);
    
    // ------------------------------------------------------------------
    // again I need 3 bitmaps for my images. In best case they should have
    // the same format as the bitmap on the display, better they should
    // be in the board memory for real fast blitting -> BMF_DISPLAYABLE
    // ------------------------------------------------------------------

    GreenBall = AllocBitMap(GREEN_WIDTH,GREEN_HEIGHT,GREEN_DEPTH,BMF_MINPLANES|BMF_DISPLAYABLE,DisplayMap);

    // ------------------------------------------------------------------
    // make sure we got the Balls
    // ------------------------------------------------------------------

    if (!GreenBall) 
    {
        CleanUp();
    }    

    // ------------------------------------------------------------------
    // we need a chunky buffer, we need it only once because of the same size
    // this chunky buffer is needed because I want to remap the images to 
    // the available colors. This is really easy if you have 8 bit chunky sources
    // ------------------------------------------------------------------

    if (!(ChunkyData = AllocVec(GREEN_WIDTH * GREEN_HEIGHT, 0))) 
    {
        CleanUp();
    }
    
    if (verbose) { printf("Converting plane to chunky ..."); fflush(stdout); }

    // -------------------------------------------------------------------
    // my own convert routine wants the planes in an array of planepointers
    // -------------------------------------------------------------------

    Planes[0] = (PLANEPTR)&GreenBallData[0*GREEN_PLANEWORDSIZE];
    Planes[1] = (PLANEPTR)&GreenBallData[1*GREEN_PLANEWORDSIZE];
    Planes[2] = (PLANEPTR)&GreenBallData[2*GREEN_PLANEWORDSIZE];
    Planes[3] = (PLANEPTR)&GreenBallData[3*GREEN_PLANEWORDSIZE];
    Planes[4] = (PLANEPTR)&GreenBallData[4*GREEN_PLANEWORDSIZE];
    Planes[5] = (PLANEPTR)&GreenBallData[5*GREEN_PLANEWORDSIZE];
    Planes[6] = (PLANEPTR)&GreenBallData[6*GREEN_PLANEWORDSIZE];
    Planes[7] = (PLANEPTR)&GreenBallData[7*GREEN_PLANEWORDSIZE];
    
    // ------------------------------------------------------------------
    // I use my own chunky converter.
    // well, this thing is really old, but does it's job...
    // It converts DEPTH planes with PLANESIZE and Planes[DEPTH] into
    // an UBYTE *ChunkyBuffer. - it does no selective (x/y) conversion.
    // ------------------------------------------------------------------

    buffer = ChunkyData;
    CopyPlane2Chunky(&Planes,buffer,GREEN_DEPTH, GREEN_PLANESIZE);

    if (verbose) { puts("done."); fflush(stdout);    }
    if (verbose) { printf("remapping image.."); fflush(stdout); }

    // ------------------------------------------------------------------
    // Now we remap <pixels> to the new colors
    // where we loose the original chunky data - we don't need them, see below
    // ------------------------------------------------------------------

    pixels = GREEN_WIDTH * GREEN_HEIGHT;
    while (pixels--)
    {
        pen = (ChunkyData[pixels]);
        ChunkyData[pixels] = ballpens[pen];
    }
    if (verbose) { puts("done"); fflush(stdout); }

    // ------------------------------------------------------------------
    // here we convert the remaped chunky image to a friend bitmap of the window
    // we use a temporary rastport here where we install the previous allocated
    // ball bitmaps. We use WriteChunkyPixels() here, so it will be converted
    // to the correct format ! This could also be a chunky format !
    // if we are on a gfxboard, this is just a plain copy, if we are on ECS/AGA,
    // it converts it to plane sources
    // ------------------------------------------------------------------

    CopyMem(win->RPort,&tmpRastPort,sizeof(struct RastPort));
    tmpRastPort.Layer = NULL;
    tmpRastPort.BitMap = GreenBall;

    // ------------------------------------------------------------------
    // I support v39 now, so I need another RastPort for the WritePixelArray8()
    // ------------------------------------------------------------------

    CopyMem(win->RPort,&tmpRastPort2,sizeof(struct RastPort));
    tmpRastPort2.Layer = NULL;
    tmpRastPort2.BitMap = AllocBitMap(GREEN_WIDTH,1,GREEN_DEPTH,0,NULL);

    // ------------------------------------------------------------------
    // I really hate this WritePixelArray8() so I try to use the WriteChunkyPixels() if possible
    // ------------------------------------------------------------------

    if (GfxBase->lib_Version >= 40)
        WriteChunkyPixels(&tmpRastPort,0,0,GREEN_WIDTH-1,GREEN_HEIGHT-1,ChunkyData,GREEN_WIDTH);
    else
        WritePixelArray8(&tmpRastPort,0,0,GREEN_WIDTH-1,GREEN_HEIGHT-1,ChunkyData,&tmpRastPort2);

    // ------------------------------------------------------------------
    // WARNING! This is available to OS 3.1 (v40) only, so this would be more
    // complicating on v39 system (OS2 is not supported , see ObtainPen())
    // -> check out the WritePixelLine8()/WritePixelArray8() functions
    // ^^^^^ you see, previously, I didn't even want to support v39 :)
    // ------------------------------------------------------------------
    
    
    // ------------------------------------------------------------------
    // we don't need the chunky puffer any more, so dispose it
    // ------------------------------------------------------------------

    if (ChunkyData)  FreeVec(ChunkyData);

    // ------------------------------------------------------------------
    // I also don't need the tmpRastPort anymore, so I have to free another bitmap
    // ------------------------------------------------------------------

    WaitBlit();
    FreeBitMap(tmpRastPort2.BitMap);
}

// ----------------------------------------------------------------------
// I used this to set some default values
// ----------------------------------------------------------------------
void InitPosition()
{
    x = 0;
    y = 0;
    dx = 5;
    dy = 5;

    gx = 10;
    gy = 50;
    dgx = 7;
    dgy = 7;

    gx_old = gx + x - dx;
    gy_old = gy + y - dy;
    WaitBlit();
    BltBitMapRastPort(MaskBall, 0,0,win->RPort,x + gx - dx ,y + gy - dy,MASK_WIDTH, MASK_HEIGHT, 0x20);
    WaitBlit();
    BltBitMapRastPort(GreenBall,0,0,win->RPort,x + gx - dx ,y + gy - dy,GREEN_WIDTH,GREEN_HEIGHT,0xE0);

}

// ----------------------------------------------------------------------
// This is the loop that moves the background around
// ----------------------------------------------------------------------
void ScrollBackGround()
{
    // ------------------------------------------------------------------
    // I must wait for a new frame...else my SD64 is way to fast to see the ball :)
    // ------------------------------------------------------------------
    
    WaitTOF();

    x  += dx;   y  += dy;            // new background position
    gx += dgx;  gy += dgy;           // new image position

    // ------------------------------------------------------------------
    // Clear the background before I scroll
    // ------------------------------------------------------------------

    WaitBlit();
    BltBitMapRastPort(SuperBackGround, gx_old ,gy_old ,
                      win->RPort,      gx_old ,gy_old ,GREEN_WIDTH, GREEN_HEIGHT, 0xC0);
    WaitBlit();

    // ------------------------------------------------------------------
    // Now move the background
    // ------------------------------------------------------------------

    ScrollLayer(NULL,win->RPort->Layer,dx,dy);

    // ------------------------------------------------------------------
    // and at last blit the Green Ball over the new background
    // ------------------------------------------------------------------

    gx_old = x + gx - dx; gy_old = y + gy - dy;

    WaitBlit();
    BltBitMapRastPort(MaskBall, 0,0,win->RPort,gx_old,gy_old,MASK_WIDTH, MASK_HEIGHT, 0x20);
    WaitBlit();
    BltBitMapRastPort(GreenBall,0,0,win->RPort,gx_old,gy_old,GREEN_WIDTH,GREEN_HEIGHT,0xE0);

    // ------------------------------------------------------------------
    // calc the new coords
    // ------------------------------------------------------------------

    if ((x > (IMAGE_WIDTH - VISIBLE_WIDTH - abs(dx))) || (x < abs(dx)))
    {
        dx *= -1;
    }
    if ((y > (IMAGE_HEIGHT - VISIBLE_HEIGHT - abs(dy))) || (y < abs(dy)))
    {
        dy *= -1;
    }
    if (((gx + abs(dgx)) > (VISIBLE_WIDTH - GREEN_WIDTH)) || (gx < abs(dgx)))
    {
        dgx *= -1;
    }
    if (((gy + abs(dgy)) > (VISIBLE_HEIGHT - GREEN_HEIGHT)) || (gy < abs(dgy)))
    {
        dgy *= -1;
    }
}

// ----------------------------------------------------------------------
// The Main Part 
// ----------------------------------------------------------------------
void main(int argc,char **argv)
{
    int i;
    USHORT class;
    USHORT code;
    struct IntuiMessage *message;
    ULONG sig;
    BOOL out = FALSE;

    GfxBase = OpenLibrary("graphics.library",39); // we need a v39+ OS, see below
    IntuitionBase = (struct IntuitionBase*)OpenLibrary("intuition.library",0);

    if (GfxBase && IntuitionBase);
    {

// ----------------------------------------------------------------------
//  I need a screen pointer, because I need a super bitmap that is a 
//  friend of the displayable bitmap : screen->RastPort->BitMap
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// this could be a custom screen ... :
// ----------------------------------------------------------------------

#ifndef PUBLIC_SCREEN

        screen = OpenScreenTags(NULL,SA_LikeWorkbench,TRUE,TAG_DONE);

#else
// ----------------------------------------------------------------------
// ... or a pubscreen (e.g. the WB):
// ----------------------------------------------------------------------

        screen = LockPubScreen(NULL);

#endif

        if (!screen) CleanUp();

        cm = screen->ViewPort.ColorMap;
        rp = &screen->RastPort;

        // ----------------------------------------------------------------
        // I need some colors so I allocate some from my screen(see above)
        // ----------------------------------------------------------------

        AllocateColors();

        SuperBackGround = AllocBitMap(BG_WIDTH,BG_HEIGHT,BG_DEPTH,
                            BMF_MINPLANES|BMF_DISPLAYABLE,rp->BitMap);
        if (!SuperBackGround) CleanUp();

        // ----------------------------------------------------------------
        // I create the bitmap in a friend format and also remap it to the 
        // available colors
        // ----------------------------------------------------------------

        CreateBackGround(SuperBackGround);
        CreateBall(rp->BitMap);

        // -------------------------
        // I open a superbitmap pal low res window, the bitmap is the one created above
        // we use windows on pubscreen, so I render borders, if you like, you
        // can make it a backdrop, borderless window. In this case clear the
        // WA_GimeZeroZero flag !
        // -------------------------

        if (win = OpenWindowTags(NULL,
                                WA_Title, "This is the SuperScroll !",
                                WA_AutoAdjust,TRUE,
                                WA_Activate,TRUE,
                                WA_CustomScreen,screen,
                                WA_InnerWidth,  VISIBLE_WIDTH, 
                                WA_InnerHeight, VISIBLE_HEIGHT,
//                                WA_Backdrop, TRUE,
//                                WA_Borderless,  TRUE,
                                WA_GimmeZeroZero, TRUE, // set to FALSE if borderless
//                                WA_SimpleRefresh, TRUE,
                                WA_SmartRefresh, TRUE,
                                WA_DragBar, TRUE,
                                WA_CloseGadget, TRUE,
                                WA_DepthGadget,TRUE,
                                WA_SizeGadget,FALSE,    // no sizing
                                WA_IDCMP,IDCMP_CLOSEWINDOW | IDCMP_NEWSIZE | IDCMP_CHANGEWINDOW,
                                WA_SuperBitMap,SuperBackGround,
                                TAG_DONE))
        {
            // ----------------------------------------------------------------
            // check out if we are on a gfx board:
            // ----------------------------------------------------------------

            i = GetBitMapAttr(rp->BitMap,BMA_FLAGS);
            IsGfxBoard = (i & BMF_STANDARD) ? FALSE : TRUE;

            // ----------------------------------------------------------------
            // and I want some init values
            // ----------------------------------------------------------------

            InitPosition();
   
            sig = (1L<<win->UserPort->mp_SigBit);
            while (!out)
            {
                // ----------------------------------------------------------------
                // This scrolls my background along
                // ----------------------------------------------------------------

                ScrollBackGround();

                // ----------------------------------------------------------------
                // I use a busy loop to check window events,
                // this is not really a problem since we run in endless mode
                // ----------------------------------------------------------------

                if (message = (struct IntuiMessage *)GetMsg(win->UserPort))
                {
            	    class = message->Class;
        	        code  = message->Code;
                    switch(class)
            	    {
           	    	    case CLOSEWINDOW:
                            out = TRUE;
                            break;
                        case CWCODE_MOVESIZE:
        		        case NEWSIZE:

                            LockLayerRom(win->RPort->Layer);
                            CopySBitMap(win->RPort->Layer);
                            UnlockLayerRom(win->RPort->Layer);

                            break;
                        default :
                            break;
               	    }
                }
            }

            // ----------------------------------------------------------------
            // we should make sure there is no bitmap used when we free it
            // ----------------------------------------------------------------

            WaitBlit();

            // ----------------------------------------------------------------
            // Free all Pens and Bitmaps
            // ----------------------------------------------------------------
            
        }
        CleanUp();
    }
}
