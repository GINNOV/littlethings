/* Example 6                                                             */
/* This example demonstrates how to create a ViewPort in dual playfield  */
/* mode. Playfield 1 use four colours and is placed behind playfield 2   */
/* which only use two colours (transparent and grey). Playfield 1 is     */
/* filled with a lot of dots and is scrolled around while playfield 2 is */
/* is not moved and is filled with only five grey rectangles.            */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>


#define DWIDTH   320 /* Display 320 pixels wide (low resolution).     */
#define DHEIGHT  200 /* Display 200 lines tall (NTSC non interlaced). */

#define RWIDTH1  600 /* 600 pixels wide.                              */
#define RHEIGHT1 300 /* 300 lines high.                               */
#define DEPTH1     2 /* Playfield one should use 2 BitPlanes.         */

#define RWIDTH2  320 /* 320 pixels wide.                              */
#define RHEIGHT2 200 /* 200 lines high.                               */
#define DEPTH2     1 /* Playfield two should use 1 BitPlane.          */

#define COLOURS   10 /* PF1: colours 0-3, PF2: colours 8 and 9. (0-9) */

#define SPEED      1 /* How many pixels the Raster should be scrolled */
                     /* every time.                                   */

#define BOXES      5 /* Draw 5 rectangles in the second playfield.    */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


struct View view;
struct View *old_view;
struct ViewPort view_port;

/* Playfield 1: */
struct RasInfo ras_info1;
struct BitMap bit_map1;
struct RastPort rast_port1;

/* Playfield 2: */
struct RasInfo ras_info2;
struct BitMap bit_map2;
struct RastPort rast_port2;


UWORD color_table[] =
{
  0x000, /* Colour 0, Black       */
  0xF00, /* Colour 1, Red         */
  0x0F0, /* Colour 2, Green       */
  0x00F, /* Colour 3, Blue        */
  0x000, /* Colour 4, Not used    */
  0x000, /* Colour 5,   - " -     */
  0x000, /* Colour 6,   - " -     */
  0x000, /* Colour 7,   - " -     */
  0x000, /* Colour 8, Transparent */
  0x888  /* Colour 9, Grey        */
};


UWORD box[ BOXES ][ 4 ] =
{
  /*  Minimum  Maximum */
  /*  X    Y    X    Y */
  {    0,   0,  50,  20 },
  {  150,  30, 260,  50 },
  {  290, 100, 319, 150 },
  {  150, 170, 210, 199 },
  {   20,  70,  90, 170 }
};


void clean_up();
void main();


