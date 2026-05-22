
/* $Log$ */

#include <stdio.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <libraries/iffparse.h>
#include <datatypes/pictureclass.h>

#include <clib/dos_protos.h>
#include <clib/graphics_protos.h>
#include <clib/exec_protos.h>
#include <clib/iffparse_protos.h>

#include "IFF.h"

#define message printf

#define RowBytes(w) ((((w)+15)>>4)<<1)

static struct BitMapHeader *findbmhd(struct IFFHandle *iff)
{
    struct StoredProperty *sp;

    if (!(sp = FindProp(iff, ID_ILBM, ID_BMHD)))
        message("Couldn't find bitmap header.\n");
    else
    {
        return((struct BitMapHeader *)sp->sp_Data);
    }
    return(NULL);
}

static struct BitMap *allocbitmap(struct BitMapHeader *bmhd)
{
    struct BitMap *bm;

    if (!(bm = AllocBitMap(bmhd->bmh_Width, bmhd->bmh_Height, bmhd->bmh_Depth, BMF_INTERLEAVED, NULL)))
        message("Insufficient free graphics memory.\n");
    else
    {
        return(bm);
    }
    return(NULL);
}

static BYTE *loadchunk(struct IFFHandle *iff, LONG *psize)
{
    struct ContextNode *cn;

    if (!(cn = CurrentChunk(iff)))
        message("Couldn't get current chunk.\n");
    else
    {
        LONG size = cn->cn_Size;
        BYTE *buf;

        if (!(buf = AllocMem(size, MEMF_PUBLIC)))
            message("Insufficient free memory.\n");
        else
        {
            if (ReadChunkBytes(iff, buf, size) != size)
                message("Couldn't read chunk bytes.\n");
            else
            {
                *psize = size;
                return(buf);
            }
            FreeMem(buf, size);
        }
    }
    return(NULL);
}

static BOOL unpackrow(BYTE **pchunk, LONG *psize, BYTE *plane, WORD bpr, UBYTE cmp)
{
    BYTE *chunk = *pchunk;
    LONG size = *psize;

    if (cmp == cmpNone)
    {
        if (size < bpr)
            return(FALSE);

        CopyMem(chunk, plane, bpr);
        chunk += bpr;
        size -= bpr;
    }
    else if (cmp == cmpByteRun1)
    {
        while (bpr > 0)
        {
            BYTE con;
            if (size < 1)
                return(FALSE);
            size--;
            if ((con = *chunk++) >= 0)
            {
                WORD count = con + 1;
                if (size < count || bpr < count)
                    return(FALSE);
                size -= count;
                bpr -= count;
                while (count-- > 0)
                    *plane++ = *chunk++;
            }
            else if (con != -128)
            {
                WORD count = (-con) + 1;
                BYTE data;
                if (size < 1 || bpr < count)
                    return(FALSE);
                size--;
                bpr -= count;
                data = *chunk++;
                while (count-- > 0)
                    *plane++ = data;
            }
        }
    }
    else
        return(FALSE);
    *pchunk = chunk;
    *psize = size;
    return(TRUE);
}

static BOOL unpackbitmap(struct BitMapHeader *bmhd, struct BitMap *bm, BYTE *chunk, LONG size)
{
    PLANEPTR planes[8 + 1];
    WORD bpr = RowBytes(bmhd->bmh_Width), height = bmhd->bmh_Height;
    UBYTE depth = bmhd->bmh_Depth, cmp = bmhd->bmh_Compression;
    WORD p, i;

    for (p = 0; p < depth; p++)
    {
        planes[p] = bm->Planes[p];
    }

    for (i = 0; i < height; i++)
    {
        for (p = 0; p < depth; p++)
        {
            if (!(unpackrow(&chunk, &size, planes[p], bpr, cmp)))
            {
                message("Decompression error.\n");
                return(FALSE);
            }
            planes[p] += bm->BytesPerRow;
        }
    }
    return(TRUE);
}

static struct IFFHandle *openiff(STRPTR name, LONG mode)
{
    static LONG dosmodes[] = { MODE_OLDFILE, MODE_NEWFILE };
    struct IFFHandle *iff;

    if (!(iff = AllocIFF()))
        message("Insufficient free memory.\n");
    else
    {
        if (!(iff->iff_Stream = Open(name, dosmodes[mode])))
            message("Couldn't open file '%s'.\n", name);
        else
        {
            LONG err;

            InitIFFasDOS(iff);
            if ((err = OpenIFF(iff, mode)) != 0)
                message("Couldn't open IFF (error %ld).\n", err);
            else
            {
                return(iff);
            }
            Close(iff->iff_Stream);
        }
        FreeIFF(iff);
    }
    return(NULL);
}

static void closeiff(struct IFFHandle *iff)
{
    CloseIFF(iff);
    Close(iff->iff_Stream);
    FreeIFF(iff);
}

static LONG scanilbm(struct IFFHandle *iff)
{
    LONG err;

    if ((err = PropChunk(iff, ID_ILBM, ID_BMHD)) != 0   ||
        (err = PropChunk(iff, ID_ILBM, ID_CMAP)) != 0   ||
        (err = PropChunk(iff, ID_ILBM, ID_CAMG)) != 0   ||
        (err = StopChunk(iff, ID_ILBM, ID_BODY)) != 0   )
        message("Coudn't install chunks (error %ld).\n", err);
    else
    {
        err = ParseIFF(iff, IFFPARSE_SCAN);
        if (err != 0            &&
            err != IFFERR_EOC   &&
            err != IFFERR_EOF   )
            message("Couldn't parse IFF (error %ld).\n", err);
        else
        {
            return(err);
        }
    }
    return(err);
}

static BOOL loadcmap(struct IFFHandle *iff, struct ColorMap *cm)
{
    struct StoredProperty *sp;

    if (!(sp = FindProp(iff, ID_ILBM, ID_CMAP)))
        message("Couldn't find color map.\n");
    else
    {
        WORD c, count = sp->sp_Size / 3;
        UBYTE *cmap = sp->sp_Data;

        for (c = 0; c < count; c++)
        {
            UBYTE red = *cmap++;
            UBYTE green = *cmap++;
            UBYTE blue = *cmap++;

            SetRGB32CM(cm, c, RGB(red), RGB(green), RGB(blue));
        }
        return(TRUE);
    }
    return(FALSE);
}

struct BitMap *loadilbm(STRPTR name, struct ColorMap *cm)
{
    struct IFFHandle *iff;

    if (iff = openiff(name, IFFF_READ))
    {
        if (scanilbm(iff) == 0)
        {
            struct BitMapHeader *bmhd;
            if (bmhd = findbmhd(iff))
            {
                if (loadcmap(iff, cm))
                {
                    struct BitMap *bm;
                    if (bm = allocbitmap(bmhd))
                    {
                        BYTE *chunk;
                        LONG size;
                        if (chunk = loadchunk(iff, &size))
                        {
                            if (unpackbitmap(bmhd, bm, chunk, size))
                            {
                                FreeMem(chunk, size);
                                closeiff(iff);
                                return(bm);
                            }
                            FreeMem(chunk, size);
                        }
                        FreeBitMap(bm);
                    }
                }
            }
        }
        closeiff(iff);
    }
    return(NULL);
}
