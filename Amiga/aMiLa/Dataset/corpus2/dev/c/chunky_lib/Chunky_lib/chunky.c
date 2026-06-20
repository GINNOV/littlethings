//
// chunky.c v2.27
// 
// Routines to create, render and delete chunky graphics data.
// Based on really buggy code written previously by 
//  pernathw@cip.ub.uni-muenchen.de (Wanja Pernath).
// New improved version by Andrew 'Oondy' King.
// Version 2.00+ is (c) 1998 Rosande Software Limited, all rights reserved.
// The original v1.0 chunky.c sources can be found in Aminet:dev/c.

// Changes: 1.0 - inital thing done by Wanja.
//          2.0 - loads of bugs fixed by oondy
//              - added ChooseHardwareMode()
//          2.1 - added DrawChunkyChunky()
//              - all chunky stuff now contained in a single object file
//         2.11 - added some more safer checks now for boundries
//         2.12 - DrawChunkyChunky() 75% faster now.
//         2.13 - added DrawChunkyChunkyArea()
//         2.14 - fixed minor bug in FreeChunky() (now safe if cp == NULL)
//         2.15 - fixed clipping bug in DrawChunkyChunkyArea()
//         2.16 - ChooseHardwareMode() failed on gfx boards!
//          2.2 - MAJOR UPDATE... transparent support for Picasso96/AGA (cgfx coming soon)
//         2.21 - doh.. removed p96 and used cybergraphics instead
//         2.22 - fixed several bugs with cgfx support (InsertChunky() now inserts)
//              - tidyed up a few routines by removing duplicate code
//         2.23 - added code to read and write chunkyport structs+data to disk
//              - changed how chunkyports are allocated and freed
//         2.24 - fixed bug in CHK_ReadChunkyPort()
//              - added routine to read chunkyport data from a memory location
//              - fixed massive bug in CHK_InsertChunky() (rpa8() was being an arse)
//         2.25 - added optional colour palette support (256 colours only)
//         2.26 - file-based chunkyports are now compressed (uncompressed still supported)
//         2.27 - added CHK_DrawChunkyTiled()

// DON'T EVEN THINK ABOUT USING THIS ON PRE-OS 3.0 SYSTEMS!

#include <exec/libraries.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/view.h>
#include <cybergraphx/cybergraphics.h>
#include <dos/dos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/cybergraphics_protos.h>
#include <clib/dos_protos.h>
#include <pragma/cybergraphics_lib.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "chunky.h"
#include "BRC1.h"  // new in 2.26

char _chunkymsg_[] = __FILE__ " 2.27 - (c) 1998 Rosande Limited, all rights reserved " __DATE__ "\0";

extern struct Library *CyberGfxBase;

#define PI (3.141592654) // Please change to 32dp's ;)
#define RAWDOFMT_COPY ((void *)"\x16\xc0\x4e\x75")

short UseAmigaOS = 0; // Set to 0 if AGA mode or 1 for RTG mode
short UseRTG = 0;     // If != 0, use RTG stuff.. see includes for settings

static void CHK_TextSoftStyle(struct ChunkyPort *, char *, int);
// Note the lowercase "t" for this one
static void CHK_text(struct ChunkyPort *, char *, int ); 
static void CHK_Text3DNoB(struct ChunkyPort *, char *, int);
static void CHK_Text3D(struct ChunkyPort *, char *, int);
static void CHK_TextOutline(struct ChunkyPort *, char *, int);
static void CHK_TextEmboss(struct ChunkyPort *, char *, int);
static void CHK_TextBold(struct ChunkyPort *, char *, int);

static int sptst(float x)
{
  int ret = 0;

  if( x < 0 )       ret = -1;
  else if( x > 0 )  ret = 1;
  else              ret = 0;
  return( ret );
}

// Create a new chunky block of memory
struct ChunkyPort *CHK_InitChunky(unsigned short sx, unsigned short sy)
{
  struct ChunkyPort *cp = NULL;
  unsigned char *Buf = NULL;
  unsigned long size;
  
  // Use a custom chunky buffer
  size = (sx * sy);
  if(cp = AllocVec(sizeof(struct ChunkyPort), MEMF_ANY|MEMF_CLEAR))
  {
    if(Buf = AllocVec(size, MEMF_CLEAR|MEMF_ANY))
    {
      cp->cp_Chunky = Buf;
      cp->cp_BufSize = size;
      cp->cp_Width  = sx;
      cp->cp_Height = sy;
      cp->cp_NoFree = FALSE;
      cp->cp_Colours = NULL;
      cp->cp_Identifier = HEAD_CHKP;
      CHK_SetDrMd(cp, JAM1);
      CHK_SetABOPen(cp, 1, 0, 0);
    }
    else
    {
      FreeVec(cp); cp = NULL;
    }
  }
  return(cp);
}

// Allocate a colour table for a chunkyport (all colours are set to black)
struct ColoursCP *CHK_InitColours(struct ChunkyPort *cp)
{
  struct ColoursCP *cpc = NULL;
  if(cp)
  {
    if(cp->cp_Colours == NULL)
    {
      // Allocate some memory
      if(cpc = AllocVec(sizeof(struct ColoursCP), MEMF_CLEAR))
      {
        // Attach it to the chunkyport
        cp->cp_Colours = cpc;
      }
    }
    else
    {
      cpc = cp->cp_Colours;
    }
  }
  return(cpc);
}
  
// Free up a chunky memory block created with InitChunkyPort()
void CHK_FreeChunky(struct ChunkyPort *cp)
{
  if(cp)
  {
    if(cp->cp_TxtChunky) FreeVec(cp->cp_TxtChunky);
    if(cp->cp_Colours) FreeVec(cp->cp_Colours);
    if(cp->cp_NoFree == FALSE) // external application will free memory if == TRUE
    {
      if(cp->cp_Chunky) FreeVec(cp->cp_Chunky);
      FreeVec(cp);
    }
  }
}

