/**************************************************************************/
/*                             image.c                                    */
/**************************************************************************/
/* Misc routines to process pictures                                      */
/* GP 1996 2009                                                           */
/**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>

#include <exec/types.h>
#include <exec/memory.h>
#include <graphics/gfxmacros.h>
#include <libraries/iffparse.h>
#include <utility/tagitem.h>

#include "image.h"
#include "gui.h"

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/iffparse.h>

int getwidth(struct ImageDataInfo *info)
{
  return info->width ;
}

int getheight(struct ImageDataInfo *info)
{
  return info->height ;
}

long GetRGB(struct ColorMap *cm, int index) ;

int calcangle(int dx, int dy) ;
int calcdist(int dx, int dy) ;
void calcRGB(int hue, int sat, int light, unsigned char *r, unsigned char *g, unsigned char *b) ;

int getrowX(struct ImageDataInfo *info, int row, unsigned char *array, int color)
{
  int retval = -1 ;

  if (info != NULL)
  {
    /* from file */
    if (info->f != NULL)
    {
      if (row < info->height)
      {
        fseek(info->f, 4 + (2+info->width*3)*row + 2, SEEK_SET) ;
        switch (color)
        {
          case 0 :
          case 1 :
          {
            /* red */
            fseek(info->f, 0*info->width, SEEK_CUR) ;
            fread(array, info->width, 1, info->f) ;
            retval = 0 ;  
            break ;
          }

          case 2 :
          {
            /* green */
            fseek(info->f, 1*info->width, SEEK_CUR) ;
            fread(array, info->width, 1, info->f) ;
            retval = 0 ;  
            break ;
          }

          case 3 :
          {
            /* blue */
            fseek(info->f, 2*info->width, SEEK_CUR) ;
            fread(array, info->width, 1, info->f) ;
            retval = 0 ;
            break ;
          }
        }
      }
    }
    else
    {
      switch (info->template)
      {
        case IMAGE_TEMPLATE_PALETTE :
        case IMAGE_TEMPLATE_PALETTEREF :
        {
          if ((info->rp != NULL) && (info->cm != NULL))
          {
            int col ;
            int value ;

            if (row < info->height)
            {
              for ( col = 0 ; col < info->width ; col ++ )
              {  
                value = GetRGB(info->cm, ReadPixel(info->rp, col, row)) ;

                switch (color)
                {
                  case 0 :
                  case 1 : /* red */
                  {
                    array[col] = (value >> 16) & 0xff ;
                    break ;
                  }

                  case 2 : /* green */
                  {
                    array[col] = (value >>  8) & 0xff ;
                    break ;
                  }

                  case 3 : /* blue */
                  {
                    array[col] = (value >>  0) & 0xff ;
                    break ;
                  }
                }
              }
              retval = 0 ;
            }
          }
          break ;
        }

        case IMAGE_TEMPLATE_COLORWHEEL :
        {
          int centrex = info->width/2 ;
          int centrey = info->height/2 ;
          int col ;
          int dx, dy, distance, angle ;

          if (row < info->height)
          {
            for ( col = 0 ; col < info->width ; col++ )
            {
              dx = centrex-col ;
              dy = centrey-row ;

              distance = calcdist(dx,dy) ;
              if (distance < info->radius)
              {
                angle = calcangle(dx,dy) ;
                distance = (info->radius-distance)*255/info->radius ;

                switch (color)
                {
                  case 0 :
                  case 1 : /* red */
                  {
                    calcRGB(angle, distance, 0, &array[col], NULL, NULL) ;
                    break ;
                  }

                  case 2 : /* green */
                  {
                    calcRGB(angle, distance, 0, NULL, &array[col], NULL) ;
                    break ;
                  }

                  case 3 : /* blue */
                  {
                    calcRGB(angle, distance, 0, NULL, NULL, &array[col]) ;
                    break ;
                  }
                }
              }
              else if (distance < (info->radius+2))
              {
                /* black border outside colorwheel */
                array[col] = 0x00 ;
              }
              else
              {
                /* outside is paper white */
                array[col] = 0xff ;
              }
            }
            retval = 0 ; 
          }
          break ;
        }

        case IMAGE_TEMPLATE_COLORSPREAD : /* turboprint sample */
        {
          int col ;

          for ( col = 0 ; col < info->width ; col++ )
          {
            switch (color)
            {
              case 0 :
              case 1 : /* red */
              {
                array[col] = 255 - ((col+row)>>1) ;
                break ;
              }

              case 2 : /* green */
              {
                array[col] = (col>127)?2*(col-128):255-2*col ;
                break ;
              }

              case 3 : /* blue */
              {
                array[col] = (row>127)?(row<127)?255-((col+row)>>1):2*(row-127):0 ;
                break ;
              }
            }
          }
          retval = 0 ;
          break ;
        }
      }
    }
  }

  return retval ;
}



