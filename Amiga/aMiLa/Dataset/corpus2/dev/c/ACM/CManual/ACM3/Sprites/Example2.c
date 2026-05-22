/* Example2                                                            */
/* This program shows how to declare and initialize some sprite data   */
/* and a SimpleSprite structure. It also shows how to reserve a sprite */
/* (sprite 2), and how to move it around. The user moves the sprite by */
/* pressing the arrow keys. In this example we animate the sprite (6   */
/* frames taken from Miniblast).                                       */



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
  "MICROBLAST",  /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/*********************************************************************/
/* Extra information:                                                */
/* When we declare the window pointer, the intuition library pointer */
/* etc, we initialize them to point to NULL:                         */
/* struct Window *my_window = NULL;                                  */
/* Since we then know that all of the pointers will point to NULL    */
/* when we start, we can check if they still point to NULL when we   */
/* quit. If they do not point to NULL anymore, we close that window, */
/* library etc.                                                      */
/*********************************************************************/



/********************************************************/
/* 1. Declare and initialize some sprite graphics data: */
/********************************************************/
/* Sprite data for a ship: */
/* (6 frames, 4 different images: 1 2 3 4 3 2) */
UWORD chip ship_data[6][28]=
{
  {
  	0x0000, 0x0000, /* Ship 1 */

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

  	0x0000, 0x0000,
  },
  {
  	0x0000, 0x0000, /* Ship 2 */

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

  	0x0000, 0x0000,
  },
  {
  	0x0000, 0x0000, /* Ship 3 */

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

  	0x0000, 0x0000,
  },
  {
  	0x0000, 0x0000, /* Ship 4 */

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

  	0x0000, 0x0000,
  },
  {
  	0x0000, 0x0000, /* Ship 5 (3) */

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

  	0x0000, 0x0000,
  },
  {
  	0x0000, 0x0000, /* Ship 6 (2) */

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

  	0x0000, 0x0000,
  }
};



/*******************************************************/
/* 2. Declare and initialize a SimpleSprite structure: */
/*******************************************************/
struct SimpleSprite my_sprite=
{
  ship_data[0],   /* posctldata, pointer to the sprite data. (Frame 0) */
  12,             /* height, 12 lines tall. */
  40, 80,         /* x, y, position on the screen. */
  -1,             /* num, this field is automatically initialized when  */
                  /* you call the GetSprite() function, so we set it to */
                  /* -1 for the moment.                                 */
};



void main()
{
  /* Sprite position: */
  WORD x = my_sprite.x;
  WORD y = my_sprite.y;

  /* Direction of the sprite: */
  WORD x_direction = 0;
  WORD y_direction = 0;

  UWORD frame = 0; /* Frame 0 */

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
    free_memory(); /* Could NOT open the Intuition Library! */



  /* Since we are using sprites we need to open the Graphics Library: */
  /* Open the Graphics Library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
    free_memory(); /* Could NOT open the Graphics Library! */



  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
    free_memory(); /* Could NOT open the Window! */



  /* Change the colour register 21 - 23: */
  SetRGB4( &my_window->WScreen->ViewPort, 21, 0x0, 0x0, 0x0 ); /* Black */
  SetRGB4( &my_window->WScreen->ViewPort, 22, 0x0, 0x8, 0x0 ); /* DGreen */
  SetRGB4( &my_window->WScreen->ViewPort, 23, 0x0, 0xD, 0x0 ); /* Green */



  /*******************************/
  /* 3. Try to reserve sprite 2: */
  /*******************************/
  if( GetSprite( &my_sprite, 2 ) != 2 )
    free_memory(); /* Could not reserve sprite number 2. */



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

    /* Move the sprite: */
    MoveSprite( 0, &my_sprite, x, y );



    /* Change frame: */
    frame++;
      
    /* 6 frames: */
    if( frame > 5 )
      frame = 0;
      
    /* Change the sprite data: */
    ChangeSprite( 0, &my_sprite, ship_data[ frame ] );



    /* Wait for the videobeam to reach the top of the display: (This */
    /* will slow down the animation so the user can see the sprite)  */
    /* (If you want to have some "action" you can take it away...) */
    WaitTOF();
  }



  /* Free all allocated memory: (Close the window, libraries etc) */
  free_memory();

  /* THE END */
}



/* This function frees all allocated memory. */
void free_memory()
{
  if( my_sprite.num != -1 )
    FreeSprite( my_sprite.num );

  if( my_window )
    CloseWindow( my_window );
  
  if( GfxBase )
    CloseLibrary( GfxBase );

  if( IntuitionBase )
    CloseLibrary( IntuitionBase );

  exit();
}