void *LockBitMapTags(void *BitMap, ...)
{
  void *Result;
  va_list Args;
  
  va_start(Args, BitMap);
  Result = LockBitMapTagList(BitMap, (struct TagItem *)Args);
  va_end(Args);
  return(Result);
}

// Draws part of a chunky buffer onto a rastport at x,y
void CHK_DrawChunkyArea(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y, unsigned short sizex, unsigned short sizey)
{
  if(!UseAmigaOS)
  {
    // Use custom c2p stuff.
    // THIS IS AGA ONLY!
    struct  c2pStruct c2p;

    c2p.bmap         = rp->BitMap;
    c2p.startX       = x;
    c2p.startY       = y;
    c2p.width        = sizex;
    c2p.height       = sizey;
    c2p.ChunkyBuffer = cp->cp_Chunky;

    // Call an asm function to do this - not even written by me ;)
    ChunkyToPlanar(&c2p);
  }
  else
  {
    // Use cybergraphics
/*
    void *lock = NULL;
    unsigned char *addr;
    unsigned long pixfmt;

    // Use quick mode?
    if((x == 0) && (y == 0) && (cp->cp_Width == GetBitMapAttr(rp->BitMap, BMA_WIDTH)))
    {
      // Simple copy mode
      // Can we lock this bitmap?
      if(GetCyberMapAttr(rp->BitMap, CYBRMATTR_ISCYBERGFX))
      {
        // We can so lock the bitmap (ouch!)
        if(lock = LockBitMapTags(rp->BitMap, LBMI_PIXFMT, &pixfmt, LBMI_BASEADDRESS, &addr, TAG_DONE))
        {
          // Copy (!) the chunky buffer into the bitmap
          CopyMem(cp->cp_Chunky, addr, cp->cp_BufSize);
          // Unlock !
          UnLockBitMap(lock);
        }
      }
    }
    if(!lock)
    {
      // If we didn't/couldn't lock the bitmap - use traditional methods
      WritePixelArray(cp->cp_Chunky, 0, 0, cp->cp_Width, rp, x, y, (sizex-1), (sizey-1), RECTFMT_LUT8);
    }
*/
    WriteChunkyPixels(rp, x, y, (x + sizex) - 1, (y + sizey) - 1, cp->cp_Chunky, cp->cp_Width);
  }
}

// Draws the contents of a chunky buffer onto a rastport at x,y.
void CHK_DrawChunky(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y)
{
  CHK_DrawChunkyArea(cp, rp, x, y, cp->cp_Width, cp->cp_Height);
}

// Draws a chunky buffer onto a rastport at x,y but all pixels that are of colour 0
// will be skipped over (i.e. preserving the background that you are rendering onto)
void CHK_InsertChunky(struct ChunkyPort *cp, struct RastPort *rp, unsigned short x, unsigned short y)
{
  struct  p2cStruct p2c;
  struct  ChunkyPort  *tmp;
  unsigned char *src, *dst, p;
  unsigned long size = cp->cp_Height * cp->cp_Width, i = 0, count = 0, w;

  // Make a temp chunky buffer
  w = (((cp->cp_Width+15)>>4)<<4);
  if(tmp = CHK_InitChunky(cp->cp_Width, cp->cp_Height))
  {
    if(!UseAmigaOS)
    {
      // Convert the rastport we're blitting (heh) to into chunky
      p2c.bmap         = rp->BitMap;
      p2c.startX       = x;
      p2c.startY       = y;
      p2c.width        = tmp->cp_Width;
      p2c.height       = tmp->cp_Height;
      p2c.ChunkyBuffer = tmp->cp_Chunky;
      PlanarToChunky(&p2c);
      count = tmp->cp_BufSize;
    }
    else
    {
      struct BitMap *tbm = NULL;
      struct RastPort trp;
      unsigned long width = (((tmp->cp_Width+15)>>4)<<1), yy;
      unsigned char *buf = NULL;

      if((tbm = AllocBitMap(width, 1, 8, BMF_CLEAR, NULL)) && (buf = AllocVec(w, MEMF_CLEAR)))
      {
        trp = *rp;
        trp.Layer = NULL;
        trp.BitMap = tbm;
        for(yy = 0; yy < tmp->cp_Height; yy++)
        {
          count += ReadPixelLine8(rp, x, (y + yy), tmp->cp_Width, buf, &trp);
          CopyMem(buf, CHK_GET_PIXEL_POS(tmp, 0, yy), tmp->cp_Width);
        }
      }
      if(tbm) FreeBitMap(tbm);
      if(buf) FreeVec(buf);
/*
      unsigned long xx,yy;
      for(yy = 0; yy < tmp->cp_Height; yy++)
      {
        for(xx = 0; xx < tmp->cp_Width; xx++, count++)
        {
          CHK_WritePixel(tmp, xx, yy, ReadPixel(rp, (x + xx), (y + yy)));
        }
      }
*/
    }

    if(count == tmp->cp_BufSize)
    {
      // Go through the source chunky buffer looking for pixels which aren't
      // colour 0 and copy them to the destination buffer.
      src = cp->cp_Chunky;
      dst = tmp->cp_Chunky;
      while(i < size)
      {
        p = *src++; if(p) *dst++ = p else dst++;
        i++;
      }

      // Apply the changes
      CHK_DrawChunky(tmp, rp, x, y);
    }
    CHK_FreeChunky(tmp);
  }
}

// Use a bitmap to create a new chunky buffer from
struct ChunkyPort *CHK_CreateChunkyFromBitMap(struct BitMap *bm, unsigned short x, unsigned short y, unsigned short width, unsigned short height)
{
  struct ChunkyPort *cp = NULL;
  // Use p2c to get a chunky buffer
  struct p2cStruct p2c;