/* lire un short int dans le format INTEL */
unsigned short getintelword( FILE *f )
{
  return 
  (unsigned short)
  ( (unsigned short)((fgetc(f) & 0xff) << 0) |
    (unsigned short)((fgetc(f) & 0xff) << 8) 
  ) ;
} /* getintelword */

/* ecriture dans le format INTEL */
void putintelword( unsigned short a, FILE *f )
{
  fputc(((a>>0) & 0xff), f) ;
  fputc(((a>>8) & 0xff), f) ;
} /* putintelword */

long QRT_check(struct ImageDataInfo *info)
{
  int t, n, max;
  int gap;
  int retval = 0 ;

  fseek( info->f, 0, SEEK_SET) ;
  info->width  = getintelword( info->f ) ;
  info->height = getintelword( info->f ) ;
  max = 3;
  gap = info->width*3;
  
  if ( info->height < 3 )
  {
    max = info->height;
  }

  t = 0 ;
  retval = 1 ;
  while (retval && (t < max))
  {
    if ((n = getintelword(info->f)) != t)
    {
      retval = 0 ;
    }
    else
    {
      fseek( info->f, gap , SEEK_CUR) ;
      t++ ;
    }
  }

  return retval ;
} /* QRT_check */


/* bitmaps and rasters */

void MyFreeBitMap(struct BitMap *bm)
{
  int i ;
  ULONG sizex, sizey, depth ;

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
} /* MyFreeBitMap */

struct BitMap *MyAllocBitMap(
ULONG sizex,
ULONG sizey,
ULONG depth
)
{
  struct BitMap *bm ;
  int i ;

  bm = (struct BitMap *)AllocMem(sizeof(struct BitMap), MEMF_PUBLIC|MEMF_CLEAR) ;
  if (bm != NULL)
  {
    InitBitMap(bm, depth, sizex, sizey) ;
    i = 0 ;
    while ((bm != NULL) && (i < depth))
    {
      bm->Planes[i] = (PLANEPTR)AllocRaster(sizex, sizey) ;
      if (bm->Planes[i] == NULL)
      {
        MyFreeBitMap(bm) ;
        bm = NULL ;
      }
      i++ ;
    }
  }

  return bm ;
} /* MyAllocBitMap */

void MyFreeColorMap(struct ColorMap *cm)
{
  if (cm != NULL)
  {
    FreeMem(cm, sizeof(struct ColorMap) + cm->Count * 4) ;
  }
} /* MyFreeColorMap */

struct ColorMap *MyGetColorMap(int nbcolors)
{
  struct ColorMap *cm ;

  cm = AllocMem(sizeof(struct ColorMap) + nbcolors * 4, MEMF_CLEAR) ;
  if (cm != NULL)
  {
    cm->Flags      = 0 ;
    cm->Type       = 3 ;
    cm->Count      = nbcolors ;
    cm->ColorTable = (char *)cm + sizeof(struct ColorMap) ; 
  }

  return cm ;
} /* MyGetColorMap */

void MySetRGB4CM(struct ColorMap *cm, int index, long R, long G, long B)
{
  long value = (((R*17 & 0xff) << 16) |
                ((G*17 & 0xff) <<  8) |
                ((B*17 & 0xff) <<  0)) ;

  if (cm != NULL)
  {
    if ((index >= 0) && (index < cm->Count))
    {
      ((long *)cm->ColorTable)[index] = value ;
    } 
  } 
} /* MySetRGB4CM */

void MySetRGB32CM(struct ColorMap *cm, int index, long R, long G, long B)
{
  long value = ((((R >> 24) & 0xff) << 16) |
                (((G >> 24) & 0xff) <<  8) |
                (((B >> 24) & 0xff) <<  0)) ;

  if (cm != NULL)
  {
    if ((index >= 0) && (index < cm->Count))
    {
      ((long *)cm->ColorTable)[index] = value ;
    } 
  }  
} /* MySetRGB32CM */

