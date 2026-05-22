/* Example 2                                                            */
/* This example shows how to create a large Raster and a smaller        */
/* display. We fill the Raster with a lot of pixels in seven different  */
/* colours and by altering the RxOffset and RyOffset values in the      */
/* RasInfo structure, the Raster is scrolled in all directions. This    */
/* method to scroll a large drawing in full speed is used in many games */
/* and was even used in my own racing game "Car".                       */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>


#define RWIDTH   450 /* Raster 450 pixels wide.  */
#define RHEIGHT  250 /* Raster 250 lines high.   */ 

/* The ViewPort is quite small, and is placed in the middle of the View: */
#define DWIDTH   200 /* Display 200 pixels wide. */ 
#define DHEIGHT  100 /* Display 100 lines high.  */
#define DXOFFSET  60 /* DxOffset 60 pixels.      */
#define DYOFFSET  50 /* DyOffset 50 lines.       */

#define DEPTH      3 /* 3 BitPlanes should be used, gives eight colours. */
#define COLOURS    8 /* 2^3 = 8                                          */

#define SPEED      1 /* How many pixels the Raster should be scrolled */
                     /* every time.                                   */


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
  my_old_view = GfxBase->ActiView;


  /* 1. Prepare the View structure, and give it a pointer to */
  /*    the first ViewPort:                                  */
  InitView( &my_view );
  my_view.ViewPort = &my_view_port;


  /* 2. Prepare the ViewPort structure, and set some important values: */
  InitVPort( &my_view_port );
  my_view_port.DWidth = DWIDTH;        /* Set the width.                */
  my_view_port.DHeight = DHEIGHT;      /* Set the height.               */
  my_view_port.DxOffset = DXOFFSET;    /* Set the display X offset.     */
  my_view_port.DyOffset = DYOFFSET;    /* Set the display Y offset.     */
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
  InitBitMap( &my_bit_map, DEPTH, RWIDTH, RHEIGHT );

  /* Allocate memory for the Raster: */ 
  for( loop = 0; loop < DEPTH; loop++ )
  {
    my_bit_map.Planes[ loop ] = (PLANEPTR) AllocRaster( RWIDTH, RHEIGHT );
    if( my_bit_map.Planes[ loop ] == NULL )
      clean_up( "Could NOT allocate enough memory for the raster!" );

    /* Clear the display memory with help of the Blitter: */
    BltClear( my_bit_map.Planes[ loop ], RASSIZE( RWIDTH, RHEIGHT ), 0 );
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
  /* Draw 10000 pixels in seven different colours, randomly. */ 
  for( loop = 0; loop < 10000; loop++ )
  {
    /* Set FgPen's colour (1-7, 0 used for the the background). */
    SetAPen( &my_rast_port, rand() % (COLOURS-1) + 1 );
    /* Write a pixel somewere on the display: */
    WritePixel( &my_rast_port, rand() % RWIDTH, rand() % RHEIGHT );
  }


  /* Scroll the Raster in all directions for a little while: */
  for( loop = 0; loop < 5000; loop++ )
  {
    my_ras_info.RxOffset += deltaX;
    my_ras_info.RyOffset += deltaY;

    /* The Raster is moved in one direction until the other side is */
    /* reached were we change the direction:                        */ 

    /* Have we reached the left side? */
    if( my_ras_info.RxOffset <= 0 )
      deltaX = SPEED;
    /* Have we reached the right (Raster width - Display width) side? */
    if( my_ras_info.RxOffset >= RWIDTH - DWIDTH )
      deltaX = -SPEED;

    /* Have we reached the top side? */
    if( my_ras_info.RyOffset <= 0 )
      deltaY = SPEED;
    /* Have we reached the bottom (Raster height - Display height) side? */
    if( my_ras_info.RyOffset >= RHEIGHT - DHEIGHT )
      deltaY = -SPEED;


    /* Recalculate the display instructions: (If you change any values */
    /* in the display structures the Amiga have to recalculate the     */
    /* entire display instructions. You must therefore call all three  */
    /* display functions: MakeVPort(), MrgCop() and LoadView().)       */
    MakeVPort( &my_view, &my_view_port );
    MrgCop( &my_view );
    LoadView( &my_view );
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
  
  /* Deallocate the display memory, BitPlane for BitPlane: */
  for( loop = 0; loop < DEPTH; loop++ )
    if( my_bit_map.Planes[ loop ] )
      FreeRaster( my_bit_map.Planes[ loop ], RWIDTH, RHEIGHT );

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
