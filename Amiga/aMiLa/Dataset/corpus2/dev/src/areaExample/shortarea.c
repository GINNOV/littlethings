#define MAX_COORD 40

#include <intuition/intuition.h>
#include <intuition/screens.h>
#include <graphics/gfxmacros.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/graphics_protos.h>

struct Library *IntuitionBase;
struct GfxBase *GfxBase;
struct NewScreen my_newscreen =
{ 0, 0, 320, 200, 3, 0, 1, NULL, CUSTOMSCREEN, NULL,
  "A Screen for area-experiments.", NULL, NULL };

void main( void )
{
  struct Screen *my_scr;
  struct RastPort *my_rp;
  struct AreaInfo my_AIstruct = { 0 };
  struct TmpRas my_tmpras;
  PLANEPTR my_rastptr;
  WORD coor_buf[ MAX_COORD*5 ];
  int i;

  IntuitionBase =
    OpenLibrary( "intuition.library",0 );
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0 );

  my_scr=OpenScreen( &my_newscreen );
  my_rp=& my_scr->RastPort;
  
  my_rastptr = AllocRaster( my_scr->Width, my_scr->Height );

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
   
  FreeRaster( my_rastptr, my_scr->Width, my_scr->Height );
  CloseScreen( my_scr );
  CloseLibrary( GfxBase );
  CloseLibrary( IntuitionBase );
}