  // Create the chunky buffer
  if(cp = CHK_InitChunky(width, height))
  {
    // Apply the conversion
    p2c.bmap         = bm;
    p2c.startX       = x;
    p2c.startY       = y;
    p2c.width        = width;
    p2c.height       = height;
    p2c.ChunkyBuffer = cp->cp_Chunky;
    PlanarToChunky( &p2c );
  }
  return(cp);
}

// Use a rastport to create a new chunky buffer from.
struct ChunkyPort *CHK_CreateChunkyFromRastPort(struct RastPort *rp, unsigned short x, unsigned short y, unsigned short width, unsigned short height)
{
  // Basically exactly the same as CreateChunkyFromBitMap()...
  return(CHK_CreateChunkyFromBitMap(rp->BitMap, x, y, width, height));
}

// These functions do the same as their graphics.library equilivents
void CHK_SetDrMd(struct ChunkyPort *cp, unsigned short flags)
{
  cp->cp_Flags = flags;
}

void CHK_SetAPen(struct ChunkyPort *cp, unsigned char p)
{
  cp->cp_APen = p;
}

void CHK_SetOPen(struct ChunkyPort *cp, unsigned char p)
{
  // OS doesn't have an outline pen...
  cp->cp_OPen = p;
}

void CHK_SetABOPen(struct ChunkyPort *cp, unsigned char a, unsigned char b, unsigned char o)
{
  cp->cp_APen = a;
  cp->cp_BPen = b;
  cp->cp_OPen = o;
}

void CHK_Move(struct ChunkyPort *cp, unsigned short x1, unsigned short y1)
{
  cp->cp_cx = x1;
  cp->cp_cy = y1;
}

void CHK_WritePixel(struct ChunkyPort *cp, unsigned short p, unsigned short x, unsigned short y)
{
  if(cp && (x < cp->cp_Width) && (y < cp->cp_Height))
    CHK_SET_PIXEL(cp, p, x, y);
}

char CHK_ReadPixel(struct ChunkyPort *cp, unsigned short x, unsigned short y)
{
  if(cp && (x < cp->cp_Width) && (y < cp->cp_Height))
    return(CHK_GET_PIXEL(cp, x, y));
  return(-1);
}

void CHK_Draw(struct ChunkyPort *cp, unsigned short x2, unsigned short y2)
{
  const char p = cp->cp_APen;
  unsigned char *chk = cp->cp_Chunky;
  unsigned short x1 = cp->cp_cx;
  unsigned short y1 = cp->cp_cy;
  int     i, change, s1, s2;
  long    x, y, dx, dy, e;

  x = x1;
  y = y1;

  // Horizontal line?
  if(y1 == y2)
  {
    // Calculate start address and then move the bytes into the buffer
    x = MIN(x1, x2);
    y = MAX(x1, x2);
    chk = ((unsigned char *)((unsigned long)chk) + ((cp->cp_Width * y1) + x));
    for( i = x; i < y; i++ )
    {
      *chk++ = p;
    }
  } 
  else if(x1 == x2)
  {
    // Vertical line
    x = MIN(y1, y2 );
    y = MAX(y1, y2 );
    chk = ((unsigned char *)((unsigned long)chk) + ((cp->cp_Width * x) + x1));

    for( i = x; i < y; i++ )
    {
      *chk = p;
      chk += cp->cp_Width;
    }
  }
  else
  {
     // A diagonal line (oh god)
//    dx  = (long)abs((float)((short)x2 - (short)x1));   // Number of x-moves
//    dy  = (long)abs((float)((short)y2 - (short)y1));   // Number of y-moves
    dx  = (long)labs((short)x2 - (short)x1);   // Number of x-moves
    dy  = (long)labs((short)y2 - (short)y1);   // Number of y-moves
    s1  = sptst(x2 - x1);        // Sign for x-direction
    s2  = sptst(y2 - y1);        // Sign for y-direction

    // Go which way?
    if(dy > dx)
    {
      dy = dx;
//      dx = (long)abs((float)(y2 - y1));
      dx = (long)labs(y2 - y1);
      change = 1; // Go right
    }
    else
    {
      change = 0; // Go left
    }

    e = 2 * dy - dx;

    // Draw it
    for(i = 1; i <= dx; i++)
      {
      CHK_SET_PIXEL(cp, p, x, y);

      while(e >= 0)
      {
        if(change)
        {
          x = x + s1;
        }
        else
        {
          y = y + s2;
        }
        e = e - 2 * dx;
      }
      if(change)
      {
        y = y + s2;
      }
      else
      {
        x = x + s1;
      }
      e = e + 2*dy;
    }
  }
  // Position the Draw() point at where we finished
  CHK_Move(cp, x2, y2);
}

// Draw a solid line from x1,y1 to x2,y2.
// Equal to Move(x1,y1); Draw(x2, y2);
void CHK_DrawLine(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2)
{
  CHK_Move(cp, x1, y1);
  CHK_Draw(cp, x2, y2);
}

// Draw a transparent rectangle
void CHK_DrawRect(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2)
{
  // Draw a box into the chunky-buffer
  CHK_Move(cp, x1, y1);
  CHK_Draw(cp, x2, y1);
  CHK_Draw(cp, x2, y2);
  CHK_Draw(cp, x1, y2);
  CHK_Draw(cp, x1, y1);
}

// Draws a filled rectangle
void CHK_RectFill(struct ChunkyPort *cp, unsigned short x1, unsigned short y1, unsigned short x2, unsigned short y2)
{
  // Draw a filled box at the specified position
  unsigned short rx1=x1, ry1=y1, rx2=x2, ry2=y2;
  int i;

  // Crude box drawing hehe
  for(i = ry1; i < ry2; i++)
  {
    CHK_DrawLine(cp, rx1, i, rx2, i);
  }
}

