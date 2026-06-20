/* Example6                                                              */
/* This program will open a low-resolution, non-Interlaced, 4 colour     */
/* Custom Screen. It will after 5 secondes start to change the screens   */
/* colours, and will after a while close the screen and exit.            */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


/* Declare a pointer to a Screen structure: */ 
struct Screen *my_screen;

/* Declare and initialize your NewScreen structure: */
struct NewScreen my_new_screen=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display.*/
  320,          /* Width     We are using a low-resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  2,            /* Depth     4 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  NULL,         /* ViewModes No special modes. (Low-res, Non-Interlaced) */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "MY SCREEN",  /* Title     The screen' title. */
  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};



main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */
  


  /* Before we can use the function SetRGB4() we need to open the */
  /* graphics Library. (See chapter 0 INTRODUCTION for more       */
  /* information.)                                                */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
  {
    /* Could NOT open the Graphics Library! */

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }



  /* We will now try to open the screen: */
  my_screen = (struct Screen *) OpenScreen( &my_new_screen );
  
  /* The "(struct Screen *)" is not necessary but it tells the compiler */
  /* that the function OpenScreen() returns a pointer to a Screen */
  /* structure. (See chapter "Amiga C" for more information) */

  /* Have we opened the screen succesfully? */
  if(my_screen == NULL)
  {
    /* Could NOT open the Screen! */
    
    /* Close the Graphics Library since we have opened it: */
    CloseLibrary( GfxBase );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the screen, and everything seems to be OK. */

  /* Wait for 5 seconds: */
  Delay( 50 * 5);



  /* Change colour register 1 to red: */
  SetRGB4( &my_screen->ViewPort, 1, 15, 0, 0 );  

  /* Wait for 1 second: */
  Delay( 50 * 1);



  /* Change colour register 1 to green: */
  SetRGB4( &my_screen->ViewPort, 1, 0, 15, 0 );  

  /* Wait for 1 second: */
  Delay( 50 * 1);



  /* Change colour register 1 to blue: */
  SetRGB4( &my_screen->ViewPort, 1, 0, 0, 15 );  

  /* Wait for 1 second: */
  Delay( 50 * 1);



  /* Change colour register 1 to white: */
  SetRGB4( &my_screen->ViewPort, 1, 15, 15, 15 );  

  /* Wait for 1 second: */
  Delay( 50 * 1);



  /* Change colour register 0 to black: */
  SetRGB4( &my_screen->ViewPort, 0, 0, 0, 0 );  

  /* Wait for 1 second: */
  Delay( 50 * 1);



  /* Wait for 5 seconds: */
  Delay( 50 * 5);



  /* We should always close the screens we have opened before we leave: */
  CloseScreen( my_screen );



  /* Close the Graphics Library since we have opened it: */
  CloseLibrary( GfxBase );

  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );

  /* THE END */
}
