/* Example7                                                            */
/* This program will open a normal window which is connected to the    */
/* Workbench Screen. We will then draw the nice 4 colour face that was */
/* described in chapter 3.5 IMAGES.                                    */



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
  80,            /* Height      80 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "THE 4 COLOUR FACE",/* Title  Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* REMEMBER! Image data MUST be put in chip-memory! */
USHORT chip my_image_data[]= /* Image data for a nice four colour face: */
{
  0x3E00, /* Bitplane ZERO */
  0x7F00,
  0xC980,
  0xBE80,
  0xFF80,
  0xFF80,
  0xEB80,
  0xEB80,
  0xFF80,
  0xDD80,
  0x6300,
  0x7F00,
  0x3E00,

  0x3E00, /* Bitplane ONE */
  0x7F00,
  0xFF80,
  0xFF80,
  0xC980,
  0xC980,
  0xDD80,
  0xDD80,
  0xFF80,
  0xFF80,
  0x7F00,
  0x7F00,
  0x3E00
};

struct Image my_image=
{
  40, 30,         /* LeftEdge, TopEdge. */
  9,              /* Width, 9 pixels/bitts wide. */
  13,             /* Height, 13 lines high. */
  2,              /* Depth, two Bitplanes, 4 colours. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0003,         /* PickPlane, bitplane Zero and One affects. */
  0x0000,         /* PlaneOnOff, all Bitplanes are already "picked". */
  NULL            /* NextImage, no more Images. */
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



  /* Tell Intuition to draw the face: */
  DrawImage( my_window->RPort, &my_image, 0, 0 );



  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}