/* Example 3                                                      */
/* This program demonstrates how to animate several (!) VSprites. */



/* Since we use Intuition, include this file: */
#include <intuition/intuition.h>

/* Include this file since you are using sprites: */
#include <graphics/gels.h>



/* We will use 32 VSprites: */
#define MAXVSPRITES 32

/* They will move one pixel each time: */
#define SPEED 1



/* Declare the functions we are going to use: */
void main();
void clean_up();



struct IntuitionBase *IntuitionBase = NULL;
/* We need to open the Graphics library since we are using sprites: */
struct GfxBase *GfxBase = NULL;


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
  SPRITES,      /* ViewModes No special modes. (Low-res, Non-Interlaced) */
  CUSTOMSCREEN, /* Type      Your own customized screen. */
  NULL,         /* Font      Default font. */
  "MY SCREEN",  /* Title     The screen' title. */
  NULL,         /* Gadget    Must for the moment be NULL. */
  NULL          /* BitMap    No special CustomBitMap. */
};



/* Declare a pointer to a Window structure: */ 
struct Window *my_window = NULL;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  0,             /* LeftEdge    x position of the window. */
  0,             /* TopEdge     y positio of the window. */
  320,           /* Width       320 pixels wide. */
  200,           /* Height      200 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW,   /* IDCMPFlags  The window will give us a message if the */
                 /*             user has selected the Close window gad. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "VSprites with no limitations!", /* Title */
  NULL,          /* Screen      Will later be connected to a custom scr. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  320,           /* MaxWidth    than 320 x 200. */
  200,           /* MaxHeight */
  CUSTOMSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* 1. Declare and initialize some sprite data: */
/* (6 frames, 4 different images: 1 2 3 4 3 2) */
UWORD chip ship_data[6][28]=
{
  {
    0xFFF8, 0x0000,
    0x0200, 0x0000,
    0x877C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x8F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  },
  {
    0x7FF0, 0x0000,
    0x0200, 0x0000,
    0x077C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x0F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  },
  {
    0x3FE0, 0x0000,
    0x0200, 0x0000,
    0x877C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x8F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  },
  {
    0x1FC0, 0x0000,
    0x0200, 0x0000,
    0x077C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x0F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  },
  {
    0x3FE0, 0x0000,
    0x0200, 0x0000,
    0x877C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x8F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  },
  {
    0x7FF0, 0x0000,
    0x0200, 0x0000,
    0x077C, 0x0000,
    0x8786, 0x027C,
    0xBFBF, 0x02C6,
    0xEDFF, 0x1AC2,
    0xA57D, 0x1AFE,
    0xBF19, 0x02FE,
    0x0F12, 0x00FC,
    0x04FC, 0x0000,
    0x0809, 0x0000,
    0x3FFE, 0x0000,
  }
};



/* 2. Declare VSprite structures: */
struct VSprite head, tail, vsprite[ MAXVSPRITES ];


/* 3. Declare the VSprites' colour tables:     */
WORD colour_table[ MAXVSPRITES ][ 3 ];


/* 4. Declare a GelsInfo structure: */
struct GelsInfo ginfo;


/* This boolean variable will tell us if the VSprites are */
/* in the list or not:                                    */
BOOL vsprite_on = FALSE;


