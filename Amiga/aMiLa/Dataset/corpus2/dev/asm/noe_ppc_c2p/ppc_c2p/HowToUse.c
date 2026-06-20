#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include <exec/types.h>

#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/utility.h>
#include <proto/va3d.h>

#include "ppc_c2p.h"


#define TAG_ITEM(tagitem, tag, data) tagitem.ti_Tag=(ULONG)tag;tagitem.ti_Data=(ULONG)data;


typedef
	struct Display
	{
		ULONG Width, Height;
		ULONG Type;

		ULONG Depth;
		ULONG DisplayID;

		struct Screen *Screen;
		struct ViewPort *ViewPort;
		struct Window *Window;
		struct RastPort *RastPort;
		struct BitMap *BitMap;

	} DISPLAY;

#define DT_NORMAL8	          0
#define DT_HAM6			1

DISPLAY *MainDisplay;

UWORD SGIheader[256]; 
UBYTE *R, *G, *B;
UBYTE *chunky;
UWORD *rgb15;
ULONG palette[256*3+2];

DISPLAY *OpenDisplay(ULONG Width, ULONG Height, ULONG Type)
{
DISPLAY *Display;
struct TagItem tmpTagList[20];
LONG i, j;
ULONG *Plane4, *Plane5;
ULONG DWidth;

	if((Display = calloc(1, sizeof(DISPLAY))) == NULL)
		return NULL;

	Display->Width = Width;
	Display->Height = Height;
	Display->Type = Type;

	switch(Type)
	{
		case DT_NORMAL8:
			Display->Depth = 8;
			DWidth = Width;
			TAG_ITEM(tmpTagList[0], BIDTAG_NominalWidth, DWidth);
			TAG_ITEM(tmpTagList[1], BIDTAG_NominalHeight, Height);
			TAG_ITEM(tmpTagList[2], BIDTAG_Depth, Display->Depth);
			TAG_ITEM(tmpTagList[3], TAG_DONE, 0);
			break;

		case DT_HAM6:
			Display->Depth = 6;
			DWidth = Width*4;
			TAG_ITEM(tmpTagList[0], BIDTAG_NominalWidth, DWidth);
			TAG_ITEM(tmpTagList[1], BIDTAG_NominalHeight, Height);
			TAG_ITEM(tmpTagList[2], BIDTAG_Depth, Display->Depth);
			TAG_ITEM(tmpTagList[3], BIDTAG_DIPFMustHave, DIPF_IS_HAM);
			TAG_ITEM(tmpTagList[4], TAG_DONE, 0);
			break;
	}

	if((Display->DisplayID = BestModeIDA(tmpTagList)) == (ULONG)INVALID_ID)
		return NULL;

	TAG_ITEM(tmpTagList[0], SA_Width, DWidth);
	TAG_ITEM(tmpTagList[1], SA_Height, Display->Height);
	TAG_ITEM(tmpTagList[2], SA_Depth, Display->Depth);
	TAG_ITEM(tmpTagList[3], SA_Quiet, TRUE);
	TAG_ITEM(tmpTagList[4], SA_Type, CUSTOMSCREEN);
	TAG_ITEM(tmpTagList[5], SA_DisplayID, Display->DisplayID);
	TAG_ITEM(tmpTagList[6], SA_AutoScroll, FALSE);
	TAG_ITEM(tmpTagList[7], SA_ShowTitle, FALSE);
	TAG_ITEM(tmpTagList[8], SA_Interleaved, FALSE);
	TAG_ITEM(tmpTagList[9], TAG_DONE, 0);

	if((Display->Screen = OpenScreenTagList(NULL, tmpTagList)) == NULL)
		return NULL;

	Display->ViewPort = &Display->Screen->ViewPort;

	TAG_ITEM(tmpTagList[0], WA_Left, 0);
	TAG_ITEM(tmpTagList[1], WA_Top, 0);
	TAG_ITEM(tmpTagList[2], WA_Width, DWidth);
	TAG_ITEM(tmpTagList[3], WA_Height, Display->Height);
	TAG_ITEM(tmpTagList[4], WA_IDCMP, 0);
	TAG_ITEM(tmpTagList[5], WA_CustomScreen, Display->Screen);
	TAG_ITEM(tmpTagList[6], WA_Backdrop, TRUE);
	TAG_ITEM(tmpTagList[7], WA_Borderless, TRUE);
	TAG_ITEM(tmpTagList[8], WA_Activate, TRUE);
	TAG_ITEM(tmpTagList[9], WA_RMBTrap, TRUE);
	TAG_ITEM(tmpTagList[10], WA_NoCareRefresh, TRUE);
	TAG_ITEM(tmpTagList[11], TAG_DONE, 0);
	if((Display->Window = OpenWindowTagList(NULL, tmpTagList)) == NULL)
		return NULL;

	if((Display->RastPort = malloc(sizeof(struct RastPort))) == NULL)
		return NULL;

	memcpy(Display->RastPort, Display->Window->RPort, sizeof(struct RastPort));

	Display->BitMap = Display->RastPort->BitMap;

	switch(Type)
	{
		case DT_HAM6:

			Plane4 = (ULONG *)Display->BitMap->Planes[4];
			Plane5 = (ULONG *)Display->BitMap->Planes[5];

		  for(i=0; i<Height; i++)
				for(j=0; j<(DWidth/32); j++)
	  		{	// pixel order: RGGB
  			  Plane4[i*DWidth/32+j] = 0x77777777;
  			  Plane5[i*DWidth/32+j] = 0xeeeeeeee;
 				}

			break;

          default:
			break;
	}

	return Display;
}


