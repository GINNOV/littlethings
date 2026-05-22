/*
 *
 * Module Definition Section
 * -------------------------
 *
 * Routines Contained :
 *  1) AllocBitMap
 *  2) DeAllocBitMap
 */

#include <intuition/intuition.h>
#include <exec/memory.h> 
#include <exec/types.h>
#include "iff.h"

UBYTE ByteBits[8] = { 1,2,4,8,16,32,64,128};

extern void *AllocRaster();
extern void *AllocMem();
extern void DeAllocBitMap();

/*---------------------------------------------------*
 * Allocate a bitmap and return with Pointer to same *
 * w   = Width in pixels                             *
 * h   = Height in rows                              *
 * d   = depth                                       *
 * p   = PlanePick                                   *
 *---------------------------------------------------*/
struct BitMap *AllocBitMap(w,h,d,p)
SHORT w,h,d;
UBYTE p;
{
struct BitMap *bm;
int   i;

if ((bm = AllocMem(sizeof(struct BitMap) ,MEMF_CLEAR)) == 0)
   DoAnAlert("AllocBitMap-F: no fast\n");

InitBitMap(bm,d,w,h);

for (i = 0 ; i < d ; i++)
   if ( p & ByteBits[i] )
      {
         if ((bm->Planes[i] = (UBYTE *)AllocRaster(w,h) ) == 0)
            DoAnAlert("AllocBitMap-F: No memory for BitMaps\n");
         BltClear(bm->Planes[i],RASSIZE(w,h));
      }
return(bm);
}


/*---------------------------------------------------*
 * DeAllocate a bitmap and BitMap structure          *
 * bm    = Pointer to BitMap                         *
 *---------------------------------------------------*/
void DeAllocBitMap(bm)
struct BitMap *bm;
{
SHORT w = bm->BytesPerRow * 8;
SHORT h = bm->Rows;
SHORT d = bm->Depth;

int   i;

if (!bm) return;


for (i = 0 ; i < d ; i++)
   if (bm->Planes[i])
      FreeRaster(bm->Planes[i],w,h);

FreeMem(bm,sizeof(struct BitMap));
}


struct GraphObject *AllocGraphObject(w,h,d,pp)
SHORT w,h,d;
UBYTE pp;
{
struct GraphObject *go;
int i,dd;
dd=0;
for(i=0;i<d;i++)
  dd+=(ByteBits[i]&pp)?1:0;

if (!(go = AllocMem(sizeof(struct GraphObject) , MEMF_CHIP | MEMF_CLEAR)))
   DoAnAlert("AllocGraphObjecj-F:No Memory for GraphObject structure");

if (!(go->Image = AllocMem(RASSIZE(w,h)*dd,MEMF_CHIP | MEMF_CLEAR)))
   DoAnAlert("AllocGraphObject-F: No Memory for GraphOnject Image");

go->Width = w;
go->Height = h;
go->Depth = d;
go->RDepth=dd;
return(go);
}      

void DeAllocGraphObject(go)
struct GraphObject *go;
{
if (! go) 
   return;/* Its not there in the first place (I wonder why) */

if (! go->Image)
   return;/* Its not there in the first place (I wonder why) */ 

FreeMem(go->Image,RASSIZE(go->Width,go->Height)*go->RDepth);

FreeMem(go,sizeof (struct GraphObject));

}      