// Draw an ellipse
void CHK_DrawEllipse(struct ChunkyPort *cp, unsigned short cx, unsigned short cy, unsigned short rx, unsigned short ry)
{
  double x, y, i, step=0.02;
  long    x2, y2, x3, y3, x4, y4;
  const char   apen = cp->cp_APen;

  // Must have a radius
  if(rx == 0 || ry == 0) return;

  // Okay, draw the elliptical shape...
  for(i = (PI / 2); i > 0; i -= step)
  {
    x = cos(i)*rx; y = sin(i)*ry;
    x2 = (long)x;  y2 = (long)-y;
    x3 = (long)-x; y3 = (long)-y;
    x4 = (long)-x; y4 = (long)y;

    CHK_SET_PIXEL(cp, apen, cx + (int)x, cy + (int)y);
    CHK_SET_PIXEL(cp, apen, cx + x2, cy + y2);
    CHK_SET_PIXEL(cp, apen, cx + x3, cy + y3);
    CHK_SET_PIXEL(cp, apen, cx + x4, cy + y4);
  }
}

void CHK_SetRast(struct ChunkyPort *cp, unsigned char p)
{
  unsigned char *buf = cp->cp_Chunky;
  unsigned long size = cp->cp_Width * cp->cp_Height;
  unsigned long i=0;

  while( i < size )
  {
    *buf++ = p;
    i++;
  }
}

// -------------------- PRIVATE ----------------------------
static char get_pen(char *cb, long bpr, long x, long y)
{
  return(*((unsigned char *)((unsigned long)cb) + ((bpr * y) + x)));
}

// Clone of graphics.library/Text()
static void CHK_text(struct ChunkyPort *cp, char *text, int length)
{
  struct TextFont *tf = cp->cp_Font;
  char  dpen = cp->cp_APen;
  int   sx, sy, dx, x, y;
  unsigned char *src = cp->cp_TxtChunky;
  short  *cloc = tf->tf_CharLoc;
  unsigned short *cspa = tf->tf_CharSpace;
  unsigned short *ckern= tf->tf_CharKern;
  int   cwidth, cx, spa, kern;
  int   bpr  = tf->tf_Modulo * 8;
  char  c, p;

  // Need a text font
  if(tf == NULL)          return;
  // And need a string
  if(strlen(text) == 0) return;

  while(length--)
  {
    c = *text++;

    // Find character
    if((c < tf->tf_LoChar || c > tf->tf_HiChar))
      c = tf->tf_HiChar + 1;
    c -= tf->tf_LoChar;
    cx     = cloc[ c*2 ];
    cwidth = cloc[ c*2+1];

    // Character spacing and kern
    spa    = cspa ? cspa[c] : tf->tf_XSize;
    kern   = ckern ? ckern[c] : 0;
    sx = cp->cp_cx + kern;
    cp->cp_cx += spa;

    sy = cp->cp_cy + 1;

    // What we doing with it?
    if(cp->cp_Flags == JAM1)
    {
      for(y = 0; y < tf->tf_YSize; y++)
      {
        dx = sx;
        for(x = cx; x < cx + cwidth; x++)
        {
          p = get_pen(src, bpr, x, y);
          // Since colour 0 is transparent for JAM1, miss out this pen
          if(p) CHK_SET_PIXEL(cp, dpen, dx, sy+y);
          dx++;
        }
      }
    }
    else if(cp->cp_Flags == JAM2)
    {
      for(y = 0; y < tf->tf_YSize; y++)
      {
        dx = sx;
        for(x = cx; x < cx + cwidth; x++)
        {
          p = get_pen(src, bpr, x, y);
          CHK_SET_PIXEL(cp, p ? dpen : cp->cp_BPen, dx++, sy + y);
        }
      }
    }
    else if(cp->cp_Flags == INVERSVID)
    {
      for(y = 0; y < tf->tf_YSize; y++)
      {
        dx = sx;
        for(x = cx; x < cx + cwidth; x++)
        {
          p = get_pen(src, bpr, x, y);
          CHK_SET_PIXEL(cp, p ? cp->cp_BPen : dpen, dx++, sy + y);
        }
      }
    }
  }
}

// Print some BOLD text
static void CHK_TextBold(struct ChunkyPort *cp, char *t, int l)
{
  int o_f = cp->cp_Flags;
  int x = cp->cp_cx;
  int y = cp->cp_cy;

  CHK_SetDrMd(cp, JAM1);
  CHK_text(cp, t, l);
  CHK_Move(cp, x + 1, y);
  CHK_text(cp, t, l);
  CHK_SetDrMd(cp, o_f);
}

// Print some 3D-styled text, without bolding (not a washing powder :)
static void CHK_Text3DNoB(struct ChunkyPort *cp, char *t, int l)
{
  // Use bpen as shadow and apen as textpen
  int x = cp->cp_cx;
  int y = cp->cp_cy;
  char bpen = cp->cp_BPen;
  char apen = cp->cp_APen;

  // Draw dark shadow of 3d
  CHK_SetAPen(cp, bpen);
  CHK_TextBold(cp, t, l);  // Heh, the next draw kills the bold :)
  CHK_Move(cp, x-2, y-2);

  // draw light pen of 3d
  CHK_SetAPen(cp, apen);
  CHK_text(cp, t, l); // Booyaka - the bold is gone
}

// Print some 3D-styled text
static void CHK_Text3D (struct ChunkyPort *cp, char *t, int l)
{
  int x = cp->cp_cx;
  int y = cp->cp_cy;
  char bpen = cp->cp_BPen;
  char apen = cp->cp_APen;

  CHK_SetAPen(cp, bpen);

  if(cp->cp_TxStyle & FSF_BOLD)
  {
    CHK_TextBold(cp, t, l);
    CHK_Move(cp, x-2, y-2);
    CHK_SetAPen(cp, apen);
    CHK_TextBold(cp, t, l);
  } 
  else
  {
    CHK_text(cp, t, l);
    CHK_Move(cp, x-1, y-1);
    CHK_SetAPen(cp, apen);
    CHK_text(cp, t, l);
  }
}

