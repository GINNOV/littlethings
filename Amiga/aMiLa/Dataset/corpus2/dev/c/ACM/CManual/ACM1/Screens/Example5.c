/* Example5                                                            */
/* This program will open two screens, one (low-resolution 32 colours) */
/* at the top of the display, and the other one (high-resolution 16    */
/* colours) a bit further down. After 10 seconds the low-resolution    */
/* screen will move down 75 lines. After another 10 seconds it will be */
/* put in front of all other screens. 10 seconds later it will move    */
/* down another 75 lines. The program will wait 10 seconds before the  */
/* screens are closed and the program exits.                           */


/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare two pointer to a Screen structure: */ 
struct Screen *my_screen1;
struct Screen *my_screen2;

/* Declare and initialize your NewScreen structure for screen 1: */
struct NewScreen my_new_screen1=
{
  0,            /* LeftEdge  Should always be 0. */
  0,            /* TopEdge   Top of the display.*/
  320,          /* Width     We are using a low-resolution screen. */
  100,          /* Height    */
  5,            /* Depth     32 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  NULL,         /* ViewModes No special modes. (Low-res, Non-Interlaced) */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "MY SCREEN1", /* Title     The screen' title. */
  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};

/* Declare and initialize your NewScreen structure for screen 2: */
struct NewScreen my_new_screen2=
{
  0,            /* LeftEdge  Should always be 0. */
  105,          /* TopEdge   Top of the display.*/
  640,          /* Width     We are using a low-resolution screen. */
  95,           /* Height    */
  4,            /* Depth     16 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES,        /* ViewModes High-resolution, Non-Interlaced */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "MY SCREEN2", /* Title     The screen' title. */
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
  


  /* We will now try to open the first screen: */
  my_screen1 = (struct Screen *) OpenScreen( &my_new_screen1 );
  
  /* Have we opened screen1 succesfully? */
  if(my_screen1 == NULL)
  {
    /* Could NOT open the Screen1! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We will now try to open the second screen: */
  my_screen2 = (struct Screen *) OpenScreen( &my_new_screen2 );
  
  /* Have we opened screen2 succesfully? */
  if(my_screen2 == NULL)
  {
    /* Could NOT open Screen2! */
    
    /* Close Screen1 before we leave since we have opened it: */
    CloseScreen( my_screen1 );
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the screens, and everything seems to be OK. */

  /* Wait for 10 seconds: */
  Delay( 50 * 10);

  /* Move the low-resolution screen down 75 lines: */
  MoveScreen( my_screen1, 0, 75 );

  /* Wait for 10 seconds: */
  Delay( 50 * 10);

  /* Put the low-resolution screen in front of all other screens: */
  ScreenToFront( my_screen1 );

  /* Wait for 10 seconds: */
  Delay( 50 * 10);

  /* Move the low-resolution screen down another 75 lines: */
  MoveScreen( my_screen1, 0, 75 );

  /* Wait for 10 seconds: */
  Delay( 50 * 10);


  /* We should always close the screens we have opened before we leave: */
  CloseScreen( my_screen2 );
  CloseScreen( my_screen1 );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}