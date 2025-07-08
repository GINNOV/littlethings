/*
 * iff.h
 * ql_plugin_test_2
 *
 * Created by David R on 13-03-09.
 * Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdint.h>
#include <CoreGraphics/CoreGraphics.h>
#include <stdbool.h>

typedef struct
{
    uint32_t    id;
    uint32_t    size;
}
header_t;

typedef struct
{
    header_t    header;
    uint32_t    type;
}
form_t;

typedef struct
{
    header_t    header;
    uint16_t    w,h;        /* raster width & height in pixels    */
    int16_t        x,y;        /* pixel position for this image    */
    uint8_t        nPlanes;    /* # source bitplanes    */
    uint8_t        masking;
    uint8_t        compression;
    uint8_t        pad1;    /* unused; for consistency, put 0 here    */
    uint16_t    transparentColor;    /* transparent "color number" (sort of)    */
    uint8_t        xAspect, yAspect;    /* pixel aspect, a ratio width : height    */
    int16_t        pageWidth, pageHeight;    /* source "page" size in pixels    */
}
bmhd_t;

typedef struct
{
    header_t    header;
    uint8_t        data;
}
cmap_t;

typedef struct
{
    header_t    header;
    uint8_t data;
}
body_t;

typedef struct
{
    header_t    header;
    uint32_t    viewMode;
}
camg_t;

typedef struct
{
    form_t *form;
    bmhd_t *bmhd;
    camg_t *camg;
    cmap_t *cmap;
    body_t *body;
}
chunkMap_t;

// Public function declarations
CGImageRef iff_createImageFromData(const UInt8 *data, long length, bool withAlpha);
int iff_mapChunks(const UInt8 *bytePtr, long length, chunkMap_t *ckmap);
int bmhd_getWidth(bmhd_t *bmhd);
int bmhd_getHeight(bmhd_t *bmhd);
int bmhd_getDepth(bmhd_t *bmhd);
int bmhd_getCompression(bmhd_t *bmhd);
int bmhd_getMasking(bmhd_t *bmhd);
uint32_t form_getType(form_t *form);
int header_getSize(header_t *h);
int camg_getLace(camg_t *camg);