// Print text in with an outline
static void CHK_TextOutline (struct ChunkyPort *cp, char *t, int l)
{
  unsigned short xpos, ypos;
  int x = cp->cp_cx;
  int y = cp->cp_cy;
  int o_f = cp->cp_Flags;
  char apen = cp->cp_APen;
  char open = cp->cp_OPen;

  CHK_SetDrMd(cp, JAM1);

  if(cp->cp_TxStyle & FSF_BOLD)
  {
    CHK_SetAPen(cp, open);
    for(ypos = y; ypos < y+3; ypos++)
    {
      for(xpos = x; xpos < x+3; xpos++)
      {
        CHK_Move(cp, xpos, ypos);
        CHK_TextBold(cp, t, l);
      }
    }
    CHK_SetAPen(cp, apen);
    CHK_Move(cp, x+1, y+1);
    CHK_TextBold(cp, t, l);
  }
  else
  {
    CHK_SetAPen(cp, open);
    for(ypos = y; ypos < y+3; ypos++)
    {
      for(xpos = x; xpos < x+3; xpos++)
      {
        CHK_Move(cp, xpos, ypos);
        CHK_text(cp, t, l);
      }
    }
    CHK_SetAPen(cp, apen);
    CHK_Move(cp, x+1, y+1);
    CHK_text(cp, t, l);
  }
  CHK_SetDrMd(cp, o_f);
}

// Emboss that text!
static void CHK_TextEmboss(struct ChunkyPort *cp, char *t, int l)
{
  int x = cp->cp_cx;
  int y = cp->cp_cy;
  int o_f = cp->cp_Flags;
  char apen = cp->cp_APen;
  char bpen = cp->cp_BPen;
  char open = cp->cp_OPen;

  CHK_SetDrMd(cp, JAM1);

  if(cp->cp_TxStyle & FSF_BOLD)
  {
    CHK_SetAPen(cp, bpen);
    CHK_Move(cp, x-1, y-1);
    CHK_TextBold(cp, t, l);

    CHK_SetAPen(cp, open);
    CHK_Move(cp, x+1, y+1);
    CHK_TextBold(cp, t, l);

    CHK_SetAPen(cp, apen);
    CHK_Move(cp, x, y);
    CHK_TextBold(cp, t, l);
  }
  else
  {
    CHK_SetAPen(cp, bpen);
    CHK_Move(cp, x-1, y-1);
    CHK_text(cp, t, l);

    CHK_SetAPen(cp, open);
    CHK_Move(cp, x+1, y+1);
    CHK_text(cp, t, l);

    CHK_SetAPen(cp, apen);
    CHK_Move(cp, x, y);
    CHK_text(cp, t, l);
  }
  CHK_SetDrMd(cp, o_f);
}

// Draw text whilst obeying the softstyle which has been set
static void CHK_TextSoftStyle(struct ChunkyPort *cp, char *text, int len)
{
  if(cp->cp_TxStyle == FS_NORMAL)
  {
    CHK_text(cp, text, len);
  }
  else if(cp->cp_TxStyle == FSF_BOLD)
  {
    CHK_TextBold(cp, text, len);
  } 
  else if(cp->cp_TxStyle & FSF_3D)
  {
    CHK_Text3D(cp, text, len);
  } 
  else if(cp->cp_TxStyle & FSF_WIDE3D)
  {
    CHK_Text3DNoB(cp, text, len);
  }
  else if(cp->cp_TxStyle & FSF_OUTLINE)
  {
    CHK_TextOutline (cp, text, len);
  }
  else if(cp->cp_TxStyle & FSF_EMBOSSED)
  {
    CHK_TextEmboss(cp, text, len);
  }
  else
  {
    CHK_text(cp, text, len);
  }
}

// ------------------------ PUBLIC -----------------------------
// Changes which font we should use to print with.  Must be called before
// any text can be printed to a chunky buffer.  Usage is as graphics/SetFont().
void CHK_SetFont(struct ChunkyPort *cp, struct TextFont *tf)
{
  if(tf == NULL)        return;
  CHK_SetSoftStyle(cp, FS_NORMAL);
  if(cp->cp_Font == tf) return;

  // Fill in what we need to know based on the font
  cp->cp_Font       = tf;
  cp->cp_TxHeight   = tf->tf_YSize;
  cp->cp_TxBaseline = tf->tf_Baseline;
  CHK_SetSoftStyle(cp, FS_NORMAL);

  // If we had created a font before, free the buffer we used to chunkify it
  if(cp->cp_TxtChunky)
  {
    FreeVec(cp->cp_TxtChunky);
    cp->cp_TxtChunky = NULL;
  }

  // Chunkify font
  if(cp->cp_TxtChunky = AllocVec(tf->tf_YSize * (tf->tf_Modulo * 8), MEMF_CLEAR|MEMF_ANY))
  {
    struct  BitMap    *bm;
    struct  p2cStruct p2c;
    if(bm = AllocBitMap(tf->tf_Modulo * 8, tf->tf_YSize, 1, BMF_CLEAR, NULL))
    {
      CopyMem(tf->tf_CharData, bm->Planes[0], tf->tf_YSize * tf->tf_Modulo);
      p2c.ChunkyBuffer = cp->cp_TxtChunky;
      p2c.startX       = 0;
      p2c.startY       = 0;
      p2c.bmap         = bm;
      p2c.width        = (tf->tf_Modulo * 8);
      p2c.height       = tf->tf_YSize;
      PlanarToChunky(&p2c);
      FreeBitMap(bm);
    }
  }
}

