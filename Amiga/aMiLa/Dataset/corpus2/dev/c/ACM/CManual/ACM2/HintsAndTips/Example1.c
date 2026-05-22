/* Example 1                                               */
/* This example tell you if you have an American (NTSC) or */
/* European (PAL) system.                                  */ 


/* Declares commonly used data types, such as UWORD etc: */
#include <exec/types.h>

/* This header file declares the GfxBase structure: */
#include <graphics/gfxbase.h>


/* Pointer to the GfxBase structure. NOTE! This pointer must */
/* allways be called "GfxBase"!                              */
struct GfxBase *GfxBase;


main()
{
  int loop;
  
  /* Open the Graphics Library: (any version) */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0 );

  if( !GfxBase )
    exit(); /* ERROR! Could not open the Graphics Library! */


  if( GfxBase->DisplayFlags & NTSC )
    printf( "You have an American (NTSC) Amiga.\n" );

  if( GfxBase->DisplayFlags & PAL )
    printf( "You have an European (PAL) Amiga.\n" );


  /* Close the Graphics Library: */
  CloseLibrary( GfxBase );


  /* Wait for a while: */
  for( loop = 0; loop < 500000; loop++ )
    ;
}
