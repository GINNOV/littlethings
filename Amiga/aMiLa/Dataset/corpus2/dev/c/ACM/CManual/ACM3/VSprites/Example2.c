/* Example 2                                             */
/* This example demonstrates how to use several VSprites */
/* each with its own colour table.                       */



/* Since we use Intuition, include this file: */
#include <intuition/intuition.h>

/* Include this file since you are using sprites: */
#include <graphics/gels.h>



/* We will use 15 VSprites: */
#define MAXVSPRITES 15

/* They will move two pixels each time: */
#define SPEED 2



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
  "VSprites are great!",        /* Title */
  NULL,          /* Screen      Will later be connected to a custom scr. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  320,           /* MaxWidth    than 320 x 200. */
  200,           /* MaxHeight   */
  CUSTOMSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* 1. Declare and initialize some sprite data: */
UWORD chip vsprite_data[]=
{
  0x0180, 0x0000,
  0x03C0, 0x0000,
  0x07E0, 0x0000,
  0x0FF0, 0x0000,
  0x1FF8, 0x0000,
  0x3FFC, 0x0000,
  0x7FFE, 0x0000,
  0x0000, 0xFFFF,
  0x0000, 0xFFFF,
  0x7FFE, 0x7FFE,
  0x3FFC, 0x3FFC,
  0x1FF8, 0x1FF8,
  0x0FF0, 0x0FF0,
  0x07E0, 0x07E0,
  0x03C0, 0x03C0,
  0x0180, 0x0180,
};



/* 2. Declare three VSprite structures. One will be used, */
/*    the other two are "dummies":                        */
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
  WORD y_direction[ MAXVSPRITES ];

  /* Boolean variable used for the while loop: */
  BOOL close_me = FALSE;

  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  /* Used as counter in the for loop: */
  UBYTE loop;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    clean_up(); /* Could NOT open the Intuition Library! */



  /* 5. Open the Graphics Library:                                    */
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

  /* All sprites except the first two may be used to draw */
  /* the VSprites: ( 11111100 = 0xFC )                    */
  ginfo.sprRsrvd = 0xFC;
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

  /* Set a random seed: */
  srand( 64 );

  for( loop = 0; loop < MAXVSPRITES; loop++ )
  {
    /* Set the VSprite's colours: */
    colour_table[ loop ][ 0 ] = loop;      /* Blue  */
    colour_table[ loop ][ 1 ] = loop << 4; /* Green */
    colour_table[ loop ][ 2 ] = loop << 8; /* Red   */
    
    /* Set the speed and direction of the VSprite: */
    x_direction[ loop ] = SPEED;
    y_direction[ loop ] = -SPEED;

    vsprite[ loop ].Flags = VSPRITE;    /* It is a VSprite.    */
    vsprite[ loop ].X = 10 + 20 * loop; /* X position.         */
    vsprite[ loop ].Y = 10 + 20 * loop; /* Y position.         */
    vsprite[ loop ].Height = 16;        /* 16 lines tall.      */
    vsprite[ loop ].Width = 2;          /* 2 words wide.       */
    vsprite[ loop ].Depth = 2;          /* 2 bitpl, 4 colours. */

    /* Pointer to the sprite data: */
    vsprite[ loop ].ImageData = vsprite_data;

    /* Pointer to the colour table: */
    vsprite[ loop ].SprColors = colour_table[ loop ];


    /* 8. Add the VSprites to the VSprite list: */
    AddVSprite( &vsprite[ loop ], my_window->RPort );
  }
  
  
  /* The VSprites are in the list. */
  vsprite_on = TRUE;


  /* Stay in the while loop until the user has */
  /* selected the Close window gadget:         */
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
      /* Change the position of the VSprite: */
      vsprite[ loop ].X += x_direction[ loop ];
      vsprite[ loop ].Y += y_direction[ loop ];


      /* Check that the sprite does not move outside the screen: */
      if(vsprite[ loop ].X > 300)
        x_direction[ loop ] = -SPEED;

      if(vsprite[ loop ].X < 0)
        x_direction[ loop ] = SPEED;
  
      if(vsprite[ loop ].Y > 180)
        y_direction[ loop ] = -SPEED;
  
      if(vsprite[ loop ].Y < 4)
        y_direction[ loop ] = SPEED;
    }
  
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