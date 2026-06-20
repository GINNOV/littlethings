/***************************************************************************
 * picpak.c    - "PicPak" - IFF ILBM picture manipulation functions        *
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
 * File: (picpak.c) IFF package routines                                   *
 *-------------------------------------------------------------------------*
 * Modification History                                                    *
 * Date     Author   Comment                                               *
 * -------- ------   -------                                               *
 * 10-02-90    PTM   Created. Pic allocation/freeing with specified memtype
 * 10-03-90    PTM   iff.library hooks
 * 10-08-90    PTM   clean up memory allocation
 * 11-28-90    PTM   SetImageType(), custom processing of non-standard forms
 *                   ViewPort fade/color set functions, color-cycling
 * 12-01-90    PTM   SHAM Chunk/ColorMap support - improve file parsing
 * 12-02-90    PTM   SHAM Copper-list code, ViewPort support code
 * 12-06-90    PTM   Add image decompression buffer
 * 12-07-90    PTM   Free mask plane if present in a Frame BitMap
 * 10-13-91    PTM   re-prototype
 * 24-10-95    MC    put __far on Custom
 * 24-10-95    MC    inserted CHECK_BMHD in LoadImage()
 * 24-10-95    MC    changed name from pic_pak.c to picpak.c
 ***************************************************************************/

#ifndef PICPAK_H
#include "picpak.h"
#endif

/* adjusted by mark carter 24.10.95 for DICE compiler */
#ifdef _DCC
__far extern struct Custom custom;
#else
extern struct Custom far custom;
#endif

extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
extern struct Library *DOSBase;

/* Some IFF parsing structs/constants */
#define BUFFER_SIZE  32000                /* image decompression buffer */

#define MAKE_ID(a,b,c,d) (((long)(a)<<24)|((long)(b)<<16)|((long)(c)<<8)|(long)(d))

/*  IFF types we may encounter  */
#define FORM   MAKE_ID('F', 'O', 'R', 'M')
#define ILBM   MAKE_ID('I', 'L', 'B', 'M')
#define BMHD   MAKE_ID('B', 'M', 'H', 'D')
#define CMAP   MAKE_ID('C', 'M', 'A', 'P')
#define BODY   MAKE_ID('B', 'O', 'D', 'Y')
#define CAMG   MAKE_ID('C', 'A', 'M', 'G')
#define CRNG   MAKE_ID('C', 'R', 'N', 'G')
#define SHAM   MAKE_ID('S', 'H', 'A', 'M')
#define DYCP   MAKE_ID('D', 'Y', 'C', 'P')
#define CTBL   MAKE_ID('C', 'T', 'B', 'L')
#define GRAB   MAKE_ID('G', 'R', 'A', 'B')
#define SPRT   MAKE_ID('S', 'P', 'R', 'T')
#define CCRT   MAKE_ID('C', 'C', 'R', 'T')
#define DPPV   MAKE_ID('D', 'P', 'P', 'V')
#define DPPS   MAKE_ID('D', 'P', 'P', 'S')

#define byte(n) (((n + 15) >> 4) << 1)  /* Word aligned width in bytes. */

struct BitMapHeader {
   UWORD w,h;           /* Raster width & height. */
   UWORD x,y;           /* Pixel position. */
   UBYTE nPlanes;       /* Number of source bitplanes. */
   UBYTE masking;       /* Masking... good for nothing maybe? */
   UBYTE compression;   /* Packed or unpacked? */
   UBYTE pad1;          /* We don't like odd length structures. */
   UWORD transparentColor; /* Maybe good for... */
   UBYTE xAspect, yAspect; /* Kind of quotient, width / height. */
   WORD pageWidth, pageHeight;   /* Source page size. */
};

/* IFF Stuff */
union typekludge {
   char type_str[4];
   long type_long;
};
struct ChunkHeader {
   union typekludge chunktype;
   long chunksize;
};
#define TYPE            chunktype.type_long
#define STRTYPE         chunktype.type_str

/*  Masking techniques  */
#define mskNone                 0
#define mskHasMask              1
#define mskHasTransparentColor  2
#define mskLasso                3

/*  Compression techniques  */
#define cmpNone                 0
#define cmpByteRun1             1

/* color-cycling stuff */
#define CRNG_NORATE     36      /* Don't cycle this range. */
#define CRNG_ACTIVE     1 << 0  /* This range is active. */
#define CRNG_REVERSE    1 << 1  /* This range is cycling backwards. */