unsigned long CHK_SetSoftStyle(struct ChunkyPort *cp, unsigned long newStyle)
{
  // FSF_ITALIC, FSF_UNDERLINED don't work so we filter those out here
  unsigned long realStyle = newStyle;

  if(newStyle & FSF_ITALIC)     realStyle = realStyle & ~FSF_ITALIC;
  if(newStyle & FSF_UNDERLINED) realStyle = realStyle & ~FSF_UNDERLINED;

  cp->cp_TxStyle = realStyle;
  return(realStyle);
}

// See graphics/TextLength() :)
long CHK_TextLength(struct ChunkyPort *cp, char *text, int length)
{
  long  plen = 0;
  struct TextFont *tf = cp->cp_Font;
  unsigned short *cspa = tf->tf_CharSpace;
  int   lst = cspa ? 1 : 0;
  char  c;
  if(strlen(text) == 0) return(NULL);

  // Need a font and a text
  if(tf == NULL)          return(NULL);

  // Basically the same as printing the text, except we don't print it
  while(length--)
  {
    c = *text++;
    if((c < tf->tf_LoChar || c > tf->tf_HiChar))
      c = tf->tf_HiChar + 1;
    c -= tf->tf_LoChar;
    plen  += cspa ? cspa[c] : tf->tf_XSize;
  }
  plen += lst;

  if(cp->cp_TxStyle == FSF_BOLD)    return(plen+1);
  if(cp->cp_TxStyle & FSF_BOLD )    plen+=1;
  if(cp->cp_TxStyle & FSF_OUTLINE)  plen+=3;
  if(cp->cp_TxStyle & FSF_EMBOSSED)  plen+=2;
  return(plen);
}

// Um see graphics/Text()
void CHK_Text(struct ChunkyPort *cp, char *text)
{
  CHK_TextSoftStyle(cp, text, strlen(text));
}

// Centres some text on the x coord
void CHK_TextCentre(struct ChunkyPort *cp, char *text, unsigned short y)
{
  int  l = strlen(text);
  long sx,x;

  sx = CHK_TextLength(cp, text, l);
  x  = (cp->cp_Width - sx) / 2;
  if(x > 0)
  {
    CHK_Move(cp, x, y);
    CHK_TextSoftStyle(cp, text, l);
  }
  else
  {
    // Figure out how much text we can print since the whole string is too long
    // and needs to be clipped.
    while(sx > cp->cp_Width)
    {
      sx = CHK_TextLength(cp, text, --l);
    }
    x = (cp->cp_Width - sx) / 2;
    CHK_Move(cp, x, y);
    CHK_TextSoftStyle(cp, text, l);
  }
}

// Wow, new function for graphics.library - sprintf() Text() :)
void CHK_SPrintF(struct ChunkyPort *cp, char *format, ...)
{
  char buffer[256];
  RawDoFmt(format, &format+1, RAWDOFMT_COPY, buffer);
  CHK_TextSoftStyle(cp, buffer, strlen(buffer));
}

// Call this function after you've opened a screen or somesort to figure out
// which drawing method suits the screen best (i.e. rtg calls or custom c2p)
void CHK_ChooseHardwareMode(unsigned long ModeID)
{
/*
  DisplayInfoHandle handle;
  struct DisplayInfo dinfo;
*/
      
  UseAmigaOS = 0;
  // Okay, check for cybergraphics mode
  if((CyberGfxBase) && (IsCyberModeID(ModeID)))
  {
    // It's a CGFX screen mode
    UseAmigaOS = 1; UseRTG = RTG_CGFX;
  }
/*
  else
  {
    // Check for normal ;)
    if(handle = FindDisplayInfo(ModeID))
    {
      if(GetDisplayInfoData(handle, (unsigned char *)&dinfo, 
                            sizeof(struct DisplayInfo), DTAG_DISP, NULL))
      {
        // Okay, look at dinfo and see what we can come up with
        if(!(((dinfo.PropertyFlags & DIPF_IS_AA) != 0) ||
           ((dinfo.PropertyFlags & DIPF_IS_EXTRAHALFBRITE) != 0) ||
           ((dinfo.PropertyFlags & DIPF_IS_DBUFFER) != 0) ||
           ((dinfo.PropertyFlags & DIPF_IS_ECS) != 0) &&
           ((dinfo.PropertyFlags & DIPF_IS_FOREIGN) == 0))) UseAmigaOS = 1;
      }
    }
  }
*/
}

// Function to copy chunky data from one chunky buffer to another -
// useful for off-screen rendering then CHK_DrawChunky()'ing
// dest, src, destx, desty, srcx, srcy, srcw, srch
void CHK_DrawChunkyChunkyArea(struct ChunkyPort *destcp, struct ChunkyPort *srccp, unsigned short destx, unsigned short desty, unsigned short srcx, unsigned short srcy, unsigned short w, unsigned short h)
{
  // Insert a chunky buffer from one into another
  int widthsrc, heightsrc, widthdest, heightdest;
  unsigned int dy, sy;
  unsigned char *pos, *pos2, *here;
  
  if(destcp && srccp)
  {
    if(!(w && h))
    {
      widthsrc = srccp->cp_Width; heightsrc = srccp->cp_Height; 
    }
    else
    {
      widthsrc = w; heightsrc = h;
    }
    widthdest = destcp->cp_Width; heightdest = destcp->cp_Height;
    
    sy = srcy;
    if(!(((destx + (widthsrc-1)) > (widthdest - 1)) || ((desty + (heightsrc-1)) > (heightdest - 1))))
    {
      for(dy = desty; dy < (desty + heightsrc) - 1; dy++)
      {
        pos = CHK_GET_PIXEL_POS(destcp, destx, dy);
        pos2 = CHK_GET_PIXEL_POS(srccp, srcx, sy);
        for(here = pos2; here < (pos2 + widthsrc); here++, pos++)
        {
          if((unsigned char)*here != 0)
          {
            *pos = *here;
          }
        }
        sy++;
      }
    }
    // Done
  }
}