long GetRGB(struct ColorMap *cm, int index)
{
  long value = -1 ;

  if (cm != NULL)
  {
    if ((index >= 0) && (index < cm->Count))
    {
      value = ((long *)cm->ColorTable)[index] ;
    } 
  }

  return value ;
} /* GetRGB */

void CouleursRef(struct ColorMap *cm) ;
void Couleurs(struct ColorMap *) ;
void Efface(struct RastPort *) ;
void Dessin(struct RastPort *, long, long, long, long) ;


void image_init(struct ImageDataInfo *info)
{
  if (info->f != NULL)
  {
  }
  else
  {
    switch (info->template)
    {
      case IMAGE_TEMPLATE_PALETTE :
      case IMAGE_TEMPLATE_PALETTEREF :
      {
        struct BitMap *bm = NULL ;
        int depth ;

        info->width  = 640 ;
        info->height = 512 ;
        depth = 8 ;

        info->rp = NULL ;
        info->cm = NULL ;

        bm = MyAllocBitMap(info->width, info->height, depth) ;
        if (bm != NULL)
        {
          info->rp = (struct RastPort *)AllocMem(sizeof(struct RastPort), MEMF_PUBLIC|MEMF_CLEAR) ;
          if (info->rp == NULL)
          {
            MyFreeBitMap(bm) ;
          }
          else
          {
            InitRastPort(info->rp) ;
            info->rp->BitMap = bm ;

            info->cm = (struct ColorMap *)MyGetColorMap(1 << depth) ;
            if (info->cm == NULL)
            {
              MyFreeBitMap(bm) ;
              FreeMem(info->rp, sizeof(struct RastPort)) ;
              info->rp = NULL ;
            }
            else
            {
              /* ok */

              switch (info->template)
              {
                case IMAGE_TEMPLATE_PALETTE :
                {
                  /* init palette */
                  Couleurs(info->cm) ;

                  /* init drawing */
                  Efface(info->rp) ;

                  /* Draw something */
                  Dessin(info->rp, 0, 10, info->width, info->height-10) ;
                  break ;
                }

                case IMAGE_TEMPLATE_PALETTEREF :
                {
                  CouleursRef(info->cm) ;

                  /* init drawing */
                  Efface(info->rp) ;

                  /* Draw something */
                  Dessin(info->rp, 0, 10, info->width, info->height-10) ;
                }
              }
            }
          }
        }
        info->f = NULL ;
        break ;
      }

      case IMAGE_TEMPLATE_COLORWHEEL :
      {
        if (info->width  <= 0) info->width  = 100 ;
        if (info->height <= 0) info->height = 100 ;
        if (info->radius <= 0) info->radius = 40 ;
        break ;
      }

      case IMAGE_TEMPLATE_COLORSPREAD :
      {
        if (info->width  <= 0) info->width  = 100 ;
        if (info->height <= 0) info->height = 100 ;
        break ;
      }
    }
  }
}

struct ImageDataInfo *image_open(char *filename)
{
  struct ImageDataInfo *info = NULL ;

  info = (struct ImageDataInfo *)malloc(sizeof(struct ImageDataInfo)) ;
  if (info != NULL)
  {
    memset(info, 0, sizeof(struct ImageDataInfo)) ;
    if (filename != NULL)
    {
      info->rp = NULL ;
      info->cm = NULL ;
      
      info->f = fopen(filename,"rb") ;
      if (info->f == NULL)
      {
        image_close(info) ;
        info = NULL ;
      }
      else
      {
        if (!QRT_check(info))
        {
          image_close(info) ;
          info = NULL ;
        }
      }
    }
  }

  return info ;
}

void image_close(struct ImageDataInfo *info)
{
  if (info != NULL)
  {
    if (info->f != NULL)
    {
      fclose(info->f) ;
      info->f = NULL ;
    }

    if (info->rp != NULL)
    {
      if (info->rp->BitMap != NULL)
      {
        MyFreeBitMap(info->rp->BitMap) ;
        info->rp->BitMap = NULL ;
      }
      FreeMem(info->rp, sizeof(struct RastPort)) ;
    }

    if (info->cm != NULL)
    {
      MyFreeColorMap(info->cm) ;
      info->cm = NULL ;
    }

    free(info) ;
  }
}