/* GraphiCraft private cycling chunk. */
struct CcrtChunk {
   WORD  direction;
   UBYTE start;
   UBYTE end;
   LONG  seconds;
   LONG  microseconds;
   WORD  pad;
};

/* some color-cycling globals (used only if color-cycling is enabled) */
struct CycleData *cdata = NULL;
int i, j;                     /* general-purpose indexes used by cycler */

UWORD fade_delay = 0;
ULONG max_bufsize = BUFFER_SIZE;

struct Pic *AllocatePic(UWORD width, UWORD height, UBYTE depth, UBYTE memtype)
{
   struct Pic *pic;
   struct BitMap *bitmap;
   ULONG i, size, memsize;

   if (memtype == NULL)
      memtype = MEMTYPE_CHIP;

   pic = (struct Pic *)AllocMem(PIC_SIZE, MEMF_CLEAR);
   if (!pic) return(NULL);

   bitmap = &pic->BitMap;

   InitBitMap(bitmap, (long)depth, (long)width, (long)height);

   pic->Width = width;
   pic->Height = height;
   pic->Depth = depth;
   pic->Colors = 1<<depth;

   size = bitmap->BytesPerRow * bitmap->Rows;
   memsize = size * (ULONG)depth;

   if (memtype != MEMTYPE_NONE)
   {
      /* attempt to allocate a chunk of the required memory size and type */
      if (memtype == MEMTYPE_ANY)      /* if ANY type, try CHIP first */
      {
         bitmap->Planes[0] = (PLANEPTR)AllocMem(memsize, MEMF_CHIP);
         if (!bitmap->Planes[0])
            memtype = MEMTYPE_FAST;    /* out of CHIP, try for FAST */
      }

      if (memtype == MEMTYPE_CHIP)
         bitmap->Planes[0] = (PLANEPTR)AllocMem(memsize, MEMF_CHIP);

      if (memtype == MEMTYPE_FAST)
         bitmap->Planes[0] = (PLANEPTR)AllocMem(memsize, MEMF_FAST);

      if (!bitmap->Planes[0])       /* couldn't get the memory */
      {
         FreePic(pic);
         return(NULL);
      }
      for (i = 1; i < depth; i++)      /* set the plane pointers */
         bitmap->Planes[i] = (PLANEPTR)(bitmap->Planes[0] + (i * size));
   }
   if (memtype == MEMTYPE_ANY)   /* actually got CHIP ram */
      memtype = MEMTYPE_CHIP;

   pic->Memtype = memtype;

   return(pic);
}

void FreePic(struct Pic *pic)
{
   ULONG size, chunksize;
   struct BitMap *bm;

   if (pic)
   {
      if (bm = &pic->BitMap)
      {
         size = bm->BytesPerRow * bm->Rows;
         chunksize = size * (ULONG)bm->Depth;

         if (bm->Planes[0])
            FreeMem(bm->Planes[0], chunksize);
      }
      if (pic->PicExt)
      {
         switch (pic->Type)
         {
            case PICTYPE_SHAM:
               FreeMem(pic->PicExt, SHAMDATA_SIZE);
               break;
            case PICTYPE_DHIRES:
               size = pic->Height * DHIRES_COLORS * sizeof(WORD);
               FreeMem(pic->PicExt, size);
               break;
         }
      }
      FreeMem(pic, PIC_SIZE);
   }
}

struct Frame *AllocateFrame(UWORD width, UWORD height, UBYTE depth)
{
   struct Frame *frame;
   struct BitMap *bitmap;
   ULONG i, size, memsize;

   frame = (struct Frame *)AllocMem(FRAME_SIZE, MEMF_CLEAR);
   if (!frame) return(NULL);

   bitmap = &frame->BitMap;

   InitBitMap(bitmap, (long)depth, (long)width, (long)height);

   frame->Width = width;
   frame->Height = height;

   size = bitmap->BytesPerRow * bitmap->Rows;
   memsize = size * (ULONG)depth;

   bitmap->Planes[0] = (PLANEPTR)AllocMem(memsize, MEMF_CHIP);
   if (!bitmap->Planes[0])
   {
      FreeMem(frame, FRAME_SIZE);
      return(NULL);
   }
   for (i = 1; i < depth; i++)      /* set the plane pointers */
      bitmap->Planes[i] = (PLANEPTR)(bitmap->Planes[0] + (i * size));

