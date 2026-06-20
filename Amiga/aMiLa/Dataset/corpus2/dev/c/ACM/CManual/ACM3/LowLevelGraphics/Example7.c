/* Example 7                                                           */
/* This example demonstrates how to create a ViewPort with the special */
/* display mode "Hold and Modify".                                     */
/*                                                                     */
/* -------------------------------------------------------------       */
/* BitPlane                                                            */
/*  543210   Description                                               */
/* -------------------------------------------------------------       */
/*  00XXXX   One of the base colours will be used.                     */
/*  01XXXX   The pixel to left will be dublicated, and the blue        */
/*           value will be set by the first four bits (XXXX).          */
/*  10XXXX   The pixel to left will be dublicated, and the red         */
/*           value will be set by the first four bits (XXXX).          */
/*  01XXXX   The pixel to left will be dublicated, and the green       */
/*           value will be set by the first four bits (XXXX).          */
/* -------------------------------------------------------------       */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>


/* Whith help of this macro we can write numbers in binary, and it */
/* will be translated to normal decimal numbers. For example:      */
/* BIN(0,1,0,1,0,1) will be 21 (010101[b] -> 21[d])                */
#define BIN(a,b,c,d,e,f) ((a)<<5|(b)<<4|(c)<<3|(d)<<2|(e)<<1|(f))


#define WIDTH   320 /* 320 pixels wide (low resolution)             */
#define HEIGHT  200 /* 200 lines high (non interlaced NTSC display) */ 
#define DEPTH     6 /* 6 BitPlanes + HAM = 4096 colours.            */
#define COLOURS  16 /* 16 base colours.                             */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


struct View my_view;
struct View *my_old_view;
struct ViewPort my_view_port;
struct RasInfo my_ras_info;
struct BitMap my_bit_map;
struct RastPort my_rast_port;


/* The base colours: */
UWORD my_color_table[] =
{
  0x000, /* Colour  0, Black */
  0x111, /* Colour  1,       */
  0x222, /* Colour  2,   |   */
  0x333, /* Colour  3,   |   */
  0x444, /* Colour  4,   |   */
  0x555, /* Colour  5,   |   */
  0x666, /* Colour  6,   |   */
  0x777, /* Colour  7,   |   */
  0x888, /* Colour  8,   |   */
  0x999, /* Colour  9,   |   */
  0xAAA, /* Colour 10,   |   */
  0xBBB, /* Colour 11,   |   */
  0xCCC, /* Colour 12,   |   */
  0xDDD, /* Colour 13,   V   */
  0xEEE, /* Colour 14,       */
  0xFFF, /* Colour 15, White */
};


void clean_up();
void main();


