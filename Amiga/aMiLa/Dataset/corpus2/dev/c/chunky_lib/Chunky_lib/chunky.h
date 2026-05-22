//
// Chunky.c include and header file
//
// by Andrew "Oondy" King
// (c) 1998 Rosande Software Limited, all rights reserved.

#ifndef _CHK_DRAW_H
#define _CHK_DRAW_H

#include <exec/memory.h>
#include <graphics/gfx.h>
#include <graphics/text.h>
#include <graphics/rastport.h>
#include <graphics/view.h>

#define HEAD_CHKP 0x43484B50
#define HEAD_CPCL 0x4350434C

struct cp_Colour32
{
  unsigned long R, G, B;
};

struct ColoursCP
{
  unsigned long      cpc_Identifier; // == CPCL
  short              cpc_ColourRecord;
  short              cpc_ColourFirst; //  = 0
  struct cp_Colour32 cpc_ColourTable32[256+1];
};

struct ChunkyPort
{
  unsigned long     cp_Identifier; // == CHKP
  unsigned char    *cp_Chunky; // Memory allocated for the chunky data
  unsigned short    cp_cx,      // Draw pen x position in buffer
                    cp_cy;      // Y pen
  unsigned char     cp_APen;    // Foreground pen
  unsigned char     cp_OPen;    // Outline pen
  unsigned char     cp_BPen;    // Background pen
  unsigned char     cp_IPen;    // Shine/shadow pen
  unsigned short    cp_Flags;   // Flags which are the same as graphics/rastport.h

  struct TextFont  *cp_Font;        // Font to use for text rendering
  unsigned char    *cp_TxtChunky;   // Chunky data buffer used for text rendering
  unsigned short    cp_TxHeight;    // Height of the text
  unsigned short    cp_TxBaseline;  // Baseline of the text
  unsigned short    cp_TxStyle;     // Softstyles in graphics/text.h plus these...
  unsigned short    cp_NoFree;      // TRUE if buffer was grabbed from a memory location
  unsigned long     cp_BufSize;     // Number of bytes used for cp_Chunky
  unsigned short    cp_Width,   // Pixel width of buffer
                    cp_Height;  // Pixel height of buffer
  struct ColoursCP *cp_Colours; // Pointer to colour palete data or NULL if none
  unsigned long     cp_Reserved[7];
};

// New softstyles
#define FSB_OUTLINE   8
#define FSB_3D        9
#define FSB_WIDE3D    10
#define FSB_EMBOSSED  11
#define FSF_OUTLINE   (1<<FSB_OUTLINE)
#define FSF_3D        (1<<FSB_3D)
#define FSF_WIDE3D    (1<<FSB_WIDE3D)
#define FSF_EMBOSSED  (1<<FSB_EMBOSSED)

struct c2pStruct
{
  struct BitMap *bmap;
  unsigned short startX, startY, width, height;
  unsigned char *ChunkyBuffer;
};

struct p2cStruct
{
  struct BitMap *bmap;
  unsigned short startX, startY, width, height;
  unsigned char *ChunkyBuffer;
};

extern void ChunkyToPlanarAsm(register __a0 struct c2pStruct *);
extern void PlanarToChunkyAsm(register __a0 struct p2cStruct *);

#define ChunkyToPlanar(c2p)  ChunkyToPlanarAsm((struct c2pStruct *)c2p);
#define PlanarToChunky(p2c)  PlanarToChunkyAsm((struct p2cStruct *)p2c);

// Don't use these!  Use CHK_WritePixel()/ReadPixel() to be 100% safe!
#define CHK_SET_PIXEL(cp, p, x, y) \
  *((unsigned char *)((unsigned long )cp->cp_Chunky) + ((cp->cp_Width * (y) )+(x))) = (p)

#define CHK_GET_PIXEL(cp, x, y) \
  *((unsigned char *)((unsigned long )cp->cp_Chunky) + ((cp->cp_Width * (y))+(x)))

