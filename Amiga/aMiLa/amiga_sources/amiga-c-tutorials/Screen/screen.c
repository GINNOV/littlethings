/* Screen of My Amiga 600 */
#include <intuition/intuition.h>
#include <graphics/display.h>
#include "a600.h"

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
int i;

struct TextAttr my_font=
{
  "topaz.font", /* Font Name      Topaz */
  TOPAZ_SIXTY,  /* Font Height    64/32 character, 9 lines tall */
  FSF_BOLD,   	/* Style          Italic */
  FPF_ROMFONT   /* Preferences    The font exist in ROM */
};

struct Screen *my_screen;

struct NewScreen my_new_screen=
{
  0,               /* LeftEdge  Daima 0 olmali */
  0,               /* TopEdge   */
  640,             /* Width     */
  512,             /* Height    */
  4,               /* Depth     16 colours. */
  0,               /* DetailPen */
  1,               /* BlockPen */
  HIRES|INTERLACE, /* ViewModes High-resolution, Interlaced */
  CUSTOMSCREEN,    /* Type customized screen. */
  &my_font,            /* Font */
  "My Amiga Screen",     /* Title */
  NULL,            /* Gadget */
  NULL             /* BitMap */
};

struct Window *my_window;

struct NewWindow my_new_window=
{
  20,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y position of the window. */
  255,           /* Width       */
  265,           /* Height      */
  0,             /* DetailPen   */
  1,             /* BlockPen    */
  NULL,          /* IDCMPFlags  */
  SMART_REFRESH| /* Flags       */
  WINDOWDRAG|    /*             */
  WINDOWDEPTH|   /*             */
  ACTIVATE,      /*             */
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  "My Amiga 600",/* Title       */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  0,             /* MinWidth    */
  0,             /* MinHeight   */
  0,             /* MaxWidth    */
  0,             /* MaxHeight */
  CUSTOMSCREEN   /* Type        */
};

main()
{
  IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit();

  GfxBase = (struct GfxBase *) OpenLibrary( "graphics.library", 0 );

  if( GfxBase == NULL )
  {
    CloseLibrary( IntuitionBase );
    exit();
  }

  my_screen= (struct Screen *) OpenScreen( &my_new_screen );

  if(my_screen == NULL)
  {
    CloseLibrary( GfxBase );
    CloseLibrary( IntuitionBase );
    exit();  
  }
  
  // Palette

  SetRGB4( &my_screen->ViewPort,  0, 0xc, 0xb, 0x9 );
  SetRGB4( &my_screen->ViewPort,  1, 0xb, 0xa, 0x9 );
  SetRGB4( &my_screen->ViewPort,  2, 0xa, 0x9, 0x7 );
  SetRGB4( &my_screen->ViewPort,  3, 0x9, 0x8, 0x7 );
  SetRGB4( &my_screen->ViewPort,  4, 0x8, 0x7, 0x6 );
  SetRGB4( &my_screen->ViewPort,  5, 0x6, 0x6, 0x5 );
  SetRGB4( &my_screen->ViewPort,  6, 0xf, 0xF, 0xe );
  SetRGB4( &my_screen->ViewPort,  7, 0xe, 0xe, 0xd );

  SetRGB4( &my_screen->ViewPort,  8, 0xD, 0xd, 0xc );
  SetRGB4( &my_screen->ViewPort,  9, 0xc, 0xc, 0xb );
  SetRGB4( &my_screen->ViewPort, 10, 0xc, 0xc, 0xb );
  SetRGB4( &my_screen->ViewPort, 11, 0xb, 0xb, 0xa );
  SetRGB4( &my_screen->ViewPort, 12, 0xa, 0xa, 0x9 );
  SetRGB4( &my_screen->ViewPort, 13, 0x4, 0x4, 0x3 );
  SetRGB4( &my_screen->ViewPort, 14, 0x2, 0x2, 0x2 );
  SetRGB4( &my_screen->ViewPort, 15, 0x1, 0x1, 0x1 );

  my_new_window.Screen = my_screen;
  
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  if(my_window == NULL)
  {
    CloseScreen( my_screen );
    CloseLibrary( GfxBase );
    CloseLibrary( IntuitionBase );
    exit();  
  }

  DrawImage( my_window->RPort, &Amiga600, 3, 13 );
  Delay( 50 * 5);

  for (i=0;i<10;i++)
  {
	  MoveScreen(my_screen,0,50);
	  Delay(2);
  }

  for (i=0;i<5;i++)
  {
	  MoveScreen(my_screen,0,-100);
	  Delay(1);
  }
  
  for (i=0;i<16;i++)
  {
	  SetRGB4( &my_screen->ViewPort, 1, i, i, i );  
	  Delay(1);
  }
  
  SetRGB4( &my_screen->ViewPort,  1, 0xb, 0xa, 0x9 );
	
  Delay( 50 * 5);
  
  CloseWindow( my_window );
  CloseScreen( my_screen );
  CloseLibrary( GfxBase );
  CloseLibrary( IntuitionBase );
}
