/**************************************************************************
 *                              RasterDump.c                              *
 **************************************************************************
 * This piece of code shows how to print a 256 color rastport.
 *
 * Ce morceau de code montre comment imprimer un port graphique comportant
 * 256 couleurs.
 *
 * GP
 * 27-Nov-2010 Close device before waiting user
 * 17-Nov-2009 Cosmetic changes, all messages in english
 * 01-Mar-2009 Progress bar with transparent percent value
 * 28-Feb-2009 Stop gadget
 * 25-Feb-2009 Be sure that opt nostackcheck is set before compiling
 *             if not, the guru is not so far.
 * 15-Feb-2009 Redirecting into a file
 * 26-Dec-2008 SASC 6.0 SendIO() CheckIO() AbortIO() WaitIO()
 *             Now use include 3.1 constants for intuition
 * 14-Feb-1995 Lattice C 5.10 DoIO()
 */


#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

#include <exec/memory.h>
#include <exec/io.h>
#include <exec/libraries.h>
#include <exec/devices.h>

#include <devices/printer.h>
#include <devices/prtbase.h>

#include <intuition/intuition.h>
#include <graphics/gfxmacros.h>

#include <libraries/iffparse.h>

#include "gui.h"

#include <clib/alib_protos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/iffparse.h>


/* Libraries */
struct Library *IFFParseBase  = NULL;
extern struct Library *SysBase;
extern struct Library *DOSBase;

void CleanExit(char *libname) ;

struct Library *OpenLib(char *libname, long version)
{
  struct Library *lib ;

  lib = OpenLibrary(libname, version) ;
  if (lib == NULL)
  {
    CleanExit(libname) ;
  }

  return lib ;
}

void OpenLibs(void)
{ 
  IntuitionBase = OpenLib("intuition.library", 31) ;
  GfxBase       = OpenLib("graphics.library", 31) ;
  IFFParseBase  = OpenLibrary("iffparse.library",0) ;
} /* OpenLibs */

void CloseLibs(void)
{
  if(IntuitionBase) CloseLibrary(IntuitionBase) ;
  if(GfxBase      ) CloseLibrary(GfxBase) ;
  if(IFFParseBase ) CloseLibrary(IFFParseBase) ;
} /* CloseLibs */

void CleanExit(char *s)
{
  CloseLibs() ;
  if (s != NULL)
  {
    printf("\"%s\" won't open\n", s) ;
  }

  exit(0) ;
} /* CleanExit */

void MyFreeBitMap(struct BitMap *bm)
{
  if (0 && GfxBase->lib_Version >= 39)
  {
    // Don't work
    FreeBitMap(bm) ;
  }
  else
  {
    register int i ;
    ULONG depth, sizex, sizey ;

    if (bm != NULL)
    {
      sizex = bm->BytesPerRow * 8 ;
      sizey = bm->Rows ;
      depth = bm->Depth ;

      for ( i = 0 ; i < depth ; i++ )
      {
        if (bm->Planes[i] != NULL)
        {
          FreeRaster(bm->Planes[i], sizex, sizey) ;
        }
      }
      FreeMem(bm, sizeof(struct BitMap)) ;
    }
  }
} /* MyFreeBitMap */

struct BitMap *MyAllocBitMap(
ULONG sizex,
ULONG sizey,
ULONG depth,
ULONG flags,
struct BitMap *friend_bitmap
)
{
  register struct BitMap *bm ;

  if (0 && GfxBase->lib_Version >= 39)
  {
    // Don't work
    bm = AllocBitMap(sizex, sizey, depth, flags, friend_bitmap) ;
  }
  else
  {
    register int i ;
  
    bm = (struct BitMap*)
         AllocMem(sizeof(struct BitMap), MEMF_PUBLIC|MEMF_CLEAR) ;

    if (bm != NULL)
    {
      InitBitMap(bm, depth, sizex, sizey) ; 
    
      i = 0 ;
      while ((bm != NULL) && (i < depth))
      {
        bm->Planes[i] = (PLANEPTR)AllocRaster(sizex, sizey) ;
        if (bm->Planes[i] == NULL)
        {
          MyFreeBitMap( bm ) ;
          bm = NULL ;
        }
        i++ ;
      }
    }
  }

  return bm;  
} /* AllocBitMap */

#define FRAC8(a) (a << 24 | a << 16 | a << 8 | a)

#define ID_ILBM MAKE_ID('I','L','B','M')
#define ID_CMAP MAKE_ID('C','M','A','P')

struct RGBColor
{
  unsigned char red, green, blue;
};

struct RGBColor palette[256];

BOOL LoadPalette(
struct ColorMap *cm,
char *name
)
{
  struct IFFHandle *iff ;
  struct StoredProperty *sp ;
  BOOL def ;
  long index, err ;
  
  if (IFFParseBase == NULL)
  {
    //printf("no iffparse.library\n");
    return FALSE;
  }
  
  def = FALSE ;
  iff = AllocIFF() ;
  if (iff != NULL)
  {
    iff->iff_Stream = (ULONG)Open(name, MODE_OLDFILE) ;
    if (iff->iff_Stream != 0)
    {
      InitIFFasDOS(iff) ;
      err = OpenIFF(iff,IFFF_READ) ;
      if (err == 0)
      {
        PropChunk(iff, ID_ILBM, ID_CMAP) ;
        StopOnExit(iff, ID_ILBM, ID_FORM) ;
        err = ParseIFF(iff,IFFPARSE_SCAN) ;
        sp = FindProp(iff, ID_ILBM, ID_CMAP) ;
        if (sp == NULL)
        {
          //printf("No CMAP found\n") ;
        }
        else
        {
          //printf("number of colors %d\n", sp->sp_Size / 3) ;
          for ( index = 0 ; index < sp->sp_Size / 3 ; index++ )
          {
            if (GfxBase->lib_Version >= 39)
            {
              SetRGB32CM
              ( cm,
                index,
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].red),  
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].green),
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].blue)
              ) ;
            }
            else
            {
              SetRGB4CM
              ( cm,
                index,
                ((struct RGBColor*)(sp->sp_Data))[index].red/17,  
                ((struct RGBColor*)(sp->sp_Data))[index].green/17,
                ((struct RGBColor*)(sp->sp_Data))[index].blue/17
              ) ;
            }
          }
          def = TRUE ;
        }
        CloseIFF(iff) ;
      }
      Close(iff->iff_Stream) ;
    }
    FreeIFF(iff) ;
  }  
  return def ;   
} /* loadpalette */

