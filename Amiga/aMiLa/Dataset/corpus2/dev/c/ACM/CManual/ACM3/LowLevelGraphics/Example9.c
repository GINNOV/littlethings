/* Example 9                                                             */
/* This example shows how to flood fill a figure, and how to draw filled */
/* rectangles (both solid as well as filled with single and multi        */
/* coloured patterns).                                                   */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>


/* NOTE! We must include the file "gfxmacros.h" inorder to be able to */
/* use the functions (macros) SetOPen() and SetAfPt().                */


#define WIDTH  320 /* 320 pixels wide (low resolution)                */
#define HEIGHT 200 /* 200 lines high (non interlaced NTSC display)    */ 
#define DEPTH    2 /* 2 BitPlanes should be used, gives four colours. */
#define COLOURS  4 /* 2^2 = 4                                         */


#define OUTLINE_MODE 0 /* Fill until we find same colour as Outline Pen. */
#define COLOUR_MODE  1 /* Fill until we find another colour.             */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


struct View my_view;
struct View *my_old_view;
struct ViewPort my_view_port;
struct RasInfo my_ras_info;
struct BitMap my_bit_map;
struct RastPort my_rast_port;


UWORD my_color_table[] =
{
  0x000, /* Colour 0, Black */
  0xF00, /* Colour 1, Red   */
  0x0F0, /* Colour 2, Green */
  0x00F  /* Colour 3, Blue  */
};


/* The coordinates (25) for the PolyDraw() function: */
WORD coordinates[] =
{
    0,   0,
  120,   0,
  120,  40,
  180,  40,
  180,   0,
  300,   0,
  300,  20,
  200,  20,
  200,  60,
  160,  60,
  160, 100,
  280, 100,
  280,  40,
  300,  40,
  300, 120,
    0, 120,
    0,  40,
   20,  40,
   20, 100,
  140, 100,
  140,  60,
  100,  60,
  100,  20,
    0,  20,
    0,   0
};


/* A heart (1 BitPlane):                                               */
/* An area pattern is always 16 bits wide, and the hight is some power */
/* of two (1, 2, 4, 8, 16, 32, and so on ).                            */
UWORD pattern[] =
{
  0x38E0, /* 0011 1000 1110 0000 */
  0x7DF0, /* 0111 1101 1111 0000 */
  0xFFF8, /* 1111 1111 1111 1000 */
  0xFFF8, /* 1111 1111 1111 1000 */
  0xFFF8, /* 1111 1111 1111 1000 */
  0x7FF0, /* 0111 1111 1111 0000 */
  0x3FE0, /* 0011 1111 1110 0000 */
  0x1FC0, /* 0001 1111 1100 0000 */
  0x0F80, /* 0000 1111 1000 0000 */
  0x0700, /* 0000 0111 0000 0000 */
  0x0200, /* 0000 0010 0000 0000 */

  0x0000, /* 0000 0000 0000 0000 */
  0x0000, /* 0000 0000 0000 0000 */
  0x0000, /* 0000 0000 0000 0000 */
  0x0000, /* 0000 0000 0000 0000 */
  0x0000, /* 0000 0000 0000 0000 */
};


/* A four-coloured pattern: (Black, red, green and blue lines) */
UWORD coloured_pattern[][] =
{
  {
    0x00FF, /* BitPlane 0 */
    0xFF00,
    0x00FF,
    0xFF00
  },
  {
    0x00FF, /* BitPlane 1 */
    0x00FF,
    0xFF00,
    0xFF00
  }
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
  my_view_port.Modes = NULL;           /* Low resolution.               */


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



  SetDrMd( &my_rast_port, JAM2 ); /* Use Fg and Bg Pen. */
  SetAPen( &my_rast_port, 3 );    /* FgPen:  Blue       */
  SetBPen( &my_rast_port, 2 );    /* BgPen:  Green      */
  SetOPen( &my_rast_port, 3 );    /* BgPen:  Blue       */


  /* Draw a funny figure in blue colour: */
  Move( &my_rast_port, 0, 0 );
  PolyDraw( &my_rast_port, 25, coordinates );


  /* Wait 5 seconds: */
  Delay( 50 * 5 );


  /* Change FgPen colour to red, and fill the figure: */
  SetAPen( &my_rast_port, 1 );    /* FgPen: Red       */
  Flood( &my_rast_port, OUTLINE_MODE, 10, 10 );


  /* Wait 5 seconds: */
  Delay( 50 * 5 );
  

  /* Draw a filled rectangle at the bottom of the display: */
  RectFill( &my_rast_port, 0, 150, 150, 190 );


  /* Wait 5 seconds: */
  Delay( 50 * 5 );


  /* Set the are pattern. We will now draw a rectangle filled with a */
  /* lot of  hearts. (The pattern is 16 lines tall which is 2 to the  */
  /* power of 4.)                                                    */
  SetAfPt( &my_rast_port, (USHORT *) pattern, 4);

  /* Draw a rectangle filled with hearts at the bottom of the display: */
  RectFill( &my_rast_port, 150, 150, 300, 190 );


  /* Wait 5 seconds: */
  Delay( 50 * 5 );


  /* Prepare to fill with a coloured pattern: */
  /* Drawmode JAM2, FgPen colour 255, BgPen 0 */
  SetDrMd( &my_rast_port, JAM2 );
  SetAPen( &my_rast_port, 255 );
  SetBPen( &my_rast_port, 0 );
  SetAfPt( &my_rast_port, (USHORT *) coloured_pattern, -2);
  /* 4 lines = 2^2 -> 2 : Multicolour: -2 */

  /* Draw a rectangle filled with four colours: */
  RectFill( &my_rast_port, 0, 150, 300, 190 );


  /* Wait 5 seconds: */
  Delay( 50 * 5 );



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
