/***************************************************************************
*                                                                          *
*              DEMO CODE --- link with NBUFF.c                             *
*                                                                          *
***************************************************************************/

#include <stdio.h>
#include <intuition/intuitionbase.h>
#include <graphics/gfxbase.h>
#include <graphics/display.h>

#include <proto/exec.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>
#include <proto/dos.h>  // for Delay()

#include "NBuff.h"

#define DEPTH 2   // number of bitplanes per buffer

void main(void);
int make_screen(SHORT, SHORT, SHORT, SHORT, UBYTE, UBYTE, USHORT, char *);
int make_window(SHORT, SHORT, SHORT, SHORT, char *, UBYTE, UBYTE, ULONG,
                ULONG, struct Screen *, struct Gadget *);
void DrawFigure(struct RastPort *, short, short);

/* Global Amiga system variables */
// (already automatically present as externs with SAS C 5.10b)
// struct IntuitionBase   *IntuitionBase = NULL;
// struct GfxBase         *GfxBase       = NULL;

// NOTE:  Uncomment the following line if compiling under SAS C 5.10b.
//        It's not needed in SAS C 6.2 (it's declared in <proto/layers.h>)
// struct LayersBase      *LayersBase    = NULL;


void main()
{
   /* Amiga system variables */
   struct Screen   *screen    = NULL;  /* Intuition screen */
   struct Window   *window    = NULL;  /* Intuition window */
   struct RastPort *RP[2] =    { NULL, /* Intuition supplied rastport */
                                 NULL };
   short  j;

   /********************** Open Libraries ************************/
   if (!(IntuitionBase = (struct IntuitionBase *)
         OpenLibrary("intuition.library", 0)))
   {
        puts("NO INTUITION LIBRARY.");
        goto CRAPOUT;
   }

   if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0)))
   {
        puts("NO GRAPHICS LIBRARY.");
        goto CRAPOUT;
   }

   if ((LayersBase = OpenLibrary("layers.library", 0)) == NULL) {
        puts("No layers library.");
        goto CRAPOUT;
        }

   /************* Open Intuition screen and window ********************/
   if((screen = (struct Screen *)make_screen(0,640,400,DEPTH,0xff,0xff,
                HIRES|INTERLACE,NULL)) == NULL)
   {
      puts("Can't open screen.");
      goto CRAPOUT;
   }
   ShowTitle(screen, FALSE);  // delete screen title for backdrop window

   /* get a window on the workbench     */
   if((window = (struct Window *)make_window(0,0,640,400,NULL,0xff,0xff,
                 BORDERLESS|SIMPLE_REFRESH|BACKDROP|ACTIVATE|NOCAREREFRESH,0,
                 screen,NULL)) == NULL)
   {
      puts("Can't open window.");
      goto CRAPOUT;
   }

   RP[0] = window->RPort;
   SetRast(RP[0], 2);
           InitNBuff(screen,DEPTH,window,0);  // initialize buffer 0
   RP[1] = InitNBuff(screen,DEPTH,window,1);  // initialize buffer 1

   /********** Loop which draws into alternate bitmaps and swaps view *********/
   for(j=200; j<440; j++)
   {
      if(j%2)  /* Odd cases --- Draw to RP1 */
      {
         ShowView(1);
         if(j-2) DrawFigure(RP[0],j-2,2);      /* Clear previous version */
         DrawFigure(RP[0],j,1);                /* Draw this version      */
      }
      else     /* Even cases --- Draw to RP2 */
      {
         ShowView(0);
         if(j-2 >= 0) DrawFigure(RP[1],j-2,0); /* Clear previous version */
         DrawFigure(RP[1],j,1);                /* Draw this version      */
      }
//      Delay(1);
   }
   
#ifdef FASTNBUFF
puts("\nWhat you just saw was fast, Intuition-unfriendly double-buffered\nanimation, rapidly switching between 2 views having different\nbackground colors.\n");
#else
puts("\nWhat you just saw was double-buffered animation, rapidly switching\nbetween two views having different background colors.\n");
#endif