   return(frame);
}

void FreeFrame(struct Frame *frame)
{
   ULONG size, chunksize;
   struct BitMap *bm;

   if (frame)
   {
      if (bm = &frame->BitMap)
      {
         size = RASSIZE(bm->BytesPerRow * 8, bm->Rows);
         chunksize = size * (ULONG)bm->Depth;

         if (bm->Planes[0])
            FreeMem(bm->Planes[0], chunksize);
         if (bm->Planes[bm->Depth])                /* extra mask plane */
            FreeMem(bm->Planes[bm->Depth], size);
      }
      FreeMem(frame, FRAME_SIZE);
   }
}

struct Pic *LoadPic(STRPTR filename, UBYTE memtype)
{
   return(LoadImage(filename, NULL, PICTYPE_NORMAL, memtype));
}

struct Pic *LoadPic2BitMap(STRPTR filename, struct BitMap *bitmap)
{
   return(LoadImage(filename, bitmap, PICTYPE_NORMAL, MEMTYPE_NONE));
}

struct Frame *LoadFrame(STRPTR filename)
{
   return((struct Frame *)LoadImage(filename, NULL, PICTYPE_FRAME, NULL));
}

struct Pic *LoadImage(STRPTR filename, struct BitMap *bitmap, UBYTE type, UBYTE memtype)
{
   struct Pic *pic = NULL;
   struct Frame *frame = NULL;
   struct BitMapHeader bmhd;
   struct ChunkHeader ch;
   FILE *file;
   LONG formsize, subtype;
   UWORD version;
   ULONG size;

   file = fopen(filename, "r");
   if (!file)
      return(NULL);

   if (!fread((char *)&ch, sizeof(struct ChunkHeader), 1, file))
   {
      fclose(file);
      return(NULL);
   }
   if (ch.TYPE != FORM)    /* not an IFF file */
   {
      fclose(file);
      return(NULL);
   }

   if (!fread((char *)&subtype, sizeof(subtype), 1, file))
   {
      fclose(file);
      return(NULL);
   }
   formsize = ch.chunksize - sizeof(subtype);
   if (subtype != ILBM)    /* not an ILBM image */
   {
      fclose(file);
      return(NULL);
   }

