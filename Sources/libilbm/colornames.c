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

#include "colornames.h"
#include <stdlib.h>
#include <string.h>
#include <libiff/field.h>
#include <libiff/io.h>
#include <libiff/error.h>
#include <libiff/util.h>
#include "ilbm.h"

#define BUFFER_SIZE 1024

IFF_Chunk *ILBM_createColorNamesChunk(const IFF_ID chunkId, const IFF_Long chunkSize)
{
    ILBM_ColorNames *colorNames = (ILBM_ColorNames*)IFF_createChunk(ILBM_ID_CNAM, chunkSize, sizeof(ILBM_ColorNames));

    if(colorNames != NULL)
    {
        colorNames->startingColor = 0;
        colorNames->endingColor = 0;

        colorNames->colorNamesLength = 0;
        colorNames->colorNames = NULL;
    }

    return (IFF_Chunk*)colorNames;
}

ILBM_ColorNames *ILBM_createColorNames(void)
{
    return (ILBM_ColorNames*)ILBM_createColorNamesChunk(ILBM_ID_CNAM, ILBM_CNAM_DEFAULT_SIZE);
}

static size_t addColorName(ILBM_ColorNames *colorNames, char *colorName)
{
    size_t colorNameSize = strlen(colorName) + 1;

    colorNames->colorNames = (char**)realloc(colorNames->colorNames, (colorNames->colorNamesLength + 1) * sizeof(char*));
    colorNames->colorNames[colorNames->colorNamesLength] = (char*)malloc(colorNameSize);
    strncpy(colorNames->colorNames[colorNames->colorNamesLength], colorName, colorNameSize);
    colorNames->colorNamesLength++;

    return colorNameSize;
}

void ILBM_addColorName(ILBM_ColorNames *colorNames, char *colorName)
{
    size_t colorNameSize = addColorName(colorNames, colorName);
    colorNames->chunkSize += colorNameSize;
}

IFF_Bool ILBM_readColorNames(FILE *file, IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry, IFF_Long *bytesProcessed)
{
    ILBM_ColorNames *colorNames = (ILBM_ColorNames*)chunk;
    IFF_FieldStatus status;
    unsigned int i, colorNamesLength;

    if((status = IFF_readUWordField(file, &colorNames->startingColor, chunk, "startingColor", bytesProcessed)) != IFF_FIELD_MORE)
        return IFF_deriveSuccess(status);

    if((status = IFF_readUWordField(file, &colorNames->endingColor, chunk, "endingColor", bytesProcessed)) != IFF_FIELD_MORE)
        return IFF_deriveSuccess(status);

    colorNamesLength = colorNames->endingColor - colorNames->startingColor + 1;

    /* Read the color names. TODO: also quit when the end of chunk has been reached */
    for(i = 0; i < colorNamesLength; i++)
    {
        int c;
        char colorName[BUFFER_SIZE];
        /* Reset the buffer index to 0 */
        unsigned int index = 0;

        do
        {
            c = fgetc(file); /* Read character */

            if(c == EOF) /* We should never reach the end of the file prematurely */
                return FALSE;

            colorName[index] = c; /* Add character to the buffer */
            index++;
            *bytesProcessed = *bytesProcessed + 1;

            if(index >= BUFFER_SIZE) /* If we would exceed the buffer size, fail */
               return FALSE;
        }
        while(c != '\0'); /* Keep repeating until we read a 0-byte */

        /* Add the color name that we just read */
        addColorName(colorNames, colorName);
    }

    return TRUE;
}

IFF_Bool ILBM_writeColorNames(FILE *file, const IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry, IFF_Long *bytesProcessed)
{
    const ILBM_ColorNames *colorNames = (const ILBM_ColorNames*)chunk;
    IFF_FieldStatus status;
    unsigned int i;

    if((status = IFF_writeUWordField(file, colorNames->startingColor, chunk, "startingColor", bytesProcessed)) != IFF_FIELD_MORE)
        return IFF_deriveSuccess(status);

    if((status = IFF_writeUWordField(file, colorNames->endingColor, chunk, "endingColor", bytesProcessed)) != IFF_FIELD_MORE)
        return IFF_deriveSuccess(status);

    /* TODO: make sure we don't exceed chunkSize */
    for(i = 0; i < colorNames->colorNamesLength; i++)
    {
        char *colorName = colorNames->colorNames[i];
        fputs(colorName, file);
        fputc('\0', file);
        *bytesProcessed += *bytesProcessed + strlen(colorName) + 1;
    }

    return TRUE;
}

IFF_Bool ILBM_checkColorNames(const IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry)
{
    const ILBM_ColorNames *colorNames = (ILBM_ColorNames*)chunk;

    if(colorNames->startingColor > colorNames->endingColor)
    {
        IFF_error("'CNAM'.startingColor: %u cannot be greater than the 'CNAM'.endingColor: %u\n", colorNames->startingColor, colorNames->endingColor);
        return FALSE;
    }

    if(colorNames->endingColor - colorNames->startingColor + 1 != colorNames->colorNamesLength)
    {
        IFF_error("The 'CNAM'.startingColor: %u and 'CNAM'.endingColor: %u difference do not match the length: %u\n", colorNames->startingColor, colorNames->endingColor, colorNames->colorNamesLength);
        return FALSE;
    }

    return TRUE;
}

void ILBM_freeColorNames(IFF_Chunk *chunk, const IFF_ChunkRegistry *chunkRegistry)
{
    ILBM_ColorNames *colorNames = (ILBM_ColorNames*)chunk;
    unsigned int i;

    for(i = 0; i < colorNames->colorNamesLength; i++)
    {
        char *colorName = colorNames->colorNames[i];
        free(colorName);
    }

    free(colorNames->colorNames);
}

void ILBM_printColorNames(const IFF_Chunk *chunk, const unsigned int indentLevel, const IFF_ChunkRegistry *chunkRegistry)
{
    const ILBM_ColorNames *colorNames = (const ILBM_ColorNames*)chunk;
    unsigned int i;

    IFF_printIndent(stdout, indentLevel, "startingColor = %u;\n", colorNames->startingColor);
    IFF_printIndent(stdout, indentLevel, "endingColor = %u;\n", colorNames->endingColor);

    for(i = 0; i < colorNames->colorNamesLength; i++)
    {
        char *colorName = colorNames->colorNames[i];
        IFF_printIndent(stdout, indentLevel, "{ \"%s\" };\n", colorName);
    }
}

IFF_Bool ILBM_compareColorNames(const IFF_Chunk *chunk1, const IFF_Chunk *chunk2, const IFF_ChunkRegistry *chunkRegistry)
{
    const ILBM_ColorNames *colorNames1 = (const ILBM_ColorNames*)chunk1;
    const ILBM_ColorNames *colorNames2 = (const ILBM_ColorNames*)chunk2;
    unsigned int i;

    if(colorNames1->startingColor != colorNames2->startingColor)
        return FALSE;

    if(colorNames1->endingColor != colorNames2->endingColor)
        return FALSE;

    if(colorNames1->colorNamesLength != colorNames2->colorNamesLength)
        return FALSE;

    for(i = 0; i < colorNames1->colorNamesLength; i++)
    {
        if(strcmp(colorNames1->colorNames[i], colorNames2->colorNames[i]) != 0)
            return FALSE;
    }

    return TRUE;
}
