
#include "iff.h"
#include <exec/alerts.h>
#include <exec/memory.h>
#include <graphics/view.h>
#include <stdio.h>

extern UBYTE  ByteBits[8];	/* = { 1,2,4,8,16,32,64,128 };*/
extern void *AllocBitMap();
extern void *AllocGraphObject();
UWORD LD_ColorTBL[0x100];
extern struct ViewPort VPort;
#undef DEBUG
extern UWORD LunarCMap[32];
struct ChunkHeader chunk;
struct BitMapInfo  bmfo;
struct FromTotal totl;

extern void *AllocMem();
char LertBuffer[80];
extern void LoadImages();


/*
   LoadImages
   Enter with the name of file to load (It must have been packed).
   Sprite is a ptr to a sprite image which has a number of Frames,
   these frames are filled with a BitMap if its a screen or a
   GraphObject if its a bob/s.
*/   
   
void LoadImages(name,Sprite,CMap)
char *name;
struct SpriteImage *Sprite;
UWORD *CMap;
{
PLANEPTR ramptr;
int  loop,loop1,loop2;
FILE *fp;
int PlaneSize;
struct GraphObject *graphobj;
struct BitMap *bm;

#ifdef DEEP_DEBUG
  Set_Debug("LoadImages");
#endif

dprintf("Loading %s\n",name);

if(!(fp = fopen( name,"r")))
  {
  sprintf(LertBuffer,"LoadImages-F: Cant open file %s",name);
  DoAnAlert(LertBuffer);
  return;
  }

/*----------------------------------------------------------*
 * This is the format that we expect for screen . 
 * They must have been converted using iff_emrl
 * emrl   ->12 bytes				
 * totl   ->16 bytes
 * colr   ->72 bytes
 *              total = 100 bytes
 *    bmfo   ->28 bytes
 *              total = 28 bytes               
 *    plne   ->   as many as there are planepicks in the bitmap
 *    
 *           
 *-------------------------------------------------------------*/

/* 
   advance past the EMRL 12 bytes into file
*/
fseek(fp,12,1);
  
/*
   load in the TOTL.
*/

fread(&chunk, sizeof(chunk),1,fp);
if (chunk.ckID != TOTL)
   {
   DoAnAlert("LoadImages-F: Not TOTL.");
   return;
   }

fread(&totl, sizeof(totl), 1, fp);

/*
   skip past the COLR.
*/

fread(&chunk, sizeof(chunk),1,fp);


if (chunk.ckID != COLR)
   {
   DoAnAlert("LoadImages-F: Not COLR.");
   return;
   }

fread(LD_ColorTBL, chunk.ckSize,1,fp);
   
   if(CMap) {
      int i;
      UWORD j;
      for(i=0;i<32;i++)
        CMap[i]=LD_ColorTBL[i];
   }

Sprite->Count = totl.Total; /* So we know how many to free later on */

/*
   loop around Total times allocating and loading BMFO objects as we loop
*/

for (loop = 0 ; loop < totl.Total ; loop++)
   {/* loop through all the pictures that may be in the file */
  
   /*
      load in the BITMAPINFO.
   */
   fread(&chunk, sizeof(chunk),1,fp);
   if (chunk.ckID != BMFO)
      {
      DoAnAlert("LoadImages-F: Not BMFO.");
      return;
      }
   fread(&bmfo, sizeof(bmfo), 1, fp);

   if(bmfo.Width<8&&(bmfo.Height&1))
      bmfo.Height+=2-(bmfo.Height&1);
   /* 
    * if we are loading a screen then the width better be 320 or greater
    * cause if its not then the next part of code will allocate an image
    * contigously in memory and that may not be nice.
   */ 
   if (bmfo.Width >= 320) { 

      if (!( bm = AllocBitMap(bmfo.Width,bmfo.Height,
                              bmfo.Depth,bmfo.PlanePick)))
         DoAnAlert("LoadImages-F: No memory for screen BitMap.");

      Sprite->Frames[loop] = (char *)bm;   
      Sprite->Class = CLS_Screen;
    } else {
      /* allocate a sprite image instead of a bitmap */                  
      /*
         Allocate chip memory for the Image and Mask.
      */
      if(!( graphobj = AllocGraphObject(bmfo.Width,bmfo.Height,bmfo.Depth,
      				        bmfo.PlanePick)))
         {
         DoAnAlert("LoadImages-F: No memory for GraphObject.");
         return;
         }
      Sprite->Frames[loop] = (char *)graphobj;
      graphobj->HotX=bmfo.HotX;
      graphobj->HotY=bmfo.HotY;

      if(bmfo.Width<8)
         Sprite->Class = CLS_SoftBob;
      else
         Sprite->Class = CLS_Bob;
      
      PlaneSize = RASSIZE(bmfo.Width,bmfo.Height);
      /* we have to allocate a bitmap to unpack PLNE,must free it later */
      if (!(bm = AllocMem(sizeof (struct BitMap),MEMF_CHIP | MEMF_CLEAR))) 
         {
         DoAnAlert("LoadImages-F: No memory for Tmp BitMap.");
         return;
         }
      InitBitMap(bm,bmfo.Depth,bmfo.Width,bmfo.Height);
      
      /*
         We want the mask as the first address in AlienShip.
      */     
      loop2=0;
      for(loop1=0;loop1<bmfo.Depth;loop1++)
        if(bmfo.PlanePick & ByteBits[loop1])
          bm->Planes[loop1]=(UBYTE *)graphobj->Image+PlaneSize*loop2++;
        else
          bm->Planes[loop1]=NULL;

      }      
      
   /*
      We should now be at the PLNE so we load the 
      body struct to get the size
   */
   for (loop1 = 0 ; loop1 < bmfo.Depth ; loop1++)
      {/* Unpack each Plane into the BitMap */ 
#ifdef DEBUG
dprintf("Doing plane %d\n",loop1);
#endif
      if (bmfo.PlanePick & ByteBits[loop1])
         {/* Only load a PLNE if PlanePick say's so */
         /*
            read in the chunk for PLNE 
         */
         fread(&chunk, sizeof(chunk),1,fp);
         if (chunk.ckID != PLNE)
            {
            sprintf(LertBuffer,"LoadImages-F: No PLNE %d on loading",loop1);
            DoAnAlert(LertBuffer);
            }
        /*         
            Now unpack the loaded file into this tmp bitmap.
         */   
#ifdef DEBUG
dprintf("Unpacking palane\n");
#endif
         Unpack(fp,chunk.ckSize,bm->Planes[loop1]);
         
         }
      }
   if (Sprite->Class == CLS_Bob)
      FreeMem(bm,sizeof(struct BitMap));
   }
   fclose(fp);				/* Silly Billy */

#ifdef DEEP_DEBUG
  Clear_Debug();
#endif
}