   while (formsize > 0)
   {
      if (!fread((char *)&ch, sizeof(struct ChunkHeader), 1, file))
      {
         fclose(file);
         if (pic) FreePic(pic);
         if (frame) FreeFrame(frame);
         return(NULL);
      }
      formsize -= sizeof(struct ChunkHeader);

      switch (ch.TYPE)
      {
         case BMHD:
            fread((char *)&bmhd, ch.chunksize, 1, file);

            /* some error checking */
            if (bmhd.nPlanes < 1 || bmhd.nPlanes > 8)
            {
               fclose(file);
               return(NULL);
            }
            if (bitmap)          /* application has supplied a BitMap */
               memtype = MEMTYPE_NONE;

            if (type == PICTYPE_FRAME)
            {
               frame = AllocateFrame(bmhd.w, bmhd.h, bmhd.nPlanes);
               if (!frame)
               {
                  fclose(file);
                  return(NULL);
               }
               frame->X = bmhd.w;
               frame->Y = bmhd.h;
            }
            else
            {
               pic = AllocatePic(bmhd.w, bmhd.h, bmhd.nPlanes, memtype);
               if (!pic)
               {
                  fclose(file);
                  return(NULL);
               }
            }
            break;
         case CMAP:
            if (type == PICTYPE_FRAME)
            {
               fseek(file, ch.chunksize, 1);
               break;
            }
            pic->Colors = LoadCMAP(file, ch.chunksize, &pic->Colormap[0]);
            break;
         case CAMG:
            if (type == PICTYPE_FRAME)
            {
               fseek(file, ch.chunksize, 1);
               break;
            }
            fread((char *)&subtype, sizeof(subtype), 1, file);
            pic->ViewModes = (ULONG)subtype;
            if ((UWORD)pic->ViewModes == NULL)
               pic->ViewModes >>= 16L;
            pic->ViewModes &= ~(SPRITES|VP_HIDE|PFBA|GENLOCK_AUDIO|GENLOCK_VIDEO);
            break;
         case CRNG:
         case CCRT:
            if (type == PICTYPE_FRAME || pic->Cycles == MAXCRANGES)
            {
               fseek(file, ch.chunksize, 1);
               break;
            }
            LoadCycleRange(file, &pic->CRanges[pic->Cycles], ch.TYPE);
            pic->Cycles++;
            break;
         case SHAM:
            if (type == PICTYPE_FRAME)
            {
               fseek(file, ch.chunksize, 1);
               break;
            }
            pic->PicExt = (APTR)AllocMem(SHAMDATA_SIZE, NULL);
            if (!pic->PicExt)
               fseek(file, ch.chunksize, 1);
            else
            {
               fread((char *)&version, sizeof(UWORD), 1, file);
               ch.chunksize -= sizeof(UWORD);
               if (version == 0)
               {
                  fread((char *)pic->PicExt, ch.chunksize, 1, file);
                  pic->Type = PICTYPE_SHAM;
               }
               else
                  fseek(file, ch.chunksize, 1);
            }
            break;
         case CTBL:
            if (type == PICTYPE_FRAME)
            {
               fseek(file, ch.chunksize, 1);
               break;
            }
            size = pic->Height * DHIRES_COLORS * sizeof(WORD);
            pic->PicExt = (APTR)AllocMem(size, NULL);
            if (!pic->PicExt)
               fseek(file, ch.chunksize, 1);
            else
            {
               fread((char *)pic->PicExt, ch.chunksize, 1, file);
               pic->Type = PICTYPE_DHIRES;
            }
            break;
         case BODY:
            if (type == PICTYPE_FRAME && frame)
            {
               if (!LoadRaster(file, ch.chunksize, &frame->BitMap.Planes[0], &bmhd))
               {
                  fclose(file);
                  FreeFrame(frame);
                  return(NULL);
               }
            }
            if (type != PICTYPE_FRAME)
            {
               if (!bitmap)
                  bitmap = &pic->BitMap;
               if (!LoadRaster(file, ch.chunksize, &bitmap->Planes[0], &bmhd))
               {
                  fclose(file);
                  FreePic(pic);
                  return(NULL);
               }
            }
            /* make sure the BODY isn't off a few bytes */
            if (formsize - ch.chunksize > 0)
               ch.chunksize += (formsize - ch.chunksize);
            break;
         default:
            fseek(file, ch.chunksize, 1);
            break;
      }
      formsize -= ch.chunksize;
      if (ch.chunksize & 1)         /* odd-length chunk */
      {
         formsize--;
         fseek(file, 1L, 1);
      }
   }
   fclose(file);

   if (type == PICTYPE_FRAME)
      return((struct Pic *)frame);

   SetImageType(pic);      /* perform any post-processing/identification */


  
   /* now double-check the display size flags */
   /* mark carter 24-10-95. I decided to wrap up this portion of code */
   #ifdef CHECK_BMHD
      if (bmhd.pageHeight > 242)
         pic->ViewModes |= LACE;
      if (bmhd.pageWidth >= 640)
         pic->ViewModes |= HIRES;
    #endif

   return(pic);
}

/* GetPicAttrs()
      - return the specified picture's size, depth, and viewmode information
        in supplied pointer variables
*/

GetPicAttrs(STRPTR filename, WORD *w, WORD *h, WORD *d, ULONG *vm)
{
   struct Pic *pic;

   /* load just the header information */
   pic = LoadImage(filename, NULL, NULL, MEMTYPE_NONE);
   if (pic)
   {
      *w = pic->Width;
      *h = pic->Height;
      *d = pic->Depth;
      *vm = pic->ViewModes;
      FreePic(pic);
      return(1);
   }
   return(NULL);
}

/* Pic2BitMap()
      - download Pic imagery stored in FAST RAM to the specified BitMap
*/
Pic2BitMap(struct Pic *pic, struct BitMap *bm)
{
   ULONG i, size;

   if (pic && bm)
   {
      if (pic->Memtype == MEMTYPE_CHIP)
      {
         BltBitMap(&pic->BitMap, 0, 0, bm, 0, 0, pic->Width,pic->Height,
                   0xc0, 0xff, NULL);
         return(1);
      }

      if (pic->Depth != bm->Depth)
         return(NULL);
      if (pic->Width != bm->BytesPerRow * 8)
         return(NULL);
      if (pic->Height != bm->Rows)
         return(NULL);

      size = pic->BitMap.BytesPerRow * pic->BitMap.Rows;
      for (i = 0; i < bm->Depth; i++)
         memcpy(bm->Planes[i], pic->BitMap.Planes[i], size);

      return(1);
   }
   return(NULL);
}

