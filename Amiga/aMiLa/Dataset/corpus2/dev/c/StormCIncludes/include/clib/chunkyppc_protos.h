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

#ifndef CYBERGRAPHX_CYBERGRAPHICS_H
#include <cybergraphx/cybergraphics.h>
#endif

#ifndef LIBRARIES_CHUNKYPPC_H
#include <libraries/chunkyppc.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct Mode_Screen *OpenGraphics(char *Title, struct Mode_Screen *ms,int override);
void CloseGraphics(struct Mode_Screen *ms, int shutdownlibs);
void LoadColors(struct Mode_Screen *ms, ULONG *Table);
void DoubleBuffer(struct Mode_Screen *ms);
int ChunkyInit68k(struct Mode_Screen *ms, int srcformat);

void ChunkyNoffFast(UBYTE *, UBYTE *, int, int, int);
void ChunkyNoffFastest(UBYTE *, UBYTE *, int, int, int);
void ChunkyNoffNormal(UBYTE *, UBYTE *, int, int, int);
void ChunkyFast(UBYTE *, UBYTE *, int, int, int, int, int);
void ChunkyFastest(UBYTE *, UBYTE *, int, int, int, int, int);
void ChunkyNormal(UBYTE *, UBYTE *, int, int, int, int, int);
void ChunkyFastFull(UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
void ChunkyFastestFull(UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
void ChunkyNormalFull(UBYTE *, UBYTE *, struct Soff *, struct Soff *, int, struct Soff *, int);
void c2p_1(UBYTE *, struct BitMap *, int, int);
void c2p_2(UBYTE *, UBYTE *, UBYTE *, int);
void c2p_3(void *, void *, int , int , struct Soff * , int , int);
void c2p_4(void *, UBYTE *, UBYTE *, struct Soff *, struct Soff *, struct Soff *);
void ChunkyNoffFastHT(UBYTE *,UBYTE *,int,int,int,int);
void ChunkyNoffFastestHT(UBYTE *,UBYTE *,int,int,int,int);
void ChunkyNoffNormalHT(UBYTE *,UBYTE *,int,int,int,int);
void ChunkyFastHT(UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
void ChunkyFastestHT(UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
void ChunkyNormalHT(UBYTE *,UBYTE *,struct Soff *,int,int,int,int);
void ChunkyFastFullHT(UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *,struct Soff *,int);
void ChunkyFastestFullHT(UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *, struct Soff *, int);
void ChunkyNormalFullHT(UBYTE *,UBYTE *,struct Soff *,struct Soff *,struct Soff *,struct Soff *, int);
void ChunkyNoffMask(struct Buffers *,UBYTE *,int,int,int,int);
void ChunkyMask(struct Buffers *,UBYTE *,struct Soff *,int,int,int,int);
void ChunkyMaskFull(struct Buffers *,UBYTE *,struct Soff *, struct Soff *,struct Soff *,struct Soff *, int);
void c2p_HI(UBYTE *, int, UBYTE *, UBYTE *, UBYTE *, UBYTE *, UBYTE *);
void ham_c2p(unsigned char *chunky, unsigned char *planar, int width, int height, int depth, int qual, int ham_width);
int ChunkyInit(struct Mode_Screen *, int);

#ifdef __cplusplus
};
#endif

#endif