// Simply calls CHK_DrawChunkyChunkyArea() but just copies the complete
// src to dest, not part of it.
void CHK_DrawChunkyChunky(struct ChunkyPort *destcp, struct ChunkyPort *srccp, unsigned short x, unsigned short y)
{
  CHK_DrawChunkyChunkyArea(destcp, srccp, x, y, 0, 0, srccp->cp_Width, srccp->cp_Height);
}

// Draws a "transparent" rectangle.  This is how FUBAR draws its "transparent"
// rectangles which is just every-after-one pixel is colour 0 (transparent)
// and the others pixels are SetAPen() coloured.  Effective, but not true
// transparent (graphics card owners could improve this to be so, or even
// die-hard AGA fanactics :).  But changing the palette is out of the scope of
// this library heh.
void CHK_DrawTransparentRectangle(struct ChunkyPort *cp, unsigned short x, unsigned short y, unsigned short w, unsigned short h)
{
  short sx,sy,dx,dy;
  char on = 1, c;
  unsigned char *p;

  if(cp && w && h)
  {
    dx = (x + w) - 1; dy = (y + h) - 1;
    c = cp->cp_APen;
    if(dx > cp->cp_Width) dx = (cp->cp_Width - x);
    if(dy > cp->cp_Height) dy = (cp->cp_Height - y);
    for(sy = y; sy <= dy; sy++)
    {
      for(sx = x; sx <= dx; sx++)
      {
        if(on)
        {
//          CHK_WritePixel(cp, c, sx, sy);
          p = CHK_GET_PIXEL_POS(cp, sx, sy);
          *p = c;
        }
        on = 1 - on;
      }
    }
  }
}

// Writes out a chunky port structure AND chunky data to a file (not font chunky data).
// (supports BRC1 compression in 2.26+)
unsigned short CHK_WriteChunkyPort(struct ChunkyPort *cp, unsigned char *filename)
{
  long fh;
  struct ChunkyPort writeme;
  struct ColoursCP  colours, *boing;
  unsigned char *Buffer;
  unsigned short Result = FALSE, donecomp = FALSE;
  void *WorkBuffer = NULL;
  struct BRC1Header *CompBuffer = NULL;
  unsigned long size;
  
  if(cp)
  {
    // Copy the chunkyport cos we need to alter some things before we write
    CopyMem(cp, &writeme, sizeof(struct ChunkyPort));
    boing = cp->cp_Colours;
    if(boing)
    {
      CopyMem(boing, &colours, sizeof(struct ColoursCP));
      colours.cpc_Identifier = HEAD_CPCL;
    }
    Buffer = writeme.cp_Chunky;
    writeme.cp_Identifier = HEAD_CHKP;
    writeme.cp_Chunky = NULL;
    writeme.cp_Colours = NULL;
    writeme.cp_Font = NULL;
    writeme.cp_TxtChunky = NULL;
    writeme.cp_NoFree = FALSE;
    
    // Open the file
    if(fh = Open(filename, MODE_NEWFILE))
    {
      // Get a work buffer
      size = sizeof(struct ChunkyPort) + writeme.cp_BufSize;
      if(WorkBuffer = AllocVec(size, MEMF_CLEAR))
      {
        // Okay, pack it
        CopyMem(&writeme, WorkBuffer, sizeof(struct ChunkyPort));
        CopyMem(Buffer, (void *)((unsigned long)WorkBuffer + sizeof(struct ChunkyPort)), writeme.cp_BufSize);
        // Really pack it :)
        if(CompBuffer = BRC_Compress(WorkBuffer, size))
        {
          // Write it out
          Write(fh, CompBuffer, sizeof(struct BRC1Header));
          Write(fh, CompBuffer->br_Buffer, CompBuffer->br_PackedSize);
          donecomp = TRUE;
          BRC_FreeBuffer(CompBuffer);
        }
        FreeVec(WorkBuffer);
      }
      if(!donecomp)
      {
        // If compression failed, revert to uncompressed data
        // Write the header
        Write(fh, &writeme, sizeof(struct ChunkyPort));
        // Write the chunky buffer
        Write(fh, Buffer, writeme.cp_BufSize);
      }
      // Write the colours?
      if(boing)
      {
        Write(fh, &colours, sizeof(struct ColoursCP));
      }
      // Done
      Result = TRUE;
      Close(fh);
    }
  }
  return(Result);
}

// Reads in chunky port and chunky data structures returning the chunkyport if okay
// (supports BRC1 compression in 2.26+)
struct ChunkyPort *CHK_ReadChunkyPort(unsigned char *filename)
{
  long fh;
  struct ChunkyPort *Result = NULL;
  struct ColoursCP  *cpc = NULL;
  unsigned char *Buffer = NULL;
  unsigned long HeaderCheck;
  struct BRC1Header Head, *Head2;
  void *WorkBuffer = NULL;
  