BOOL LoadRaster(FILE *file, ULONG chunksize, PLANEPTR *BitPlanes, struct BitMapHeader *BMHeader)
{
   register LONG i, j, k;
   register BYTE ChkVal;
   register UBYTE Value, SoFar;
   UBYTE Compr, Depth;
   LONG Height, Width;
   PLANEPTR Planes[9];    /* 9 for possible bitmask. */
   UBYTE *memory = NULL;

   for(i = 0; i < 9; i++)
      Planes[i] = NULL;

   Width   = byte(BMHeader->w);
   Height  = BMHeader->h;
   Depth   = BMHeader->nPlanes;
   Compr   = BMHeader->compression;

   if (Compr > cmpByteRun1 || !BitPlanes)
      return(FALSE);

   for(i = 0; i < Depth; i++)
      Planes[i] = BitPlanes[i];

   if (BMHeader->masking == mskHasMask)
      Depth++;

   if (Compr == cmpNone)
   {
      for (k = 0; k < Height; k++)
      {
         for (j = 0; j < Depth; j++)
         {
            if (Planes[j])
            {
               fread((char *)Planes[j], Width, 1, file);
               Planes[j] += Width;
            }
            else
               fseek(file, Width, 1);
         }
      }
   }
   if (Compr == cmpByteRun1)
   {
      if (chunksize < max_bufsize)
      {
         memory = (UBYTE *)AllocMem(chunksize, NULL);
         if (memory)
         {
            fread(memory, chunksize, 1, file);
            mem_decompress(memory, &Planes[0], Width, Height, Depth);
            FreeMem(memory, chunksize);
            return(1);
         }
      }
      for (k = 0; k < Height; k++)
      {
         for (j = 0; j < Depth; j++)
         {
            for (SoFar = 0; SoFar < Width ;)
            {
               ChkVal = fgetc(file);

               if (ChkVal > 0)
               {
                  if (Planes[j])
                  {
                     fread(Planes[j], ChkVal + 1, 1, file);
                     Planes[j] += ChkVal + 1;
                  }
                  else
                     fseek(file, ChkVal + 1, 1);

                  SoFar += ChkVal + 1;
               }
               else
               {
                  if (ChkVal != 128)
                  {
                     Value = fgetc(file);

                     for (i = 0; i <= -ChkVal; i++)
                     {
                        if (Planes[j])
                        {
                           *Planes[j] = Value;
                           Planes[j]++;
                        }
                        SoFar++;
                     }
                  }
               }
            }
         }
      }
   }
   return(TRUE);
}

void mem_decompress(register UBYTE *ptr, PLANEPTR *Planes, LONG Width, LONG Height, UBYTE Depth)
{
   LONG i, j, k;
   register BYTE ChkVal;
   UBYTE Value, SoFar;

   for (k = 0; k < Height; k++)
   {
      for (j = 0; j < Depth; j++)
      {
         for (SoFar = 0; SoFar < Width ;)
         {
            ChkVal = *ptr;
            ptr++;

            if (ChkVal > 0)
            {
               if (Planes[j])
               {
                  memcpy(Planes[j], ptr, ChkVal+1);
                  Planes[j] += ChkVal + 1;
                  ptr += ChkVal + 1;
               }
               else
                  ptr += ChkVal + 1;

               SoFar += ChkVal + 1;
            }
            else
            {
               if (ChkVal != 128)
               {
                  Value = *ptr;
                  ptr++;

                  for (i = 0; i <= -ChkVal; i++)
                  {
                     if (Planes[j])
                     {
                        *Planes[j] = Value;
                        Planes[j]++;
                     }
                     SoFar++;
                  }
               }
            }
         }
      }
   }
}

void SetPicReadBufSize(ULONG size)
{
   max_bufsize = size;
}

UWORD LoadCMAP(FILE *file, LONG csize, UWORD *cmap)
{
   UBYTE *ctable;
   UWORD i, n;
   LONG len;

   len = csize;
   if (len > (MAXCOLORS * 3))
      len = MAXCOLORS * 3;

   ctable = (UBYTE *)AllocMem(csize, NULL);
   if (!ctable)
      return(NULL);

   fread((char *)ctable, csize, 1, file);

   for (i = n = 0; n < len; i++, n += 3)
      cmap[i] = ((ctable[n]>>4)<<8)+((ctable[n+1]>>4)<<4)+(ctable[n+2]>>4);

   FreeMem(ctable, csize);

   return(i);
}

