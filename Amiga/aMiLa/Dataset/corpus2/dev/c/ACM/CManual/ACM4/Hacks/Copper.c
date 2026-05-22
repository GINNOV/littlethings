/* Copper.c                                               */
/* This program demonstrates how to play with the Copper. */


#include <intuition/intuition.h> /* Intuition Library           */
#include <graphics/gfxbase.h>    /* Graphics Library [ActiView] */
#include <exec/memory.h>         /* AllocMem() [MEMF_PUBLIC]    */
#include <graphics/view.h>       /* struct ViewPort             */
#include <graphics/gfxmacros.h>  /* CINIT(), CMOVE(), etc       */
#include <hardware/custom.h>     /* struct Custom               */


#define WIDTH  640 /* 640 pixels wide (high resolution)              */
#define HEIGHT 200 /* 200 lines high (non interlaced NTSC display)   */ 
#define DEPTH    1 /* 1 BitPlanes should be used, gives two colours. */
#define COLOURS  2 /* 2^1 = 2                                        */


struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;


/* 1. Declare a Custom structure. This structure will automatically */
/*    be initialized!                                               */
extern struct Custom far custom;


struct View my_view;
struct View *my_old_view;
struct ViewPort my_view_port;
struct RasInfo my_ras_info;
struct BitMap my_bit_map;
struct RastPort my_rast_port;


UWORD my_color_table[] =
{
  0x000, /* Colour 0, Black */
  0xFFF  /* Colour 1, White */
};


void clean_up();
void _main();


/* NOTE! Since we have declared our main() function as _main(), */
/* no Consol window will be opened if it is run from the        */
/* Workbench. The disadvantage is that we must NEVER use the    */
/* printf() or similar console functions. It would crash the    */
/* system.                                                      */
void _main()
{
  /* 2. Declare a pointer to a use copper list structure: */
  struct UCopList *copper;
  /* Colour value: */
  int colour = 0;

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


  /* Prepare the ViewPort structure, and set some important values: */
  InitVPort( &my_view_port );
  my_view_port.DWidth = WIDTH;         /* Set the width.                */
  my_view_port.DHeight = HEIGHT;       /* Set the height.               */
  my_view_port.RasInfo = &my_ras_info; /* Give it a pointer to RasInfo. */
  my_view_port.Modes = HIRES;          /* High resolution.              */


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



  /* 3. Allocate memory for a UCopList structure:            */
	/*    [Must be Chip memory!]                               */
  /*    The Amiga will automatically deallocate this memory  */
	/*    when the program terminates, so we should not do it. */
  copper = (struct UCopList *)
	  AllocMem( sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CHIP|MEMF_CLEAR );


  /* 4. Initialize the copper list: */
	CINIT( copper, 1 );


  /* 5. Modify the copper list:                                  */
	/*    [0 - 15 - 0 - 15 and so on, change blue, green and red.] */
  for( loop=0; loop < HEIGHT; loop++ )
	{
		(loop / 15) % 2 ? colour-- : colour++ ;

    /* Blue:  (Bits 0 - 3)  */
    CWAIT( copper, loop, 0 );
	  CMOVE( copper, custom.color[0], colour );

    /* Green: (Bits 4 - 7)  */
    CWAIT( copper, loop, 110 );
	  CMOVE( copper, custom.color[0], colour<<4 );

    /* Red:   (Bits 8 - 11) */
    CWAIT( copper, loop, 170 );
	  CMOVE( copper, custom.color[0], colour<<8 );
	}

  /* The last lines should be black: */
  CWAIT( copper, loop, 0 );
  CMOVE( copper, custom.color[0], 0 );


  /* 6. Tell the Copper that no more instructions will be given: */
  CEND( copper );


  /* 7. Link our own copperlist to our ViewPort: */
  my_view_port.UCopIns = copper;


  /* 8. Create the display: */
  MakeVPort( &my_view, &my_view_port );
  MrgCop( &my_view );



  /* Prepare the RastPort, and give it a pointer to the BitMap. */
  InitRastPort( &my_rast_port );
  my_rast_port.BitMap = &my_bit_map;
  

  /* Show the new View: */
  LoadView( &my_view );



  /* Wait 10 seconds: */
  Delay( 10 * 50 );



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

  /* Print the message and leave:   */
	/* NO! As I said above, we must   */
	/* not use any console functions! */
	/* If you want to use printf(),   */
	/* declare the main function as   */
	/* main() and not as _main().     */
  /* printf( "%s\n", message );     */
  exit();
}
