/* Example1                                                         */
/* This program will open a normal window which is connected to the */
/* Workbench Screen. We will then draw a strange line with help of  */
/* Intuition's Border structure.                                    */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  40,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y positio of the window. */
  250,           /* Width       250 pixels wide. */
  40,            /* Height      40 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "STRANGE LINE",/* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* The coordinates for the lines: */
SHORT my_points[]=
{
  10,10, /* Start at position (10,10) */
  25,10, /* Draw a line to the right to position (25,10) */
  25,14, /* Draw a line down to position (25,14) */
  35,14, /* Draw a line to the right to position (35,14) */
  35,12  /* Finish of by drawing a line up to position (35,12) */ 
};



/* The Border structure: */
struct Border my_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  3,           /* FrontPen, colour register 3. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 3. */
  5,           /* Count, 5 pair of coordinates in the array. */
  my_points,   /* XY, pointer to the array with the coordinates. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};



main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
  {
    /* Could NOT open the Window! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* Tell Intuition to draw a strange line, using my_border structure: */
  DrawBorder( my_window->RPort, &my_border, 10, 12 );



  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}