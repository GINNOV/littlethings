/****************************************************
 *                KNIGHTBLIT.C
 *
 * Blitter Routines for the KnightLore Stuff
 *
 * Written by Kel & Billy 8-Apr-88
 *
 */
 
#include "Header:knightblit.h"
#include "Header:knightlore.h"

extern struct RastPort *rport;
struct BitMap MyBitMap;

#define MASKMAP 0
#define IMAGEMAP 1
extern void *AllocRaster();
extern UWORD MyBobData[];
extern UWORD MyBobMask[];

struct BitMap MyBitMaps[2];
struct RastPort MyRPorts[2];

struct RastPort MyRPort;

void InitOurPorts()
{
  int i,j;
  USHORT *Plane1,*Plane2;
  InitBitMap(&MyBitMap,2,SCREENWIDTH,SCREENHEIGHT);
  MyBitMap.Planes[0]=AllocRaster(SCREENWIDTH,SCREENHEIGHT);
  MyBitMap.Planes[1]=AllocRaster(SCREENWIDTH,SCREENHEIGHT);
  InitRastPort(&MyRPort);
  MyRPort.BitMap=&MyBitMap;
  EraseOurBitMaps();
  for(i=0;i<2;i++) {
    InitBitMap(&MyBitMaps[i],2,32,16);
    MyBitMaps[i].Planes[0]=AllocRaster(32,16);
    MyBitMaps[i].Planes[1]=AllocRaster(32,16);
    InitRastPort(&MyRPorts[i]);
    MyRPorts[i].BitMap=&MyBitMaps[i];
  }
  Plane1=(USHORT *)MyBitMaps[IMAGEMAP].Planes[0];
  Plane2=(USHORT *)MyBitMaps[IMAGEMAP].Planes[1];
  for(j=0;j<32;j++) {
    Plane1[j]=MyBobData[j];
    Plane2[j]=MyBobData[32+j];
  }
  Plane1=(USHORT *)MyBitMaps[MASKMAP].Planes[0];
  Plane2=(USHORT *)MyBitMaps[MASKMAP].Planes[1];
  for(j=0;j<32;j++)
    Plane1[j]=Plane2[j]=MyBobMask[j];
}
void FreeOurPorts()
{
   int i;
   FreeRaster(MyBitMap.Planes[0],640,200);
   FreeRaster(MyBitMap.Planes[1],640,200);
   for(i=0;i<2;i++){
      FreeRaster(MyBitMaps[i].Planes[0],32,16);
      FreeRaster(MyBitMaps[i].Planes[1],32,16);
   }
}
 
void EraseOurBitMaps()
{
  ClipBlit(&MyRPort,0,0,&MyRPort,0,0,SCREENWIDTH,SCREENHEIGHT,0);
}

void DumpOurBitMaps()
{
   ClipBlit(&MyRPort,1,10,rport,1,10,SCREENWIDTH-1,SCREENHEIGHT-10,0xc0);
}    

void EraseRectangle(x1,y1,w,h)
int x1,y1,w,h;
{
  ClipBlit(&MyRPort,x1,y1,&MyRPort,x1,y1,w,h,0);
}

void BlitBrick(x,y)
int x,y;
{
   ClipBlit(&MyRPorts[MASKMAP],0,0,&MyRPort,x,y,32,16,0x20);
   ClipBlit(&MyRPorts[IMAGEMAP],0,0,&MyRPort,x,y,32,16,0xe0);
}

void DumpRectangle(x,y,w,h)
int x,y,w,h;
{
   ClipBlit(&MyRPort,x,y,rport,x,y,w,h,0xc0);
}
