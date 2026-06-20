/*
 * 3D example 2
 */


#define INTUI_V36_NAMES_ONLY

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>
#include <intuition/screens.h>

#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

#include "3d.h"

/* characteristics of the screen */
#define SCR_WIDTH  (320)
#define SCR_HEIGHT (200)
#define SCR_DEPTH    (2)


/* Prototypes for our functions */
VOID   runDBuff(struct Screen *, struct BitMap ** );
struct BitMap **setupBitMaps( LONG, LONG, LONG );
VOID   freeBitMaps(struct BitMap **,LONG, LONG, LONG );
LONG   setupPlanes(struct BitMap *, LONG, LONG, LONG );
VOID    freePlanes(struct BitMap *, LONG, LONG, LONG );


struct Library *IntuitionBase = NULL;
struct Library *GfxBase       = NULL;

double dmatA[4][4];
matrix matA = { 4, 4, &dmatA[0][0]};

double cubep[8][3]=
{
   1.0, 1.0, 1.0,
   1.0, 1.0,-1.0,
   1.0,-1.0,-1.0,
   1.0,-1.0, 1.0,
  -1.0, 1.0, 1.0,
  -1.0, 1.0,-1.0,
  -1.0,-1.0,-1.0,
  -1.0,-1.0, 1.0
};
int cubel[16][2]=
{
  0,1,
  1,2,
  2,3,
  3,0,
  4,5,
  5,6,
  6,7,
  7,4,
  0,4,
  1,5,
  2,6,
  3,7
//  0,6,
//  7,2,
//  3,5,
//  4,2
};

object cube=
{
  8.0,16.0,&cubep[0][0],&cubel[0][0]
};

double cubep2[8][3];
int cubel2[16][2];
object cube2=
{
  8.0,16.0,&cubep2[0][0],&cubel2[0][0]
};
   


/*
** Main routine.  Setup for using the double buffered screen.
** Clean up all resources when done or on any error.
*/

VOID main(int argc, char **argv)
{
struct BitMap **myBitMaps;
struct Screen  *screen;
struct NewScreen myNewScreen;

IntuitionBase = OpenLibrary("intuition.library", 33L);
if ( IntuitionBase != NULL )
    {
    GfxBase = OpenLibrary("graphics.library", 33L);
    if ( GfxBase != NULL )
        {
        myBitMaps = setupBitMaps(SCR_DEPTH, SCR_WIDTH, SCR_HEIGHT);
        if ( myBitMaps != NULL )
            {
            /* Open a simple quiet screen that is using the first
            ** of the two bitmaps.
            */
            myNewScreen.LeftEdge=0;
            myNewScreen.TopEdge=0;
            myNewScreen.Width=SCR_WIDTH;
            myNewScreen.Height=SCR_HEIGHT;
            myNewScreen.Depth=SCR_DEPTH;
            myNewScreen.DetailPen=0;
            myNewScreen.BlockPen=1;
            myNewScreen.ViewModes=LORES_KEY;
            myNewScreen.Type=CUSTOMSCREEN | CUSTOMBITMAP | SCREENQUIET;
            myNewScreen.Font=NULL;
            myNewScreen.DefaultTitle=NULL;
            myNewScreen.Gadgets=NULL;
            myNewScreen.CustomBitMap=myBitMaps[0];

            screen = OpenScreen(&myNewScreen);
            if (screen != NULL)
                {
                /* Indicate that the rastport is double buffered. */
                screen->RastPort.Flags = DBUFFER;

                runDBuff(screen, myBitMaps);

                CloseScreen(screen);
                }
            freeBitMaps(myBitMaps, SCR_DEPTH, SCR_WIDTH, SCR_HEIGHT);
            }
        CloseLibrary(GfxBase);
        }
    CloseLibrary(IntuitionBase);
    }
}





