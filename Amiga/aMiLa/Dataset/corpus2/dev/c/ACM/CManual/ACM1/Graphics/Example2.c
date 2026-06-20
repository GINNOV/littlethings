/* Example2                                                          */
/* This program will open a normal window which is connected to the  */
/* Workbench Screen. We will then draw two rectangles with different */
/* colours. This shows how you can link Border structures to each    */
/* other in order to get the desired effects.                        */



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
  150,           /* Height      150 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "RECTANGLES",  /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* The coordinates for the small rectangle: */
SHORT small_points[]=
{
   0,  0, /* Start at position (0,0) */
  80,  0, /* Draw a line to the right to position (80,0) */
  80, 40, /* Draw a line down to position (80,40) */
   0, 40, /* Draw a line to the left to position (0,40) */
   0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The coordinates for the big rectangle: */
SHORT big_points[]=
{
    0,  0, /* Start at position (0,0) */
  100,  0, /* Draw a line to the right to position (100,0) */
  100, 50, /* Draw a line down to position (100,50) */
    0, 50, /* Draw a line to the left to position (0,50) */
    0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};



/* The small Border structure: */
struct Border small_rectangle=
{
  10, 5,        /* LeftEdge, TopEdge. */
  3,            /* FrontPen, colour register 3. */
  0,            /* BackPen, for the moment unused. */
  JAM1,         /* DrawMode, draw the lines with colour 3. */
  5,            /* Count, 5 pair of coordinates in the array. */
  small_points, /* XY, pointer to the array with the coordinates. */
  NULL          /* NextBorder, no other Border structures are connected. */
};



/* The BIG Border structure: */
struct Border big_rectangle=
{
  0, 0,             /* LeftEdge, TopEdge. */
  1,                /* FrontPen, colour register 1. */
  0,                /* BackPen, for the moment unused. */
  JAM1,             /* DrawMode, draw the lines with colour 1. */
  5,                /* Count, 5 pair of coordinates in the array. */
  big_points,       /* XY, pointer to the array with the coordinates. */
  &small_rectangle  /* NextBorder, pointing to the small_rectangle. */
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



  /* Tell Intuition to draw the rectangles: */
  DrawBorder( my_window->RPort, &big_rectangle, 10, 15 );



  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}