void main()
{
  SHORT deltaX = SPEED;
  SHORT deltaY = SPEED;
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
  old_view = GfxBase->ActiView;



  /* 1. Prepare the View structure, and give it a pointer to */
  /*    the first ViewPort:                                  */
  InitView( &view );
  view.ViewPort = &view_port;



  /* 2. Prepare the ViewPort structure, and set some important values: */
  InitVPort( &view_port );
  view_port.DWidth = DWIDTH;        /* Set the width.                  */
  view_port.DHeight = DHEIGHT;      /* Set the height.                 */
  view_port.RasInfo = &ras_info1;   /* Give it a pointer to RasInfo.   */
  view_port.Modes = DUALPF|PFBA;    /* Dual playfields, 2 on top of 1. */


  /* 3. Get a colour map, link it to the ViewPort, and prepare it: */
  view_port.ColorMap = (struct ColorMap *) GetColorMap( COLOURS );
  if( view_port.ColorMap == NULL )
    clean_up( "Could NOT get a ColorMap!" );

  /* Get a pointer to the colour map: */
  pointer = (UWORD *) view_port.ColorMap->ColorTable;

  /* Set the colours: */
  for( loop = 0; loop < COLOURS; loop++ )
    *pointer++ = color_table[ loop ];



  /* 4. Prepare the BitMaps: */

  /* Playfield 1: */
  InitBitMap( &bit_map1, DEPTH1, RWIDTH1, RHEIGHT1 );
  /* Allocate memory for the Raster: */ 
  for( loop = 0; loop < DEPTH1; loop++ )
  {
    bit_map1.Planes[ loop ] = (PLANEPTR) AllocRaster( RWIDTH1, RHEIGHT1 );
    if( bit_map1.Planes[ loop ] == NULL )
      clean_up( "Could NOT allocate enough memory for the raster!" );

    /* Clear the display memory with help of the Blitter: */
    BltClear( bit_map1.Planes[ loop ], RASSIZE( RWIDTH1, RHEIGHT1 ), 0 );
  }

  /* Playfield 2: */
  InitBitMap( &bit_map2, DEPTH2, RWIDTH2, RHEIGHT2 );
  /* Allocate memory for the Raster: */ 
  for( loop = 0; loop < DEPTH2; loop++ )
  {
    bit_map2.Planes[ loop ] = (PLANEPTR) AllocRaster( RWIDTH2, RHEIGHT2 );
    if( bit_map2.Planes[ loop ] == NULL )
      clean_up( "Could NOT allocate enough memory for the raster!" );

    /* Clear the display memory with help of the Blitter: */
    BltClear( bit_map2.Planes[ loop ], RASSIZE( RWIDTH2, RHEIGHT2 ), 0 );
  }


 
  /* 5. Prepare the RasInfo structures: */

  /* Playfield 1: */
  ras_info1.BitMap = &bit_map1; /* Pointer to the BitMap structure.  */
  ras_info1.RxOffset = 0;       /* The top left corner of the Raster */
  ras_info1.RyOffset = 0;       /* should be at the top left corner  */
                                /* of the display.                   */
  ras_info1.Next = &ras_info2;  /* Link RasInfo1 to RasInfo2.        */

  /* Playfield 2: */
  ras_info2.BitMap = &bit_map2; /* Pointer to the BitMap structure.  */
  ras_info2.RxOffset = 0;       /* The top left corner of the Raster */
  ras_info2.RyOffset = 0;       /* should be at the top left corner  */
                                /* of the display.                   */
  ras_info2.Next = NULL;        /* Last RasInfo structure.           */



  /* 6. Create the display: */
  MakeVPort( &view, &view_port );
  MrgCop( &view );



  /* 7. Prepare the RastPorts, and give them a pointer to each BitMap. */

  /* Playfield 1: */
  InitRastPort( &rast_port1 );
  rast_port1.BitMap = &bit_map1;

  /* Playfield 2: */
  InitRastPort( &rast_port2 );
  rast_port2.BitMap = &bit_map2;
  


  /* 8. Show the new View: */
  LoadView( &view );



  /* Playfield 2: */
  /* Set the draw mode to JAM1. FgPen's colour will be used. */
  SetDrMd( &rast_port2, JAM1 );
  /* Use colour 9 (grey): */
  SetAPen( &rast_port2, 9 );
  /* Draw five grey boxes: */
  for( loop = 0; loop < BOXES; loop++ )
    RectFill( &rast_port2, box[ loop ][ 0 ], 
                           box[ loop ][ 1 ],
                           box[ loop ][ 2 ],
                           box[ loop ][ 3 ] );


  /* Playfield 1: */
  /* Set the draw mode to JAM1. FgPen's colour will be used. */
  SetDrMd( &rast_port1, JAM1 );
  /* PF1: Draw 5000 pixels in four different colours, randomly. */ 
  for( loop = 0; loop < 5000; loop++ )
  {
    /* Set FgPen's colour (0-3): */
    SetAPen( &rast_port1, rand() % 4 );
    /* Write a pixel somewere on the display: */
    WritePixel( &rast_port1, rand() % RWIDTH1, rand() % RHEIGHT1 );
  }

  /* Scroll the Raster (PF 1) in all directions for a little while: */
  for( loop = 0; loop < 5000; loop++ )
  {
    ras_info1.RxOffset += deltaX;
    ras_info1.RyOffset += deltaY;

    /* The Raster is moved in one direction until the other side is */
    /* reached were we change the direction:                        */ 

    /* Have we reached the left side? */
    if( ras_info1.RxOffset <= 0 )
      deltaX = SPEED;
    /* Have we reached the right (Raster width - Display width) side? */
    if( ras_info1.RxOffset >= RWIDTH1 - DWIDTH )
      deltaX = -SPEED;

    /* Have we reached the top side? */
    if( ras_info1.RyOffset <= 0 )
      deltaY = SPEED;
    /* Have we reached the bottom (Raster height - Display height) side? */
    if( ras_info1.RyOffset >= RHEIGHT1 - DHEIGHT )
      deltaY = -SPEED;


    /* Recalculate the display instructions: (If you change any values */
    /* in the display structures the Amiga have to recalculate the     */
    /* entire display instructions. You must therefore call all three  */
    /* display functions: MakeVPort(), MrgCop() and LoadView().)       */
    MakeVPort( &view, &view_port );
    MrgCop( &view );
    LoadView( &view );
  }



  /* 9. Restore the old View: */
  LoadView( old_view );


  /* Free all allocated resources and leave. */
  clean_up( "THE END" );
}


/* Returns all allocated resources: */
void clean_up( message )
STRPTR message;
{
  int loop;

  /* Free automatically allocated display structures: */
  FreeVPortCopLists( &view_port );
  FreeCprList( view.LOFCprList );
  
  /* Deallocate the display memory, BitPlane for BitPlane: */
  /* Playfield 1: */
  for( loop = 0; loop < DEPTH1; loop++ )
    if( bit_map1.Planes[ loop ] )
      FreeRaster( bit_map1.Planes[ loop ], RWIDTH1, RHEIGHT1 );
  /* Playfield 2: */
  for( loop = 0; loop < DEPTH2; loop++ )
    if( bit_map2.Planes[ loop ] )
      FreeRaster( bit_map2.Planes[ loop ], RWIDTH2, RHEIGHT2 );

  /* Deallocate the ColorMap: */
  if( view_port.ColorMap ) FreeColorMap( view_port.ColorMap );

  /* Close the Graphics library: */
  if( GfxBase ) CloseLibrary( GfxBase );

  /* Close the Intuition library: */
  if( IntuitionBase ) CloseLibrary( IntuitionBase );

  /* Print the message and leave: */
  printf( "%s\n", message ); 
  exit();
}