/**/

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
              MySetRGB32CM
              ( cm,
                index,
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].red),  
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].green),
                FRAC8(((struct RGBColor*)(sp->sp_Data))[index].blue)
              ) ;
            }
            else
            {
              MySetRGB4CM
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

void Couleurs_Defaut(struct ColorMap* cm)
{
  /* nombre de couleurs 256 */

  MySetRGB4CM( cm,   0, FRAC8(0),  FRAC8(0),  FRAC8(0)); /* noir  */
  MySetRGB4CM( cm,   1, 15, 15, 15); /* blanc */

  if (cm->Count <= 2) return ;  
  MySetRGB4CM( cm,   2, 15,  1,  0);
  MySetRGB4CM( cm,   3, 15,  2,  0);

  if (cm->Count <= 4) return ;
  MySetRGB4CM( cm,   4, 15,  3,  0);
  MySetRGB4CM( cm,   5, 15,  4,  0);
  MySetRGB4CM( cm,   6, 15,  5,  0);
  MySetRGB4CM( cm,   7, 15,  6,  0);

  if (cm->Count <= 8) return ;
  MySetRGB4CM( cm,   8, 15,  7,  0);
  MySetRGB4CM( cm,   9, 15,  8,  0);
  MySetRGB4CM( cm,  10, 15,  9,  0);
  MySetRGB4CM( cm,  11, 15, 10,  0);
  MySetRGB4CM( cm,  12, 15, 11,  0);
  MySetRGB4CM( cm,  13, 15, 12,  0);
  MySetRGB4CM( cm,  14, 15, 13,  0);
  MySetRGB4CM( cm,  15, 15, 14,  0);

  if (cm->Count <= 16) return ;
  MySetRGB4CM( cm,  16, 14,  1,  0);
  MySetRGB4CM( cm,  17, 14,  2,  0);
  MySetRGB4CM( cm,  18, 14,  3,  0);
  MySetRGB4CM( cm,  19, 14,  4,  0);
  MySetRGB4CM( cm,  20, 14,  5,  0);
  MySetRGB4CM( cm,  21, 14,  6,  0);
  MySetRGB4CM( cm,  22, 14,  7,  0);
  MySetRGB4CM( cm,  23, 14,  8,  0);
  MySetRGB4CM( cm,  24, 14,  9,  0);
  MySetRGB4CM( cm,  25, 14, 10,  0);
  MySetRGB4CM( cm,  26, 14, 11,  0);
  MySetRGB4CM( cm,  27, 14, 12,  0);
  MySetRGB4CM( cm,  28, 14, 13,  0);
  MySetRGB4CM( cm,  29, 14, 14,  0);
  MySetRGB4CM( cm,  30, 14, 15,  0);
  MySetRGB4CM( cm,  31, 13,  1,  0);

  if (cm->Count <= 32) return ;
  MySetRGB4CM( cm,  32, 13,  2,  0);
  MySetRGB4CM( cm,  33, 13,  3,  0);
  MySetRGB4CM( cm,  34, 13,  4,  0);
  MySetRGB4CM( cm,  35, 13,  5,  0);
  MySetRGB4CM( cm,  36, 13,  6,  0);
  MySetRGB4CM( cm,  37, 13,  7,  0);
  MySetRGB4CM( cm,  38, 13,  8,  0);
  MySetRGB4CM( cm,  39, 13,  9,  0);
  MySetRGB4CM( cm,  40, 13, 10,  0);
  MySetRGB4CM( cm,  41, 13, 11,  0);
  MySetRGB4CM( cm,  42, 13, 12,  0);
  MySetRGB4CM( cm,  43, 13, 13,  0);
  MySetRGB4CM( cm,  44, 13, 14,  0);
  MySetRGB4CM( cm,  45, 13, 15,  0);
  MySetRGB4CM( cm,  46, 12,  1,  0);
  MySetRGB4CM( cm,  47, 12,  2,  0);
  MySetRGB4CM( cm,  48, 12,  3,  0);
  MySetRGB4CM( cm,  49, 12,  4,  0);
  MySetRGB4CM( cm,  50, 12,  5,  0);
  MySetRGB4CM( cm,  51, 12,  6,  0);
  MySetRGB4CM( cm,  52, 12,  7,  0);
  MySetRGB4CM( cm,  53, 12,  8,  0);
  MySetRGB4CM( cm,  54, 12,  9,  0);
  MySetRGB4CM( cm,  55, 12, 10,  0);
  MySetRGB4CM( cm,  56, 12, 11,  0);
  MySetRGB4CM( cm,  57, 12, 12,  0);
  MySetRGB4CM( cm,  58, 12, 13,  0);
  MySetRGB4CM( cm,  59, 12, 14,  0);
  MySetRGB4CM( cm,  60, 12, 15,  0);
  MySetRGB4CM( cm,  61, 11,  1,  0);
  MySetRGB4CM( cm,  62, 11,  2,  0);
  MySetRGB4CM( cm,  63, 11,  3,  0);

  if (cm->Count <= 64) return ;
  MySetRGB4CM( cm,  64, 11,  4,  0);
  MySetRGB4CM( cm,  65, 11, 15,  0);
  MySetRGB4CM( cm,  66, 11, 15,  0);
  MySetRGB4CM( cm,  67, 11, 15,  2);
  MySetRGB4CM( cm,  68, 11, 15,  3);
  MySetRGB4CM( cm,  69, 11, 15,  3);
  MySetRGB4CM( cm,  70,  0, 15,  4);
  MySetRGB4CM( cm,  71,  0, 15,  4);
  MySetRGB4CM( cm,  72,  0, 15,  5);
  MySetRGB4CM( cm,  73,  0, 15,  5);
  MySetRGB4CM( cm,  74,  0, 15,  6);
  MySetRGB4CM( cm,  75,  0, 15,  6);
  MySetRGB4CM( cm,  76,  0, 15,  7);
  MySetRGB4CM( cm,  77,  0, 15,  7);
  MySetRGB4CM( cm,  78,  0, 15,  8);
  MySetRGB4CM( cm,  79,  0, 15,  8);
  MySetRGB4CM( cm,  80,  0, 15,  9);
  MySetRGB4CM( cm,  81,  0, 15,  9);
  MySetRGB4CM( cm,  82,  0, 15, 10);
  MySetRGB4CM( cm,  83,  0, 15, 10);
  MySetRGB4CM( cm,  84,  0, 15, 11);
  MySetRGB4CM( cm,  85,  0, 15, 11);
  MySetRGB4CM( cm,  86,  0, 15, 12);
  MySetRGB4CM( cm,  87,  0, 15, 12);
  MySetRGB4CM( cm,  88,  0, 15, 13);
  MySetRGB4CM( cm,  89,  0, 15, 13);
  MySetRGB4CM( cm,  90,  0, 15, 14);
  MySetRGB4CM( cm,  91,  0, 15, 14);
  MySetRGB4CM( cm,  92,  0, 15, 15);
  MySetRGB4CM( cm,  93,  0, 14, 15);
  MySetRGB4CM( cm,  94,  0, 13, 15);
  MySetRGB4CM( cm,  95,  0, 13, 15);
  MySetRGB4CM( cm,  96,  0, 12, 15);
  MySetRGB4CM( cm,  97,  0, 12, 15);
  MySetRGB4CM( cm,  98,  0, 11, 15);
  MySetRGB4CM( cm,  99,  0, 11, 15);
  MySetRGB4CM( cm, 100,  0, 10, 15);
  MySetRGB4CM( cm, 101,  0, 10, 15);
  MySetRGB4CM( cm, 102,  0,  9, 15);
  MySetRGB4CM( cm, 103,  0,  9, 15);
  MySetRGB4CM( cm, 104,  0,  8, 15);
  MySetRGB4CM( cm, 105,  0,  8, 15);
  MySetRGB4CM( cm, 106,  0,  7, 15);
  MySetRGB4CM( cm, 107,  0,  7, 15);
  MySetRGB4CM( cm, 108,  0,  6, 15);
  MySetRGB4CM( cm, 109,  0,  6, 15);
  MySetRGB4CM( cm, 110,  0,  5, 15);
  MySetRGB4CM( cm, 111,  0,  5, 15);
  MySetRGB4CM( cm, 112,  0,  4, 15);
  MySetRGB4CM( cm, 113,  0,  4, 15);
  MySetRGB4CM( cm, 114,  0,  3, 15);
  MySetRGB4CM( cm, 115,  0,  3, 15);
  MySetRGB4CM( cm, 116,  0,  2, 15);
  MySetRGB4CM( cm, 117,  0,  2, 15);
  MySetRGB4CM( cm, 118,  0,  1, 15);
  MySetRGB4CM( cm, 119,  0,  1, 15);
  MySetRGB4CM( cm, 120,  0,  0, 15);
  MySetRGB4CM( cm, 121,  0,  0, 15);
  MySetRGB4CM( cm, 122,  0,  0, 15);
  MySetRGB4CM( cm, 123,  0,  0, 15);
  MySetRGB4CM( cm, 124,  1,  0, 15);
  MySetRGB4CM( cm, 125,  1,  0, 15);
  MySetRGB4CM( cm, 126,  2,  0, 15);
  MySetRGB4CM( cm, 127,  2,  0, 15);

  if (cm->Count <= 128) return ;
  MySetRGB4CM( cm, 128,  3,  0, 15);
  MySetRGB4CM( cm, 129,  3,  0, 15);
  MySetRGB4CM( cm, 130,  4,  0, 15);
  MySetRGB4CM( cm, 131,  4,  0, 15);
  MySetRGB4CM( cm, 132,  5,  0, 15);
  MySetRGB4CM( cm, 133,  5,  0, 15);
  MySetRGB4CM( cm, 134,  6,  0, 15);
  MySetRGB4CM( cm, 135,  6,  0, 15);
  MySetRGB4CM( cm, 136,  7,  0, 15);
  MySetRGB4CM( cm, 137,  7,  0, 15);
  MySetRGB4CM( cm, 138,  8,  0, 15);
  MySetRGB4CM( cm, 139,  8,  0, 15);
  MySetRGB4CM( cm, 140,  9,  0, 15);
  MySetRGB4CM( cm, 141,  9,  0, 15);
  MySetRGB4CM( cm, 142, 10,  0, 15);
  MySetRGB4CM( cm, 143, 10,  0, 15);
  MySetRGB4CM( cm, 144, 11,  0, 15);
  MySetRGB4CM( cm, 145, 11,  0, 15);
  MySetRGB4CM( cm, 146, 12,  0, 15);
  MySetRGB4CM( cm, 147, 12,  0, 15);
  MySetRGB4CM( cm, 148, 13,  0, 15);
  MySetRGB4CM( cm, 149, 13,  0, 15);
  MySetRGB4CM( cm, 150, 14,  0, 15);
  MySetRGB4CM( cm, 151, 14,  0, 15);
  MySetRGB4CM( cm, 152, 15,  0, 15);
  MySetRGB4CM( cm, 153, 15,  0, 14);
  MySetRGB4CM( cm, 154, 15,  0, 13);
  MySetRGB4CM( cm, 155, 15,  0, 12);
  MySetRGB4CM( cm, 156, 15,  0, 11);
  MySetRGB4CM( cm, 157, 15,  0, 10);
  MySetRGB4CM( cm, 158, 15,  0,  9);
  MySetRGB4CM( cm, 159, 15,  0,  8);
  MySetRGB4CM( cm, 160, 15,  0,  7);
  MySetRGB4CM( cm, 161, 15,  0,  6);
  MySetRGB4CM( cm, 162, 15,  0,  5);
  MySetRGB4CM( cm, 163, 15,  0,  4);
  MySetRGB4CM( cm, 164, 15,  0,  3);
  MySetRGB4CM( cm, 165, 15,  0,  2);
  MySetRGB4CM( cm, 166, 15,  0,  1);
  MySetRGB4CM( cm, 167, 15,  1,  1);
  MySetRGB4CM( cm, 168, 15,  2,  2);
  MySetRGB4CM( cm, 169, 15,  3,  3);
  MySetRGB4CM( cm, 170, 15,  4,  4);
  MySetRGB4CM( cm, 171, 15,  5,  5);
  MySetRGB4CM( cm, 172, 15,  6,  6);
  MySetRGB4CM( cm, 173, 15,  7,  7);
  MySetRGB4CM( cm, 174, 15,  8,  8);
  MySetRGB4CM( cm, 175, 15,  9,  9);
  MySetRGB4CM( cm, 176, 15, 10, 10);
  MySetRGB4CM( cm, 177, 15, 11, 11);
  MySetRGB4CM( cm, 178, 15, 12, 12);
  MySetRGB4CM( cm, 179, 15, 13, 13);
  MySetRGB4CM( cm, 180, 15, 14, 14);
  MySetRGB4CM( cm, 181,  7, 15,  1);
  MySetRGB4CM( cm, 182,  8, 15,  2);
  MySetRGB4CM( cm, 183,  8, 15,  3);
  MySetRGB4CM( cm, 184,  9, 15,  4);
  MySetRGB4CM( cm, 185,  9, 15,  5);
  MySetRGB4CM( cm, 186, 10, 15,  6);
  MySetRGB4CM( cm, 187, 10, 15,  7);
  MySetRGB4CM( cm, 188, 11, 15,  8);
  MySetRGB4CM( cm, 189, 11, 15,  9);
  MySetRGB4CM( cm, 190, 12, 15, 10);
  MySetRGB4CM( cm, 191, 12, 15, 11);
  MySetRGB4CM( cm, 192, 13, 15, 12);
  MySetRGB4CM( cm, 193, 13, 15, 13);
  MySetRGB4CM( cm, 194, 14, 15, 14);
  MySetRGB4CM( cm, 195,  1,  1, 15);
  MySetRGB4CM( cm, 196,  2,  2, 15);
  MySetRGB4CM( cm, 197,  3,  3, 15);
  MySetRGB4CM( cm, 198,  4,  4, 15);
  MySetRGB4CM( cm, 199,  5,  5, 15);
  MySetRGB4CM( cm, 200,  6,  6, 15);
  MySetRGB4CM( cm, 201,  7,  7, 15);
  MySetRGB4CM( cm, 202,  8,  8, 15);
  MySetRGB4CM( cm, 203,  9,  9, 15);
  MySetRGB4CM( cm, 204, 10, 10, 15);
  MySetRGB4CM( cm, 205, 11, 11, 15);
  MySetRGB4CM( cm, 206, 12, 12, 15);
  MySetRGB4CM( cm, 207, 13, 13, 15);
  MySetRGB4CM( cm, 208, 14, 14, 15);
  MySetRGB4CM( cm, 209, 15, 15,  1);
  MySetRGB4CM( cm, 210, 15, 15,  2);
  MySetRGB4CM( cm, 211, 15, 15,  3);
  MySetRGB4CM( cm, 212, 15, 15,  4);
  MySetRGB4CM( cm, 213, 15, 15,  5);
  MySetRGB4CM( cm, 214, 15, 15,  6);
  MySetRGB4CM( cm, 215, 15, 15,  7);
  MySetRGB4CM( cm, 216, 15, 15,  8);
  MySetRGB4CM( cm, 217, 15, 15,  9);
  MySetRGB4CM( cm, 218, 15, 15, 10);
  MySetRGB4CM( cm, 219, 15, 15, 11);
  MySetRGB4CM( cm, 220, 15, 15, 12);
  MySetRGB4CM( cm, 221, 15, 15, 13);
  MySetRGB4CM( cm, 222, 15, 15, 14);
  MySetRGB4CM( cm, 223,  1, 15, 15);
  MySetRGB4CM( cm, 224,  2, 15, 15);
  MySetRGB4CM( cm, 225,  3, 15, 15);
  MySetRGB4CM( cm, 226,  4, 15, 15);
  MySetRGB4CM( cm, 227,  5, 15, 15);
  MySetRGB4CM( cm, 228,  6, 15, 15);
  MySetRGB4CM( cm, 229,  7, 15, 15);
  MySetRGB4CM( cm, 230,  8, 15, 15);
  MySetRGB4CM( cm, 231, 10, 15, 15);
  MySetRGB4CM( cm, 232,  9, 15, 15);
  MySetRGB4CM( cm, 233, 11, 15, 15);
  MySetRGB4CM( cm, 234, 12, 15, 15);
  MySetRGB4CM( cm, 235, 13, 15, 15);
  MySetRGB4CM( cm, 236, 14, 15, 15);
  MySetRGB4CM( cm, 237, 15,  1, 15);
  MySetRGB4CM( cm, 238, 15,  2, 15);
  MySetRGB4CM( cm, 239, 15,  3, 15);
  MySetRGB4CM( cm, 240, 15,  4, 15);
  MySetRGB4CM( cm, 241, 15,  5, 15);
  MySetRGB4CM( cm, 242, 15,  6, 15);
  MySetRGB4CM( cm, 243, 15,  7, 15);
  MySetRGB4CM( cm, 244, 15,  8, 15);
  MySetRGB4CM( cm, 245, 15,  9, 15);
  MySetRGB4CM( cm, 246, 15, 10, 15);
  MySetRGB4CM( cm, 247, 15, 11, 15);
  MySetRGB4CM( cm, 248, 15, 12, 15);
  MySetRGB4CM( cm, 249, 15, 13, 15);
  MySetRGB4CM( cm, 250, 15, 14, 15);
  MySetRGB4CM( cm, 251, 14, 14, 14);
  MySetRGB4CM( cm, 252, 11, 11, 11);
  MySetRGB4CM( cm, 253,  8,  8,  8);
  MySetRGB4CM( cm, 254,  5,  5,  5);
  MySetRGB4CM( cm, 255,  2,  2,  2);
} /* Couleurs_Defaut */

void Couleurs(struct ColorMap* cm)
{
  BOOL lp = NULL ;

  lp = LoadPalette(cm, "default.pal") ;
  if (lp != NULL)
  {
    printf("Use file \"default.pal\"\n") ;
  }
  else
  {
    //printf("Palette by default\n") ;
    Couleurs_Defaut(cm) ;
  }
    
  /* patch */
  MySetRGB4CM( cm, 0,  0,  0,  0 ); /* noir  */ 
  MySetRGB4CM( cm, 1, 15, 15, 15 ); /* blanc */
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

/**/
void CouleursRef(struct ColorMap *cm)
{
  int i ;

  MySetRGB32CM( cm,  0, FRAC8(  0), FRAC8(  0), FRAC8(  0) ) ; /* noir  */ 
  MySetRGB32CM( cm,  1, FRAC8(255), FRAC8(255), FRAC8(255) ) ; /* blanc */

  for (i = 2 ; i < 255 ; i ++)
  {
    MySetRGB32CM( cm,  i,  FRAC8(i-1), FRAC8(i-1), FRAC8(i-1) ) ; 
  }
}



/***************************************************************************/
/* COLORWHEEL 1996                                                         */
/***************************************************************************/
int calcangle(int dx, int dy)
{ 
  int quadrant;
  int angle;
  
  if (dx < 0)
  { 
    if (dy < 0)
    {
      quadrant = 3 ;
    }
    else
    {
      quadrant = 0 ;
    }
  }
  else
  { 
    if (dy < 0)
    {
      quadrant = 2 ;
    }
    else
    {
      quadrant = 1 ;
    }
  }
  
  if (dx != 0)
  { 
    angle = (int)(atan(abs((double)(dy)/(double)(dx)))*180.00/PI) ;   

    switch (quadrant)
    { 
      case 1: angle = 180-angle ; break ;
      case 2: angle = 180+angle ; break ;
      case 3: angle = 360-angle ; break ;
      default: break ;
    }
  }
  else
  {
    if(quadrant == 1)
    {
      angle = 90 ;
    }
    else
    {
      angle = 270 ;
    }
  }
  return angle;
}

int sqr(int a)
{ 
  int b;
  
  if (a == 0) return 0 ;
  if (a == 1) return 1 ;

  b = 2;
  while (b*b < a)
  {
    b++ ;
  }

  return b ;
} /* sqr */
  
int calcdist(int dx, int dy)
{ 
  return sqr(dx*dx + dy*dy) ;
}

/* 
          
  180   150   120    90    60    30    0    330   300   270   240   210
   |     |     |     |     |     |     |     |     |     |     |     |
   +-----+-----+-----+-----+-----############+-----+-----+-----+-----+
   |     |     |     |     ######            ######|     |     |     |
   |     |     |     ######                        ######|     |     |
 #####################                                   ################

*/

/* calcRGB
   hue [0..360[
   
 */
void calcRGB(int hue, int sat, int light, unsigned char *r, unsigned char *g, unsigned char *b)
{ 
  int red, grn, blu;

  if (hue <= 60)
  {
    red = 255; grn = hue*255/60; blu = 0;
  } 
  else if (hue <= 120)
  {
    red = 255-(hue-60)*255/60; grn = 255; blu = 0;
  }
  else if (hue <= 180)
  {
    red = 0; grn = 255; blu = (hue-120)*255/60;
  }
  else if (hue <= 240)
  {
    red = 0; grn = 255-(hue-180)*255/60; blu = 255;
  }
  else if (hue <= 300)
  {
    red = (hue-240)*255/60; grn = 0; blu = 255;
  }
  else 
  {
    red = 255; grn = 0; blu = 255-(hue-300)*255/60;
  }
   
  red += sat-light;
  grn += sat-light;
  blu += sat-light;
  if (red>255) red = 255;
  if (grn>255) grn = 255;
  if (blu>255) blu = 255;
  if (red<  0) red = 0;
  if (grn<  0) grn = 0;
  if (blu<  0) blu = 0;
  
  if (r != NULL) *r = red & 0xff;
  if (g != NULL) *g = grn & 0xff;
  if (b != NULL) *b = blu & 0xff;
}