#define CHK_GET_PIXEL_POS(cp, x, y)\
  (void *)(((unsigned long)cp->cp_Chunky) + ((cp->cp_Width * (y))+(x)))

#define MAX(a,b)  (((a)>(b)) ? (a) : (b))
#define MIN(a,b)  (((a)<(b)) ? (a) : (b))

// Values for UseRTG
#define RTG_P96  1 // Set to use p96 stuff  (no!)
#define RTG_CGFX 2 // Set to use CGFX stuff

// Functions in chunky.o
struct ChunkyPort *CHK_InitChunky(unsigned short sx, unsigned short sy);
struct ColoursCP *CHK_InitColours(struct ChunkyPort *cp);
void CHK_FreeChunky(struct ChunkyPort *cp);
void CHK_DrawChunky(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y);
void CHK_DrawChunkyArea(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y, unsigned short sizex, unsigned short sizey);
void CHK_InsertChunky(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y);
struct ChunkyPort *CHK_CreateChunkyFromBitMap(struct BitMap *bm, unsigned short x, unsigned short y, unsigned short width, unsigned short height);
struct ChunkyPort *CHK_CreateChunkyFromRastPort(struct RastPort *rp, unsigned short x, unsigned short y, unsigned short width, unsigned short height);
void CHK_SetDrMd(struct ChunkyPort *cp, unsigned short flags);
void CHK_SetAPen(struct ChunkyPort *cp, unsigned char p);
void CHK_SetOPen(struct ChunkyPort *cp, unsigned char p);
void CHK_SetABOPen(struct ChunkyPort *cp, unsigned char a, unsigned char b, unsigned char o);
void CHK_Move(struct ChunkyPort *cp, unsigned short x1, unsigned short y1);
void CHK_WritePixel(struct ChunkyPort *cp, unsigned short p, unsigned short x, unsigned short y);
char CHK_ReadPixel(struct ChunkyPort *cp, unsigned short x, unsigned short y);
void CHK_Draw(struct ChunkyPort *cp, unsigned short x2, unsigned short y2);
void CHK_DrawLine(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2);
void CHK_DrawRect(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2);
void CHK_RectFill(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2);
void CHK_DrawEllipse(struct ChunkyPort *cp, unsigned short cx, unsigned short cy, unsigned short rx, unsigned short ry);
void CHK_SetRast(struct ChunkyPort *cp, unsigned char p);
void CHK_SetFont(struct ChunkyPort *cp, struct TextFont *tf);
unsigned long CHK_SetSoftStyle(struct ChunkyPort *cp, unsigned long newStyle);
long CHK_TextLength(struct ChunkyPort *cp, char *text, int length);
void CHK_Text(struct ChunkyPort *cp, char *text);
void CHK_TextCentre(struct ChunkyPort *cp, char *text, unsigned short y);
void CHK_SPrintF(struct ChunkyPort *cp, char *format, ...);
void CHK_ChooseHardwareMode(unsigned long ModeID);
void CHK_DrawChunkyChunkyArea(struct ChunkyPort *destcp, struct ChunkyPort *srccp, unsigned short destx, unsigned short desty, unsigned short srcx, unsigned short srcy, unsigned short w, unsigned short h);
void CHK_DrawChunkyChunky(struct ChunkyPort *destcp, struct ChunkyPort *srccp, unsigned short x, unsigned short y);
void CHK_DrawTransparentRectangle(struct ChunkyPort *cp, unsigned short x, unsigned short y, unsigned short w, unsigned short h);
unsigned short CHK_WriteChunkyPort(struct ChunkyPort *cp, unsigned char *filename);
struct ChunkyPort *CHK_ReadChunkyPort(unsigned char *filename);
struct ChunkyPort *CHK_GetChunkyPort(void *MemoryLocation, unsigned short UseLocationBuffers);
unsigned short CHK_PutChunkyColours(struct ChunkyPort *cp, struct ViewPort *vp);
void CHK_DrawChunkyTiled(struct ChunkyPort *cp, struct RastPort *rp, short x, short y, short w, short h);

#endif

