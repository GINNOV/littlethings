/* Name: Example.c

   CCC                                W     W
  C   C                               W     W
  C      OOO  L      OOO  U   U RRRR  W     W III N   N DDD    OOO  W     W
  C     O   O L     O   O U   U R   R W     W  I  NN  N D  D  O   O W     W
  C     O   O L     O   O U   U RRRR  W  W  W  I  N N N D   D O   O W  W  W
  C   C O   O L     O   O U   U R  R   W W W   I  N  NN D  D  O   O  W W W
   CCC   OOO  LLLLL  OOO   UUU  R   R   W W   III N   N DDD    OOO    W W


  COLOUR WINDOW   EXAMPLE   VERSION 1.00   90-07-22

  Yet another program dedicated to Sioe-Lin Kwik.
  

  COLOUR WINDOW was created by Anders Bjerin, and is distributed as
  public domain with NO RIGHTS RESERVED. That means that you can do
  what ever you want with the program.
  
  You may use COLOUR WINDOW in your own programs, commercial or not,
  and do not even need to mention that you have used it. You may
  alter the source code to fit your needs, and you may spread it to
  anyone.

  HAPPY PROGRAMMING,

  Anders Bjerin

*/



/* Include Intuition's and ColourWindow's header file: */
#include <intuition/intuition.h>
#include "ColourWindow.h"



/* ColourWindow needs both the Intuition and Graphics library: */
struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;



/* Declare a pointer to a Screen structure: */ 
struct Screen *screen = NULL;

/* Declare and initialize a NewScreen structure: */
struct NewScreen screen_data=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display. */
  640,          /* Width     We are using a high resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  4,            /* Depth     16 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES,        /* ViewModes High-resolution. (Non-Interlaced) */
  CUSTOMSCREEN, /* Type      A customized screen. */
  NULL,         /* Font      Default font. */

  "ColourWindow  V1.00  By Anders Bjerin",  /* Title */

  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};



void main();
void CleanUp();



void main()
{
  UBYTE result;



  /* 1. Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  if( IntuitionBase == NULL )
    CleanUp( "Could NOT open the Intuition Library!" );



  /* 2. Open the Graphics Library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0 );
  if( GfxBase == NULL )
    CleanUp( "Could NOT open the Graphics Library!" );



  /* 3. Open the screen: */
  screen = (struct Screen *) OpenScreen( &screen_data );
  if( screen == NULL )
    CleanUp( "Could NOT open the Screen!" );



  result = ColourWindow( screen, "ColourWindow V1.00", 20, 20 );

  switch( result )
  {
    case ERROR:  printf("ERROR!\n");  break;
    case OK:     printf("OK!\n");     break;
    case CANCEL: printf("CANCEL!\n"); break;
    case QUIT:   printf("QUIT!\n");   break;
  }



  CleanUp( "THE END" );
}



/* This function will close everything that have been opened: */
void CleanUp( message )
STRPTR message;
{
  if( screen )
    CloseScreen( screen );
  
  if( GfxBase )
    CloseLibrary( GfxBase );
  
  if( IntuitionBase )
    CloseLibrary( IntuitionBase );

  printf("%s\n", message );

  exit();
}