void LoadCycleRange(FILE *file, CRange *range, LONG type)
{
   struct CcrtChunk crtchunk;

   switch (type)
   {
      case CRNG:
         fread((char *)range, sizeof(CRange), 1, file);

         /* Carefully determine the activity of the chunk. */
         if (range->active == CRNG_NORATE || !range->rate || range->low == range->high)
            range->active = 0;

         /* Recalculate speed value. */
         if (range->rate > 0)
            range->rate = 16384 / range->rate;
         else
            range->rate = 0;
         break;
      case CCRT:
         fread((char *)&crtchunk, sizeof(struct CcrtChunk), 1, file);

         /* We have located a CCRT chunk, now make it a CRNG chunk. */
         range->low  = crtchunk.start;
         range->high = crtchunk.end;

         if (crtchunk.direction != 0)
            range->active = CRNG_ACTIVE;
         else
            range->active = 0;

         if (crtchunk.direction > 0)
            range->active |= CRNG_REVERSE;

         /* Recalculate speed (by Carolyn Scheppner). */
         range->rate = 16384 / (crtchunk.seconds * 60 +
                         (crtchunk.microseconds + 8334) / 16667);
         if (!range->rate || range->low == range->high)
            range->active = 0;
         if (range->rate > 0)
            range->rate = 16384 / range->rate;
         else
            range->rate = 0;
         break;
   }
}

void SetImageType(struct Pic *pic)
{
   /* handle custom processing of non-standard picture types */
   if (pic->Type)    /* already set */
   {
      switch (pic->Type)
      {
         case PICTYPE_SHAM:
            pic->Colors = 16;
            pic->ViewModes |= HAM;
            break;
      }
      return;
   }

   if (pic->ViewModes & HAM)
   {
      pic->Colors = 16;
      pic->Type = PICTYPE_HAM;
      return;
   }
   if (pic->Width <= 320 && pic->Height <= 200 && pic->Depth == 6)
   {
      pic->Colors = MAXCOLORS;
      pic->ViewModes = EXTRA_HALFBRITE;
      pic->Type = PICTYPE_EHB;
      return;
   }
   pic->Type = PICTYPE_NORMAL;
}

/**********************************************************/
/* GENERAL-PURPOSE PICTURE/VIEWPORT MANIPULATION ROUTINES */
/**********************************************************/

/*****************/
/* COLOR-CYCLING */
/*****************/

struct CycleData {
   struct ViewPort *vp;
   struct Pic *pic;
   struct Interrupt *vblank;
   UBYTE cycling;
   UBYTE pad;
   UWORD temp_col;
   UWORD cmap[MAXCOLORS];
   WORD  ticks[16];
};

typedef void   (*FPTR)();

InitCycler()
{
   cdata = (struct CycleData *)AllocMem(sizeof(struct CycleData), MEMF_CLEAR);
   if (!cdata)
      return(NULL);

   cdata->vblank = (struct Interrupt *)AllocMem(sizeof(struct Interrupt), MEMF_CLEAR);
   if (!cdata->vblank)
      return(NULL);

   cdata->vblank->is_Data = NULL;
   cdata->vblank->is_Code = (FPTR)cycle;
   cdata->vblank->is_Node.ln_Succ = NULL;
   cdata->vblank->is_Node.ln_Pred = NULL;
   cdata->vblank->is_Node.ln_Type = NT_INTERRUPT;
   cdata->vblank->is_Node.ln_Pri = 0;
   cdata->vblank->is_Node.ln_Name = "PicPak_Color_Cycler";

   AddIntServer(INTB_VERTB, cdata->vblank);

   return(1);
}

void FreeCycler()
{
   if (cdata)
   {
      if (cdata->vblank)
      {
         StopCycling();

         RemIntServer(INTB_VERTB, cdata->vblank);
         FreeMem(cdata->vblank, sizeof(struct Interrupt));
         WaitTOF();
         WaitTOF();
         WaitTOF();
      }
      FreeMem(cdata, sizeof(struct CycleData));
   }
}

