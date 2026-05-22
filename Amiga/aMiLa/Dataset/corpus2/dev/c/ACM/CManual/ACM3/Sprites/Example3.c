/* Example3                                                          */
/* This program shows how to set up a 15 coloured sprite, and how to */
/* move it around.                                                   */



#include <intuition/intuition.h>
/* Include this file since you are using sprites: */
#include <graphics/sprite.h>



/* Declare the functions we are going to use: */
void main();
void free_memory();



struct IntuitionBase *IntuitionBase = NULL;
/* We need to open the Graphics library since we are using sprites: */
struct GfxBase *GfxBase = NULL;



/* Declare a pointer to a Window structure: */ 
struct Window *my_window = NULL;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  320,           /* Width       320 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
  RAWKEY,        /*             user has selected the Close window gad, */
                 /*             or if the user has pressed a key. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "15-COLOURED SPRITE",/* Title Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/********************************************************/
/* 1. Declare and initialize some sprite graphics data: */
/********************************************************/

/* Sprite Data for the Bottom Sprite: */
UWORD chip bottom_sprite_data[36]=
{
  0x0000, 0x0000,

  /* Bitplane */
  /* ZERO ONE */
  
  0x0000, 0x0000,
  0xFFFF, 0x0000,
  0x0000, 0xFFFF,
  0xFFFF, 0xFFFF,

  0x0000, 0x0000,
  0xFFFF, 0x0000,
  0x0000, 0xFFFF,
  0xFFFF, 0xFFFF,

  0x0000, 0x0000,
  0xFFFF, 0x0000,
  0x0000, 0xFFFF,
  0xFFFF, 0xFFFF,

  0x0000, 0x0000,
  0xFFFF, 0x0000,
  0x0000, 0xFFFF,
  0xFFFF, 0xFFFF,
    
  0x0000, 0x0000
};

/* Sprite Data for the Top Sprite: */
UWORD chip top_sprite_data[36]=
{
  0x0000, SPRITE_ATTACHED, /* We attach the Top Sprite to the Bottom */
                           /* Sprite.                                */

  /*  Bitplane  */
  /* TWO  THREE */
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,
  0x0000, 0x0000,

  0xFFFF, 0x0000,
  0xFFFF, 0x0000,
  0xFFFF, 0x0000,
  0xFFFF, 0x0000,

  0x0000, 0xFFFF,
  0x0000, 0xFFFF,
  0x0000, 0xFFFF,
  0x0000, 0xFFFF,

  0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF,
  0xFFFF, 0xFFFF,
    
  0x0000, 0x0000
};



/*********************************************************/
/* 2. Declare and initialize two SimpleSprite structure: */
/*********************************************************/

/* Bottom sprite: */
struct SimpleSprite bottom_sprite=
{
  bottom_sprite_data, /* posctldata, pointer to the sprite data. */
  16,                 /* height, 16 lines tall. */
  40, 80,             /* x, y, position on the screen. */
  -1,                 /* num, this field is automatically initialized */
                      /* when you call the GetSprite() function, so   */
                      /* we set it to -1 for the moment.              */
};

/* Top sprite: */
struct SimpleSprite top_sprite=
{
  top_sprite_data, /* posctldata, pointer to the sprite data. */
  16,              /* height, 16 lines tall. */
  40, 80,          /* x, y, position on the screen. */
  -1,              /* num, this field is automatically initialized */
                   /* when you call the GetSprite() function, so   */
                   /* we set it to -1 for the moment.              */
};