  if(filename)
  {
    // Open the file
    if(fh = Open(filename, MODE_OLDFILE))
    {
      // Is the chunkyport compressed with BRC?
      Read(fh, &HeaderCheck, sizeof(unsigned long));
      Seek(fh, 0, OFFSET_BEGINNING);
      switch(HeaderCheck)
      {
        case HEAD_BRC1:
        {
          Read(fh, &Head, sizeof(struct BRC1Header));
          if(WorkBuffer = Head2 = AllocVec(Head.br_UnpackedSize + sizeof(struct BRC1Header), MEMF_CLEAR))
          {
            CopyMem(&Head, WorkBuffer, sizeof(struct BRC1Header));
            Head2->br_Buffer = (void *)((unsigned long)WorkBuffer + sizeof(struct BRC1Header));
            // Read in the rest of the file
            Read(fh, Head2->br_Buffer, Head2->br_PackedSize);
            // Unpack it
            Result = BRC_Uncompress(WorkBuffer);
            if(Result)
            {
              // Try loading colour data (ok to fail)
              if(cpc = AllocVec(sizeof(struct ColoursCP), MEMF_CLEAR))
              {
                Read(fh, cpc, sizeof(struct ColoursCP));
                if(cpc->cpc_Identifier == HEAD_CPCL)
                {
                  // Neat - there are colours
                  Result->cp_Colours = cpc;
                }
                else
                {
                  FreeVec(cpc); cpc = NULL;
                }
              }
            }
            FreeVec(WorkBuffer);
          }
          break;
        }
        case HEAD_CHKP:
        {
          // Allocate a chunkyport
          if(Result = AllocVec(sizeof(struct ChunkyPort), MEMF_CLEAR))
          {
            // Read it in
            Read(fh, Result, sizeof(struct ChunkyPort));
            // Good, load the chunky data
            if(Buffer = AllocVec(Result->cp_BufSize, MEMF_CLEAR))
            {
              Read(fh, Buffer, Result->cp_BufSize);
              Result->cp_Chunky = Buffer;
              // Try loading colour data (ok to fail)
              if(cpc = AllocVec(sizeof(struct ColoursCP), MEMF_CLEAR))
              {
                Read(fh, cpc, sizeof(struct ColoursCP));
                if(cpc->cpc_Identifier == HEAD_CPCL)
                {
                  // Neat - there are colours
                  Result->cp_Colours = cpc;
                }
                else
                {
                  FreeVec(cpc); cpc = NULL;
                }
              }
            }
            else
            {
              break;
            }
          }
          else
          {
            break;
          }
          break;
        }
      }
      Close(fh); fh = NULL;
    }
  }
  if(!Result) goto fail;
  return(Result);
  
  fail:
  if(fh) Close(fh);
  if(Buffer) FreeVec(Buffer);
  if(Result) FreeVec(Result);
  return(NULL);
}

// Gets chunky data from a memory location (must be ChunkyPort struct immediately followed by buffer)
// Set UseLocationBuffers to TRUE if this routine should *NOT* copy the data
// DATA MUST BE UNCOMPRESSED!
struct ChunkyPort *CHK_GetChunkyPort(void *MemoryLocation, unsigned short UseLocationBuffers)
{
  struct ChunkyPort *Result = NULL;
  void *Here = NULL;
  struct ColoursCP *AndHere = NULL;
  
  if(*((unsigned long *)MemoryLocation) == HEAD_CHKP)
  {
    // Looks like a chunky port
    Here = MemoryLocation;
    if(UseLocationBuffers)
    {
      Result = (struct ChunkyPort *)Here;
      Here = (void *)((unsigned long)Here + (unsigned long)sizeof(struct ChunkyPort));
      // Get the buffer location
      Result->cp_Chunky = (unsigned char *)Here;
      Result->cp_NoFree = TRUE;
      // Any colours?
      Here = (void *)((unsigned long)Here + (unsigned long)Result->cp_BufSize);
      if(*((unsigned long *)Here) == HEAD_CPCL)
      {
        // Neat - colours
        if(AndHere = CHK_InitColours(Result))
        {
          CopyMem(Here, (void *)AndHere, sizeof(struct ColoursCP));
        }
      }
    }
    else
    {
      // Need to copy the buffers
      unsigned char *Buffer;
      
      if(Result = CHK_InitChunky(((struct ChunkyPort *)Here)->cp_Width, ((struct ChunkyPort *)Here)->cp_Height))
      {
        Buffer = Result->cp_Chunky;
        CopyMem(Result, Here, sizeof(struct ChunkyPort));
        Result->cp_Chunky = Buffer;
        Here = (void *)((unsigned long)Here + (unsigned long)sizeof(struct ChunkyPort));
        CopyMem(Buffer, Here, sizeof(struct ChunkyPort));
        Here = (void *)((unsigned long)Here + (unsigned long)Result->cp_BufSize);
        if(*((unsigned long *)Here) == HEAD_CPCL)
        {
          if(AndHere = CHK_InitColours(Result))
          {
            CopyMem(Here, (void *)AndHere, sizeof(struct ColoursCP));
          }
        }
      }
    }
  }
  return(Result);
}

// Puts the colours from a chunky port onto the specified viewport
unsigned short CHK_PutChunkyColours(struct ChunkyPort *cp, struct ViewPort *vp)
{
  void *Table;
  unsigned short Result = FALSE;
  if(cp && vp)
  {
    if(cp->cp_Colours)
    {
      Table = (void *)((unsigned long)cp->cp_Colours + sizeof(unsigned long));
      LoadRGB32(vp, (unsigned long *)Table);
      Result = TRUE;
    }
  }
  return(Result);
}

// Tiles a chunkyport on a rastport
void CHK_DrawChunkyTiled(struct ChunkyPort *cp, struct RastPort *rp, short x, short y, short w, short h)
{
  short xx = x, yy = y, cw, ch, xxx, yyy, poo = 0;
  
  cw = cp->cp_Width; ch = cp->cp_Height;
  if(cw > w) cw = w; if(ch > h) ch = h;
  yy = y; yyy = 0;
  for(;;)
  {
    xx = x; xxx = 0;
    for(;;)
    {
      CHK_DrawChunkyArea(cp, rp, xx, yy, cw, ch);
      xx += cw; xxx = xx + cw;
      if(xxx > w)
      {
        cw = ((x + w) - xx);
        CHK_DrawChunkyArea(cp, rp, xx, yy, cw, ch);
        break;
      }
    }
    yy += ch; yyy = yy + ch;
    if(!poo)
    {
      if(ch != cp->cp_Height) break;
      if(yyy > h)
      {
        ch = ((y + h) - yy);
        poo = 1;
      }
    }
    else
    {
      break;
    }
  }
}

