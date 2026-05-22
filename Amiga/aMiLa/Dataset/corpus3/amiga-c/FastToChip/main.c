/*
    Situtation

    I want to display a series of images (or pieces of images) on the screen.

    I want to preload all the images at the start of the program and then display them later on.
    Chip memory is limited so I want to load the images into fast memory first and then copy them to chip memory when I need them.

    Images are stored as raw bitplane data in a file.

    In the end I want to use the "BlitBitMap" function to display a piece of the image on the screen.
    So I need a BitMap structure with the image data in chip memory.

    Question: whats the best/most efficient way to do this?
    The following code works fine, but it seems overly complicated.

*/

#include <proto/intuition.h>
#include <proto/graphics.h>
#include <stdio.h>
#include <exec/memory.h>

#define SCREENWIDTH 320
#define SCREENHEIGHT 240
#define PLANES 5 // 32 colors

static struct RastPort screenContext;
static struct BitMap screenBitMap;
static struct Screen *screen;

static struct NewScreen screenProperties = {
        0, 0, SCREENWIDTH, SCREENHEIGHT, PLANES, 0, 0, 0,
	    CUSTOMSCREEN | CUSTOMBITMAP,
	    NULL, NULL, NULL, NULL,
     };

int main() {
    int i;
    UBYTE *fastMemory;
    UBYTE *chipMemory;
    FILE *fileHandle;
    ULONG fileSize;
    struct Image image;
    struct RastPort ctx;
    struct BitMap bitmap;

    int imageWidth = 296;
    int imageHeight = 210;
    const unsigned short palette[16] = {0X000,0X000,0X100,0X111,0X211,0X411,0X422,0X611,0X811,0X732,0Xa32,0Xc42,0Xa65,0Xd63,0Xe84,0Xdb9};


    // prepare the screen
    // we prepare a bitmap with 5 planes/32 colors and attach that to the screen rastport  
    InitRastPort(&screenContext);
    screenContext.BitMap = &screenBitMap;

    InitBitMap(&screenBitMap, PLANES, SCREENWIDTH, SCREENHEIGHT);
    
    for(i = 0; i < PLANES; i++) if(screenBitMap.Planes[i] = AllocRaster(SCREENWIDTH, SCREENHEIGHT), screenBitMap.Planes[i] == 0) {
        fprintf(stderr, "%s (%dx%dx%d)\n","failed to allocate screen context", SCREENWIDTH, SCREENHEIGHT, PLANES);
        return -1;
    }
    screenProperties.CustomBitMap = screenContext.BitMap;

    // open the screen
    if(screen = OpenScreen((void *)(&screenProperties)), screen == 0) {
        fprintf(stderr, "Failed to open screen\n");
        return -1;
    }
    ShowTitle(screen, FALSE);

    // Load the palette
    LoadRGB4(&screen->ViewPort, (UWORD *)palette, 16);

    // Clear the screen
    SetRast(&screenContext, 0);

    // open file
    fileHandle = fopen("bear.planes", "rb");
    if (fileHandle == NULL) {
        printf("Failed to open file\n");
        return -1;
    }

    // Get the file size
    fseek(fileHandle,0,2);
    fileSize=ftell(fileHandle);
    printf("file is %d bytes\n",fileSize);
    rewind(fileHandle);

   
    // Allocate fast memory
    fastMemory = AllocMem(fileSize, MEMF_FAST);
    if (fastMemory == NULL) {
        printf("Failed to allocate fast memory\n");
        fclose(fileHandle);
        return -1;
    }

    // Read the file into fast memory
    if (fread(fastMemory, sizeof(UBYTE), fileSize, fileHandle) != fileSize) {
        printf("Failed to read file\n");
        FreeMem(fastMemory, fileSize);
        fclose(fileHandle);
        return -1;
    }
    fclose(fileHandle);

    // let's asume we do other stuff here
    // after a while I want to fetch the image from fast memory and display it on the screen

    // Allocate chip memory
    chipMemory = AllocMem(fileSize, MEMF_CHIP);
     if (chipMemory == NULL) {
            printf("Failed to allocate chip memory\n");
            return 1;
        }

    // Copy the image data from fast memory to chip memory    
    CopyMem(fastMemory, chipMemory, fileSize);
    FreeMem(fastMemory, fileSize);

    // Set up the image
    // this seems overly complicated
    // is this fastest way to git the image data in the Bitmap structure?
    image.Depth = 4;
    image.Width = imageWidth;
    image.Height = imageHeight;
    image.LeftEdge = 0;
    image.TopEdge = 0;
    image.PlanePick = 0x0F;
    image.PlaneOnOff = 0;
    image.NextImage = NULL;
    image.ImageData = chipMemory;

    InitRastPort(&ctx);
    ctx.BitMap = &bitmap;
    InitBitMap(&bitmap, 4, imageWidth, imageHeight);
    for (i = 0; i < 4; i++) {
        bitmap.Planes[i] = AllocRaster(imageWidth, imageHeight);
        if (bitmap.Planes[i] == 0) {
            printf("failed to allocate sprite bitmap\n");
            return -1;
        }
    }

    // Draw the image to the bitmap
    DrawImage(&ctx,&image,0,0);
    FreeMem(chipMemory, fileSize);

    // OK now I have my bitmap that I can use to do graphical stuff.
    // Let's just display the entire image

    // Blit the image to the screen
    BltBitMap(&bitmap, 
        0,0,
        &screenBitMap,
        0,10,
        imageWidth,imageHeight,
        0xC0,0X0F,NULL );  
 
    Delay(100);

    // Free the image
    for (i = 0; i < 4; i++) {
        if (bitmap.Planes[i]) {
            FreeRaster(bitmap.Planes[i], imageWidth, imageHeight);
            bitmap.Planes[i] = 0;
        }
    }

    // close the screen
    if(screen) { CloseScreen(screen); screen = 0; }

    // and free the screen bitmap
    for(i = 0; i < PLANES; i++) if(screenBitMap.Planes[i]) { FreeRaster(screenBitMap.Planes[i], SCREENWIDTH, SCREENHEIGHT); screenBitMap.Planes[i] = 0; }

    return 0;
}

