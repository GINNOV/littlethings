/***************************************************************************
 * picpak.h    - "PicPak" - IFF ILBM picture manipulation functions        *
 *                (c) 1990 Videoworks Computer Applications                *
 *                All rights reserved.                                     *
 *                                                                         *
 *                Written by Paul T. Miller                                *
 *                                                                         *
 * DISCLAIMER:                                                             *
 * Feel free to use these routines or derivatives in your own code, but    *
 * please leave credit in your documentation. This code is NOT public      *
 * domain, and I am only allowing use of it because I'm a nice guy and I   *
 * want to show people how to effectively use their code. If you make any  *
 * modifications or enhancements to this code, please let me know.         *
 *                                                                         *
 * Send comments/suggestions to:                                           *
 * Paul Miller                                                             *
 * The MBT, Coconut Telegraph, The TARDIS                                  *
 *                                                                         *
 * Program Name:  N/A                                                      *
 * Version:       1                                                        *
 * Revision:      4                                                        *
 *-------------------------------------------------------------------------*
 * File: (picpak.h) IFF package definitions and function prototypes        *
 *-------------------------------------------------------------------------*
 * Modification History                                                    *
 * Date     Author   Comment                                               *
 * -------- ------   -------                                               *
 * 10-02-90    PTM   Created. Structures, constants.
 * 10-03-90    PTM   iff.library hooks
 * 10-16-90    PTM   use custom iff code - remove the library
 * 11-28-90    PTM   Special picture types - package name change
 * 11-30-90    PTM   Add Pic extension pointer + SHAMData struct
 * 12-02-90    PTM   Frame structure
 * 24-10-95    MC    Changed name from pic_pak.h to picpak.h
 ***************************************************************************/

#ifndef PICPAK_H
#define PICPAK_H

#ifndef NULL
#include <stdio.h>
#endif

/* some useful constants */
#define LORES_WIDTH        320
#define LORES_HEIGHT       200
#define HIRES_WIDTH        640
#define INTERLACE_HEIGHT   400
#define HAM_DEPTH          6
#define EHB_DEPTH          6

#define MAXCOLORS          32
#define MAXCRANGES         6

typedef struct {
   WORD pad1;         /* Odd length? Nope. */
   WORD rate;         /* Speed! */
   WORD active;       /* What shall we do with a drunken... */
   UBYTE low,high;    /* That's where we start and stop. */
} CRange;

/* Pic structure:
      - contains Pic-specific information such as size, type of memory
        it's stored in, viewmode and imagery data
*/
struct Pic {
   WORD              Width;      /* width of Pic (in pixels) */
   WORD              Height;     /* height of Pic (in pixels) */
   UBYTE             Depth;      /* depth of Pic (in planes) */
   UBYTE             Memtype;    /* type of memory image is stored in */
   UWORD             Colors;     /* total number of colors */
   ULONG             ViewModes;  /* ViewMode bits */
   struct BitMap     BitMap;     /* the image's BitMap */
   UWORD             Colormap[MAXCOLORS]; /* the image's colormap */
   CRange            CRanges[MAXCRANGES]; /* cycle-range blocks */
   UWORD             Cycles;     /* how many cycle ranges? */
   UBYTE             Type;       /* picture type */
   UBYTE             pad;
   APTR             *PicExt;     /* pointer to Pic extension data */
};
#define PIC_SIZE (sizeof(struct Pic))

/* Frame structure:
      - contains just positional and image information, for use with displays
        of known size, depth, and colors. Frames are always in CHIP ram. */
struct Frame {
   WORD              X, Y;       /* upper-left corner */
   WORD              Width;      /* width of frame */
   WORD              Height;     /* height of frame */
   struct BitMap     BitMap;     /* the frame's BitMap */
};
#define FRAME_SIZE   (sizeof(struct Frame))

/* picture types */
#define PICTYPE_NORMAL  0
#define PICTYPE_HAM     1
#define PICTYPE_EHB     2
#define PICTYPE_DHAM    3
#define PICTYPE_SHAM    4
#define PICTYPE_DHIRES  5
#define PICTYPE_HAME    6
#define PICTYPE_DCTV    7
#define PICTYPE_24BIT   9
#define PICTYPE_FRAME   20          /* just positional info please */

/* Picture Extension chunks */
#define SHAM_PALETTES   200
#define SHAM_COLORS     16

struct SHAMData {
   UWORD ColorTable[SHAM_PALETTES][16];  /* 200 palettes/16 colors each */
};
#define SHAMDATA_SIZE   sizeof(struct SHAMData)

#define DHIRES_PALETTES 480
#define DHIRES_COLORS   16

/* Pic MemTypes */
/* When used in calling AllocatePic(), specifies type of RAM to allocate
   for the imagery. Then used internally to notify whether an image is
   actually in FAST RAM or not, so it can be downloaded to CHIP for display
*/
#define MEMTYPE_CHIP 0x00  /* must have CHIP RAM */
#define MEMTYPE_FAST 0x01  /* must have FAST RAM */
#define MEMTYPE_ANY  0x02  /* doesn't matter what type it is */
#define MEMTYPE_NONE 0x10  /* no memory allocated */
#define MEMTYPE_DL   0x80  /* currently downloaded, erase when done */

/* pic_pak function prototypes */
struct Pic *AllocatePic(UWORD width, UWORD height, UBYTE depth, UBYTE flags);
void FreePic(struct Pic *pic);
struct Frame *AllocateFrame(UWORD width, UWORD height, UBYTE flags);
void FreeFrame(struct Frame *frame);
struct Pic *LoadPic(STRPTR name, UBYTE flags);
struct Pic *LoadPic2BitMap(STRPTR name, struct BitMap *bitmap);
struct Frame *LoadFrame(STRPTR name);
struct Pic *LoadImage(STRPTR name, struct BitMap *bitmap, UBYTE type, UBYTE flags);
GetPicAttrs(STRPTR name, WORD *w, WORD *h, WORD *d, ULONG *viewmodes);
Pic2BitMap(struct Pic *pic, struct BitMap *bitmap);
BOOL LoadRaster(FILE *file, ULONG chunksize, PLANEPTR *planes, 
                struct BitMapHeader *header);

void mem_decompress(UBYTE *mem, PLANEPTR *, LONG, LONG, UBYTE);
void SetPicReadBufSize(ULONG);
UWORD LoadCMAP(FILE *, LONG, UWORD *);
void LoadCycleRange(FILE *, CRange *, LONG);
void SetImageType(struct Pic *);

/* color-cycling */
InitCycler(void);
void FreeCycler(void);
__saveds void cycle(void);
void StartCycling(struct ViewPort *, struct Pic *);
void StopCycling(void);
void ToggleCycling(void);
IsCycling(void);

/* ViewPort color-set/fading */
void SetViewPortPicColors(struct ViewPort *, struct Pic *);
void ClearViewPortColors(struct ViewPort *, UWORD);
void FadeViewPortIn(struct ViewPort *, UWORD *, UWORD);
void FadeViewPortOut(struct ViewPort *, UWORD);
void SetFadeSpeed(UWORD);

/* Special image handling */
InitSHAM(struct ViewPort *, struct Pic *);
InitDHIRES(struct ViewPort *, struct Pic *);
void FreeSHAM(struct ViewPort *);

#endif /* PICPAK_H */
