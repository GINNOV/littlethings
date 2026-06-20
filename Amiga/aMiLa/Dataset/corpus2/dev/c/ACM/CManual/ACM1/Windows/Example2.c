/* Example2                                                         */
/* This program will open a high resolution 16 colour Custom Screen */
/* and a normal window which is connected to it. It will display it */
/* for 30 seconds, and then close the Custom Screen and the window. */



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
  640,          /* Width     We are using a high-resolution screen. */
  200,          /* Height    Non-Interlaced NTSC (American) display. */
  4,            /* Depth     16 colours. */
  0,            /* DetailPen Text should be drawn with colour reg. 0 */
  1,            /* BlockPen  Blocks should be drawn with colour reg. 1 */
  HIRES,        /* ViewModes High-resolution. (Non-Interlaced) */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "MY SCREEN",  /* Title     The screen' title. */
  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};




/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  150,           /* Width       150 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH, /* Flags       Intuition should refresh the window. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "MY WINDOW",   /* Title       Title of the window. */
  NULL,          /* Screen      We will later connect it to the screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we havent supplied the window with */
  0,             /* MaxWidth    a Sizing Gadget. */
  0,             /* MaxHeight */
  CUSTOMSCREEN   /* Type        Connected to the Workbench Screen. */
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



  /* Before we can open the window we need to give the NewWindow */
  /* structure a pointer to the opened Custom Screen: */
  my_new_window.Screen = my_screen;



  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
  {
    /* Could NOT open the Window! */

    /* Close the screen since we have opened it: */
    CloseScreen( my_screen );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close what we have opened: */
  CloseWindow( my_window );

  /* Remember that all windows connected to a screen must be closed */
  /* before you may close the screen! */
  CloseScreen( my_screen );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}