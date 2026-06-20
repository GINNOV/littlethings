/* Example9                                                            */
/* This program will open a normal window with all system gadgets      */
/* connected to it. If you activate the window, the pointer will chage */
/* shapes into a "nice" arrow.                                         */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,            /* LeftEdge    x position of the window. */
  50,            /* TopEdge     y positio of the window. */
  200,           /* Width       200 pixels wide. */
  150,           /* Height      150 lines high. */
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
  "MY WINDOW",   /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* Declare and initialize Sprite data for the Pointer: */
USHORT chip my_sprite_data[36]=
{
	0x0000, 0x0000, /* Used by Intuition only. */

	0x0000, 0x0100,
	0x0000, 0x0300,
	0x0200, 0x0700,
	0x0600, 0x0D00,
	0x0E00, 0x1900,
	0x1E00, 0x31FC,
	0x3FFC, 0x60FE,
	0x7FFE, 0xc003,
	0x3FFE, 0x4001,
	0x1E0E, 0x21F1,
	0x0E0E, 0x1119,
	0x060E, 0x0919,
	0x020E, 0x0519,
	0x000E, 0x0319,
	0x000E, 0x0119,
	0x0000, 0x001F,

	0x0000, 0x0000  /* Used by Intuition only. */
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



  /* We will now call the function SetPointer() to change the windows */
  /* default pointer. If you now Activate the window, by clicking */
  /* somewhere inside it, the pointer will change: */
  SetPointer( my_window, my_sprite_data, 16, 16, 0, -7);

  /* my_window:       Pointer to the window. */
  /* &my_sprite_data: Pointer to the Sprite Data. */
  /* 16:              Height, 16 lines. */
  /* 16:              Width, 16 pixels. */
  /* 0:               XOffset, left side. (Position of the "Hot Spot") */
  /* -7:              YOffset, 7 lines down.         -"- */


  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}