__saveds void cycle()
{
   if (cdata->cycling)
   {
      for (i = 0; i < cdata->pic->Cycles; i++)
      {
         /* Increment event counter. */
         cdata->ticks[i]++;

         /* Is this one up to cycle next? */
         if (cdata->ticks[i] == cdata->pic->CRanges[i].rate)
         {
            /* Reset event counter for this range. */

            cdata->ticks[i] = 0;

            /* Is this range active? */

            if (!(cdata->pic->CRanges[i].active & CRNG_ACTIVE))
               continue;

            /* Cycling backwards? */
            if(cdata->pic->CRanges[i].active & CRNG_REVERSE)
            {
               /* Move the colours. */
               cdata->temp_col = cdata->cmap[cdata->pic->CRanges[i].low];

               for(j = cdata->pic->CRanges[i].low; j < cdata->pic->CRanges[i].high; j++)
                  cdata->cmap[j] = cdata->cmap[j+1];

               cdata->cmap[cdata->pic->CRanges[i].high] = cdata->temp_col;
            }
            else
            {
               /* This one is cycling forwards. */

               cdata->temp_col = cdata->cmap[cdata->pic->CRanges[i].high];

               for(j = cdata->pic->CRanges[i].high; j > cdata->pic->CRanges[i].low; j--)
                  cdata->cmap[j] = cdata->cmap[j-1];

               cdata->cmap[cdata->pic->CRanges[i].low] = cdata->temp_col;
            }
            /* Okay, everything has been moved, now load the new palette. */
            LoadRGB4(cdata->vp, cdata->cmap, cdata->pic->Colors);
         }
      }
   }
}

void StartCycling(struct ViewPort *vp, struct Pic *pic)
{
   if (cdata && pic->Cycles)
   {
      cdata->pic = pic;
      cdata->vp = vp;

      /* reset the palette and event counters */
      for (i = 0; i < pic->Colors; i++)
         cdata->cmap[i] = pic->Colormap[i];

      for (i = 0; i < pic->Cycles; i++)
         cdata->ticks[i] = 0;

      cdata->cycling = 1;
   }
}

void StopCycling()
{
   /* restore old colormap */
   if (cdata)
   {
      if (cdata->cycling)
         LoadRGB4(cdata->vp, &cdata->pic->Colormap[0], cdata->pic->Colors);

      cdata->cycling = NULL;
   }
}

void ToggleCycling()
{
   if (cdata)
   {
      if (cdata->cycling)
         StopCycling();
      else
         StartCycling(cdata->vp, cdata->pic);
   }
}

IsCycling()
{
   if (!cdata) return(NULL);
   return((int)cdata->cycling);
}

/***************************/
/* VIEWPORT-COLOR ROUTINES */
/***************************/

void SetViewPortPicColors(struct ViewPort *vp, struct Pic *pic)
{
   switch (pic->Type)
   {
      case PICTYPE_SHAM:
         InitSHAM(vp, pic);
         break;
      case PICTYPE_DHIRES:
         InitDHIRES(vp, pic);
         break;
      default:
         LoadRGB4(vp, &pic->Colormap[0], pic->Colors);
   }
}

void ClearViewPortColors(struct ViewPort *vp, UWORD colors)
{
   register int i;

   if (colors > MAXCOLORS)
      colors = MAXCOLORS;

   for (i = 0; i < colors; i++)
      SetRGB4(vp, i, 0, 0, 0);
}

#define RED(c)    ((c >> 8) & 0xF)
#define GREEN(c)  ((c >> 4) & 0xF)
#define BLUE(c)   (c & 0xF)

void FadeViewPortIn(struct ViewPort *vp, UWORD *cm, UWORD colors)
{
   ULONG rf[MAXCOLORS], gf[MAXCOLORS], bf[MAXCOLORS];
   register USHORT rgb, r, g, b;
   WORD i, n;

   if (colors > MAXCOLORS)
      colors = MAXCOLORS;

   for (i = 0; i < colors; i++)
   {
      rgb = cm[i];
      rf[i] = (RED(rgb) << 16) / 15;
      gf[i] = (GREEN(rgb) << 16) / 15;
      bf[i] = (BLUE(rgb) << 16) / 15;
   }
   for (n = 1; n < 16; n++)
   {
      for (i = 0; i < colors; i++)
      {
         r = (((rf[i] * n) + 0x8000) >> 16);
         g = (((gf[i] * n) + 0x8000) >> 16);
         b = (((bf[i] * n) + 0x8000) >> 16);

         SetRGB4(vp, i, r, g, b);
      }
      if (fade_delay > 0) Delay(fade_delay);
   }
}