#define LARGEUR 640
#define HAUTEUR 512
#define NBPLANS 8

void Couleurs_Defaut(struct ColorMap* cm)
{
  /* nombre de couleurs 256 */

  SetRGB4CM( cm,   0,  0,  0,  0); /* noir  */
  SetRGB4CM( cm,   1, 15, 15, 15); /* blanc */

  if (cm->Count <= 2) return ;  
  SetRGB4CM( cm,   2, 15,  0,  0);
  SetRGB4CM( cm,   3, 15,  0,  0);

  if (cm->Count <= 4) return ;
  SetRGB4CM( cm,   4, 15,  1,  0);
  SetRGB4CM( cm,   5, 15,  1,  0);
  SetRGB4CM( cm,   6, 15,  2,  0);
  SetRGB4CM( cm,   7, 15,  2,  0);

  if (cm->Count <= 8) return ;
  SetRGB4CM( cm,   8, 15,  3,  0);
  SetRGB4CM( cm,   9, 15,  3,  0);
  SetRGB4CM( cm,  10, 15,  4,  0);
  SetRGB4CM( cm,  11, 15,  4,  0);
  SetRGB4CM( cm,  12, 15,  5,  0);
  SetRGB4CM( cm,  13, 15,  5,  0);
  SetRGB4CM( cm,  14, 15,  6,  0);
  SetRGB4CM( cm,  15, 15,  6,  0);

  if (cm->Count <= 16) return ;
  SetRGB4CM( cm,  16, 15,  7,  0);
  SetRGB4CM( cm,  17, 15,  7,  0);
  SetRGB4CM( cm,  18, 15,  8,  0);
  SetRGB4CM( cm,  19, 15,  8,  0);
  SetRGB4CM( cm,  20, 15,  9,  0);
  SetRGB4CM( cm,  21, 15,  9,  0);
  SetRGB4CM( cm,  22, 15, 10,  0);
  SetRGB4CM( cm,  23, 15, 10,  0);
  SetRGB4CM( cm,  24, 15, 11,  0);
  SetRGB4CM( cm,  25, 15, 11,  0);
  SetRGB4CM( cm,  26, 15, 12,  0);
  SetRGB4CM( cm,  27, 15, 12,  0);
  SetRGB4CM( cm,  28, 15, 13,  0);
  SetRGB4CM( cm,  29, 15, 13,  0);
  SetRGB4CM( cm,  30, 15, 14,  0);
  SetRGB4CM( cm,  31, 15, 14,  0);

  if (cm->Count <= 32) return ;
  SetRGB4CM( cm,  32, 15, 15,  0);
  SetRGB4CM( cm,  33, 14, 15,  0);
  SetRGB4CM( cm,  34, 13, 15,  0);
  SetRGB4CM( cm,  35, 13, 15,  0);
  SetRGB4CM( cm,  36, 12, 15,  0);
  SetRGB4CM( cm,  37, 12, 15,  0);
  SetRGB4CM( cm,  38, 11, 15,  0);
  SetRGB4CM( cm,  39, 11, 15,  0);
  SetRGB4CM( cm,  40, 10, 15,  0);
  SetRGB4CM( cm,  41, 10, 15,  0);
  SetRGB4CM( cm,  42,  9, 15,  0);
  SetRGB4CM( cm,  43,  9, 15,  0);
  SetRGB4CM( cm,  44,  8, 15,  0);
  SetRGB4CM( cm,  45,  8, 15,  0);
  SetRGB4CM( cm,  46,  7, 15,  0);
  SetRGB4CM( cm,  47,  7, 15,  0);
  SetRGB4CM( cm,  48,  6, 15,  0);
  SetRGB4CM( cm,  49,  6, 15,  0);
  SetRGB4CM( cm,  50,  5, 15,  0);
  SetRGB4CM( cm,  51,  5, 15,  0);
  SetRGB4CM( cm,  52,  4, 15,  0);
  SetRGB4CM( cm,  53,  4, 15,  0);
  SetRGB4CM( cm,  54,  3, 15,  0);
  SetRGB4CM( cm,  55,  3, 15,  0);
  SetRGB4CM( cm,  56,  2, 15,  0);
  SetRGB4CM( cm,  57,  2, 15,  0);
  SetRGB4CM( cm,  58,  1, 15,  0);
  SetRGB4CM( cm,  59,  1, 15,  0);
  SetRGB4CM( cm,  60,  0, 15,  0);
  SetRGB4CM( cm,  61,  0, 15,  0);
  SetRGB4CM( cm,  62,  0, 15,  0);
  SetRGB4CM( cm,  63,  0, 15,  0);

  if (cm->Count <= 64) return ;
  SetRGB4CM( cm,  64,  0, 15,  1);
  SetRGB4CM( cm,  65,  0, 15,  1);
  SetRGB4CM( cm,  66,  0, 15,  2);
  SetRGB4CM( cm,  67,  0, 15,  2);
  SetRGB4CM( cm,  68,  0, 15,  3);
  SetRGB4CM( cm,  69,  0, 15,  3);
  SetRGB4CM( cm,  70,  0, 15,  4);
  SetRGB4CM( cm,  71,  0, 15,  4);
  SetRGB4CM( cm,  72,  0, 15,  5);
  SetRGB4CM( cm,  73,  0, 15,  5);
  SetRGB4CM( cm,  74,  0, 15,  6);
  SetRGB4CM( cm,  75,  0, 15,  6);
  SetRGB4CM( cm,  76,  0, 15,  7);
  SetRGB4CM( cm,  77,  0, 15,  7);
  SetRGB4CM( cm,  78,  0, 15,  8);
  SetRGB4CM( cm,  79,  0, 15,  8);
  SetRGB4CM( cm,  80,  0, 15,  9);
  SetRGB4CM( cm,  81,  0, 15,  9);
  SetRGB4CM( cm,  82,  0, 15, 10);
  SetRGB4CM( cm,  83,  0, 15, 10);
  SetRGB4CM( cm,  84,  0, 15, 11);
  SetRGB4CM( cm,  85,  0, 15, 11);
  SetRGB4CM( cm,  86,  0, 15, 12);
  SetRGB4CM( cm,  87,  0, 15, 12);
  SetRGB4CM( cm,  88,  0, 15, 13);
  SetRGB4CM( cm,  89,  0, 15, 13);
  SetRGB4CM( cm,  90,  0, 15, 14);
  SetRGB4CM( cm,  91,  0, 15, 14);
  SetRGB4CM( cm,  92,  0, 15, 15);
  SetRGB4CM( cm,  93,  0, 14, 15);
  SetRGB4CM( cm,  94,  0, 13, 15);
  SetRGB4CM( cm,  95,  0, 13, 15);
  SetRGB4CM( cm,  96,  0, 12, 15);
  SetRGB4CM( cm,  97,  0, 12, 15);
  SetRGB4CM( cm,  98,  0, 11, 15);
  SetRGB4CM( cm,  99,  0, 11, 15);
  SetRGB4CM( cm, 100,  0, 10, 15);
  SetRGB4CM( cm, 101,  0, 10, 15);
  SetRGB4CM( cm, 102,  0,  9, 15);
  SetRGB4CM( cm, 103,  0,  9, 15);
  SetRGB4CM( cm, 104,  0,  8, 15);
  SetRGB4CM( cm, 105,  0,  8, 15);
  SetRGB4CM( cm, 106,  0,  7, 15);
  SetRGB4CM( cm, 107,  0,  7, 15);
  SetRGB4CM( cm, 108,  0,  6, 15);
  SetRGB4CM( cm, 109,  0,  6, 15);
  SetRGB4CM( cm, 110,  0,  5, 15);
  SetRGB4CM( cm, 111,  0,  5, 15);
  SetRGB4CM( cm, 112,  0,  4, 15);
  SetRGB4CM( cm, 113,  0,  4, 15);
  SetRGB4CM( cm, 114,  0,  3, 15);
  SetRGB4CM( cm, 115,  0,  3, 15);
  SetRGB4CM( cm, 116,  0,  2, 15);
  SetRGB4CM( cm, 117,  0,  2, 15);
  SetRGB4CM( cm, 118,  0,  1, 15);
  SetRGB4CM( cm, 119,  0,  1, 15);
  SetRGB4CM( cm, 120,  0,  0, 15);
  SetRGB4CM( cm, 121,  0,  0, 15);
  SetRGB4CM( cm, 122,  0,  0, 15);
  SetRGB4CM( cm, 123,  0,  0, 15);
  SetRGB4CM( cm, 124,  1,  0, 15);
  SetRGB4CM( cm, 125,  1,  0, 15);
  SetRGB4CM( cm, 126,  2,  0, 15);
  SetRGB4CM( cm, 127,  2,  0, 15);

  if (cm->Count <= 128) return ;
  SetRGB4CM( cm, 128,  3,  0, 15);
  SetRGB4CM( cm, 129,  3,  0, 15);
  SetRGB4CM( cm, 130,  4,  0, 15);
  SetRGB4CM( cm, 131,  4,  0, 15);
  SetRGB4CM( cm, 132,  5,  0, 15);
  SetRGB4CM( cm, 133,  5,  0, 15);
  SetRGB4CM( cm, 134,  6,  0, 15);
  SetRGB4CM( cm, 135,  6,  0, 15);
  SetRGB4CM( cm, 136,  7,  0, 15);
  SetRGB4CM( cm, 137,  7,  0, 15);
  SetRGB4CM( cm, 138,  8,  0, 15);
  SetRGB4CM( cm, 139,  8,  0, 15);
  SetRGB4CM( cm, 140,  9,  0, 15);
  SetRGB4CM( cm, 141,  9,  0, 15);
  SetRGB4CM( cm, 142, 10,  0, 15);
  SetRGB4CM( cm, 143, 10,  0, 15);
  SetRGB4CM( cm, 144, 11,  0, 15);
  SetRGB4CM( cm, 145, 11,  0, 15);
  SetRGB4CM( cm, 146, 12,  0, 15);
  SetRGB4CM( cm, 147, 12,  0, 15);
  SetRGB4CM( cm, 148, 13,  0, 15);
  SetRGB4CM( cm, 149, 13,  0, 15);
  SetRGB4CM( cm, 150, 14,  0, 15);
  SetRGB4CM( cm, 151, 14,  0, 15);
  SetRGB4CM( cm, 152, 15,  0, 15);
  SetRGB4CM( cm, 153, 15,  0, 14);
  SetRGB4CM( cm, 154, 15,  0, 13);
  SetRGB4CM( cm, 155, 15,  0, 12);
  SetRGB4CM( cm, 156, 15,  0, 11);
  SetRGB4CM( cm, 157, 15,  0, 10);
  SetRGB4CM( cm, 158, 15,  0,  9);
  SetRGB4CM( cm, 159, 15,  0,  8);
  SetRGB4CM( cm, 160, 15,  0,  7);
  SetRGB4CM( cm, 161, 15,  0,  6);
  SetRGB4CM( cm, 162, 15,  0,  5);
  SetRGB4CM( cm, 163, 15,  0,  4);
  SetRGB4CM( cm, 164, 15,  0,  3);
  SetRGB4CM( cm, 165, 15,  0,  2);
  SetRGB4CM( cm, 166, 15,  0,  1);
  SetRGB4CM( cm, 167, 15,  1,  1);
  SetRGB4CM( cm, 168, 15,  2,  2);
  SetRGB4CM( cm, 169, 15,  3,  3);
  SetRGB4CM( cm, 170, 15,  4,  4);
  SetRGB4CM( cm, 171, 15,  5,  5);
  SetRGB4CM( cm, 172, 15,  6,  6);
  SetRGB4CM( cm, 173, 15,  7,  7);
  SetRGB4CM( cm, 174, 15,  8,  8);
  SetRGB4CM( cm, 175, 15,  9,  9);
  SetRGB4CM( cm, 176, 15, 10, 10);
  SetRGB4CM( cm, 177, 15, 11, 11);
  SetRGB4CM( cm, 178, 15, 12, 12);
  SetRGB4CM( cm, 179, 15, 13, 13);
  SetRGB4CM( cm, 180, 15, 14, 14);
  SetRGB4CM( cm, 181,  7, 15,  1);
  SetRGB4CM( cm, 182,  8, 15,  2);
  SetRGB4CM( cm, 183,  8, 15,  3);
  SetRGB4CM( cm, 184,  9, 15,  4);
  SetRGB4CM( cm, 185,  9, 15,  5);
  SetRGB4CM( cm, 186, 10, 15,  6);
  SetRGB4CM( cm, 187, 10, 15,  7);
  SetRGB4CM( cm, 188, 11, 15,  8);
  SetRGB4CM( cm, 189, 11, 15,  9);
  SetRGB4CM( cm, 190, 12, 15, 10);
  SetRGB4CM( cm, 191, 12, 15, 11);
  SetRGB4CM( cm, 192, 13, 15, 12);
  SetRGB4CM( cm, 193, 13, 15, 13);
  SetRGB4CM( cm, 194, 14, 15, 14);
  SetRGB4CM( cm, 195,  1,  1, 15);
  SetRGB4CM( cm, 196,  2,  2, 15);
  SetRGB4CM( cm, 197,  3,  3, 15);
  SetRGB4CM( cm, 198,  4,  4, 15);
  SetRGB4CM( cm, 199,  5,  5, 15);
  SetRGB4CM( cm, 200,  6,  6, 15);
  SetRGB4CM( cm, 201,  7,  7, 15);
  SetRGB4CM( cm, 202,  8,  8, 15);
  SetRGB4CM( cm, 203,  9,  9, 15);
  SetRGB4CM( cm, 204, 10, 10, 15);
  SetRGB4CM( cm, 205, 11, 11, 15);
  SetRGB4CM( cm, 206, 12, 12, 15);
  SetRGB4CM( cm, 207, 13, 13, 15);
  SetRGB4CM( cm, 208, 14, 14, 15);
  SetRGB4CM( cm, 209, 15, 15,  1);
  SetRGB4CM( cm, 210, 15, 15,  2);
  SetRGB4CM( cm, 211, 15, 15,  3);
  SetRGB4CM( cm, 212, 15, 15,  4);
  SetRGB4CM( cm, 213, 15, 15,  5);
  SetRGB4CM( cm, 214, 15, 15,  6);
  SetRGB4CM( cm, 215, 15, 15,  7);
  SetRGB4CM( cm, 216, 15, 15,  8);
  SetRGB4CM( cm, 217, 15, 15,  9);
  SetRGB4CM( cm, 218, 15, 15, 10);
  SetRGB4CM( cm, 219, 15, 15, 11);
  SetRGB4CM( cm, 220, 15, 15, 12);
  SetRGB4CM( cm, 221, 15, 15, 13);
  SetRGB4CM( cm, 222, 15, 15, 14);
  SetRGB4CM( cm, 223,  1, 15, 15);
  SetRGB4CM( cm, 224,  2, 15, 15);
  SetRGB4CM( cm, 225,  3, 15, 15);
  SetRGB4CM( cm, 226,  4, 15, 15);
  SetRGB4CM( cm, 227,  5, 15, 15);
  SetRGB4CM( cm, 228,  6, 15, 15);
  SetRGB4CM( cm, 229,  7, 15, 15);
  SetRGB4CM( cm, 230,  8, 15, 15);
  SetRGB4CM( cm, 231, 10, 15, 15);
  SetRGB4CM( cm, 232,  9, 15, 15);
  SetRGB4CM( cm, 233, 11, 15, 15);
  SetRGB4CM( cm, 234, 12, 15, 15);
  SetRGB4CM( cm, 235, 13, 15, 15);
  SetRGB4CM( cm, 236, 14, 15, 15);
  SetRGB4CM( cm, 237, 15,  1, 15);
  SetRGB4CM( cm, 238, 15,  2, 15);
  SetRGB4CM( cm, 239, 15,  3, 15);
  SetRGB4CM( cm, 240, 15,  4, 15);
  SetRGB4CM( cm, 241, 15,  5, 15);
  SetRGB4CM( cm, 242, 15,  6, 15);
  SetRGB4CM( cm, 243, 15,  7, 15);
  SetRGB4CM( cm, 244, 15,  8, 15);
  SetRGB4CM( cm, 245, 15,  9, 15);
  SetRGB4CM( cm, 246, 15, 10, 15);
  SetRGB4CM( cm, 247, 15, 11, 15);
  SetRGB4CM( cm, 248, 15, 12, 15);
  SetRGB4CM( cm, 249, 15, 13, 15);
  SetRGB4CM( cm, 250, 15, 14, 15);
  SetRGB4CM( cm, 251, 14, 14, 14);
  SetRGB4CM( cm, 252, 11, 11, 11);
  SetRGB4CM( cm, 253,  8,  8,  8);
  SetRGB4CM( cm, 254,  5,  5,  5);
  SetRGB4CM( cm, 255,  2,  2,  2);
} /* Couleurs_Defaut */

