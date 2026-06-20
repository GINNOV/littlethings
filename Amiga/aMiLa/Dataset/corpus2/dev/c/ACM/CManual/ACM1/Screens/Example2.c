/* Example2                                                              */
/* This program will open a high-resolution, Interlaced, four colour     */
/* Custom Screen. It will display it for 30 secondes, and then close it. */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>

/* Since we are using an interlaced display (ViewModes = INTERLACE) we */
/* need to include the headerfile "display.h" which declares the       */
/* constant "INTERLACE".                                               */
#include <graphics/display.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Screen structure: */ 
struct Screen *my_screen;

/* Declare and initialize your NewScreen structure: */
struct NewScreen my_new_screen=
{
  0,               /* LeftEdge  Should always be 0. */
  0,               /* TopEdge   Top of the display.*/
  640,             /* Width     We are using a high-resolution screen. */
  400,             /* Height    Interlaced NTSC (American) display. */
  2,               /* Depth     4 colours. */
  0,               /* DetailPen Text should be drawn with colour reg. 0 */
  1,               /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES|INTERLACE, /* ViewModes High-resolution, Interlaced */
  CUSTOMSCREEN,    /* Type      Your own customized screen. */
  NULL,            /* Font      Default font. */
  "MY SCREEN",     /* Title     The screen' title. */
  NULL,            /* Gadget    Must for the moment be NULL. */
  NULL             /* BitMap    No special CustomBitMap. */
};



main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */
  


  /* We will now try to open the screen: */
  my_screen = (struct Screen *) OpenScreen( &my_new_screen );
  
  /* Have we opened the screen succesfully? */
  if(my_screen == NULL)
  {
    /* Could NOT open the Screen! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the screen, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the screens we have opened before we leave: */
  CloseScreen( my_screen );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}