/* This program will not open any console window if run from */
/* Workbench, but we must therefore not print anything.      */
/* Functions like printf() must therefore not be used.       */
void _main()
{
  /* The GelsInfo structure needs the following arrays: */
  WORD nextline[ 8 ];
  WORD *lastcolor[ 8 ];

  /* Direction of the sprite: */
  WORD x_direction[ MAXVSPRITES ];

  /* Boolean variable used for the while loop: */
  BOOL close_me = FALSE;

  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  UBYTE loop;      /* Used as counter in the for loop: */
  UBYTE image = 0; /* Which image is used, 1-6.        */
  UBYTE x = 0;     /* X and Y position.                */
  UBYTE y = 0;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    clean_up(); /* Could NOT open the Intuition Library! */



  /* Since we are using sprites we need to open the Graphics Library: */
  /* Open the Graphics Library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
    clean_up(); /* Could NOT open the Graphics Library! */



  /* We will now try to open the screen: */
  my_screen = (struct Screen *) OpenScreen( &my_new_screen );

  /* Have we opened the screen succesfully? */
  if(my_screen == NULL)
    clean_up();


  my_new_window.Screen = my_screen;


  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
    clean_up(); /* Could NOT open the Window! */




  /* 6. Initialize the GelsInfo structure: */

  /* All sprites may be used to draw the VSprites: */
  /* ( 11111111 = 0xFF )                           */
  ginfo.sprRsrvd = 0xFF;
  /* If we do not exclude the first two sprites, the mouse */
  /* pointer's colours may be affected.                    */


  /* Give the GelsInfo structure some memory: */
  ginfo.nextLine = nextline;
  ginfo.lastColor = lastcolor;


  /* Give the Rastport a pointer to the GelsInfo structure: */
  my_window->RPort->GelsInfo = &ginfo;

  
  /* Give the GelsInfo structure to the system: */
  InitGels( &head, &tail, &ginfo );



  /* 7. Initialize the VSprite structures: */
  for( loop = 0; loop < MAXVSPRITES; loop++ )
  {
    /* Set the VSprite's colours: */
    colour_table[ loop ][ 0 ] = 0x0000; /* Black */
    colour_table[ loop ][ 1 ] = 0x0080; /* Dark green */
    colour_table[ loop ][ 2 ] = 0x00D0; /* Green */
    
    /* Set the speed and horizontal direction of the VSprite: */
    x_direction[ loop ] = SPEED;

    vsprite[ loop ].Flags = VSPRITE; /* It is a VSprite.    */
    vsprite[ loop ].X = 10 + 20 * x; /* X position.         */
    vsprite[ loop ].Y = 30 + 20 * y; /* Y position.         */
    vsprite[ loop ].Height = 12;     /* 16 lines tall.      */
    vsprite[ loop ].Width = 2;       /* 2 words wide.       */
    vsprite[ loop ].Depth = 2;       /* 2 bitpl, 4 colours. */

    /* Pointer to the sprite data: */
    vsprite[ loop ].ImageData = ship_data[ image ];

    /* Pointer to the colour table: */
    vsprite[ loop ].SprColors = colour_table[ loop ];


    /* 8. Add the VSprites to the VSprite list: */
    AddVSprite( &vsprite[ loop ], my_window->RPort );


    /* Position of the VSprites: */
    y++;
    if( y > 7 )
    {
      y = 0;
      x++;
    }
  }
  
  
  /* The VSprites are in the list. */
  vsprite_on = TRUE;


  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    /* Stay in the while loop as long as we can collect messages: */
    while(my_message = (struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      if( my_message->Class == CLOSEWINDOW)
        close_me=TRUE;

      ReplyMsg( my_message );
    }


    /* Affect all VSprites: */
    for( loop = 0; loop < MAXVSPRITES; loop++ )
    {
      /* Change the x position of the VSprite: */
      vsprite[ loop ].X += x_direction[ loop ];


      /* Check that the sprite does not move outside the screen: */
      if(vsprite[ loop ].X > 300)
        x_direction[ loop ] = -SPEED;

      if(vsprite[ loop ].X < 0)
        x_direction[ loop ] = SPEED;


      /* Change the image of the VSprite: */
      vsprite[ loop ].ImageData = ship_data[ image ];
    }
    

    /* Image counter: */
    image++;
    if( image > 5 )
      image = 0;
  

    /* 9. Sort the Gels list: */
    SortGList( my_window->RPort );

    /* 10. Draw the Gels list: */
    DrawGList( my_window->RPort, &(my_screen->ViewPort) );

    /* 11. Set the Copper and redraw the display: */
    MakeScreen( my_screen );
    RethinkDisplay();    
  }



  /* Free all allocated memory: (Close the window, libraries etc) */
  clean_up();

  /* THE END */
}



/* This function frees all allocated memory. */
void clean_up()
{
  UBYTE loop;
  
  if( vsprite_on )
    for( loop = 0; loop < MAXVSPRITES; loop++ )
      RemVSprite( &vsprite[ loop ] );

  if( my_window )
    CloseWindow( my_window );
  
  if(my_screen )
    CloseScreen( my_screen );

  if( GfxBase )
    CloseLibrary( GfxBase );

  if( IntuitionBase )
    CloseLibrary( IntuitionBase );

  exit();
}
