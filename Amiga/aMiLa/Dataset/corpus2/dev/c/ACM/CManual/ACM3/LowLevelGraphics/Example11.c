/* Example 11                                                    */
/* This example demonstrate how to copy rectangular memory areas */
/* with help of the blitter.                                     */



#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>


/* NOTE! We must include the file "gfxmacros.h" inorder to be able to */
/* use the function (macro) SetDrPt().                                */


#define WIDTH  320 /* 320 pixels wide (low resolution)             */
#define HEIGHT 200 /* 200 lines high (non interlaced NTSC display) */ 
#define DEPTH    2 /* 2 BitPlanes should be used, gives 4 colours. */
#define COLOURS  4 /* 2^2 = 4                                      */


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
  0x000, /* Colour  0, Black      */
  0x555, /* Colour  1, Dark grey  */
  0x777, /* Colour  2, Grey       */
  0x999, /* Colour  3, Light grey */
};


void clean_up();
void main();


void main()
{
  UWORD *pointer;
  int loop;
  int x, y;
  

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


  SetDrMd( &my_rast_port, JAM1 ); /* Use FgPen only.   */

  SetAPen( &my_rast_port, 1 );    /* Dark grey */
  Move( &my_rast_port, 10, 10 );
  Draw( &my_rast_port, 26, 10 );
  Draw( &my_rast_port, 26, 26 );

  SetAPen( &my_rast_port, 3 );    /* Light grey */
  Draw( &my_rast_port, 10, 26 );
  Draw( &my_rast_port, 10, 10 );

  SetAPen( &my_rast_port, 2 );    /* Grey */
  RectFill( &my_rast_port, 11, 11, 25, 25 );
  WritePixel( &my_rast_port, 10, 10 );
  WritePixel( &my_rast_port, 26, 26 );

  SetAPen( &my_rast_port, 1 );    /* Dark grey */
  WritePixel( &my_rast_port, 13, 13 );
  WritePixel( &my_rast_port, 23, 13 );
  WritePixel( &my_rast_port, 23, 23 );
  WritePixel( &my_rast_port, 13, 23 );


  /* We will now make 150 copies of the brick: */
  for( x = 0; x < 15; x++ )
    for( y = 0; y < 10; y++ )
      BltBitMap(
        &my_bit_map, /* Source                 */
        10, 10,      /* Position, source.      */
        &my_bit_map, /* Destination.           */
        50 + 17 * x, /* Position, destination. */
        10 + 17 * y, /*          - " -         */
        17, 17,      /* Width and height.      */
        0xC0,        /* Normal copy.           */
        0xFF,        /* All bitplanes.         */
        NULL );      /* No temporary storage.  */


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