void Couleurs(struct ColorMap* cm)
{
  BOOL lp ;

  lp = LoadPalette(cm, "default.pal") ;

  if (lp)
  {
    //printf("USe file \"default.pal\"\n") ;
  }
  else
  {
    //printf("Palette by default\n") ;
    Couleurs_Defaut(cm) ;
  }
    
  /* patch */
  SetRGB4CM( cm, 0,  0,  0,  0 ); /* noir  */ 
  SetRGB4CM( cm, 1, 15, 15, 15 ); /* blanc */
} /* Couleurs */

void Efface(struct RastPort *rp)
{
  UBYTE NOIR, BLANC ;

  NOIR  = 0 ;
  BLANC = 1 ;

  SetAPen(rp, BLANC) ;
  RectFill(rp, 0, 0, (rp->BitMap->BytesPerRow * 8)-1, (rp->BitMap->Rows)-1) ;
}

void Dessin(struct RastPort *rp, long x0, long y0, long x1, long y1)
{
  LONG i, j ;
  UBYTE NOIR, BLANC ;
  UBYTE index ;
  WORD posx, posy ;
  UBYTE *s ; 
  
  NOIR  = 0;
  BLANC = 1;
  
  s = "256 colors";
  SetAPen(rp, NOIR);
  SetBPen(rp, BLANC) ;
  SetDrMd(rp, JAM1);
  Move(rp,x0,y0+12);
  Text(rp,s,strlen(s));

  index = 0 ;
  posx  = x0 ;
  for (j = 0 ; j < 256 ; j ++ )
  {
    SetAPen(rp, index) ;
    RectFill(rp, posx, y0+15, posx+2, y0+30) ;
    posx += 2 ;
    index++ ;
  }

  index = 0 ;
  posx  = x0 ;
  posy  = y0+40 ;
  for ( j = 0 ; j < 8 ; j++ )
  {
    for ( i = 0 ; i < 32 ; i++ )
    {
      SetAPen(rp,index) ;
      RectFill(rp, posx+2, posy+2, posx+12, posy+12) ;

      SetAPen(rp, NOIR) ;
      DrawRect(rp, posx, posy, posx+14, posy+14) ;

      index++ ;
      posx += 16 ;
    }
    posx = 0 ;
    posy += 16 ;
  }
} /* Dessin */

