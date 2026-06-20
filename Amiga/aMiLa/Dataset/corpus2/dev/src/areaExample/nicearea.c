#include <stdio.h> /* for printf in Die_G() */
#define MAX_COORD 40

#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/gfxmacros.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>

struct Library *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;
struct NewScreen my_newscreen =
{ 0, 0, 320, 200, 3, 0, 1, NULL, CUSTOMSCREEN, NULL,
  "A Screen for area-experiments.", NULL, NULL };


/* I have moved the variables out here, so 
 *  Die_gracefully() can see them.
 */
struct Screen *my_scr = NULL;
struct RastPort *my_rp;
struct AreaInfo my_AIstruct;
struct TmpRas my_tmpras;
PLANEPTR my_rastptr = NULL;
WORD coor_buf[ MAX_COORD*5 ];

void Die_Gracefully(char *reason)
{
  printf("%s\n", reason);

  if( my_rastptr )
    FreeRaster( my_rastptr, my_scr->Width, my_scr->Height );

  if( my_scr )
    CloseScreen( my_scr );

  if( GfxBase )
    CloseLibrary( GfxBase );

  if( IntuitionBase )
    CloseLibrary( IntuitionBase );

  exit(1);
}

void main( void )
{  
  int i;

  IntuitionBase =
    OpenLibrary( "intuition.library",0 );
  if( !IntuitionBase )
    Die_Gracefully("Could not open Intuition Library.");
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0 );
  if( !GfxBase )
    Die_Gracefully("Could not open Graphics Library.");

  my_scr=OpenScreen( &my_newscreen );
  if( !my_scr )
    Die_Gracefully("Could not open a screen.");

  my_rp=& my_scr->RastPort;
  
  my_rastptr = AllocRaster( my_scr->Width, my_scr->Height );
  if( !my_rastptr )
    Die_Gracefully("Could not allocate raster memory.");

  InitTmpRas( &my_tmpras, my_rastptr,
       ((my_scr->Width+15)/16)*my_scr->Height );
  InitArea( &my_AIstruct, coor_buf, MAX_COORD );
    
  my_rp->TmpRas = &my_tmpras;
  my_rp->AreaInfo = &my_AIstruct;

  SetAPen( my_rp, 4);
  SetBPen( my_rp, 5); 
  SetOPen( my_rp, 6);
  
  AreaMove( my_rp, 40, 50 );
  for(i=0; i<18; i++)
    AreaDraw( my_rp, rand()%140+20, rand()%185+15 );
  AreaMove( my_rp, 210, 120 );
  for(i=0; i<18; i++)
    AreaDraw( my_rp, rand()%140+160, rand()%185+15 );
  
  AreaEnd( my_rp );

  Delay(500);
  Die_Gracefully("All went according to plan!");
}
