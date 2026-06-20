/* Example7                                                              */
/* This program will open three windows, two are normal and the third is */
/* a Backdrop window. The windows will use all System Gadgets, except    */
/* the Backdrop window, which only can use the close-window gadget.      */
/* After 30 seconds the program quits.                                   */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to Window structure number one: */ 
struct Window *my_window1;

/* Declare and initialize your NewWindow structure number one: */
struct NewWindow my_new_window1=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  200,           /* Width       200 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING,  /*             Sizing Gadget. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "MY WINDOW 1", /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* Declare a pointer to Window structure number two: */
struct Window *my_window2;

/* Declare and initialize your NewWindow structure number two: */
struct NewWindow my_new_window2=
{
  300,           /* LeftEdge    x position of the window. */
  50,            /* TopEdge     y positio of the window. */
  200,           /* Width       200 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "MY WINDOW 2", /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  0,             /* MaxWidth    than the default sixe (200x100). */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* Declare a pointer to Window structure number three: */ 
struct Window *my_window3;

/* Declare and initialize your NewWindow structure number three: */
struct NewWindow my_new_window3=
{
  10,            /* LeftEdge    x position of the window. */
  10,            /* TopEdge     y positio of the window. */
  400,           /* Width       400 pixels wide. */
  150,           /* Height      150 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  BACKDROP|      /*             Backdrop window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "BACKDROP",    /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we havent supplied the window with */
  0,             /* MaxWidth    a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* We will now try to open the first window: */
  my_window1 = (struct Window *) OpenWindow( &my_new_window1 );
  
  /* Have we opened the first window succesfully? */
  if(my_window1 == NULL)
  {
    /* Could NOT open the first Window! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We will now try to open the second window: */
  my_window2 = (struct Window *) OpenWindow( &my_new_window2 );
  
  /* Have we opened the second window succesfully? */
  if(my_window2 == NULL)
  {
    /* Could NOT open the second Window! */
    
    /* We must close the first window since we have opened it: */
    CloseWindow( my_window1 );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We will now try to open the third window: (The Backdrop window) */
  my_window3 = (struct Window *) OpenWindow( &my_new_window3 );
  
  /* Have we opened the third window succesfully? */
  if(my_window3 == NULL)
  {
    /* Could NOT open the third Window! */
    
    /* We must close the window one and two since we have opened them: */
    CloseWindow( my_window2 );
    CloseWindow( my_window1 );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the windows, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  /* (It does not matter in which order we close the windows.) */
  CloseWindow( my_window1 );
  CloseWindow( my_window2 );
  CloseWindow( my_window3 );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}