CRAPOUT:
if (RP[1]) FreeNBuff(screen, DEPTH, RP[1], 1);  // deallocate extra buffer
if (RP[0]) FreeNBuff(screen, DEPTH, RP[0], 0);  // needed for general cleanup

/* Close stuff */
if(window)        CloseWindow(window);
if(screen)        CloseScreen(screen);
if(LayersBase)    CloseLibrary(LayersBase);
if(GfxBase)       CloseLibrary(GfxBase);
if(IntuitionBase) CloseLibrary(IntuitionBase);
}
      
/***********************************************************************/

int make_screen(SHORT y, SHORT w, SHORT h, SHORT d,
            UBYTE colour0, UBYTE colour1,
            USHORT mode, char *name)
{
   struct NewScreen NewScreen;


   NewScreen.LeftEdge=0;
   NewScreen.TopEdge=y;
   NewScreen.Width=w;
   NewScreen.Height=h;
   NewScreen.Depth=d;
   NewScreen.DetailPen=colour0;
   NewScreen.BlockPen=colour1;
   NewScreen.ViewModes=mode;
   NewScreen.Type=CUSTOMSCREEN;
   NewScreen.Font=NULL;
   NewScreen.DefaultTitle=name;
   NewScreen.Gadgets=NULL;
   NewScreen.CustomBitMap=NULL;

   return (int)(OpenScreen(&NewScreen));
}

/***********************************************************************/

int make_window(SHORT x, SHORT y, SHORT w, SHORT h,
char *name, UBYTE colour0, UBYTE colour1,
ULONG flags, ULONG iflags,
struct Screen *screen,
struct Gadget *gadg)

/* Initialize a NewWindow and Open it. */

{
   struct NewWindow NewWindow;

   NewWindow.LeftEdge=x;
   NewWindow.TopEdge=y;
   NewWindow.Width=w;
   NewWindow.Height=h;
   NewWindow.DetailPen=colour0;
   NewWindow.BlockPen=colour1;
   NewWindow.Title=name;
   NewWindow.Flags=flags;
   NewWindow.IDCMPFlags=iflags;
   NewWindow.Type=CUSTOMSCREEN;
   NewWindow.FirstGadget=gadg;
   NewWindow.CheckMark=NULL;
   NewWindow.Screen=screen;
   NewWindow.BitMap=NULL;
   NewWindow.MinWidth=0;
   NewWindow.MinHeight=0;
   NewWindow.MaxWidth=0;
   NewWindow.MaxHeight=0;

   return (int)(OpenWindow(&NewWindow));

}

/**************************************************************************/

void DrawFigure(struct RastPort *rp, short n, short p)
{
   SetAPen(rp,p);
   Move(rp,n+20,270);
   Draw(rp,n+0,250);
   Draw(rp,n+0,220);
   Draw(rp,n+20,200);
   Draw(rp,n+40,220);
   Draw(rp,n+40,250);
   Draw(rp,n+20,270);
   Draw(rp,n+20,300);
   Draw(rp,n+40,320);
   Draw(rp,n+20,340);
   Move(rp,n+40,320);
   Draw(rp,n+70,320);
   Draw(rp,n+70,340);
   Move(rp,n+70,320);
   Draw(rp,n+90,300);

   Move(rp,n+20, 70);
   Draw(rp,n+0,  50);
   Draw(rp,n+0,  20);
   Draw(rp,n+20, 00);
   Draw(rp,n+40, 20);
   Draw(rp,n+40, 50);
   Draw(rp,n+20, 70);
   Draw(rp,n+20,100);
   Draw(rp,n+40,120);
   Draw(rp,n+20,140);
   Move(rp,n+40,120);
   Draw(rp,n+70,120);
   Draw(rp,n+70,140);
   Move(rp,n+70,120);
   Draw(rp,n+90,100);
}
