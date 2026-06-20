#ifndef CHUNKYPPC_PROTOS_H
#define CHUNKYPPC_PROTOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif

#ifndef INTUITION_INTUITION_H
#include <intuition/intuition.h>
#endif

#ifndef LIBRARIES_ASL_H
#include <libraries/asl.h>
#endif

#ifndef CYBERGRAPHICS_CYBERGRAPHICS_H
#include <cybergraphics/cybergraphics.h>
#endif

#ifndef LIBRARIES_CHUNKYPPC_H
#include <libraries/chunkyppc.h>
#endif


struct Mode_Screen *OpenGraphics(char *Title, struct Mode_Screen *ms,int override);
void CloseGraphics(struct Mode_Screen *ms, int shutdownlibs);
void LoadColors(struct Mode_Screen *ms, ULONG *Table);
void DoubleBuffer(struct Mode_Screen *ms);
int ChunkyInit68k(struct Mode_Screen *ms, int srcformat);

#ifdef __cplusplus
#define CHUNKYPPC_SPROTOS_CPP
#else
#pragma +
#endif

extern "library=ChunkyPPCBase"
{
 void ChunkyNoffFast(struct Library *,UBYTE *, UBYTE *, int, int, int) ;
 void ChunkyNoffFastest(struct Library *,UBYTE *, UBYTE *, int, int, int);
 void ChunkyNoffNormal(struct Library *,UBYTE *, UBYTE *, int, int, int);
 void ChunkyFast(struct Library *,UBYTE *, UBYTE *, int, int, int, int, int);
 void ChunkyFastest(struct Library *,UBYTE *, UBYTE *, int, int, int, int, int);
 void ChunkyNormal(struct Library *,UBYTE *, UBYTE *, int, int, int, int, int);
 void ChunkyFastFull(struct Library *,UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
 void ChunkyFastestFull(struct Library *,UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
 void ChunkyNormalFull(struct Library *,UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
 void c2p_1(struct Library *,UBYTE *, struct BitMap *, int, int);
 void c2p_2(struct Library *,UBYTE *, UBYTE *, UBYTE *, int);
 void c2p_3(struct Library *,void *, void *, int , int , struct Soff * , int , int);
 void c2p_4(struct Library *,UBYTE *,UBYTE *, UBYTE *, struct Soff *,struct Soff *, struct Soff *);
 void ChunkyNoffFastHT(struct Library *,UBYTE *,UBYTE *,int,int,int,int);
 void ChunkyNoffFastestHT(struct Library *,UBYTE *,UBYTE *,int,int,int,int);
 void ChunkyNoffNormalHT(struct Library *,UBYTE *,UBYTE *,int,int,int,int);
 void ChunkyFastHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
 void ChunkyFastestHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
 void ChunkyNormalHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
 void ChunkyFastFullHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *,struct Soff *,int);
 void ChunkyFastestFullHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *, struct Soff *, int);
 void ChunkyNormalFullHT(struct Library *,UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *,struct Soff *, int);
 void ChunkyNoffMask(struct Library *,struct Buffers *,UBYTE *,int,int,int,int);
 void ChunkyMask(struct Library *,struct Buffers *,UBYTE *,struct Soff *,int,int,int,int);
 void ChunkyMaskFull(struct Library *,struct Buffers *,UBYTE *,struct Soff *, struct Soff *,struct Soff *,struct Soff *, int);
 void c2p_HI(struct Library *, UBYTE *, int, UBYTE *, UBYTE *, UBYTE *, UBYTE *, UBYTE *);
 void ham_c2p(struct Library *, unsigned char *, unsigned char *, int, int, int, int, int);
 int ChunkyInit(struct Library *,struct Mode_Screen *, int);
}

__inline int ChunkyInit(struct Mode_Screen *ms, int srcformat)
{
 extern struct Library *ChunkyPPCBase;
 return ChunkyInit(ChunkyPPCBase,ms,srcformat);
}

__inline void ham_c2p(unsigned char *chunky, unsigned char *planar, int width, int height, int depth, int qual, int ham_width)
{
 extern struct Library *ChunkyPPCBase;
 ham_c2p(ChunkyPPCBase,chunky,planar,width,height,depth,qual,ham_width);
}

__inline void c2p_HI(UBYTE *address, int num, UBYTE *bpl0, UBYTE *bpl1, UBYTE *bpl2, UBYTE *bpl3, UBYTE *bpl4)
{
 extern struct Library *ChunkyPPCBase;
 c2p_HI(ChunkyPPCBase,address,num,bpl0,bpl1,bpl2,bpl3,bpl4);
}

__inline void ChunkyNoffFast(UBYTE *address, UBYTE *data, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffFast(ChunkyPPCBase,address,data,w,h,bpr);
}

__inline void ChunkyNoffFastest(UBYTE *address, UBYTE *data, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffFastest(ChunkyPPCBase,address,data,w,h,bpr);
}

__inline void ChunkyNoffNormal(UBYTE *address, UBYTE *data, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffNormal(address,data,w,h,bpr);
}

__inline void ChunkyFast(UBYTE *address, UBYTE *data, int x, int y, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFast(address,data,x,y,w,h,bpr);
}

__inline void ChunkyFastest(UBYTE *address, UBYTE *data, int x, int y, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastest(address,data,x,y,w,h,bpr);
}

__inline void ChunkyNormal(UBYTE *address, UBYTE *data, int x, int y, int w, int h, int bpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNormal(address,data,x,y,w,h,bpr);
}

__inline void ChunkyFastFull(UBYTE *address, UBYTE *data, struct Soff *dest, struct Soff *size, int bpr, struct Soff *soff, int sbpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastFull(address,data,dest,size,bpr,soff,sbpr);
}

__inline void ChunkyFastestFull(UBYTE *address, UBYTE *data, struct Soff *dest, struct Soff *size, int bpr, struct Soff *soff, int sbpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastestFull(address,data,dest,size,bpr,soff,sbpr);
}

__inline void ChunkyNormalFull(UBYTE *address, UBYTE *data, struct Soff *dest, struct Soff *size, int bpr, struct Soff *soff, int sbpr)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNormalFull(address,data,dest,size,bpr,soff,sbpr);
}

