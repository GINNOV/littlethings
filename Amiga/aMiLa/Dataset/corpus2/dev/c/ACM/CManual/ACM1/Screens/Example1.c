/* Example1                                                              */
/* This program will open a low-resolution, non-Interlaced, eight colour */
/* Custom Screen. It will display it for 30 secondes, and then close it. */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Screen structure: */ 
struct Screen *my_screen;

/* Declare and initialize your NewScreen structure: */
struct NewScreen my_new_screen=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display.*/
  320,          /* Width     We are using a low-resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  3,            /* Depth     8 colours. */
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
  /* Before we can use the functions in the Intuition Library we need */
  /* to open it. (See chapter 0 INTRODUCTION for more information.)   */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */
  


  /* We will now try to open the screen: */
  my_screen = (struct Screen *) OpenScreen( &my_new_screen );
  
  /* The "(struct Screen *)" is not necessary but it tells the compiler */
  /* that the function OpenScreen() returns a pointer to a Screen       */
  /* structure. (See chapter 0 INTRODUCTION for more information about  */
  /* casting.)                                                          */

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
  
  /* Delay(time) is a function which stops the process for a while.      */
  /* "time" is the number of ticks it should wait. (50 ticks per second) */



  /* We should always close the screens we have opened before we leave: */
  CloseScreen( my_screen );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}