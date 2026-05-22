/*  Structs for (Windows-)BMP Files
 *  Author: Norman Walter
 *  Date: 22.12.2002
 */

#ifndef BMP_H
#define BMP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

// the universal bitmap ID
#define BITMAP_ID 0x4D42

typedef struct tagBITMAPFILEHEADER
{
    WORD          bfType;            // specifies the file type; must be BM (0x4D42)
    ULONG         bfSize;            // specifies the size in bytes of the bitmap file
    WORD          bfReserved1;       // reserved; must be zero
    WORD          bfReserved2;       // reserved; must be zero
    ULONG         bfOffBits;         // specifies the offset, in bytes, form the
                            // BITMAPFILEHEADER structure to the bitmap bits
} BITMAPFILEHEADER;

typedef struct tagBITMAPINFOHEADER
{
    ULONG         biSize;            // specifies number of bytes required by structure
    LONG          biWidth;           // specifies the width of the bitmap, in pixels
    LONG          biHeight;          // specifies the height of the bitmap, in pixels
    WORD          biPlanes;          // specifies the number of color planes, must be 1
    WORD          biBitCount;        // specifies the number of bits per pixel; must be 1,4,
                            // 8, 16, 24 or 32
    ULONG         biCompression;     // specifies the type of compression
    ULONG         biSizeImage;       // size of Image in bytes
    LONG          biXPelsPerMeter;   // specifies the number of pixels per meter in x axis
    LONG          biYPelsPerMeter;   // specifies the number of pixels per meter in y axis
    ULONG         biClrUsed;         // specifies the numper of colors used by the bitmap
    ULONG         biClrImportant;    // specifies the number of colors that are important
} BITMAPINFOHEADER;

BITMAPINFOHEADER bitmapInfoHeader;    // Bitmap info header
unsigned char*   bitmapData;          // the bitmap data

#endif