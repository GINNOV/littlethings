/*
 *  3D example 3
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

double tetrap[5][3]=
{
   0.0,1.0,0.0,
  -1.0,0.0,1.0,
   1.0,0.0,1.0,
  -1.0,0.0,-1.0,
   1.0,0.0,-1.0
};
int tetral[8][2]=
{
  0,1,
  0,2,
  0,3,
  0,4,
  1,2,
  1,3,
  4,3,
  4,2
};
object tetra=
{
  5,8,&tetrap[0][0],&tetral[0][0]
};

double tetrap2[5][3];
int tetral2[8][2];
object tetra2=
{
  5,8,&tetrap2[0][0],&tetral2[0][0]
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

int i,j;
scale3(&matA,50,50,50);
objtran(&tetra,&matA);
 
  for (j=0;j<3;j++)
    {
    toggleFrame = 0;
    SetAPen(&(screen->RastPort), 1);

    rot3(&matA,pi/16,j);
    for (i=0;i<100;i++)
      {
      screen->RastPort.BitMap          = myBitMaps[toggleFrame];
      screen->ViewPort.RasInfo->BitMap = myBitMaps[toggleFrame];

      /* Draw the objects.
      ** Here we clear the old frame and draw a simple filled rectangle.
      */
      SetRast(&(screen->RastPort), 0);
      objdraw(&(screen->RastPort),&tetra);

      objtran(&tetra,&matA);
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