void main()
{
  /* Sprite position: (We use only one pair of coordinates since the */
  /* two sprites will be attached to each other.)                    */
  WORD x = bottom_sprite.x;
  WORD y = bottom_sprite.y;

  /* Direction of the sprite: */
  WORD x_direction = 0;
  WORD y_direction = 0;

  /* Boolean variable used for the while loop: */
  BOOL close_me = FALSE;

  ULONG class; /* IDCMP */
  USHORT code; /* Code */

  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;



  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    free_memory("Could NOT open the Intuition Library!");



  /* Since we are using sprites we need to open the Graphics Library: */
  /* Open the Graphics Library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
    free_memory("Could NOT open the Graphics Library!");



  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
    free_memory("Could NOT open the Window!");



  /* Change the colour register 17 - 31: */
  /* NOTE! Since we change colour register 17, 18 and 19 we will */
  /* change the colour of Intuition's Pointer (Sprite 0). We do  */
  /* not bother about that in this Example but you should be     */
  /* careful with these three colour registers.                  */
  SetRGB4( &my_window->WScreen->ViewPort, 17, 0x0, 0xF, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 18, 0x0, 0xD, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 19, 0x0, 0xB, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 20, 0x0, 0x9, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 21, 0x0, 0x7, 0x1 );
  SetRGB4( &my_window->WScreen->ViewPort, 22, 0x0, 0x5, 0x3 );
  SetRGB4( &my_window->WScreen->ViewPort, 23, 0x0, 0x3, 0x5 );
  SetRGB4( &my_window->WScreen->ViewPort, 24, 0x1, 0x1, 0x7 );
  SetRGB4( &my_window->WScreen->ViewPort, 25, 0x3, 0x0, 0x5 );
  SetRGB4( &my_window->WScreen->ViewPort, 26, 0x5, 0x0, 0x3 );
  SetRGB4( &my_window->WScreen->ViewPort, 27, 0x7, 0x0, 0x1 );
  SetRGB4( &my_window->WScreen->ViewPort, 28, 0x9, 0x0, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 29, 0xB, 0x0, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 30, 0xD, 0x0, 0x0 );
  SetRGB4( &my_window->WScreen->ViewPort, 31, 0xF, 0x0, 0x0 );



  /* Reserve sprite 2 as Bottom Sprite: */
  if( GetSprite( &bottom_sprite, 2 ) != 2 )
    free_memory("Could NOT reserve Hardware Sprite 2!"); /* Error! */

  /* Reserve sprite 3 as Top Sprite: */
  if( GetSprite( &top_sprite, 3 ) != 3 )
    free_memory("Could NOT reserve Hardware Sprite 3!"); /* Error! */



  /* We will now move the two sprites so that we can see them: */
  /* (After you have reserved a sprite you need to call either */
  /* MoveSprite() or ChangeSprite() inorder to display the     */
  /* sprite.)                                                  */
  MoveSprite( 0, &bottom_sprite, x, y );
  MoveSprite( 0, &top_sprite, x, y );



  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    /* Stay in the while loop as long as we can collect messages */
    /* sucessfully: */
    while(my_message = (struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      class = my_message->Class;
      code  = my_message->Code;


      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* Some other process has maybe changed it. */
      ReplyMsg( my_message );


      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case CLOSEWINDOW:     /* Quit! */
               close_me=TRUE;
               break;  

        case RAWKEY:          /* A key was pressed! */
               /* Check which key was pressed: */
               switch( code )
               {
                 /* Up Arrow: */
                 case 0x4C:      y_direction = -1; break; /* Pressed */
                 case 0x4C+0x80: y_direction = 0;  break; /* Released */

                 /* Down Arrow: */
                 case 0x4D:      y_direction = 1; break; /* Pressed */
                 case 0x4D+0x80: y_direction = 0; break; /* Released */

                 /* Right Arrow: */
                 case 0x4E:      x_direction = 1; break; /* Pressed */
                 case 0x4E+0x80: x_direction = 0; break; /* Released */

                 /* Left Arrow: */
                 case 0x4F:      x_direction = -1; break; /* Pressed */
                 case 0x4F+0x80: x_direction = 0;  break; /* Released */
               }
               break;  
      }
    }



    /* Change the x/y position: */
    x += x_direction;
    y += y_direction;
    
    /* Check that the sprite does not move outside the screen: */
    if(x > 320)
      x = 320;
    if(x < 0)
      x = 0;
    if(y > 200)
      y = 200;
    if(y < 0)
      y = 0;



    /* Move the bottom sprite: */
    /* IMPORTANT! If you move the Bottom Sprite the Top Sprite will      */
    /* automatically be moved too. However, if you move the Top Sprite   */
    /* the Bottom Sprite will not be moved, and the Attach function will */
    /* not work any more. (You then get two 3-coloured sprites.)         */
    MoveSprite( 0, &bottom_sprite, x, y );



    /* Wait for the videobeam to reach the top of the display: (This */
    /* will slow down the animation so the user can see the sprite)  */
    /* (If you want to have some "action" you can take it away...)   */
    WaitTOF();
  }


    
  /* Free all allocated memory: (Close the window, libraries etc) */
  free_memory("THE END");

  /* THE END */
}



/* This function frees all allocated memory. */
void free_memory( message )
STRPTR message;
{
  printf( "%s\n", message );
  
  if( bottom_sprite.num != -1 )
    FreeSprite( bottom_sprite.num );

  if( top_sprite.num != -1 )
    FreeSprite( top_sprite.num );

  if( my_window )
    CloseWindow( my_window );
  
  if( GfxBase )
    CloseLibrary( GfxBase );

  if( IntuitionBase )
    CloseLibrary( IntuitionBase );

  exit();
}