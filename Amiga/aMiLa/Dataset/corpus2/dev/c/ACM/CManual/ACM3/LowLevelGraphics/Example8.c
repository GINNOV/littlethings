/* Example 8                                                           */
/* This example shows how to use the functions: SetAPen(), SetBPen(),  */
/* SetOPen(), SetDrMd(), SetDrPt(), WritePixel(), ReadPixel(), Move(), */
/* Draw(), Text() and finally PolyDraw().                              */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>


/* NOTE! We must include the file "gfxmacros.h" inorder to be able to */
/* use the function (macro) SetDrPt().                                */


#define WIDTH  320 /* 320 pixels wide (low resolution)                */
#define HEIGHT 200 /* 200 lines high (non interlaced NTSC display)    */ 
#define DEPTH    2 /* 2 BitPlanes should be used, gives four colours. */
#define COLOURS  4 /* 2^2 = 4                                         */


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


/* The coordinates for the PolyDraw() function: (Creates a small box) */
WORD coordinates[] =
{
  100, 10,
  140, 10,
  140, 50,
  100, 50,
  100, 10
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


  SetDrMd( &my_rast_port, JAM1 ); /* Use FgPen only. */
  SetAPen( &my_rast_port, 2 );    /* FgPen: Green    */
  SetBPen( &my_rast_port, 1 );    /* BgPen: Red      */



  /* Write a pixel: */
  WritePixel( &my_rast_port, 10, 10 );


  /* Check what colour the pixel was drawn with: */
  printf( "Colour: %d\n", ReadPixel( &my_rast_port, 10, 10 ) );


  /* Move the cursor to (20, 10) and draw a simple line to (20, 100): */
  Move( &my_rast_port, 20, 10 );
  Draw( &my_rast_port, 20, 100 );


  /* Move the cursor to (25, 10) and draw a patterned line to (25, 100): */
  /* Pattern: 1111 0110 1111 0110 1111 = F6F6 (hexadecimal)              */
  SetDrPt( &my_rast_port, 0xF6F6 );
  Move( &my_rast_port, 25, 10 );
  Draw( &my_rast_port, 25, 100 );


  /* Write "Hello!" with FgPen (green), do not change the background: */
  Move( &my_rast_port, 30, 10 );
  Text( &my_rast_port, "Hello!", 6 );

  /* Write "Hello!" with FgPen and change background to BgPen: */
  /* (Green text on red background.)                           */
  SetDrMd( &my_rast_port, JAM2 );
  Move( &my_rast_port, 30, 20 );
  Text( &my_rast_port, "Hello!", 6 );

  /* Inversed JAM1. Black text on green background: */
  SetDrMd( &my_rast_port, JAM1|INVERSVID );
  Move( &my_rast_port, 30, 30 );
  Text( &my_rast_port, "Hello!", 6 );

  /* Inversed JAM2. Red text on black background: */
  SetDrMd( &my_rast_port, JAM2|INVERSVID );
  Move( &my_rast_port, 30, 40 );
  Text( &my_rast_port, "Hello!", 6 );

  /* Print the text in red with a green shadow: */
  /* JAM1, green text background unchanged (black): */
  SetDrMd( &my_rast_port, JAM1 );
  Move( &my_rast_port, 30, 50 );
  Text( &my_rast_port, "Hello!", 6 );
  /* Change FgPen to red: */
  SetAPen( &my_rast_port, 1 );
  Move( &my_rast_port, 31, 51 );
  Text( &my_rast_port, "Hello!", 6 );


  /* Draw a small red box:  */
  /* Move to the start position. (Otherwise there would be a line from */
  /* were the cursor is for the moment up to the start position.)      */
  Move( &my_rast_port, 100, 10 );
  PolyDraw( &my_rast_port, 5, coordinates ); /* (5 : Five coordinates) */



  /* Wait 20 seconds: */
  Delay( 50 * 20 );


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