VOID CloseDisplay(DISPLAY *Display)
{

	if(Display)
	{
		if(Display->RastPort)
		{
			free(Display->RastPort);
			Display->RastPort = NULL;
		}

		if(Display->Window)
		{
			CloseWindow(Display->Window);
			Display->Window = NULL;
		}

		if(Display->Screen)
		{
			CloseScreen(Display->Screen);
			Display->Screen = NULL;
		}

		free(Display);
	}
}

#define WIDTH 320
#define HEIGHT 200

#define TEST_IMAGE15 "data/test_image.sgi"
#define TEST_IMAGE8 "data/test_image.chunky"
#define TEST_IMAGE8_PALETTE "data/test_image.palette"

#define FRAMES 100

#define TEST(FUNC, src)	\
	printf("-------------------------------------------------------------\n");\
	printf(#FUNC "()\n");\
	PPCCacheFlushAll();\
	StartTime = clock();\
	for(i=0; i<FRAMES; i++)\
	{\
		FUNC ## (src, (ULONG **)MainDisplay->BitMap->Planes, WIDTH, HEIGHT);\
	}\
	StopTime = clock();\
	printf("total time: %f sec\n", (FLOAT)(StopTime-StartTime)/(FLOAT)CLK_TCK);\
	printf("fps: %f\n", (FLOAT)FRAMES*(FLOAT)CLK_TCK/(FLOAT)(StopTime-StartTime));


VOID main(VOID)
{
FILE *File;
ULONG width, height;
LONG i;
clock_t StartTime;
clock_t StopTime;

// load test image

	File = fopen(TEST_IMAGE15, "rb");

	fread(SGIheader, 256, 2, File);

	width = SGIheader[3];
	height = SGIheader[4];

	R = malloc(width*height);
	G = malloc(width*height);
	B = malloc(width*height);
	chunky = malloc(width*height+32);
	chunky = (UBYTE *)(((ULONG)chunky+31)&0xffffffe0);

	fread(chunky, width, height, File);
	for(i=0; i<height; i++)
		memcpy(&R[i*width], &chunky[(height-i-1)*width], width);

	fread(chunky, width, height, File);
	for(i=0; i<height; i++)
		memcpy(&G[i*width], &chunky[(height-i-1)*width], width);

	fread(chunky, width, height, File);
	for(i=0; i<height; i++)
		memcpy(&B[i*width], &chunky[(height-i-1)*width], width);

	fclose(File);

	rgb15 = malloc(width*height*2+32);
	rgb15 = (UWORD *)(((ULONG)rgb15+31)&0xffffffe0);

	for(i=0; i<width*height; i++)
		rgb15[i] = ((R[i]&0xf8)<<(10-3))+((G[i]&0xf8)<<(5-3))+((B[i]&0xf8)>>3);

//

	File = fopen(TEST_IMAGE8, "rb");
	fread(chunky, width, height, File);
	fclose(File);

	File = fopen(TEST_IMAGE8_PALETTE, "rb");
	fread(palette, 256*3+2, 4, File);
	fclose(File);


// test rgb15 to ham6 c2p

	MainDisplay = OpenDisplay(WIDTH, HEIGHT, DT_HAM6);
	TEST(RGB15_TO_HAM6_NI, rgb15);
	CloseDisplay(MainDisplay);

// test c2p

	MainDisplay = OpenDisplay(WIDTH, HEIGHT, DT_NORMAL8);
	LoadRGB32(MainDisplay->ViewPort, palette);
	TEST(C2P_NI, chunky);
	CloseDisplay(MainDisplay);

	exit(0);
}
