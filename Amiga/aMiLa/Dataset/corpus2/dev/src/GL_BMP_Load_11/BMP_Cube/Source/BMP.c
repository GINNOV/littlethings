/*  BMP.c
 *  (Windows-)BMP loader routines for Amiga computers
 *  Author: Norman Walter
 *  Additional ideas by Thore Sitly
 *  Date: 29.12.2002
 *
 *  DISCLAIMER: This software is provided "as is".  No representations or
 *  warranties are made with respect to the accuracy, reliability, performance,
 *  currentness, or operation of this software, and all use is at your own risk.
 */


#ifndef BMP_H
#include "bmp.h"
#endif

/* WORD and LONG SWAP */

#define	SWAPW(a) (WORD)(((UWORD)a>>8)+((((UWORD)a&0xff)<<8)))
#define	SWAPU(a) (UWORD)(((UWORD)a>>8)+((((UWORD)a&0xff)<<8)))
#define	SWAPL(a) (LONG)(((ULONG)a>>24)+(((ULONG)a&0xff0000)>>8)+(((ULONG)a&0xff00)<<8)+(((ULONG)a&0xff)<<24))

// LoadBMP
// desc: Returns a pointer to the bitmap image of the bitmap specified
//       by filename. Also returns the bitmap header information.
//       No support for 8-bit bitmaps.
unsigned char *LoadBMP(char *filename, BITMAPINFOHEADER *bitmapInfoHeader)
{
    FILE *filePtr;                          // the file pointer
    BITMAPFILEHEADER    bitmapFileHeader;   // bitmap file header
    unsigned char       *bitmapImage;       // bitmap image data
    int                 imageIdx = 0;       // image index counter
    unsigned char       tempRGB;            // swap variable

    // open filename in "read binary" mode
    filePtr = fopen(filename, "rb");
    if (filePtr == NULL)
        return NULL;

    // read the bitmap file header

    fread(&bitmapFileHeader, sizeof(BITMAPFILEHEADER), 1, filePtr);

    // Intel -> Motorola conversion

    bitmapFileHeader.bfType = SWAPW(bitmapFileHeader.bfType);
    bitmapFileHeader.bfSize = SWAPL(bitmapFileHeader.bfSize);
    bitmapFileHeader.bfReserved1 = SWAPW(bitmapFileHeader.bfReserved1);
    bitmapFileHeader.bfReserved2 = SWAPW(bitmapFileHeader.bfReserved2);
    bitmapFileHeader.bfOffBits = SWAPL(bitmapFileHeader.bfOffBits);

    // verify that this is a bitmap by checking for the universal bitmap id
    if (bitmapFileHeader.bfType != BITMAP_ID)
    {
        fclose(filePtr);
        printf("Not a BMP File\n");
        return NULL;
    }

    // read the bitmap information header

    fread(bitmapInfoHeader, sizeof(BITMAPINFOHEADER), 1, filePtr);

    // Intel -> Motorola conversion

    bitmapInfoHeader->biSize = SWAPL(bitmapInfoHeader->biSize);
    bitmapInfoHeader->biWidth = SWAPL(bitmapInfoHeader->biWidth);
    bitmapInfoHeader->biHeight = SWAPL(bitmapInfoHeader->biHeight);
    bitmapInfoHeader->biPlanes = SWAPW(bitmapInfoHeader->biPlanes);
    bitmapInfoHeader->biBitCount = SWAPW(bitmapInfoHeader->biBitCount);

    bitmapInfoHeader->biCompression = SWAPL(bitmapInfoHeader->biCompression);
    bitmapInfoHeader->biSizeImage = SWAPL(bitmapInfoHeader->biSizeImage);
    bitmapInfoHeader->biXPelsPerMeter = SWAPL(bitmapInfoHeader->biXPelsPerMeter);
    bitmapInfoHeader->biYPelsPerMeter = SWAPL(bitmapInfoHeader->biYPelsPerMeter);
    bitmapInfoHeader->biClrUsed = SWAPL(bitmapInfoHeader->biClrUsed);
    bitmapInfoHeader->biClrImportant = SWAPL(bitmapInfoHeader->biClrImportant);

    // allocate enough memory for the bitmap image data
    bitmapImage = (unsigned char*)malloc(bitmapInfoHeader->biSizeImage);

    // verify memory allocation
    if (!bitmapImage)
    {
        free(bitmapImage);
        fclose(filePtr);
        return NULL;
    }

    // move file pointer to beginning of bitmap data
    fseek(filePtr, bitmapFileHeader.bfOffBits, SEEK_SET);

    // read in the bitmap image data

    fread(bitmapImage, 1, bitmapInfoHeader->biSizeImage, filePtr);

    // make sure bitmap image data was read
    if (bitmapImage == NULL)
    {
        fclose(filePtr);
        return NULL;
    }

    // swap the R and B values to get RGB since the bitmap color format is in BGR

    for (imageIdx = 0; imageIdx < bitmapInfoHeader->biSizeImage; imageIdx+=3)
    {
        tempRGB = bitmapImage[imageIdx];
        bitmapImage[imageIdx] = bitmapImage[imageIdx + 2];
        bitmapImage[imageIdx + 2] = tempRGB;
    }

    // close the file and return the bitmap image data
    fclose(filePtr);
    return bitmapImage;
}