void FadeViewPortOut(struct ViewPort *vp, UWORD colors)
{
   ULONG rf[MAXCOLORS], gf[MAXCOLORS], bf[MAXCOLORS];
   register UWORD rgb, r, g, b;
   WORD i, n;
   UWORD start = 0;

   if (GetRGB4(vp->ColorMap, 0) == 0x0000)
      start = 1;

   if (colors > MAXCOLORS)
      colors = MAXCOLORS;

   for (i = start; i < colors; i++)
   {
      rgb = GetRGB4(vp->ColorMap, i);
      rf[i] = (RED(rgb) << 16) / 15;
      gf[i] = (GREEN(rgb) << 16) / 15;
      bf[i] = (BLUE(rgb) << 16) / 15;
   }
   for (n = 14; n >= 0; n--)
   {
      for (i = start; i < colors; i++)
      {
         r = (((rf[i] * n) + 0x8000) >> 16);
         g = (((gf[i] * n) + 0x8000) >> 16);
         b = (((bf[i] * n) + 0x8000) >> 16);

         SetRGB4(vp, i, r, g, b);
      }
      if (fade_delay > 0) Delay(fade_delay);
   }
}

void SetFadeSpeed(UWORD val)
{
   fade_delay = val;
}

/* SPECIAL IMAGE TYPE INITIALIZATION CODE */

/* SHAM Copper-list initialization */
InitSHAM(struct ViewPort *vp, struct Pic *pic)
{
   register UWORD i, n;
   register struct SHAMData *sham;
   struct UCopList *ucoplist = NULL;
   BOOL lace = 0;
   register WORD view_dx = IntuitionBase->ViewLord.DxOffset;

   sham = (struct SHAMData *)pic->PicExt;
   if (!sham) return(NULL);

   SetRGB4(vp, 0, 0, 0, 0);
   for (i = 1; i < 16; i++)
      SetRGB4(vp, i, (UBYTE)(sham->ColorTable[0][i] / (UWORD)256),
                     (UBYTE)(sham->ColorTable[0][i] / (UWORD)16 % 16),
                     (UBYTE)(sham->ColorTable[0][i] % 16));

   ucoplist = (struct UCopList *)AllocMem(sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CLEAR);
   if (!ucoplist) return(NULL);

   if (pic->Height > LORES_HEIGHT)
      lace = 1;

   CINIT(ucoplist, (199*16));
   for (i = 1; i < 200; i++)
   {
      if (lace)
      {
         if (view_dx < 114)
         {
            CWAIT(ucoplist, i + i - 2, 0);
         }
         else
         {
            if (view_dx < 129)
            {
               CWAIT(ucoplist, i + i - 2, 0);
            }
            else
            {
               CWAIT(ucoplist, i + i, 0);
            }
         }
      }
      else
      {
         if (view_dx < 128)
         {
            CWAIT(ucoplist, i - 1, 0);
         }
         else
         {
            CWAIT(ucoplist, i, 0);
         }
      }
      for (n = 1; n < 16; n++)
         CMOVE(ucoplist, custom.color[n], (WORD)sham->ColorTable[i][n]);
   }
   CEND(ucoplist);

   Forbid();
   vp->UCopIns = ucoplist;
   Permit();
   RethinkDisplay();

   return(1);
}

/* Dynamic-HIRES Copper-list initialization */
InitDHIRES(struct ViewPort *vp, struct Pic *pic)
{
   register UWORD i, n;
   UWORD *ctbl;
   struct UCopList *ucoplist = NULL;
   BOOL lace = 0;

   ctbl = (UWORD *)pic->PicExt;
   if (!ctbl) return(NULL);

   ucoplist = (struct UCopList *)AllocMem(sizeof(struct UCopList), MEMF_PUBLIC|MEMF_CLEAR);
   if (!ucoplist) return(NULL);

   if (pic->Height > LORES_HEIGHT)
      lace = 1;

   CINIT(ucoplist, (pic->Height * 16));
   for (i = 0; i < pic->Height; i++)
   {
      CWAIT(ucoplist, i, 0);
      for (n = 0; n < 16; n++)
         CMOVE(ucoplist, custom.color[n], (WORD)*(ctbl+(i*16)+n));
   }
   CEND(ucoplist);

   Forbid();
   vp->UCopIns = ucoplist;
   Permit();
   RethinkDisplay();

   return(1);
}

void FreeSHAM(struct ViewPort *vp)
{
   if (vp->UCopIns)
      FreeVPortCopLists(vp);
}