void FreeSpriteImage(Sprite)
struct SpriteImage *Sprite;
{
UBYTE loop;

for (loop = 0 ; loop < Sprite->Count ; loop++)
   if(Sprite->Frames[loop])
      switch (Sprite->Class)
         {
         case CLS_Bob :
            DeAllocGraphObject(Sprite->Frames[loop]);
            break;
         case CLS_Screen :   
            DeAllocBitMap(Sprite->Frames[0]);
            break;
         default :
            DoAnAlert("FreeSpriteImage-F: UnKnown CLS");
            break;
         }   
Sprite->Count=-1;
}   

/* A serious demand paged Unpacker written by _-=BN=-_ */
/* July 88 */

#define MAXBUFF 512

unsigned char UnPack_Buff[MAXBUFF];

unsigned char GetByte(fp,BytesToRead,CurCh)
FILE *fp;
ULONG *BytesToRead;
ULONG *CurCh;
{
  if(*CurCh==MAXBUFF) {
     if(*BytesToRead>=MAXBUFF) {
        *BytesToRead-=MAXBUFF;
        fread(UnPack_Buff,MAXBUFF,1,fp);
     } else
        fread(UnPack_Buff,*BytesToRead,1,fp);
     *CurCh=0;
  }
  return UnPack_Buff[(*CurCh)++];
}

Unpack(fp,size,UnPackedPtr)
FILE *fp;		/* File */
ULONG size;		/* size of Packed chunk */
UBYTE *UnPackedPtr;   /* Unpack into here */
{/* Start of UnPack */
register UBYTE *UnPacked = UnPackedPtr;
register UBYTE loop;
register UBYTE count;
int BufC=MAXBUFF;	/* Force load initially */
LONG BytesToGo;
unsigned char t;

#define GETBYTE t=GetByte(fp,&BytesToGo,&BufC)

BytesToGo=size;

#ifdef DEBUG
  dprintf("Chunk size is %d\n",size);
#endif
GETBYTE;
while(1) {/* Unpack forever or until we hit end to break out */
   count = t;
   GETBYTE;
   if (count < 128) {/* We unpack different bytes or were finished */
      if (t == 0 && count == 0)
         break;

      for (loop = 0 ; loop < count ; loop++) {
         *UnPacked++ = t;
         GETBYTE;
      }
   } else {/* We unpack same bytes */
      count &= 127;/* Knock off the hi-bit Ie subtract 128 */
      for (loop = 0 ; loop < count ; loop++)
         *UnPacked++ = t;
      GETBYTE;
   }
}
}