__inline void c2p_1(UBYTE *buffer, struct BitMap *bm, int width, int height)
{
 extern struct Library *ChunkyPPCBase;
 c2p_1(ChunkyPPCBase,buffer,bm,width,height);
}

__inline void c2p_2(UBYTE *buffer, UBYTE *plane0, UBYTE *helpbfr, int PlaneSize)
{
 extern struct Library *ChunkyPPCBase;
 c2p_2(ChunkyPPCBase,buffer,plane0,helpbfr,PlaneSize);
}

__inline void c2p_3(void *chunky, void *bitplanes, int chunkyx, int chunkyy, struct Soff *soff, int bitplanesize, int depth)
{
 extern struct Library *ChunkyPPCBase;
 c2p_3(ChunkyPPCBase,chunky,bitplanes,chunkyx,chunkyy,soff,bitplanesize,depth);
}

__inline void c2p_4(UBYTE *chunky, UBYTE *Planar, UBYTE *temp, struct Soff *size, struct Soff *off, struct Soff *screensize)
{
 extern struct Library *ChunkyPPCBase;
 c2p_4(ChunkyPPCBase,chunky,Planar,temp,size,off,screensize);
}

__inline void ChunkyNoffFastHT(UBYTE *address,UBYTE *data,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffFastHT(ChunkyPPCBase,address,data,w,h,bpr,gfx_type);
}

__inline void ChunkyNoffFastestHT(UBYTE *address,UBYTE *data,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffFastestHT(ChunkyPPCBase,address,data,w,h,bpr,gfx_type);
}

__inline void ChunkyNoffNormalHT(UBYTE *address ,UBYTE *data,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffNormalHT(ChunkyPPCBase,address,data,w,h,bpr,gfx_type);
}

__inline void ChunkyFastHT(UBYTE *address,UBYTE *data,struct Soff *off,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastHT(ChunkyPPCBase,address,data,off,w,h,bpr,gfx_type);
}

__inline void ChunkyFastestHT(UBYTE *address,UBYTE *data,struct Soff *off,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastestHT(ChunkyPPCBase,address,data,off,w,h,bpr,gfx_type);
}

__inline void ChunkyNormalHT(UBYTE *address,UBYTE *data,struct Soff *off,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNormalHT(ChunkyPPCBase,address,data,off,w,h,bpr,gfx_type);
}

__inline void ChunkyFastFullHT(UBYTE *address,UBYTE *data,struct Soff *dest,struct Soff *size,struct Soff *bpr,struct Soff *soff,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastFullHT(ChunkyPPCBase,address,data,dest,size,bpr,soff,gfx_type);
}

__inline void ChunkyFastestFullHT(UBYTE *address,UBYTE *data,struct Soff *dest,struct Soff *size,struct Soff *bpr, struct Soff *soff, int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyFastestFullHT(ChunkyPPCBase,address,data,dest,size,bpr,soff,gfx_type);
}

__inline void ChunkyNormalFullHT(UBYTE *address,UBYTE *data,struct Soff *dest,struct Soff *size,struct Soff *bpr,struct Soff *soff, int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNormalFullHT(ChunkyPPCBase,address,data,dest,size,bpr,soff,gfx_type);
}

__inline void ChunkyNoffMask(struct Buffers *address,UBYTE *data,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyNoffMask(ChunkyPPCBase,address,data,w,h,bpr,gfx_type);
}

__inline void ChunkyMask(struct Buffers *address,UBYTE *data,struct Soff *dest,int w,int h,int bpr,int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyMask(ChunkyPPCBase,address,data,dest,w,h,bpr,gfx_type);
}

__inline void ChunkyMaskFull(struct Buffers *address,UBYTE *data,struct Soff *dest, struct Soff *size,struct Soff *bpr,struct Soff *soff, int gfx_type)
{
 extern struct Library *ChunkyPPCBase;
 ChunkyMaskFull(ChunkyPPCBase,address,data,dest,size,bpr,soff,gfx_type);
}

#ifndef CHUNKYPPC_SPROTOS_CPP
#pragma -
#endif

#endif