/***************************************************************************/
UBYTE printoutfile[] = "" ;

BPTR outfile = NULL ;
LONG __stdargs (*oldwrite)(UBYTE *, ULONG) = NULL ;
LONG __stdargs __saveds PWrite(UBYTE *buffer, ULONG length)
{
  if (outfile != NULL)
  {
    return Write(outfile, buffer, length) ;
  }
  return 0 ;
}

LONG __stdargs (*oldready)(VOID) = NULL ;
LONG __stdargs PBothReady(VOID)
{
  return 0 ;
}

/***************************************************************************/

LONG t_width  = 0 ;
LONG t_height = 0 ;
LONG t_rownum = 0 ;

LONG __stdargs (*oldrender)(LONG, LONG, LONG, LONG) = NULL ;
LONG __stdargs __saveds PRender(LONG ct, LONG x, LONG y, LONG status)
{
  switch (status)
  {
    case 0 :
    {
      t_width  = x ;
      t_height = y ;
      break ;
    }

    case 1 :
    {
      t_rownum = y ;
      break ;
    }
  }

  if (oldrender != NULL)
  {
    return oldrender(ct, x, y, status) ;
  }

  return 0 ;
}



/********************************************************************/

UWORD pencils[15] ;

struct Gadget stopgadget ;
struct IntuiText stopgadgettext ;
struct Image R1,R2,R3,S1,S2,S3 ;

