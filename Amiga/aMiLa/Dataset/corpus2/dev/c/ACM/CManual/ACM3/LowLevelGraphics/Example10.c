/* Example 10                                                    */
/* This example demonstrates how to use the Area Fill functions. */
/* [ AreaMove(), AreaDraw() and AreaEnd(). ]                     */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>


#define WIDTH  320 /* 320 pixels wide (low resolution)                */
#define HEIGHT 200 /* 200 lines high (non interlaced NTSC display)    */ 
#define DEPTH    2 /* 2 BitPlanes should be used, gives four colours. */
#define COLOURS  4 /* 2^2 = 4                                         */


#define MAX_VERTICES 100 /* 100 vertices, 5 bytes each = 500 bytes. */ 
#define BUFFERT_SIZE 250 /* 500 bytes = 250 words.                  */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


struct View my_view;
struct View *my_old_view;
struct ViewPort my_view_port;
struct RasInfo my_ras_info;
struct BitMap my_bit_map;

struct RastPort my_rast_port;
struct TmpRas  my_temp_ras;
struct AreaInfo my_area_info;


UWORD my_color_table[] =
{
  0x000, /* Colour 0, Black */
  0xF00, /* Colour 1, Red   */
  0x0F0, /* Colour 2, Green */
  0x00F  /* Colour 3, Blue  */
};


/* The buffert must start on a word boundary: */
UWORD buffert[ BUFFERT_SIZE ];
PLANEPTR extra_space;


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


  /* Prepare the View structure, and give it a pointer to */
  /* the first ViewPort:                                  */
  InitView( &my_view );
  my_view.ViewPort = &my_view_port;


  /* Prepare the ViewPort structure, and set some important values:     */
  InitVPort( &my_view_port );
  my_view_port.DWidth = WIDTH;         /* Set the width.                */
  my_view_port.DHeight = HEIGHT;       /* Set the height.               */
  my_view_port.RasInfo = &my_ras_info; /* Give it a pointer to RasInfo. */
  my_view_port.Modes = NULL;           /* Low resolution.               */


  /* Get a colour map, link it to the ViewPort, and prepare it: */
  my_view_port.ColorMap = (struct ColorMap *) GetColorMap( COLOURS );
  if( my_view_port.ColorMap == NULL )
    clean_up( "Could NOT get a ColorMap!" );

  /* Get a pointer to the colour map: */
  pointer = (UWORD *) my_view_port.ColorMap->ColorTable;

  /* Set the colours: */
  for( loop = 0; loop < COLOURS; loop++ )
    *pointer++ = my_color_table[ loop ];


  /* Prepare the BitMap: */
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

  
  /* Prepare the RasInfo structure: */
  my_ras_info.BitMap = &my_bit_map; /* Pointer to the BitMap structure.  */
  my_ras_info.RxOffset = 0;         /* The top left corner of the Raster */
  my_ras_info.RyOffset = 0;         /* should be at the top left corner  */
                                    /* of the display.                   */
  my_ras_info.Next = NULL;          /* Single playfield - only one       */
                                    /* RasInfo structure is necessary.   */

  /* Create the display: */
  MakeVPort( &my_view, &my_view_port );
  MrgCop( &my_view );


  /* Prepare the RastPort, and give it a pointer to the BitMap. */
  InitRastPort( &my_rast_port );
  my_rast_port.BitMap = &my_bit_map;



  /* 1. Get some space for the vertices and initialize the AreaInfo ptr: */
  InitArea( &my_area_info, buffert, MAX_VERTICES );
  my_rast_port.AreaInfo = &my_area_info;


  /* 2. Allocate some space that is needed to build up the objects: */
  extra_space = (PLANEPTR) AllocRaster( WIDTH, HEIGHT );
  if( extra_space == NULL )
    clean_up( "Could NOT allocate enough memory for the temp raster!" );


  /* 3. Initialize the TmpRas structure: */
  my_rast_port.TmpRas = (struct TmpRas *)
    InitTmpRas( &my_temp_ras, extra_space, RASSIZE( WIDTH, HEIGHT ) );



  /* Show the new View: */
  LoadView( &my_view );



  SetAPen( &my_rast_port, 1 ); /* Red   */
  SetBPen( &my_rast_port, 0 ); /* Black */
  SetOPen( &my_rast_port, 2 ); /* Green */
  SetDrMd( &my_rast_port, JAM1 );



  /* New position: */
  AreaMove( &my_rast_port,  10,  10 );

  /* Add the vertices: */
  AreaDraw( &my_rast_port, 310,  10 );
  AreaDraw( &my_rast_port, 310, 100 );
  AreaDraw( &my_rast_port, 290, 100 );
  AreaDraw( &my_rast_port, 290,  30 );
  AreaDraw( &my_rast_port,  30,  30 );
  AreaDraw( &my_rast_port,  30, 100 );
  AreaDraw( &my_rast_port,  10, 100 );

  /* End this object. The last line will be set automatically in order */
  /* to close the object, and the figure will be filled. The Outline   */
  /* pen (green) will be used to draw a line around the whole object.  */
  AreaEnd( &my_rast_port );


  /* Turn off the outline function: */
  BNDRYOFF( &my_rast_port );


  /* New position: (This figure will not be outlined.) */
  AreaMove( &my_rast_port,  10,  190 );

  /* Add the vertices: */
  AreaDraw( &my_rast_port,  10, 150);
  AreaDraw( &my_rast_port, 310, 190);
  AreaDraw( &my_rast_port, 310, 150);

  /* End this object: */
  AreaEnd( &my_rast_port );



  /* Wait 10 seconds: */
  Delay( 50 * 10 );


  /* Restore the old View: */
  LoadView( my_old_view );


  /* Free all allocated resources and leave. */
  clean_up( "THE END" );
}


/* Returns all allocated resources: */
void clean_up( message )
STRPTR message;
{
  int loop;

  /* Deallocate memory used for the objects: */
  if( extra_space )
    FreeRaster( extra_space, WIDTH, HEIGHT );

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