/*
** setupBitMaps(): allocate the bit maps for a double buffered screen.
*/
struct BitMap **setupBitMaps(LONG depth, LONG width, LONG height)
{
/* this must be static -- it cannot go away when the routine exits. */
static struct BitMap *myBitMaps[2];

myBitMaps[0] = (struct BitMap *) AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
if (myBitMaps[0] != NULL)
    {
    myBitMaps[1] = (struct BitMap *)AllocMem((LONG)sizeof(struct BitMap), MEMF_CLEAR);
    if (myBitMaps[1] != NULL)
        {
        InitBitMap(myBitMaps[0], depth, width, height);
        InitBitMap(myBitMaps[1], depth, width, height);

        if (NULL != setupPlanes(myBitMaps[0], depth, width, height))
            {
            if (NULL != setupPlanes(myBitMaps[1], depth, width, height))
                return(myBitMaps);

            freePlanes(myBitMaps[0], depth, width, height);
            }
        FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
        }
    FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
    }
return(NULL);
}

/*
** runDBuff(): loop through a number of iterations of drawing into
** alternate frames of the double-buffered screen.  Note that the
** object is drawn in color 1.
*/
VOID runDBuff(struct Screen *screen, struct BitMap **myBitMaps)
{
//WORD ktr, xpos, ypos;
WORD toggleFrame;

toggleFrame = 0;
SetAPen(&(screen->RastPort), 1);

//for (ktr = 1; ktr < 200; ktr++)
//    {
    /* Calculate a position to place the object, these
    ** calculations insure the object will stay on the screen
    ** given the range of ktr and the size of the object.
    */

int i,j,axis;
float inc;

scale3(&matA,10,10,10);
objtran(&cube,&matA);
tran3(&matA,-50,-50,0);
objtran(&cube,&matA);
rot3(&matA,pi/8,2);
objtran(&cube,&matA);
rot3(&matA,pi/8,1);
objtran(&cube,&matA);
 
  for (j=0;j<4;j++)
    {
    toggleFrame = 0;
    SetAPen(&(screen->RastPort), 1);
    axis=j%2;
    inc=(j<2?1.0:-1.0);
    tran3(&matA,(axis==0?inc:0),(axis==1?inc:0),0);
 
    for (i=0;i<100;i++)
      {
      screen->RastPort.BitMap          = myBitMaps[toggleFrame];
      screen->ViewPort.RasInfo->BitMap = myBitMaps[toggleFrame];

      /* Draw the objects.
      ** Here we clear the old frame and draw a simple filled rectangle.
      */
      SetRast(&(screen->RastPort), 0);
      objdraw(&(screen->RastPort),&cube);


      objtran(&cube,&matA);
      MakeScreen(screen); /* Tell intuition to do its stuff.          */
      RethinkDisplay();   /* Intuition compatible MrgCop & LoadView   */
                         /*               it also does a WaitTOF().  */

      /* switch the frame number for next time through */
      toggleFrame ^= 1;
      }
    }
   
}

/*
** freeBitMaps(): free up the memory allocated by setupBitMaps().
*/
VOID freeBitMaps(struct BitMap **myBitMaps, LONG depth, LONG width, LONG height)
{
freePlanes(myBitMaps[0], depth, width, height);
freePlanes(myBitMaps[1], depth, width, height);

FreeMem(myBitMaps[0], (LONG)sizeof(struct BitMap));
FreeMem(myBitMaps[1], (LONG)sizeof(struct BitMap));
}

/*
** setupPlanes(): allocate the bit planes for a screen bit map.
*/
LONG setupPlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
    {
    bitMap->Planes[plane_num] = (PLANEPTR)AllocRaster(width, height);
    if (bitMap->Planes[plane_num] != NULL )
        BltClear(bitMap->Planes[plane_num], (width / 8) * height, 1);
    else
        {
        freePlanes(bitMap, depth, width, height);
        return(NULL);
        }
    }
return(TRUE);
}

/*
** freePlanes(): free up the memory allocated by setupPlanes().
*/
VOID freePlanes(struct BitMap *bitMap, LONG depth, LONG width, LONG height)
{
SHORT plane_num ;

for (plane_num = 0; plane_num < depth; plane_num++)
    {
    if (bitMap->Planes[plane_num] != NULL)
        FreeRaster(bitMap->Planes[plane_num], width, height);
    }
}
