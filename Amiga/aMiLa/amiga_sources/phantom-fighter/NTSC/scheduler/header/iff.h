
/******************************
   IFF header file
*******************************/
   

#ifndef IFF_H
#define IFF_H

#ifndef GRAPHICS_GFX_H
#include <graphics/gfx.h>
#endif  GRAPHICS_GFX_H

#define MakeID(a,b,c,d) ( (a)<<24 | (b)<<16 | (c)<<8 | (d) )
#define ID_EMRL   MakeID('E','M','R','L')

#define TYPE_PACK MakeID('P','A','C','K') /* Packed BitMaps*/

#define BMFO MakeID('B','M','F','O')
#define COLR MakeID('C','O','L','R')
#define PLNE MakeID('P','L','N','E')
#define TOTL MakeID('T','O','T','L') /* From and Total bobs */

#define ID_BODY MakeID('B','O','D','Y')
#define ID_SMUS MakeID('S','M','U','S')
#define ID_FORM MakeID('F','O','R','M')
#define ID_SHDR MakeID('S','H','D','R')
#define ID_NAME MakeID('N','A','M','E')
#define ID_SNX1 MakeID('S','N','X','1')
#define ID_INS1 MakeID('I','N','S','1')
#define ID_TRAK MakeID('T','R','A','K')
#define ID_8SVX MakeID('8','S','V','X')
#define ID_VHDR MakeID('V','H','D','R')
#define ID_ANNO MakeID('A','N','N','O')


#define mskNone 0
#define mskHasMask 1
#define mskHasTransparentColor 2
#define mskLasso 3

#define cmpNone     0
#define cmpByteRun1 1
#define cmpPacked   2

typedef ULONG ID;
struct ChunkHeader
   {
   ID    ckID;
   LONG  ckSize;
   };

struct FromTotal
   {
   LONG     From, Total;
   };

typedef struct {
   UWORD tempo;
   UBYTE volume;
   UBYTE ctTrack;
} SScoreHeader;

typedef struct {
   UBYTE reg;
   UBYTE type;
   UBYTE data1,data2;
   char name[50];		/* Needs some-where to load name */
} RefInstrument;

typedef struct {
   UBYTE sID;
   UBYTE data;
} SEvent;

#define SID_FirstNote 0
#define SID_LastNote 127
#define SID_Rest 128
#define SID_Instrument 129
#define SID_TimeSig 130
#define SID_KeySig 131
#define SID_Dynamic 132
#define SID_MIDI_Chnl 133
#define SID_MIDI_Preset 134

#define SID_Mark 255

typedef struct {
   UBYTE tone;
   UBYTE flags;
#  define NOT_chord 0x80
#  define NOT_tieOut 0x40
#  define NOT_nTuplet 0x30
#  define NOT_dot   0x08
#  define NOT_division 0x7
} SNote;

typedef LONG Fixed;
#define UNITY 0x1000L;

typedef struct {
   ULONG oneShotHiSamples,
   repeatHiSamples,
   samplesPerHiCycle;
   UWORD samplesPerSec;
   UBYTE ctOctave,
   sCompression;
   Fixed Volume;
} Voice8Header;

typedef UBYTE Masking;
typedef UBYTE Compression;

struct BitMapInfo {
   UWORD    Width, Height;
   WORD     HotX, HotY;
   UBYTE    Depth;
   Masking  masking;
   Compression compression;
   UBYTE    transparentColor;
   UBYTE    PlanePick, PlaneOnOff;
   WORD     pageWidth, pageHeight;
   UBYTE    pad1,pad2;
   };

#define NUMIMAGES 32
   

struct SpriteImage {
  BYTE Class;
  UBYTE Count;
  char *Frames[NUMIMAGES];
};

struct GraphObject { /* An object can be a picture or a bob */ 
   UBYTE  *Image;       /* The Image (stored contigously) */ 
   SHORT  Width,Height; /* Pixel width and height of the object */
   UBYTE  Depth;        /* Depth include mask plane if any */
   UBYTE  RDepth;
   WORD HotX;
   WORD HotY;
   };

/*
 * Definitions for the Class field above
 *
 */
 
#define CLS_none     0
#define CLS_Bob      1
#define CLS_Screen   2
#define CLS_Sprite   3
#define CLS_SoftBob  4


#define MAXCLASS 5


#endif IFF_H