void main()
{
  UWORD *pointer;
  int loop;


  /* Open the Intuition library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  if( !IntuitionBase )
    clean_up( "Could NOT open the Intuition library!" );

  /* Open the Graphics library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0 );
  if( !GfxBase )
    clean_up( "Could NOT open the Graphics library!" );


  /* Save the current View, so we can restore it later: */
  my_old_view = GfxBase->ActiView;


  /* 1. Prepare the View structure, and give it a pointer to */
  /*    the first ViewPort:                                  */
  InitView( &my_view );
  my_view.ViewPort = &my_view_port;


  /* 2. Prepare the ViewPort structure, and set some important values: */
  InitVPort( &my_view_port );
  my_view_port.DWidth = WIDTH;         /* Set the width.                */
  my_view_port.DHeight = HEIGHT;       /* Set the height.               */
  my_view_port.RasInfo = &my_ras_info; /* Give it a pointer to RasInfo. */
  my_view_port.Modes = HAM;            /* Hold And Moduify.             */


  /* 3. Get a colour map, link it to the ViewPort, and prepare it: */
  my_view_port.ColorMap = (struct ColorMap *) GetColorMap( COLOURS );
  if( my_view_port.ColorMap == NULL )
    clean_up( "Could NOT get a ColorMap!" );

  /* Get a pointer to the colour map: */
  pointer = (UWORD *) my_view_port.ColorMap->ColorTable;

  /* Set the colours: */
  for( loop = 0; loop < COLOURS; loop++ )
    *pointer++ = my_color_table[ loop ];


  /* 4. Prepare the BitMap: */
  InitBitMap( &my_bit_map, DEPTH, WIDTH, HEIGHT );

  /* Allocate memory for the Raster: */ 
  for( loop = 0; loop < DEPTH; loop++ )
  {
    my_bit_map.Planes[ loop ] = (PLANEPTR) AllocRaster( WIDTH, HEIGHT );
    if( my_bit_map.Planes[ loop ] == NULL )
      clean_up( "Could NOT allocate enough memory for the raster!" );

    /* Clear the display memory with help of the Blitter: */
    BltClear( my_bit_map.Planes[ loop ], RASSIZE( WIDTH, HEIGHT ), 0 );
  }

  
  /* 5. Prepare the RasInfo structure: */
  my_ras_info.BitMap = &my_bit_map; /* Pointer to the BitMap structure.  */
  my_ras_info.RxOffset = 0;         /* The top left corner of the Raster */
  my_ras_info.RyOffset = 0;         /* should be at the top left corner  */
                                    /* of the display.                   */
  my_ras_info.Next = NULL;          /* Single playfield - only one       */
                                    /* RasInfo structure is necessary.   */

  /* 6. Create the display: */
  MakeVPort( &my_view, &my_view_port );
  MrgCop( &my_view );


  /* 7. Prepare the RastPort, and give it a pointer to the BitMap. */
  InitRastPort( &my_rast_port );
  my_rast_port.BitMap = &my_bit_map;
  

  /* 8. Show the new View: */
  LoadView( &my_view );


  /* Set the draw mode to JAM1. FgPen's colour will be used. */
  SetDrMd( &my_rast_port, JAM1 );



  /* Base colour 0: */
  SetAPen( &my_rast_port, BIN(0,0,0,0,0,0) );
  RectFill( &my_rast_port, 10, 10, 30, 130 );



  /* Change R to 3 (0011 = 3): */
  SetAPen( &my_rast_port, BIN(1,0,0,0,1,1) );
  RectFill( &my_rast_port, 30, 10, 50, 50 );

  /* Change R to 7 (0111 = 7): */
  SetAPen( &my_rast_port, BIN(1,0,0,1,1,1) );
  RectFill( &my_rast_port, 50, 10, 70, 50 );

  /* Change R to 11 (1011 = 11): */
  SetAPen( &my_rast_port, BIN(1,0,1,0,1,1) );
  RectFill( &my_rast_port, 70, 10, 90, 50 );

  /* Change R to 13 (1101 = 13): */
  SetAPen( &my_rast_port, BIN(1,0,1,1,0,1) );
  RectFill( &my_rast_port, 90, 10, 110, 50 );

  /* Change R to 15 (1111 = 15): */
  SetAPen( &my_rast_port, BIN(1,0,1,1,1,1) );
  RectFill( &my_rast_port, 110, 10, 130, 50 );



  /* Change B to 3 (0011 = 3): */
  SetAPen( &my_rast_port, BIN(0,1,0,0,1,1) );
  RectFill( &my_rast_port, 30, 50, 50, 90 );

  /* Change B to 7 (0111 = 7): */
  SetAPen( &my_rast_port, BIN(0,1,0,1,1,1) );
  RectFill( &my_rast_port, 50, 50, 70, 90 );

  /* Change B to 11 (1011 = 11): */
  SetAPen( &my_rast_port, BIN(0,1,1,0,1,1) );
  RectFill( &my_rast_port, 70, 50, 90, 90 );

  /* Change B to 13 (1101 = 13): */
  SetAPen( &my_rast_port, BIN(0,1,1,1,0,1) );
  RectFill( &my_rast_port, 90, 50, 110, 90 );

  /* Change B to 15 (1111 = 15): */
  SetAPen( &my_rast_port, BIN(0,1,1,1,1,1) );
  RectFill( &my_rast_port, 110, 50, 130, 90 );



  /* Change G to 3 (0011 = 3): */
  SetAPen( &my_rast_port, BIN(1,1,0,0,1,1) );
  RectFill( &my_rast_port, 30, 90, 50, 130 );

  /* Change G to 7 (0111 = 7): */
  SetAPen( &my_rast_port, BIN(1,1,0,1,1,1) );
  RectFill( &my_rast_port, 50, 90, 70, 130 );

  /* Change G to 11 (1011 = 11): */
  SetAPen( &my_rast_port, BIN(1,1,1,0,1,1) );
  RectFill( &my_rast_port, 70, 90, 90, 130 );

  /* Change G to 13 (1101 = 13): */
  SetAPen( &my_rast_port, BIN(1,1,1,1,0,1) );
  RectFill( &my_rast_port, 90, 90, 110, 130 );

  /* Change G to 15 (1111 = 15): */
  SetAPen( &my_rast_port, BIN(1,1,1,1,1,1) );
  RectFill( &my_rast_port, 110, 90, 130, 130 );



  /* Change the basecolour: (Black, dark grey, ... light grey, white) */
  /* As you will notice, not only the base colour will change! Since  */
  /* all rectangles' colours are modified versions of the base colour */
  /* they will also change as the base colour change.                 */
  for( loop = 0; loop < COLOURS; loop++ )
  {
    Delay( 50 );
    SetAPen( &my_rast_port, loop );
    RectFill( &my_rast_port, 10, 10, 30, 130 );
  }
  Delay( 50 );



  /* 9. Restore the old View: */
  LoadView( my_old_view );


  /* Free all allocated resources and leave. */
  clean_up( "THE END" );
}


/* Returns all allocated resources: */
void clean_up( message )
STRPTR message;
{
  int loop;

  /* Free automatically allocated display structures: */
  FreeVPortCopLists( &my_view_port );
  FreeCprList( my_view.LOFCprList );
  
  /* Deallocate the display memory, BitPlane for BitPlane: */
  for( loop = 0; loop < DEPTH; loop++ )
    if( my_bit_map.Planes[ loop ] )
      FreeRaster( my_bit_map.Planes[ loop ], WIDTH, HEIGHT );

  /* Deallocate the ColorMap: */
  if( my_view_port.ColorMap ) FreeColorMap( my_view_port.ColorMap );

  /* Close the Graphics library: */
  if( GfxBase ) CloseLibrary( GfxBase );

  /* Close the Intuition library: */
  if( IntuitionBase ) CloseLibrary( IntuitionBase );

  /* Print the message and leave: */
  printf( "%s\n", message ); 
  exit();
}
