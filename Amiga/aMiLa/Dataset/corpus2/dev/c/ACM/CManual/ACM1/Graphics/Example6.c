/* Example6                                                            */
/* This program will open a normal window which is connected to the    */
/* Workbench Screen. We will then draw the little nice arrow we talked */
/* so much about. This time, however, we draw it several times in      */
/* different colours. This shows how PlanePick/PlaneOnOff works.       */



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
  150,           /* Width       150 pixels wide. */
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
  "ARROWS",      /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* REMEMBER! Image data MUST be put in chip-memory! */
USHORT chip my_image_data[]=
{
  0x1000, /* BitPlane ZERO */
  0x3800,
  0x7C00,
  0xFE00,
  0x1000,
  0x1000,
  0x1000,
  0x1000
};

/* Orange arrow on black background: */
struct Image my_image4=
{
  70, 30,         /* LeftEdge, TopEdge. */
  7,              /* Width, 7 pixels/bitts wide. */
  8,              /* Height, 8 lines high. */
  1,              /* Depth, only one Bitplane. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0001,         /* PickPlane, bitplane Zero affects. */
  0x0002,         /* PlaneOnOff, Bitplane One will be filled with 1's. */
                  /* [The pixels' colour will be either 0010 (black) or */
                  /* 0011 (orange).] */
  NULL            /* NextImage, last structure in the list. */
};

/* Orange arrow on white background: */
struct Image my_image3=
{
  50, 30,         /* LeftEdge, TopEdge. */
  7,              /* Width, 7 pixels/bitts wide. */
  8,              /* Height, 8 lines high. */
  1,              /* Depth, only one Bitplane. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0002,         /* PickPlane, bitplane One affects. */
  0x0001,         /* PlaneOnOff, Bitplane Zero will be filled with 1's. */
                  /* [The pixels' colour will be either 0001 (white) or */
                  /* 0011 (orange).] */
  &my_image4      /* NextImage, linked to my_image2. */
};

/* Black arrow on blue background: */
struct Image my_image2=
{
  30, 30,         /* LeftEdge, TopEdge. */
  7,              /* Width, 7 pixels/bitts wide. */
  8,              /* Height, 8 lines high. */
  1,              /* Depth, only one Bitplane. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0002,         /* PickPlane, bitplane One affects. */
  0x0000,         /* PlaneOnOff, 0's on all other Bitplanes. */
                  /* [The pixels' colour will be either 0000 (0:blue) or */
                  /* 0010 (2:black).] */
  &my_image3      /* NextImage, linked to my_image3. */
};

/* White arrow on blue background: */
struct Image my_image1=
{
  10, 30,         /* LeftEdge, TopEdge. */
  7,              /* Width, 7 pixels/bitts wide. */
  8,              /* Height, 8 lines high. */
  1,              /* Depth, only one Bitplane. */
  my_image_data,  /* ImageData, pointer to my_image_data. */
  0x0001,         /* PickPlane, bitplane Zero affects. */
  0x0000,         /* PlaneOnOff, 0's on all other Bitplanes. */
                  /* [The pixels' colour will be either 0000 (0:blue) or */
                  /* 0001 (1:white).] */
  &my_image2      /* NextImage, linked to my_image2. */
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



  /* Tell Intuition to draw the images: */
  DrawImage( my_window->RPort, &my_image1, 0, 0 );



  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}