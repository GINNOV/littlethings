/* Example 5                                                           */
/* This example demonstrates how to open a ViewPort in interlace mode. */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>


#define WIDTH  640 /* 640 pixels wide (high resolution)                */
#define HEIGHT 400 /* 400 lines high (interlaced NTSC display)         */ 
#define DEPTH    3 /* 3 BitPlanes should be used, gives eight colours. */
#define COLOURS  8 /* 2^3 = 8                                          */


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
  0x000, /* Colour 0, Black       */
  0x800, /* Colour 1, Red         */
  0xF00, /* Colour 2, Light red   */
  0x080, /* Colour 3, Green       */
  0x0F0, /* Colour 4, Light green */
  0x008, /* Colour 5, Blue        */
  0x00F, /* Colour 6, Light Blue  */
  0xFFF, /* Colour 7, White       */
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
  /* The View should be interlaced: */
  my_view.Modes = LACE;


  /* 2. Prepare the ViewPort structure, and set some important values: */
  InitVPort( &my_view_port );
  my_view_port.DWidth = WIDTH;         /* Set the width.                */
  my_view_port.DHeight = HEIGHT;       /* Set the height.               */
  my_view_port.RasInfo = &my_ras_info; /* Give it a pointer to RasInfo. */
  my_view_port.Modes = HIRES|LACE;     /* High resolution interlace.    */


  /* IMPORTANT! If you want a ViewPort to be interlaced you have to set */
  /* the LACE flag in both the ViewPort as well as in the View          */
  /* structure. If the ViewPort is interlaced but the View is non-      */
  /* interlaced, only every second line in the ViewPort would be drawn. */
  /* If the ViewPort is non-interlaced but the View is interlaced,      */
  /* each line in the ViewPort would be drawn twice.                    */


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

  /* Draw 10000 lines in eight different colours, randomly. */ 
  /* Position the pen: */
  Move( &my_rast_port, rand() % WIDTH, rand() % HEIGHT );
  for( loop = 0; loop < 10000; loop++ )
  {
    /* Set FgPen's colour (0-7): */
    SetAPen( &my_rast_port, rand() % COLOURS );
    /* Draw a line: */
    Draw( &my_rast_port, rand() % WIDTH, rand() % HEIGHT );
  }


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
  FreeCprList( my_view.SHFCprList ); /* ! */

  /* An interlaced display use two copper lists (the normal LOF plus   */
  /* the special SHF). When your program closes an interlaced ViewPort */
  /* you must therefore deallocate both lists!                         */


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
