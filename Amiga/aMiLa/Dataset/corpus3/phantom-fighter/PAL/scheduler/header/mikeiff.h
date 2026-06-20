#ifndef MIFF_H
#define MIFF_H

#include "header:iff.h"

#define ID_FORM   MakeID('F','O','R','M')
#define ID_PROP   MakeID('P','R','O','P')
#define ID_LIST   MakeID('L','I','S','T')
#define ID_CAT    MakeID('C','A','T',' ')
#define ID_FILLER MakeID(' ',' ',' ',' ')
#define ID_EMRL   MakeID('E','M','R','L')

#define TYPE_ILBM MakeID('I','L','B','M') /* Interleaved BitMap */
#define TYPE_PACK MakeID('P','A','C','K') /* Packed BitMaps*/
#define TYPE_BOBS MakeID('B','O','B','S') /* Get rid of this */
#define TYPE_ANBM MakeID('A','N','B','M') /* Animated BitMap */
#define TYPE_ANSQ MakeID('A','N','S','Q') /* Animated sequence */

#define BMHD MakeID('B','M','H','D')
#define CMAP MakeID('C','M','A','P')
#define CRNG MakeID('C','R','N','G')
#define BODY MakeID('B','O','D','Y')
#define GRAB MakeID('G','R','A','B')
#define DEST MakeID('D','E','S','T')
#define ASEQ MakeID('A','S','E','Q') /* Animation sequence */
#define ASET MakeID('A','S','E','T') /* Animation set */
#define XPNT MakeID('X','P','N','T') /* XPoints for poly */
#define YPNT MakeID('Y','P','N','T') /* YPoints for poly */
#define FSQN MakeID('F','S','Q','N') /* From and Total bobs */

extern ULONG   LoadedTypes;
#define MARK_BMHD 0x1
#define MARK_CMAP 0x2
#define MARK_GRAB 0x4
#define MARK_DEST 0x8
#define MARK_TOTL 0x10
#define MARK_CRNG 0x20
#define MARK_ASET 0x40
#define MARK_ASEQ 0x80
#define MARK_BODY 0x100
#define MARK_XPNT 0x200
#define MARK_YPNT 0x400
#define MARK_FSQN 0x800
#define MARK_COLR 0x1000
#define MARK_BMFO 0x2000
#define MARK_PLNE 0x4000

#define mskNone 0
#define mskHasMask 1
#define mskHasTransparentColor 2
#define mskLasso 3

#define cmpNone     0
#define cmpByteRun1 1
#define cmpPacked   2

struct IDChunkType
   {
   ID    ckType;
   };
struct IDChunkHeader
   {
   ID    ckID;
   LONG  ckSize;
   ID    ckType;
   };

struct BitMapHeader
   {
   UWORD    w, h;
   WORD     x, y;
   UBYTE    nPlanes;
   Masking  masking;
   Compression compression;
   UBYTE    pad1;
   UWORD    transparentColor;
   UBYTE    xAspect, yAspect;
   WORD     pageWidth, pageHeight;
   };
struct DestMerge
   {
   UBYTE depth;
   UBYTE pad1;
   UWORD planePick;
   UWORD planeOnOff;
   UWORD planeMask;
   };
struct CRange
   {
   WORD     pad1;
   WORD     rate;
   WORD     active;
   UBYTE    low, high;
   };
struct Color_Range {
   UWORD  *colors;            /* pointer to the colors */
   struct CRange *range;      /* necessary info to operate on interrupt */
   WORD   RateToGo;           /* decremented by interrupt */
   UBYTE  startcol;           /* which color was last to goto range.low */
   UBYTE  pad1;
   };
struct Color_Range_Set {
   struct Color_Range *r1, *r2, *r3, *r4;/* allowed for 4 CRange's */
   BYTE   active;             /* active  != 0 all CRange's */
   BYTE   pad1[3];
   ULONG  regs[7];            /* Cant work the mcode properly holds A2 */
   };

struct Point2D
   {
   WORD     x, y;
   };
struct FramerFSQN
   {
   WORD     numframes;    /* Number of frames in the sequence */
   LONG     dt;           /* Nominal time between frames in jiffies */
   WORDBITS flags;        /* Bits modify behavior of the animation */
   UBYTE    sequence[80]; /* string of 'a'..'z' specifying sequence */
   };
#define NO_MASK 1	/* an option to remove masks */
struct Picture {
   struct BitMap *bitmap;       /* The BitMap for the picture */
   SHORT  Width,Height;         /* The Width and Height of the Picture */
   UBYTE  PlanePick,PlaneOnOff; /* PlanePick And PlaneOnOff of the Picture */
   UWORD  *Colors;              /* Pointer to the colors for this picture */
   Masking  masking;            /* If this picture has a mask or not */
   UBYTE    transparentColor;   /* Keep transcolor for saving */
   SHORT  HotX,HotY;
   SHORT  nColors;		/* How many colors for the Colors */
   };
   

#endif MIFF_H