int main(int argc, char *argv[])
{
  struct IODRPReq *prt ;

  struct MsgPort *port ;
  
  struct RastPort *rp ;
  struct BitMap *bm ;
  struct ColorMap *cm ;
  struct PrinterData *PD ;
  struct PrinterExtendedData *PED ;
  struct Device *dev ;
  int err ;
  UWORD left, top, l, t ;
  UWORD pagewidth, pageheight ;
  UBYTE pagedepth ;
  UBYTE tmp[256] ;
  ULONG mem ;
  struct Window *wndw = NULL ;

  OpenLibs() ;
 
  mem = AvailMem(MEMF_CHIP) ;

  port = (struct MsgPort*) CreatePort( 0, 0 ) ;
  if (port == NULL)
  {
    //printf( "Can't create port\n" ) ;
    CleanExit(NULL) ;
  }

  prt = (struct IODRPReq*)CreateExtIO( port, sizeof(struct IODRPReq)) ;
  if (prt == NULL)
  {
    //printf( "Can't create io\n" ) ;
    DeletePort((struct MsgPort *)port) ;
    CleanExit(NULL) ;
  }
  
  err = OpenDevice( "printer.device", 0, (struct IORequest *)prt, 0 ) ;
  if (err != 0)
  {
    printf( "Can't open printer.device error=%d\n", err ) ;
    DeleteExtIO((struct IORequest *)prt) ;
    DeletePort((struct MsgPort *)port) ;
    CleanExit(NULL) ;
  }
  else
  {
    PD  = (struct PrinterData *)prt->io_Device ;
    PED = &PD->pd_SegmentData->ps_PED ;

    if (mem <= 400000)
    {
      pagewidth  = 640 ;
      pageheight = 256 ;
      pagedepth  = 1 ;
    }
    else
    {
      pagewidth  = LARGEUR ;
      pageheight = HAUTEUR ;
      pagedepth  = NBPLANS ;
    }

    /* patch render function to get information about work size and */
    /* current render line */
    oldrender = PED->ped_Render ;
    PED->ped_Render = PRender ;

    if (printoutfile[0] != 0)
    {
      outfile = Open(printoutfile, MODE_NEWFILE) ;
      if (outfile != NULL)
      {
        oldwrite = PD->pd_PWrite ;
        PD->pd_PWrite = PWrite ;

        oldready = PD->pd_PBothReady ;
        PD->pd_PBothReady = PBothReady ;
      }
    }
  } 

  l =  5 ;
  t = 10 ;

  wndw = wopen(WA_Left,    20,
               WA_Top,     20,
               WA_Width,  400,
               WA_Height, 150,
               WA_Title, (ULONG)"RasterDump",
               WA_IDCMP, IDCMP_CLOSEWINDOW|
                         IDCMP_NEWSIZE|
                         IDCMP_ACTIVEWINDOW|
                         IDCMP_GADGETUP,
               WA_Flags, WFLG_SMART_REFRESH|
                         WFLG_GIMMEZEROZERO,
               TAG_DONE) ;

  if (wndw != NULL)
  {
    wsetpencils(pencils) ;

    bm = MyAllocBitMap(pagewidth, pageheight, pagedepth, 0, NULL) ;
    if (bm != NULL)
    {
      rp = (struct RastPort*)AllocMem(sizeof(struct RastPort), MEMF_CLEAR) ;
      if (rp != NULL)
      {
        InitRastPort( rp ) ;
        rp->BitMap = bm ;
        cm = (struct ColorMap*) GetColorMap( 1 << pagedepth ) ;
        if (cm != NULL)
        {
          struct Gadget *g ;

          Couleurs(cm) ;
          Efface(rp) ;

          prt->io_RastPort  = rp ; /* Graphique */
          prt->io_ColorMap  = cm ; /* Table des couleurs */
          prt->io_Modes     = 0 ;
          prt->io_SrcX      = 0 ;  /* dimensions */
          prt->io_SrcY      = 0 ;
          prt->io_SrcWidth  = pagewidth ;
          prt->io_SrcHeight = pageheight ;
          prt->io_DestCols  = 0 ;
          prt->io_DestRows  = 0 ;
          prt->io_Special   = SPECIAL_FULLROWS|
                              SPECIAL_ASPECT|
                              SPECIAL_DENSITY7|
                              SPECIAL_NOPRINT ;
          prt->io_Command   = PRD_DUMPRPORT ;
        
          /* fake printing */
          DoIO((struct IORequest *)prt ) ;

          SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
          SetBPen(wndw->RPort, pencils[BACKGROUNDPEN]) ;
          SetDrMd(wndw->RPort, JAM2) ;
          l =  5 ;
          t = 10 ;

          
          left = 0 ;
          top  = 10 ;
          SetAPen(rp, 0) ;
          SetDrMd(rp, JAM1) ;

          /* printer.device */
          dev = (struct Device *)prt->io_Device ;
          sprintf(tmp, "Printer: '%s' %u.%02u",
                  dev->dd_Library.lib_Node.ln_Name,
                  dev->dd_Library.lib_Version,
                  dev->dd_Library.lib_Revision) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          /* parallel.device or other low level device */
          dev = (struct Device *)PD->pd_ior0.pd_p0.IOPar.io_Device ;
          sprintf(tmp, "Port   : '%s' %u.%02u",
                  dev->dd_Library.lib_Node.ln_Name,
                  dev->dd_Library.lib_Version,
                  dev->dd_Library.lib_Revision) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "Driver : '%s' %02u.%02u",
                  PED->ped_PrinterName,
                  PD->pd_SegmentData->ps_Version,
                  PD->pd_SegmentData->ps_Revision ) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "PrinterClass=%u, ColorClass=%u",
                  PED->ped_PrinterClass,
                  PED->ped_ColorClass ) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "MaxColumns=%u, NumCharSets=%u, NumRows=%u",
                  PED->ped_MaxColumns,
                  PED->ped_NumCharSets,
                  PED->ped_NumRows ) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "MaxXDots=%lu, MaxYDots=%lu",
                  PED->ped_MaxXDots, PED->ped_MaxYDots) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "XDotsInch=%u, YDotsInch=%u",
                  PED->ped_XDotsInch, PED->ped_YDotsInch) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          sprintf(tmp, "Threshold=%ld PrintShade=%ld",
                  PD->pd_Preferences.PrintThreshold,
                  PD->pd_Preferences.PrintShade ) ;
          Move(rp, left, top) ;
          Text(rp, tmp, strlen(tmp)) ;
          top += rp->TxHeight ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          if (mem <= 400000)
          {
            /* not enough mem */
          }
          else
          {
            Dessin( rp, 0, top, pagewidth, pageheight-top) ;
          }

          sprintf(tmp, "Patience, printing in progress..." ) ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ;
          t += wndw->RPort->TxHeight ; 

          memset(&stopgadgettext, 0, sizeof(stopgadgettext)) ;
          memset(&stopgadget, 0, sizeof(stopgadget)) ;

          g = &stopgadget ;
          g->NextGadget    = NULL ;
          g->LeftEdge      = 140 ;
          g->TopEdge       = t + 10 ;
          g->Width         = 80 ;
          g->Height        = 11 ;
          g->GadgetText    = &stopgadgettext ; 
          g->Flags         = GFLG_GADGHCOMP ;
          g->Activation    = GACT_RELVERIFY|GACT_IMMEDIATE ;
          g->GadgetType    = GTYP_BOOLGADGET ;
          g->MutualExclude = 0 ;
          g->SpecialInfo   = NULL ;
          g->GadgetID      = 1 ;
          g->UserData      = 0 ;

          stopgadgettext.FrontPen  = 1 ;
          stopgadgettext.BackPen   = 0 ;
          if (g->GadgetText != NULL)
          {
            WORD h ;

            g->GadgetText->IText = "Stop" ;
            if (g->GadgetText->ITextFont != NULL)
            {
              h = g->GadgetText->ITextFont->ta_YSize ;
            }
            else
            {
              h = 8 ;
            }

            if ( h+2 > g->Height )
            {
              g->Height = h+2 ;
            }
            g->GadgetText->LeftEdge = (g->Width-IntuiTextLength(g->GadgetText))/2 ;
            g->GadgetText->TopEdge  = 1+(g->Height-h)/2 ;
          }
          stopgadgettext.DrawMode  = JAM1 ;
          stopgadgettext.ITextFont = NULL ;
          stopgadgettext.NextText  = NULL ;
          Button_SetImage(g, &R1, &R2, &R3, &S1, &S2, &S3, pencils) ;

          AddGadget(wndw, &stopgadget, 0) ;
          RefreshGadgets(&stopgadget, wndw, NULL) ; 
          SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
          DrawRect(wndw->RPort,
                   9,
                   stopgadget.TopEdge,
                   111,
                   stopgadget.TopEdge+stopgadget.Height) ;

          prt->io_RastPort  = rp ; /* Graphique */
          prt->io_ColorMap  = cm ; /* Table des couleurs */
          prt->io_Modes     = 0 ;
          prt->io_SrcX      = 0 ;  /* dimensions */
          prt->io_SrcY      = 0 ;
          prt->io_SrcWidth  = pagewidth ;
          prt->io_SrcHeight = pageheight ;
          prt->io_DestCols  = 0 ;
          prt->io_DestRows  = 0 ;
          prt->io_Special   = SPECIAL_FULLROWS|
                              SPECIAL_ASPECT|
                              SPECIAL_DENSITY7 ;
          prt->io_Command   = PRD_DUMPRPORT ;

        
          if (0)
          {
            /* not funny to wait the end of the printing */
            DoIO((struct IORequest *)prt ) ;
          }
          else
          {
            struct IORequest *io = NULL ;
            long oldtoto  = -1 ;
            long toto     = 0 ;
            BOOL loop     = TRUE ;
            struct IntuiMessage *msg, imsg ;

            SendIO((struct IORequest *)prt) ;
            do
            {
              Delay(20) ;
              msg = (struct IntuiMessage *)GetMsg(wndw->UserPort) ;
              if (msg != NULL)
              {
                imsg = *msg ;
                ReplyMsg((struct Message *)msg) ;
                switch (imsg.Class)
                {
                  case IDCMP_CLOSEWINDOW :
                  {
                    loop = FALSE ;
                    break ;
                  }
 
                  case IDCMP_GADGETUP :
                  {
                    switch (((struct Gadget *)imsg.IAddress)->GadgetID)
                    {
                      case 1 :
                      {
                        loop = FALSE ;
                        break ;
                      }
                    }
                    break ;
                  }
                }
              }

              if (!loop)
              {
                AbortIO((struct IORequest *)prt) ;
              }
              else
              {
                io = CheckIO((struct IORequest *)prt) ;
                if (io == NULL)
                {
                  if (t_height > 0)
                  {
                    toto = t_rownum * 100 / t_height ;
                  }

                  if (toto != oldtoto)
                  {
                    oldtoto = toto ;
                    SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
                    DrawRect(wndw->RPort,
                             9,
                             stopgadget.TopEdge,
                             111,
                             stopgadget.TopEdge+stopgadget.Height) ;
                    if (toto > 0)
                    {
                      SetAPen(wndw->RPort, pencils[FILLPEN]) ;
                      RectFill(wndw->RPort,
                               10,
                               stopgadget.TopEdge+1,
                               10+toto,
                               stopgadget.TopEdge+stopgadget.Height-1) ;
                    }

                    if (toto < 100)
                    {
                      SetAPen(wndw->RPort, pencils[BACKGROUNDPEN]) ;
                      RectFill(wndw->RPort,
                               10+toto,
                               stopgadget.TopEdge+1,
                               10+100,
                               stopgadget.TopEdge+stopgadget.Height-1) ;
                    }

                    SetAPen(wndw->RPort, pencils[SHINEPEN]) ; 
                    SetDrMd(wndw->RPort, JAM1) ;
                    sprintf(tmp, "%d%%", toto) ;
                    Move(wndw->RPort,
                         10 + (100 - TextLength(wndw->RPort, tmp, strlen(tmp)))/2,
                         stopgadget.TopEdge + 1 + (stopgadget.Height-wndw->RPort->TxHeight)/2+wndw->RPort->TxBaseline) ;
                    Text(wndw->RPort, tmp, strlen(tmp)) ;
                  }
                }
                else
                {
                  loop = FALSE ;
                }
              }
            } while (loop) ;
            WaitIO((struct IORequest *)prt) ;
          }

          switch (prt->io_Error)
          {
            case PDERR_NOERR :
            {
              SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
              sprintf(tmp, "Printing terminated" ) ;
              Move(wndw->RPort, l, t) ;
              Text(wndw->RPort, tmp, strlen(tmp)) ;
              t += wndw->RPort->TxHeight ;
              break ;
            }

            case -2 : /* abort */
            {
              SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
              sprintf(tmp, "Printing aborted" ) ;
              Move(wndw->RPort, l, t) ;
              Text(wndw->RPort, tmp, strlen(tmp)) ;
              t += wndw->RPort->TxHeight ; 
              break ;
            }

            default :
            {
              SetAPen(wndw->RPort, pencils[FILLPEN]) ;
              sprintf(tmp,  "Error #%d while printing",
                      prt->io_Error ) ;
              Move(wndw->RPort, l, t) ;
              Text(wndw->RPort, tmp, strlen(tmp)) ;
              t += wndw->RPort->TxHeight ; 

              tmp[0]=0 ;
              switch (prt->io_Error)
              {
                case -1: strcpy(tmp,"device failed to open") ; break ;
                case 1 : strcpy(tmp,"User cancel") ; break ;
                case 2 : strcpy(tmp,"Printer cannot output graphics") ; break ;
                case 3 : strcpy(tmp,"Inverted HAM") ; break ;
                case 4 : strcpy(tmp,"Bad dimensions") ; break ;
                case 5 : strcpy(tmp,"Dimensions overflow") ; break ;
                case 6 : strcpy(tmp,"No memory for internal variables") ; break ;
                case 7 : strcpy(tmp,"No memory for print buffer") ; break ;
                case 8 : strcpy(tmp,"Took control") ; break ;
              } 
              SetAPen(wndw->RPort, pencils[TEXTPEN]) ;
              Move(wndw->RPort, l, t) ;
              Text(wndw->RPort, tmp, strlen(tmp)) ;
              t += wndw->RPort->TxHeight ;
              break ;
            }
          }

          RemoveGadget(wndw, &stopgadget) ;

          SetAPen(wndw->RPort, pencils[BACKGROUNDPEN]) ;
          RectFill(wndw->RPort,
                   9,
                   stopgadget.TopEdge,
                   111,
                   stopgadget.TopEdge+stopgadget.Height) ;

          RectFill(wndw->RPort,
                   stopgadget.LeftEdge,
                   stopgadget.TopEdge,
                   stopgadget.LeftEdge+stopgadget.Width,
                   stopgadget.TopEdge+stopgadget.Height) ; 

          FreeColorMap( cm ) ;
        }
        else
        {
          sprintf(tmp, "Can't create color table" ) ;
          Move(wndw->RPort, l, t) ;
          Text(wndw->RPort, tmp, strlen(tmp)) ; 
        }
        FreeMem( rp, sizeof(struct RastPort) ) ;
      }
      else
      {
        sprintf(tmp,"Can't create raster" ) ;
        Move(wndw->RPort, l, t) ;
        Text(wndw->RPort, tmp, strlen(tmp)) ; 
      }
      MyFreeBitMap( bm ) ;
    }
    else
    {
      sprintf(tmp, "Can't allocate bitmap" ) ;
      Move(wndw->RPort, l, t) ;
      Text(wndw->RPort, tmp, strlen(tmp)) ; 
    }

    PED->ped_Render = oldrender ;

    if (outfile != NULL)
    {
      PD->pd_PWrite     = oldwrite ;
      PD->pd_PBothReady = oldready ;
      Close(outfile) ;
      outfile = NULL ;
    }

    CloseDevice((struct IORequest *)prt ) ;
    DeleteExtIO((struct IORequest *)prt ) ;
    DeletePort((struct MsgPort *)port ) ;

    if (1)
    {
      BOOL loop = TRUE ;
      struct IntuiMessage *msg, imsg ;

      SetWindowTitles(wndw, "<-click here to exit", "RasterDump") ;

      do
      {
        msg = (struct IntuiMessage *)GetMsg(wndw->UserPort) ;
        if (msg != NULL)
        {
          imsg = *msg ;
          ReplyMsg((struct Message *)msg) ;
          switch (imsg.Class)
          {
            case IDCMP_CLOSEWINDOW :
            {
              loop = FALSE ;
              break ;
            }
          }
        }
      } while (loop) ;
    }
           
    wclose(wndw) ;
  }

  CloseLibs() ;
} /* main */
