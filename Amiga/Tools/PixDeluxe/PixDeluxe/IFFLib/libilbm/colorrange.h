/*
 * Copyright (c) 2012 Sander van der Burg
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef __ILBM_COLORRANGE_H
#define __ILBM_COLORRANGE_H

#include <stdio.h>
#include <libiff/ifftypes.h>
#include <libiff/group.h>
#include <libiff/chunk.h>
#include <libiff/id.h>

#define ILBM_ID_CRNG IFF_MAKEID('C', 'R', 'N', 'G')

#ifdef __cplusplus
extern "C" {
#endif

#define ILBM_COLORRANGE_60_STEPS_PER_SECOND 16384
#define ILBM_COLORRANGE_SHIFT_RIGHT 0x2

#define ILBM_CRNG_DEFAULT_SIZE (3 * sizeof(IFF_Word) + 2 * sizeof(IFF_UByte))

typedef struct
{
    IFF_Group *parent;

    IFF_ID chunkId;
    IFF_Long chunkSize;

    IFF_Word pad1;
    IFF_Word rate;
    IFF_Word active;
    IFF_UByte low, high;
}
ILBM_ColorRange;

IFF_Chunk *ILBM_createColorRangeChunk(const IFF_ID chunkId, const IFF_Long chunkSize);

ILBM_ColorRange *ILBM_createColorRange(void);

IFF_Bool ILBM_readColorRange(FILE *file, IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry, IFF_Long *bytesProcessed);

IFF_Bool ILBM_writeColorRange(FILE *file, const IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry, IFF_Long *bytesProcessed);

IFF_Bool ILBM_checkColorRange(const IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry);

void ILBM_freeColorRange(IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry);

void ILBM_printColorRange(const IFF_Chunk *chunk, const unsigned int indentLevel, const IFF_ChunkRegistry *chunkRegistry);

IFF_Bool ILBM_compareColorRange(const IFF_Chunk *chunk1, const IFF_Chunk *chunk2, const IFF_ChunkRegistry *chunkRegistry);

#ifdef __cplusplus
}
#endif

#endif
