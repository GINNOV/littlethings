/* Example 3                                                          */
/* This example shows how to create a display that covers the entire  */
/* display. This method is called "Overscan", and is primarly used in */
/* video and graphics programs, but can also be used in games etc to  */
/* make the display more interesting.                                 */

/* EXTRA INFORMATION                                                  */
/* If you want your programs to work on both American (NTSC) and      */
/* European (PAL) machines you must either:                           */
/* 1. Not make the display taller than 200 lines. The program will    */
/*    then run perfectly on both types of machines, BUT the European  */
/*    user would be very annoyed since the last 56 lines could not    */
/*    be used.                                                        */
/* 2. Look at the GfxBase structure and see if the program is running */
/*    on an American machine, set the height to max 200 lines, or if  */
/*    the program is running on a European machine, set the height    */
/*    to max 256 lines. (For interlaced displays: 400 or 512 lines)   */
/*    Example:  if( GfxBase->DisplayFlags & NTSC )                    */
/*                Height=200;                                         */
/*              if( GfxBase->DisplayFlags & PAL )                     */
/*                Height=256;                                         */


#include <intuition/intuition.h>
#include <graphics/gfxbase.h>


#define WIDTH       352 /* Display 352 pixels wide. [Overscan]       */ 
#define NTSC_HEIGHT 262 /* Display 262 lines high. [NTSC - Overscan] */
#define PAL_HEIGHT  287 /* Display 287 lines high. [PAL - Overscan]  */

/* The ViewPort should be placed above and more to the    */
/* left than what is normally used:                       */
#define DXOFFSET -16 /* DxOffset -16 pixels.              */
#define DYOFFSET -31 /* DyOffset -31 lines.               */

#define DEPTH      2 /* 2 BitPlanes should be used, gives four colours. */
#define COLOURS    8 /* 2^2 = 4                                         */


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
  0x00F, /* Colour 3, Blue  */
};


SHORT height;  


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


  /* Check if the program is running on a PAL or NTSC machine: */
  if( GfxBase->DisplayFlags & PAL )
  {
    height = PAL_HEIGHT;
    printf( "You have an European (PAL) machine!\n" );
  }
  else
  {
    height = NTSC_HEIGHT;
    printf( "You have an American (NTSC) machine!\n" );
  }


  /* Save the current View, so we can restore it later: */
  my_old_view = GfxBase->ActiView;


  /* 1. Prepare the View structure, and give it a pointer to */
  /*    the first ViewPort:                                  */
  InitView( &my_view );
  my_view.ViewPort = &my_view_port;


  /* 2. Prepare the ViewPort structure, and set some important values:   */
  InitVPort( &my_view_port );
  my_view_port.DWidth = WIDTH;         /* Set the width.                */
  my_view_port.DHeight = height;       /* Set the height.               */
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
  InitBitMap( &my_bit_map, DEPTH, WIDTH, height );

  /* Allocate memory for the Raster: */ 
  for( loop = 0; loop < DEPTH; loop++ )
  {
    my_bit_map.Planes[ loop ] = (PLANEPTR) AllocRaster( WIDTH, height );
    if( my_bit_map.Planes[ loop ] == NULL )
      clean_up( "Could NOT allocate enough memory for the raster!" );

    /* Clear the display memory with help of the Blitter: */
    BltClear( my_bit_map.Planes[ loop ], RASSIZE( WIDTH, height ), 0 );
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
    WritePixel( &my_rast_port, rand() % WIDTH, rand() % height );
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
      FreeRaster( my_bit_map.Planes[ loop ], WIDTH, height );

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
